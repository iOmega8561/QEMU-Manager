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

extension Config {
    
    final class Disk: NSObject, Codable {
        
        @objc private(set) dynamic var uuid:   UUID = .init()
        @objc private(set) dynamic var url:    URL?
        @objc private(set) dynamic var type:   MediaType
        @objc private(set) dynamic var format: ImageFormat
        @objc              dynamic var label:  String
        @objc              dynamic var auto:   Bool = true
        
        init(label: String, format: ImageFormat) {
            self.label  = label
            self.format = format
            self.url    = nil
            self.type   = .disk
        }
        
        init(url: URL, type: MediaType) {
            self.url    = url
            self.type   = type
            self.label  = url.lastPathComponent
            
            let stringFormat = try? QEMU.Img().format(url: url)
            
            self.format = .init(string: stringFormat ?? "raw") ?? .raw
        }
    }
}

extension Config.Disk {
    
    @objc enum MediaType: Int, StringCodable {
        case disk
        case cdrom
        
        var description: String {
            switch self {
            case .disk:  "disk"
            case .cdrom: "cdrom"
            }
        }
    }
}

extension Config.Disk {
    
    @objc enum ImageFormat: Int, StringCodable {
        case qcow2
        case qed
        case raw
        case vdi
        case vpc
        case vmdk
        
        var description: String {
            switch self {
            case .qcow2: "qcow2"
            case .qed:   "qed"
            case .raw:   "raw"
            case .vdi:   "vdi"
            case .vpc:   "vpc"
            case .vmdk:  "vmdk"
            }
        }
    }
}
