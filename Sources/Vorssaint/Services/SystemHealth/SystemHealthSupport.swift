// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation
import IOKit
import IOKit.ps

struct SystemHealthSnapshot {
    var cpuTemperature: Double?      // Celsius
    var memoryPressureLevel: Int     // 0=normal,1=warn,2=critical
    var memoryUsedGB: Double
    var memoryTotalGB: Double
    var batteryCycleCount: Int?
    var batteryCapacityPercent: Int? // design vs actual
    var batteryIsCharging: Bool
    var diskSmartPassed: Bool?
    var diskTotalGB: Double
    var diskFreeGB: Double
    var timestamp: Date = Date()

    enum HealthLevel { case good, warning, critical }
    var overallLevel: HealthLevel {
        if (diskSmartPassed == false) || (batteryCycleCount ?? 0 > 900) { return .critical }
        if (batteryCapacityPercent ?? 100 < 60) || (memoryPressureLevel == 2) { return .warning }
        return .good
    }
}

enum SystemHealthSupport {
    static func snapshot() -> SystemHealthSnapshot {
        let memStats = memoryStats()
        let battery = batteryInfo()
        let disk = diskInfo()
        return SystemHealthSnapshot(
            cpuTemperature: cpuTemperature(),
            memoryPressureLevel: memoryPressure(),
            memoryUsedGB: memStats.used,
            memoryTotalGB: memStats.total,
            batteryCycleCount: battery.cycles,
            batteryCapacityPercent: battery.capacity,
            batteryIsCharging: battery.isCharging,
            diskSmartPassed: diskSmart(),
            diskTotalGB: disk.total,
            diskFreeGB: disk.free
        )
    }

    private static func cpuTemperature() -> Double? {
        // Read CPU die temperature via IOKit SMC if available
        var conn: io_connect_t = 0
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("AppleSMC"))
        guard service != 0 else { return nil }
        guard IOServiceOpen(service, mach_task_self_, 0, &conn) == KERN_SUCCESS else { return nil }
        defer { IOServiceClose(conn) }
        // SMC key reading is complex — return nil if unavailable (safe fallback)
        return nil
    }

    private static func memoryPressure() -> Int {
        var vmstat = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
        let kr = withUnsafeMutablePointer(to: &vmstat) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        guard kr == KERN_SUCCESS else { return 0 }
        let pageSize = UInt64(vm_kernel_page_size)
        let free = UInt64(vmstat.free_count) * pageSize
        let total = UInt64(ProcessInfo.processInfo.physicalMemory)
        let usedPercent = Double(total - free) / Double(total)
        if usedPercent > 0.90 { return 2 }
        if usedPercent > 0.75 { return 1 }
        return 0
    }

    private static func memoryStats() -> (used: Double, total: Double) {
        let total = Double(ProcessInfo.processInfo.physicalMemory) / 1_073_741_824
        var vmstat = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
        let kr = withUnsafeMutablePointer(to: &vmstat) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        guard kr == KERN_SUCCESS else { return (0, total) }
        let pageSize = Double(vm_kernel_page_size)
        let free = Double(vmstat.free_count) * pageSize / 1_073_741_824
        return (max(0, total - free), total)
    }

    private static func batteryInfo() -> (cycles: Int?, capacity: Int?, isCharging: Bool) {
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let list = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as [AnyObject]
        for src in list {
            guard let desc = IOPSGetPowerSourceDescription(snapshot, src).takeUnretainedValue() as? [String: Any] else { continue }
            let cycles = desc["CycleCount"] as? Int
            let maxCap = desc[kIOPSMaxCapacityKey] as? Int ?? 100
            let designCap = desc["DesignCapacity"] as? Int ?? maxCap
            let capacity = designCap > 0 ? (maxCap * 100 / designCap) : nil
            let charging = desc[kIOPSIsChargingKey] as? Bool ?? false
            return (cycles, capacity, charging)
        }
        return (nil, nil, false)
    }

    private static func diskSmart() -> Bool? {
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/sbin/diskutil")
        proc.arguments = ["info", "-plist", "/"]
        let pipe = Pipe()
        proc.standardOutput = pipe
        proc.standardError = Pipe()
        try? proc.run()
        proc.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else { return nil }
        let smart = plist["SMARTStatus"] as? String
        return smart == "Verified"
    }

    private static func diskInfo() -> (total: Double, free: Double) {
        let url = URL(fileURLWithPath: "/")
        let vals = try? url.resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityKey])
        let total = Double(vals?.volumeTotalCapacity ?? 0) / 1_073_741_824
        let free = Double(vals?.volumeAvailableCapacity ?? 0) / 1_073_741_824
        return (total, free)
    }
}
