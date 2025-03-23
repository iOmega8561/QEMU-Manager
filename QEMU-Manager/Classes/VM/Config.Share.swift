/*******************************************************************************
 * Copyright (c) 2021 Giuseppe Rocco
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
    
    final class Share: NSObject, Codable {
        
        @objc enum Kind: Int, StringCodable {
            case fat
            case floppy
            
            var description: String {
                switch self {
                case .fat:    "fat"
                case .floppy: "fat:floppy"
                }
            }
        }
        
        @objc private(set) dynamic var uuid: UUID = .init()
        @objc private(set) dynamic var url:  URL
        @objc private(set) dynamic var kind: Kind
        
        init(url: URL, kind: Kind) {
            self.url  = url
            self.kind = kind
        }
    }
}
