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

import Cocoa

final class ConfigGeneralViewController: ConfigViewController {
        
    @objc private dynamic var vm:         VirtualMachine
    @objc private dynamic var path:       String
    @objc private dynamic var minPortVNC: Int
    @objc private dynamic var maxPortVNC: Int
        
    @objc private dynamic var selectedIconIndex: Int {
        didSet { vm.config.icon = .init(rawValue: selectedIconIndex) ?? .generic }
    }
    
    override var nibName: NSNib.Name? { "ConfigGeneralViewController" }
    
    override func viewDidLoad() { super.viewDidLoad() }
    
    @IBAction private func revealInFinder(_ sender: Any) {
        
        guard let url = self.vm.url else {
            return NSSound.beep()
        }
        
        NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: "")
    }
    
    init(vm: VirtualMachine, sorting: Int) {
        self.vm                = vm
        self.path              = vm.url?.path ?? "--"
        self.maxPortVNC        = 65535
        self.minPortVNC        = 5900
        self.selectedIconIndex = vm.config.icon.rawValue
        super.init(title: "General", icon: NSImage(named: "InfoTemplate"), sorting: sorting)
    }
    
    required init?(coder: NSCoder) { nil }
}
