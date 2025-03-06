//
//  Device.swift
//  QEMU Manager
//
//  Created by Giuseppe Rocco on 05/03/25.
//

import Foundation

struct DeviceCategory {
    let name: String
    let devices: [Device]
}

struct Device {
    let name: String
    let bus: String?
    let desc: String?
}

extension QEMU.System {
    
    func parseDeviceHelp() -> [DeviceCategory] {
        // Execute QEMU with "-device help"
        guard let result = try? qemu.execute(arguments: ["-device", "help"]) else {
            return []
        }
        
        let lines = result.out.components(separatedBy: .newlines)
        var categories = [DeviceCategory]()
        
        var currentCategoryName: String?
        var currentDevices = [Device]()
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if trimmedLine.isEmpty { continue }
            
            // Check if the line is a category header (e.g., "Input devices:")
            if trimmedLine.hasSuffix("devices:") {
                // If there's a previous category, add it to the array
                if let currentCategoryName = currentCategoryName {
                    let category = DeviceCategory(name: currentCategoryName, devices: currentDevices)
                    categories.append(category)
                }
                
                // Extract the category name. For example, "Network devices:" becomes "Network"
                let components = trimmedLine.split(separator: " ")
                currentCategoryName = components.first.map { String($0) }
                currentDevices = []
                continue
            }
            
            // Otherwise, assume this is a device line.
            // Example: name "i8042", bus ISA, desc "Some description"
            let tokens = trimmedLine.split(separator: ",")
            var deviceName: String?
            var deviceBus: String?
            var deviceDesc: String?
            
            for token in tokens {
                let tokenTrimmed = token.trimmingCharacters(in: .whitespaces)
                if tokenTrimmed.hasPrefix("name ") {
                    // Remove the "name " prefix and trim quotes
                    let value = tokenTrimmed.dropFirst("name ".count)
                    deviceName = value.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                } else if tokenTrimmed.hasPrefix("bus ") {
                    let value = tokenTrimmed.dropFirst("bus ".count)
                    deviceBus = value.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                } else if tokenTrimmed.hasPrefix("desc ") {
                    let value = tokenTrimmed.dropFirst("desc ".count)
                    deviceDesc = value.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                }
            }
            
            if let name = deviceName {
                let device = Device(name: name, bus: deviceBus, desc: deviceDesc)
                currentDevices.append(device)
            }
        }
        
        // Add the last category if present
        if let currentCategoryName = currentCategoryName {
            let category = DeviceCategory(name: currentCategoryName, devices: currentDevices)
            categories.append(category)
        }
        
        return categories
    }
}

