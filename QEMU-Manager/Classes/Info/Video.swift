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

final class Video: InfoValue, SpecializedDefaultable {
    
    static var defaultValue: Video {
        Video(
            name: "Default",
            title: "Unspecified Video Card",
            sorting: -1
        )
    }
    
    static let allValues: [Architecture: [Video]] = {
        
        var values: [Architecture: [Video]] = [:]
        
        Architecture.allCases.forEach { arch in
            
            values[arch] = [.defaultValue]
            
            guard let devices = Device.allValues[arch] else {
                return
            }
            
            values[arch]?.append(
                contentsOf: devices.filter { $0.category == "Display" }
                    .map { .init(name: $0.name, title: $0.title) }
            )
        }
        
        return values
    }()
}
