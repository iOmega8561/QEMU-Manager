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

import Cocoa

final class BootResourceAccessoryViewController: NSViewController {
    
    @objc private dynamic var selectedIndex = 0
    
    var bootResourceKind: BootResource.Kind {
        
        switch self.selectedIndex {
        case 1:  .kernel
        case 2:  .initrd
        case 3:  .dbt
        default: .bios
        }
    }
    
    override var nibName: NSNib.Name? {
        "BootResourceAccessoryViewController"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
