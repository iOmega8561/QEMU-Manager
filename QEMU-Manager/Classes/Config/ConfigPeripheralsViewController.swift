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

import Virtualization

final class ConfigPeripheralsViewController: ConfigViewController {
    
    @IBOutlet private var usbctrls: NSArrayController!
    @IBOutlet private var networks: NSArrayController!
    @IBOutlet private var sounds:   NSArrayController!
    @IBOutlet private var videos:   NSArrayController!
    
    @objc private dynamic var vm:        VirtualMachine
    
    @objc private dynamic var usbctrl: USB?     { didSet { usbctrl.set(to: &vm.config.usbDev) } }
    @objc private dynamic var sound:   Sound?   { didSet { sound.set(to:   &vm.config.soundDev) } }
    @objc private dynamic var video:   Video?   { didSet { video.set(to:   &vm.config.videoDev) } }
    @objc private dynamic var network: Network? { didSet { network.set(to: &vm.config.network.controller) } }
    
    @IBAction func randomMAC(_ sender: Any) {
        vm.config.network.macAddress = VZMACAddress.randomLocallyAdministered().string
    }
    
    @objc private dynamic var selectedNetworkIndex: Int {
        didSet { vm.config.network.kind = .init(rawValue: selectedNetworkIndex) ?? .host }
    }
    
    override var nibName: NSNib.Name? { "ConfigPeripheralsViewController" }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sounds.sortDescriptors   = InfoValue.sortDescriptors
        self.videos.sortDescriptors   = InfoValue.sortDescriptors
        self.networks.sortDescriptors = InfoValue.sortDescriptors
        self.update()
    }
    
    private func update() {
        (usbctrls.content, usbctrl) = USB.fetchValues(for:   vm.config.architecture.rawValue, vm.config.usbDev)
        (sounds.content, sound)     = Sound.fetchValues(for:   vm.config.architecture.rawValue, vm.config.soundDev)
        (videos.content, video)     = Video.fetchValues(for:   vm.config.architecture.rawValue, vm.config.videoDev)
        (networks.content, network) = Network.fetchValues(for: vm.config.architecture.rawValue, vm.config.network.controller)
    }
    
    init(vm: VirtualMachine, sorting: Int) {
        self.vm = vm
        self.selectedNetworkIndex = vm.config.network.kind.rawValue
        super.init(title: "Peripherals", icon: NSImage(named: "PeripheralsTemplate"), sorting: sorting)
    }
    
    required init?(coder: NSCoder) { nil }
}
