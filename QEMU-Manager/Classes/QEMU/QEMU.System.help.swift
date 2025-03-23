/*******************************************************************************
 * Copyright (c) 2021 Jean-David Gadina - www.xs-labs.com
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

extension QEMU.System {
    
    func help<T: InfoValue>(command: String, skipLines: [String] = [], skipPrefixes: [String] = []) -> [T] {
        
        let result = try? qemu.execute(arguments: ["-\(command)", "help"])
        
        guard let result  else { return [] }
        
        let lines = result.out.components(separatedBy: .newlines)
        var values: [T] = []
        
        for rawLine in lines {
            
            var line = rawLine.trimmingCharacters(in: .whitespaces)
            
            if skipLines.contains(where: { line.contains($0) }) {
                continue
            }
            
            if line.isEmpty {
                if values.isEmpty { continue }; break
            }
            
            for prefix in skipPrefixes where line.hasPrefix(prefix + " ") {
                line.removeFirst(prefix.count + 1)
            }
            
            let parts = line.split(
                separator: " ",
                maxSplits: 1,
                omittingEmptySubsequences: false
            )
            
            if parts.count == 2 {
                
                let key   = String(parts[0])
                let value = String(parts[1]).trimmingCharacters(in: .whitespaces)
                
                values.append(value.starts(with: "(") ? .init(name: key) : .init(name: key, title: value))
                
            } else { values.append(.init(name: line)) }
        }
        
        return values
    }
    
    func help() -> [Device] {
        
        let result = try? qemu.execute(arguments: ["-device", "help"])
        
        guard let result else { return [] }
        
        let lines = result.out.components(separatedBy: .newlines)
        
        var currentCategoryName: String?
        var currentDevices:      [Device] = []
        
        for line in lines {
            
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            guard trimmedLine.isEmpty == false else { continue }
            
            guard trimmedLine.hasSuffix("devices:") == false else {
                
                let components      = trimmedLine.split(separator: " ")
                currentCategoryName = components.first.map { .init($0) }
                continue
            }
            
            let tokens = trimmedLine.split(separator: ",")
            
            var deviceName: String?
            var deviceBus: String?
            var deviceDesc: String?
            
            for token in tokens {
                
                let tokenTrimmed = token.trimmingCharacters(in: .whitespaces)
                
                if tokenTrimmed.hasPrefix("name ") {
                    
                    let value = tokenTrimmed.dropFirst("name ".count)
                    deviceName = value.trimmingCharacters(in: .init(charactersIn: "\""))
                    
                } else if tokenTrimmed.hasPrefix("bus ") {
                    
                    let value = tokenTrimmed.dropFirst("bus ".count)
                    deviceBus = value.trimmingCharacters(in: .init(charactersIn: "\""))
                    
                } else if tokenTrimmed.hasPrefix("desc ") {
                    
                    let value = tokenTrimmed.dropFirst("desc ".count)
                    deviceDesc = value.trimmingCharacters(in: .init(charactersIn: "\""))
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
