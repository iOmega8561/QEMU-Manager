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

final class CPU: InfoValue, SpecializedDefaultable {
    
    static var defaultValue: CPU {
        CPU(
            name: "Default",
            title: "Unspecified CPU",
            sorting: -1
        )
    }
    
    static let allValues: [Architecture: [CPU]] = {
        
        var values: [Architecture : [CPU]] = [:]
        
        Architecture.allCases.forEach { arch in
            
            values[arch] = [.defaultValue]
            
            values[arch]?.append(
                
                contentsOf: QEMU.System(arch: arch).cpus().map { cpu in
                
                    CPU(
                        name: cpu.0,
                        title: cpu.1,
                        sorting: 0
                    )
            })
        }
        
        return values
    }()
}
