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

final class ConfigSystemViewController: ConfigViewController {
    
    @IBOutlet private var sizeFormatter: SizeFormatter!
    @IBOutlet private var machines:      NSArrayController!
    @IBOutlet private var cpus:          NSArrayController!
    
    @objc private dynamic var minCores:  UInt64
    @objc private dynamic var maxCores:  UInt64
    @objc private dynamic var minMemory: UInt64
    @objc private dynamic var maxMemory: UInt64
    @objc private dynamic var vm:        VirtualMachine
    @objc private dynamic var supportsUEFI: Bool
    
    @objc private dynamic var machine: Machine? { didSet { machine.set(to: &vm.config.system.machine) } }
    @objc private dynamic var cpu: CPU?         { didSet { cpu.set(to:     &vm.config.system.cpu) } }
    
    @objc private dynamic var architecture: Int {
        didSet { vm.config.setArchitecture(architecture); update() }
    }
    
    override var nibName: NSNib.Name? { "ConfigSystemViewController" }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sizeFormatter.min = self.minMemory
        self.sizeFormatter.max = self.maxMemory
        self.machines.sortDescriptors = InfoValue.sortDescriptors
        self.cpus.sortDescriptors = InfoValue.sortDescriptors
        self.update()
    }
    
    @IBAction private func chooseFile(_ sender: NSButton) {
        
        NSOpenPanel.filePicker(self) { [weak self] url in
            
            switch sender.tag {
            case 0: self?.vm.config.system.bios = url
            case 1: self?.vm.config.system.dbt  = url
            default: return
            }
        }
    }
    
    @IBAction func removeAttachment(_ sender: NSButton) {
        switch sender.tag {
        case 0: vm.config.system.bios = nil
        case 1: vm.config.system.dbt  = nil
        default: return
        }
    }
    
    private func update() {
        supportsUEFI = vm.config.architecture.supportsUEFI
        
        (machines.content, machine) = Machine.fetchValues(for: architecture, vm.config.system.machine)
        (cpus.content, cpu)         = CPU.fetchValues(for: architecture, vm.config.system.cpu)
    }
    
    init(vm: VirtualMachine, sorting: Int) {
        self.minCores     = 1
        self.maxCores     = UInt64(ProcessInfo().processorCount)
        self.minMemory    = 1024 * 1024
        self.maxMemory    = ProcessInfo().physicalMemory / 2
        self.vm           = vm
        self.architecture = vm.config.architecture.rawValue
        self.supportsUEFI = vm.config.architecture.supportsUEFI
        
        super.init(title: "System", icon: NSImage(named: "HardwareTemplate"), sorting: sorting)
    }
    
    required init?(coder: NSCoder) { nil }
}
