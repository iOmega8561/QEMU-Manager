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

final class Accel: InfoValue, Defaultable {
    
    static var defaultValue: Accel {
        Accel(
            name: "Default",
            title: "Unspecified Acceleration",
            sorting: -1
        )
    }
    
    static let allValues: [Architecture : [Accel]] = {
        
        var values: [Architecture : [Accel]] = [:]
        
        Architecture.allCases.forEach { arch in
            
            values[arch] = [.defaultValue]
            
            values[arch]?.append(Accel(name: "tcg", title: "Tiny Code Generator", sorting: 0))
            
            if QEMU.System(arch: arch).hypervisor() {
                
                values[arch]?.append(
                    Accel(name: "hvf", title: "Hypervisor Framework", sorting: 1)
                )
            }
        }
        
        return values
    }()
}

fileprivate extension QEMU.System {
    
    func hypervisor() -> Bool {
        
        self.help(
            command: "accel",
            skipLines: ["Accelerators supported in QEMU binary:"]
        
        ).contains { $0.name == "hvf" }
    }
}
