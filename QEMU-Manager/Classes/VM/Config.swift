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

class Config: NSObject, Codable {
    
    @objc private(set) dynamic var version:       UInt64           = 0
    @objc private(set) dynamic var uuid:          UUID             = UUID()
    @objc              dynamic var architecture:  Architecture     = .aarch64
    @objc              dynamic var machine:       String?          = nil
    @objc              dynamic var cpu:           String?          = nil
    @objc              dynamic var vga:           String?          = nil
    @objc              dynamic var cores:         UInt64           = 1
    @objc              dynamic var memory:        UInt64           = 2147483648
    @objc              dynamic var enableUEFI:    Bool             = false
    @objc              dynamic var title:         String           = "Untitled"
    @objc              dynamic var icon:          String?          = nil
    @objc private(set) dynamic var disks:         [Disk]           = []
    @objc              dynamic var cdImage:       URL?             = nil
    @objc              dynamic var boot:          String           = "d"
    @objc private(set) dynamic var sharedFolders: [SharedFolder]   = []
    @objc              dynamic var arguments:     [String]         = []
    
    func addDisk( _ disk: Disk ) {
        self.disks.append( disk )
    }
    
    func removeDisk( _ disk: Disk ) {
        self.disks.removeAll { $0.uuid == disk.uuid }
    }
    
    func addSharedFolder( _ folder: SharedFolder ) {
        self.sharedFolders.append( folder )
    }
    
    func removeSharedFolder( _ folder: SharedFolder ) {
        self.sharedFolders.removeAll { $0.uuid == folder.uuid }
    }
}
