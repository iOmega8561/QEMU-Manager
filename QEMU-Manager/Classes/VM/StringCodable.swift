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

protocol StringCodable: CaseIterable, Codable, CustomStringConvertible, RawRepresentable where RawValue == Int {
    init?(string: String)
}

enum StringCodableError: Error {
    case invalidArchitecture
}

extension StringCodable {
    
    func encode(to encoder: any Encoder) throws {
        
        var container = encoder.singleValueContainer()
        
        try container.encode(self.description)
    }
    
    init(from decoder: any Decoder) throws {
        
        let container = try decoder.singleValueContainer()

        let value = try container.decode(String.self)
        
        guard let decodedValue = Self(string: value) else {
            throw StringCodableError.invalidArchitecture
        }
        
        self = decodedValue
    }
    
    init?(string: String) {
        guard let value = Self.allCases.first(where: { $0.description == string }) else {
            return nil
        }
        
        self = value
    }
}
