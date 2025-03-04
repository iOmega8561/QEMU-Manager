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
    
    @IBOutlet private var machineIcons: NSArrayController!
    
    @objc private dynamic var vm:          VirtualMachine
    @objc private dynamic var path:        String
    @objc private dynamic var machineIcon: Icon? { didSet { machineIcon.set(to: &vm.config.icon) } }
    
    override var nibName: NSNib.Name? { "ConfigGeneralViewController" }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.machineIcons.sortDescriptors = [
            NSSortDescriptor(key: "sorting", ascending: true),
            NSSortDescriptor(key: "name",    ascending: true),
            NSSortDescriptor(key: "title",   ascending: true)
        ]
        
        (machineIcons.content, machineIcon) = Icon.fetchValues(vm.config.icon)
    }
    
    @IBAction private func revealInFinder(_ sender: Any) {
        
        guard let url = self.vm.url else {
            return NSSound.beep()
        }
        
        NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: "")
    }
    
    init(vm: VirtualMachine, sorting: Int) {
        self.vm   = vm
        self.path = vm.url?.path ?? "--"
        
        super.init(title: "General", icon: NSImage(named: "InfoTemplate"), sorting: sorting)
    }
    
    required init?(coder: NSCoder) { nil }
}
