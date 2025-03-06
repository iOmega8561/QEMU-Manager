/*******************************************************************************
 * Copyright (c) 2025 Giuseppe Rocco
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 ******************************************************************************/

import Foundation

final class Device: InfoValue {
    
    static let allValues: [Architecture: [Device]] = {
        
        var values: [Architecture: [Device]] = [:]
        
        Architecture.allCases.forEach { arch in
            
            values[arch] = []
            
            values[arch]?.append(
                contentsOf: QEMU.System(arch: arch).deviceHelp()
            )
        }
                
        return values
    }()
    
    @objc private(set) dynamic var category: String
    @objc private(set) dynamic var bus:      String?

    override var description: String {
        [category, bus, name, title].compactMap { $0 }.joined(separator: " - ")
    }
    
    init(name: String, category: String, title: String? = nil, bus: String? = nil) {
        self.category = category
        self.bus = bus
        
        super.init(name: name, title: title)
    }
    
    required init(name: String, title: String? = nil, sorting: Int = 0) {
        fatalError("init(name:title:sorting:) cannot be used for Device")
    }
}

fileprivate extension QEMU.System {
    
    func deviceHelp() -> [Device] {
        // Execute QEMU with "-device help"
        guard let result = try? qemu.execute(arguments: ["-device", "help"]) else {
            return []
        }
        
        let lines = result.out.components(separatedBy: .newlines)
        
        var currentCategoryName: String?
        var currentDevices = [Device]()
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if trimmedLine.isEmpty { continue }
            
            // Check if the line is a category header (e.g., "Input devices:")
            if trimmedLine.hasSuffix("devices:") {
                
                // Extract the category name. For example, "Network devices:" becomes "Network"
                let components = trimmedLine.split(separator: " ")
                currentCategoryName = components.first.map { String($0) }
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
            
            guard let currentCategoryName, let deviceName else { continue }
            
            currentDevices.append(.init(
                name: deviceName,
                category: currentCategoryName,
                title: deviceDesc,
                bus: deviceBus
            ))
        }
        
        return currentDevices
    }
}

