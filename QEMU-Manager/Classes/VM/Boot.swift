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

final class Boot: NSObject, Codable {
    
    @objc enum Priority: Int, StringCodable {
        case disk
        case cdrom
        case network
        
        var description: String {
            switch self {
            case .disk:    "c"
            case .cdrom:   "d"
            case .network: "n"
            }
        }
    }
    
    @objc dynamic var priority: Priority = .disk
    
    @objc dynamic var kernel:   URL?     = nil {
        didSet { kernel == nil ? (append, initrd) = (nil, nil) : () }
    }
    
    @objc dynamic var append:   String?  = nil
    @objc dynamic var initrd:   URL?     = nil
}
