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
    
    @objc enum Icon: Int, StringCodable {
        
        case generic
        case appleTemplate
        case appleLegacy
        case macOS
        case windows11
        case windowsTemplate
        case windowsLegacy
        case windows9X
        case linux
        case fedora
        case ubuntu
        case freeBSD
        
        var description: String {
            switch self {
            case .generic:         "Generic"
            case .appleTemplate:   "AppleTemplate"
            case .appleLegacy:     "AppleLegacy"
            case .macOS:           "MacOS"
            case .windows11:       "Windows11"
            case .windowsTemplate: "WindowsTemplate"
            case .windowsLegacy:   "WindowsLegacy"
            case .windows9X:       "Windows9X"
            case .linux:           "Linux"
            case .fedora:          "Fedora"
            case .ubuntu:          "Ubuntu"
            case .freeBSD:         "FreeBSD"
            }
        }
    }
}
