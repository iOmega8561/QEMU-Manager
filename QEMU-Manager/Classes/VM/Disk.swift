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

final class Disk: NSObject, Codable {
    
    @objc enum MediaType: Int, Codable {
        case disk
        case cdrom
    }

    @objc private(set) dynamic var uuid: UUID = {
        var uuid: UUID = .init()
        
        while uuid.uuidString.prefix(1).rangeOfCharacter(from: .letters) == nil {
            uuid = .init()
        }
        return uuid
    }()

    @objc              dynamic var label:  String
    @objc private(set) dynamic var format: String?
    @objc private(set) dynamic var url:    URL?
    @objc private(set) dynamic var type:   MediaType
    @objc              dynamic var auto:   Bool   = true
    
    init(label: String, format: String) {
        self.label  = label
        self.format = format
        self.url    = nil
        self.type   = .disk
    }
    
    init(url: URL, type: MediaType) {
        self.url    = url
        self.type   = type
        self.label  = url.lastPathComponent
        self.format = try? QEMU.Img().format(url: url)        
    }
}
