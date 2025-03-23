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

extension Config {
    
    final class System: NSObject, Codable {
        
        @objc dynamic var machine: String? = nil   {
            didSet { machine == nil ? params = nil : () }
        }
        @objc dynamic var bios:    URL?    = nil   {
            didSet { bios != nil ? uefi = false : () }
        }
        @objc dynamic var uefi:    Bool    = false {
            didSet { uefi ? bios = nil : () }
        }
        @objc dynamic var params:  String? = nil
        @objc dynamic var dbt:     URL?    = nil
        @objc dynamic var cpu:     String? = nil
        @objc dynamic var cores:   UInt64  = 1
        @objc dynamic var memory:  UInt64  = 2147483648
    }
}
