// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation
import SystemConfiguration
import Darwin

struct NetworkInterface: Identifiable, Equatable {
    let id: String        // interface name, e.g. "en0"
    let displayName: String
    let ipv4: String?
    let ipv6: String?
    let macAddress: String?
    let isWifi: Bool
}

enum NetworkInfoSupport {
    static func currentInterfaces() -> [NetworkInterface] {
        var interfaces: [NetworkInterface] = []
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return [] }
        defer { freeifaddrs(ifaddr) }

        var v4Map: [String: String] = [:]
        var v6Map: [String: String] = [:]
        var names: [String] = []

        var ptr = ifaddr
        while let current = ptr {
            let name = String(cString: current.pointee.ifa_name)
            guard current.pointee.ifa_addr != nil else { ptr = current.pointee.ifa_next; continue }
            let family = Int32(current.pointee.ifa_addr.pointee.sa_family)
            if family == AF_INET {
                var addr = current.pointee.ifa_addr.pointee
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                if getnameinfo(&addr, socklen_t(current.pointee.ifa_addr.pointee.sa_len),
                               &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                    v4Map[name] = String(cString: hostname)
                    if !names.contains(name) { names.append(name) }
                }
            } else if family == AF_INET6 {
                var addr = current.pointee.ifa_addr.pointee
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                if getnameinfo(&addr, socklen_t(current.pointee.ifa_addr.pointee.sa_len),
                               &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                    let ip = String(cString: hostname)
                    // Skip link-local if a global one exists
                    if v6Map[name] == nil || !ip.hasPrefix("fe80") {
                        v6Map[name] = ip
                    }
                    if !names.contains(name) { names.append(name) }
                }
            }
            ptr = current.pointee.ifa_next
        }

        for name in names {
            guard name != "lo0" else { continue }
            let v4 = v4Map[name]
            let v6 = v6Map[name]
            guard v4 != nil || v6 != nil else { continue }
            let isWifi = name.hasPrefix("en") // simplistic; en0 is usually Wi-Fi
            interfaces.append(NetworkInterface(
                id: name,
                displayName: name,
                ipv4: v4,
                ipv6: v6,
                macAddress: macAddress(for: name),
                isWifi: isWifi
            ))
        }
        return interfaces
    }

    static func wifiSSID() -> String? {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/sbin/networksetup")
        task.arguments = ["-getairportnetwork", "en0"]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilExit()
        let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        // Output: "Current Wi-Fi Network: MyNetwork"
        if let range = output.range(of: ": ") {
            return String(output[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return nil
    }

    private static func macAddress(for interface: String) -> String? {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/sbin/ifconfig")
        task.arguments = [interface]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilExit()
        let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        for line in output.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("ether ") {
                return String(trimmed.dropFirst(6)).trimmingCharacters(in: .whitespaces)
            }
        }
        return nil
    }
}
