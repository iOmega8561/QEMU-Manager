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

final class ConfigHardwareViewController: ConfigViewController {
    
    @IBOutlet private var sizeFormatter: SizeFormatter!
    @IBOutlet private var machines:      NSArrayController!
    @IBOutlet private var cpus:          NSArrayController!
    @IBOutlet private var vgas:          NSArrayController!
    @IBOutlet private var cores:         NSArrayController!
    @IBOutlet private var audios:        NSArrayController!
    
    @objc private dynamic var minCores:  UInt64
    @objc private dynamic var maxCores:  UInt64
    @objc private dynamic var minMemory: UInt64
    @objc private dynamic var maxMemory: UInt64
    @objc private dynamic var vm:        VirtualMachine
    
    @objc private dynamic var machine: Machine? { didSet { machine.set(to: &vm.config.machine) } }
    @objc private dynamic var cpu: CPU?         { didSet { cpu.set(to:     &vm.config.cpu) } }
    @objc private dynamic var vga: VGA?         { didSet { vga.set(to:     &vm.config.vga) } }
    @objc private dynamic var audio: Audio?     { didSet { audio.set(to:   &vm.config.audio) } }
    
    @objc private dynamic var architecture: Int {
        didSet { vm.config.setArchitecture(architecture); update() }
    }
    
    override var nibName: NSNib.Name? { "ConfigHardwareViewController" }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sortDescriptors = [
            NSSortDescriptor(key: "sorting", ascending: true),
            NSSortDescriptor(key: "name",    ascending: true),
            NSSortDescriptor(key: "title",   ascending: true)
        ]
        
        self.sizeFormatter.min = self.minMemory
        self.sizeFormatter.max = self.maxMemory
        self.machines.sortDescriptors = sortDescriptors
        self.cpus.sortDescriptors = sortDescriptors
        self.update()
        
        for i in self.minCores ..< self.maxCores {
            self.cores.addObject(i)
        }
    }
    
    private func update() {
        (machines.content, machine) = Machine.fetchValues(for: architecture, vm.config.machine)
        (cpus.content, cpu)         = CPU.fetchValues(for: architecture, vm.config.cpu)
        (vgas.content, vga)         = VGA.fetchValues(for: architecture, vm.config.vga)
        (audios.content, audio)     = Audio.fetchValues(for: architecture, vm.config.audio)
    }
    
    init(vm: VirtualMachine, sorting: Int) {
        self.minCores     = 1
        self.maxCores     = UInt64(ProcessInfo().processorCount)
        self.minMemory    = 1024 * 1024
        self.maxMemory    = ProcessInfo().physicalMemory / 2
        self.vm           = vm
        self.architecture = vm.config.architecture.rawValue
        
        super.init(title: "Hardware", icon: NSImage(named: "HardwareTemplate"), sorting: sorting)
    }
    
    required init?(coder: NSCoder) { nil }
}
