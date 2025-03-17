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

final class ConfigEmulationViewController: ConfigViewController {
        
    @IBOutlet private var accelerators: NSArrayController!
    
    @objc private dynamic var vm:           VirtualMachine
    @objc private dynamic var supportsUEFI: Bool
    @objc private dynamic var enableUEFI:   Bool   { didSet { vm.config.emulation.uefi = enableUEFI } }
    @objc private dynamic var accel:        Accel? { didSet { accel.set(to: &vm.config.emulation.accel) } }
        
    override var nibName: NSNib.Name? { "ConfigEmulationViewController" }
    
    override func viewDidAppear() {
        
        (accelerators.content, accel) = Accel.fetchValues(
            for: vm.config.architecture.rawValue,
            vm.config.emulation.accel
        )
        
        enableUEFI   = vm.config.emulation.uefi
        supportsUEFI = vm.config.architecture.supportsUEFI
    }
    
    override func viewDidLoad() { super.viewDidLoad() }
        
    @IBAction private func chooseFile(_ sender: NSButton) {
        
        guard let window = self.view.window else {
            return NSSound.beep()
        }
        
        let panel                     = NSOpenPanel()
        panel.canChooseFiles          = true
        panel.canChooseDirectories    = false
        panel.allowsMultipleSelection = false
        
        panel.beginSheetModal(for: window) { [weak self] result in
            
            guard result == .OK, let url = panel.url else {
                return
            }

            switch sender.tag {
            case 0: self?.vm.config.emulation.kernel = url
            case 1: self?.vm.config.emulation.initrd = url
            case 2: self?.vm.config.emulation.bios   = url
            case 3: self?.vm.config.emulation.dbt    = url
            default: return
            }
        }
    }
    
    @IBAction func removeAttachment(_ sender: NSButton) {
        switch sender.tag {
        case 0: vm.config.emulation.kernel = nil
        case 1: vm.config.emulation.initrd = nil
        case 2: vm.config.emulation.bios   = nil
        case 3: vm.config.emulation.dbt    = nil
        default: return
        }
    }
    
    init(vm: VirtualMachine, sorting: Int) {
        
        self.vm           = vm
        self.enableUEFI   = vm.config.emulation.uefi
        self.supportsUEFI = vm.config.architecture.supportsUEFI
        
        super.init(title: "Emulation", icon: NSImage(named: "QEMUTemplate"), sorting: sorting)
    }
    
    required init?(coder: NSCoder) { nil }
}
