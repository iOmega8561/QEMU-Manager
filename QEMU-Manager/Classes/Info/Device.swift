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
                contentsOf: QEMU.System(arch: arch).help()
            )
        }
                
        return values
    }()
    
    @objc private(set) dynamic var category: String
    @objc private(set) dynamic var bus:      String?
    
    init(name: String, category: String, title: String? = nil, bus: String? = nil) {
        self.category = category
        self.bus = bus
        
        super.init(name: name, title: title)
    }
    
    required init(name: String, title: String? = nil, sorting: Int = 0) {
        fatalError("init(name:title:sorting:) cannot be used for Device")
    }
}
