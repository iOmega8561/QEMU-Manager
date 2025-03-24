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

protocol Defaultable: InfoValue {
        
    static var defaultValue: Self { get }
    
    static var allValues: [Architecture: [Self]] { get }
    
    static func fetchValues(for archRaw: Architecture.RawValue, _ current: String?) -> ([Self], Self)
    
    func set(to value: inout String?)
}

extension Defaultable {
    
    static func fetchValues(for archRaw: Architecture.RawValue, _ current: String?) -> ([Self], Self) {
        
        let architecture: Architecture? = .init(rawValue: archRaw)
        
        guard let architecture else {
            return ([.defaultValue], .defaultValue)
        }
        
        let values:    [Self] = Self.allValues[architecture] ?? [.defaultValue]
        let selection: Self   = values.first { $0.name == current } ?? .defaultValue
        
        return (values, selection)
    }
    
    func set(to value: inout String?)  {
        
        value = self.sorting != -1 ? self.name : nil
    }
}

extension Optional where Wrapped: Defaultable {
    
    func set(to value: inout String?)  {
        
        guard let self else {
            value = nil; return
        }
        
        self.set(to: &value)
    }
}
