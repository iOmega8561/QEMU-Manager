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

extension Data {
    
    static func contentsOf(_ url: URL, attempts: Int = 3) throws -> Data {
        
        var lastError: Error = NSError(domain: .init(), code: .zero)
        
        for _ in 0..<attempts {
        
            do {
                return try Data(contentsOf: url, options: .mappedIfSafe)
                
            } catch let error as NSError {
                
                if let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? NSError,
                   underlyingError.domain == NSPOSIXErrorDomain,
                   underlyingError.code == 4 {
                    
                    lastError = error; continue
                }
                
                throw error
            }
        }
        
        throw lastError
    }
}
