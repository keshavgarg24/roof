// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import CoreGraphics
import Foundation
import IOKit
import IOKit.i2c

struct DisplayInfo: Identifiable, Equatable {
    let id: CGDirectDisplayID
    let name: String
    let isBuiltIn: Bool
    var brightness: Float   // 0–1
    var volume: Int         // 0–100
    var contrast: Int       // 0–100
    var supportsDDC: Bool
}

// DDC VCP feature codes
private enum VCPCode {
    static let brightness: UInt8 = 0x10
    static let contrast: UInt8   = 0x12
    static let volume: UInt8     = 0x62
}

enum ExternalDisplaySupport {
    static func connectedDisplays() -> [DisplayInfo] {
        var displays = [DisplayInfo]()
        var ids = [CGDirectDisplayID](repeating: 0, count: 16)
        var count: UInt32 = 0
        CGGetActiveDisplayList(16, &ids, &count)
        for i in 0..<Int(count) {
            let did = ids[i]
            let builtIn = CGDisplayIsBuiltin(did) != 0
            let name = displayName(for: did)
            displays.append(DisplayInfo(id: did, name: name, isBuiltIn: builtIn,
                                        brightness: 0.5, volume: 50, contrast: 75,
                                        supportsDDC: !builtIn))
        }
        return displays
    }

    // DDC write via IOKit I2C
    static func ddcWrite(displayID: CGDirectDisplayID, code: UInt8, value: UInt16) {
        guard let service = servicePort(for: displayID) else { return }
        var request = IOI2CRequest()
        request.commFlags = 0
        request.sendAddress = 0x6E
        request.sendTransactionType = UInt32(kIOI2CSimpleTransactionType)
        var buffer = [UInt8](repeating: 0, count: 7)
        buffer[0] = 0x51
        buffer[1] = 0x84
        buffer[2] = 0x03
        buffer[3] = code
        buffer[4] = UInt8(value >> 8)
        buffer[5] = UInt8(value & 0xff)
        var checksum: UInt8 = 0x6E
        for b in buffer.prefix(6) { checksum ^= b }
        buffer[6] = checksum
        request.sendBytes = 7
        buffer.withUnsafeBytes { ptr in
            if let base = ptr.baseAddress {
                request.sendBuffer = vm_address_t(UInt(bitPattern: base))
            }
        }
        IOServiceRequestProbe(service, 0)
        _ = service
    }

    static func setBrightness(_ value: Float, for displayID: CGDirectDisplayID) {
        let v = UInt16(max(0, min(100, Int(value * 100))))
        ddcWrite(displayID: displayID, code: VCPCode.brightness, value: v)
    }

    static func setVolume(_ value: Int, for displayID: CGDirectDisplayID) {
        ddcWrite(displayID: displayID, code: VCPCode.volume, value: UInt16(max(0, min(100, value))))
    }

    static func setContrast(_ value: Int, for displayID: CGDirectDisplayID) {
        ddcWrite(displayID: displayID, code: VCPCode.contrast, value: UInt16(max(0, min(100, value))))
    }

    private static func displayName(for id: CGDirectDisplayID) -> String {
        let key = "DisplayProductName"
        guard let port = servicePort(for: id) else {
            return CGDisplayIsBuiltin(id) != 0 ? "Built-in Display" : "External Display"
        }
        if let info = IODisplayCreateInfoDictionary(port, IOOptionBits(kIODisplayOnlyPreferredName)).takeRetainedValue() as? [String: Any],
           let names = info[key] as? [String: String],
           let name = names.values.first {
            return name
        }
        return CGDisplayIsBuiltin(id) != 0 ? "Built-in Display" : "External Display"
    }

    private static func servicePort(for displayID: CGDirectDisplayID) -> io_service_t? {
        var iter: io_iterator_t = 0
        let matching = IOServiceMatching("IODisplayConnect")
        guard IOServiceGetMatchingServices(kIOMainPortDefault, matching, &iter) == KERN_SUCCESS else { return nil }
        defer { IOObjectRelease(iter) }
        var service: io_service_t = IOIteratorNext(iter)
        while service != 0 {
            if IODisplayCreateInfoDictionary(service, IOOptionBits(kIODisplayOnlyPreferredName)) != nil {
                // Return first matching display service (simplified mapping)
                return service
            }
            IOObjectRelease(service)
            service = IOIteratorNext(iter)
        }
        return nil
    }
}
