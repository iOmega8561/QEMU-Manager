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

final class Machine: InfoValue, SpecializedDefaultable {
    
    static var defaultValue: Machine {
        Machine(
            name: "Default",
            title: "Unspecified Machine",
            sorting: -1
        )
    }
    
    static let allValues: [Architecture: [Machine]] = {
        
        var values: [Architecture: [Machine]] = [:]
        
        Architecture.allCases.forEach { arch in
            
            values[arch] = [.defaultValue]
            
            values[arch]?.append(
                contentsOf: QEMU.System(arch: arch).machines()
            )
        }
        
        return values
    }()
}

fileprivate extension QEMU.System {
    
    func machines() -> [Machine] {
        
        self.help(
            command: "machine",
            skipLines: ["Supported machines are:"]
        )
    }
}
