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

final class ConfigQEMUViewController: ConfigViewController {
        
    @IBOutlet private var accelerators: NSArrayController!
    
    @objc private dynamic var vm:           VirtualMachine
    @objc private dynamic var supportsUEFI: Bool
    @objc private dynamic var enableUEFI:   Bool   { didSet { vm.config.enableUEFI = enableUEFI } }
    @objc private dynamic var accel:        Accel? { didSet { accel.set(to: &vm.config.accel) } }
        
    override var nibName: NSNib.Name? { "ConfigQEMUViewController" }
    
    override func viewDidAppear() {
        
        (accelerators.content, accel) = Accel.fetchValues(
            for: vm.config.architecture.rawValue,
            vm.config.accel
        )
        
        enableUEFI   = vm.config.enableUEFI
        supportsUEFI = vm.config.architecture.supportsUEFI
    }
    
    override func viewDidLoad() { super.viewDidLoad() }
        
    init(vm: VirtualMachine, sorting: Int) {
        
        self.vm           = vm
        self.enableUEFI   = vm.config.enableUEFI
        self.supportsUEFI = vm.config.architecture.supportsUEFI
        
        super.init(title: "QEMU", icon: NSImage(named: "QEMUTemplate"), sorting: sorting)
    }
    
    required init?(coder: NSCoder) { nil }
}
