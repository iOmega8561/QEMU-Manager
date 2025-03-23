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

import Virtualization

extension Config {
    
    final class Network: NSObject, Codable {
        
        @objc enum Kind: Int, StringCodable {
            case host
            case shared
            
            var description: String {
                switch self {
                case .host:   "host"
                case .shared: "shared"
                }
            }
        }
        
        @objc dynamic var kind:       Kind    = .host
        @objc dynamic var controller: String? = nil
        @objc dynamic var macAddress: String  = VZMACAddress.randomLocallyAdministered().string
    }
}
