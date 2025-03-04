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

final class Preferences {
    
    static let shared = Preferences()
    
    @UserDefault(key: "lastStart", defaultValue: nil)
    var lastStart: Date?
    
    @UserDefault(key: "vmURLs", defaultValue: [String]())
    private var vmURLs: [String]
    
    private let queue: DispatchQueue = .init(label: "com.QEMU-Manager.Preferences")
    
    func virtualMachines() -> [VirtualMachine] {
        return queue.sync {

            let validURLs = vmURLs.compactMap { URL(string: $0) }
                                   .filter { FileManager.default.fileExists(atPath: $0.path) }

            let validURLStrings = validURLs.map { $0.absoluteString }
            
            if validURLStrings != vmURLs {
                vmURLs = validURLStrings
            }
            
            return validURLs.compactMap { VirtualMachine(url: $0) }
        }
    }
    
    func addVirtualMachine(_ vm: VirtualMachine) {
        
        guard let url = vm.url else { return }
        
        queue.sync {
            vmURLs.append(url.absoluteString)
        }
    }
    
    func removeVirtualMachine(_ vm: VirtualMachine) {
        
        guard let url = vm.url else { return }
        
        queue.sync {
            vmURLs.removeAll { $0 == url.absoluteString }
        }
    }
    
    fileprivate init() {
        
        if let path = Bundle.main.path(forResource: "Defaults", ofType: "plist"),
           let defaultsDict = NSDictionary(contentsOfFile: path) as? [String: Any] {
            
            UserDefaults.standard.register(defaults: defaultsDict)
        }
    }
}
