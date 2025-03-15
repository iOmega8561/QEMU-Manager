/*******************************************************************************
 * Copyright (c) 2021 Jean-David Gadina - www.xs-labs.com
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

extension QEMU {
    
    struct Img {
        
        private let qemu: QEMU
        
        func create( url: URL, size: UInt64, format: String ) throws {
            try qemu.execute(
                arguments: ["create", "-f", format,
                            url.path, "\(size)"]
            )
        }
        
        func info( url: URL ) throws -> [String] {
            
            let res = try qemu.execute(
                arguments: ["info", url.path]
            )
            
            return res?.out.components(
                separatedBy: .newlines
            ).map { $0.trimmingCharacters(in: .whitespaces) } ?? []
        }
        
        func infoKey( url: URL, keyPrefix: String ) throws -> String? {
            
            let info = try self.info(url: url)
            
            for line in info {
                
                if line.hasPrefix(keyPrefix) {
                    
                    return .init(line.suffix(
                        from: line.index(line.startIndex, offsetBy: keyPrefix.count)
                    )).trimmingCharacters( in: .whitespaces )
                }
                
            }; return nil
        }
        
        func format( url: URL ) throws -> String? {
            
            try self.infoKey(url: url, keyPrefix: "file format:")
        }
        
        func size( url: URL ) throws -> String? {
            
            try self.infoKey(url: url, keyPrefix: "virtual size:")
        }
        
        init() { self.qemu = QEMU(executableName: "qemu-img") }
    }
}
