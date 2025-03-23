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

final class Config: NSObject, Codable {
    
    @objc private(set) dynamic var version:       UInt64       = 0
    @objc private(set) dynamic var uuid:          UUID         = .init()
    @objc              dynamic var title:         String       = "Untitled"
    @objc              dynamic var icon:          String?      = nil
    @objc private(set) dynamic var architecture:  Architecture = .aarch64
    @objc private(set) dynamic var system:        System       = .init()
    @objc private(set) dynamic var network:       Network      = .init()
    @objc              dynamic var usbDev:        String?      = nil
    @objc              dynamic var usbInput:      Bool         = false
    @objc              dynamic var soundDev:      String?      = nil
    @objc              dynamic var videoDev:      String?      = nil
    @objc private(set) dynamic var disks:         [Disk]       = []
    @objc private(set) dynamic var tweaks:        Tweaks       = .init()
    @objc private(set) dynamic var boot:          Boot         = .init()
    @objc private(set) dynamic var shares:        [Share]      = []
    @objc private(set) dynamic var arguments:     [String]     = []
    
    func setArchitecture(_ arch: Architecture.RawValue) {
        
        guard let arch = Architecture(rawValue: arch) else {
            return
        }
        
        self.architecture = arch
        self.system.uefi  = self.system.uefi && arch.supportsUEFI
    }
    
    func setArguments(_ args: [Argument]?) {
        self.arguments = args?.map { $0.value } ?? []
    }
    
    func addDisk(_ disk: Disk) {
        self.disks.append( disk )
    }
    
    func removeDisk(_ disk: Disk) {
        self.disks.removeAll { $0.uuid == disk.uuid }
    }
    
    func addSharedFolder(_ folder: Share) {
        self.shares.append( folder )
    }
    
    func removeSharedFolder(_ folder: Share) {
        self.shares.removeAll { $0.uuid == folder.uuid }
    }
}
