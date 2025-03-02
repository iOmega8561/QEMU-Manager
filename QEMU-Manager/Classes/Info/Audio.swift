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

final class Audio: InfoValue, Defaultable {
    
    static var defaultValue: Audio {
        Audio(
            name: "Default",
            title: "Unspecified Audio",
            sorting: -1
        )
    }
    
    static let allValues: [Architecture : [Audio]] = {
        
        var values: [Architecture : [Audio]] = [:]
        
        Architecture.allCases.forEach { arch in
            
            values[arch] = [.defaultValue]
            
            if arch.supportsPCI {
                
                values[arch]?.append(contentsOf: pciAudioDevs)
            }
            
        }
        
        return values
    }()
    
    private static var pciAudioDevs: [Audio] {
        [Audio(name: "intel-hda", title: "High Definition Audio", sorting: 0),
         Audio(name: "ac97",      title: "Legacy Audio",          sorting: 1)]
    }
}
