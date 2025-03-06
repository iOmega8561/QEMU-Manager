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

final class NewDeviceArgWindowController: NSWindowController {
    
    @objc private dynamic var vm:       VirtualMachine
    @objc private dynamic var params:   String?
    @objc private dynamic var loading:  Bool
    @objc private dynamic var device:   Device?
    @objc private dynamic var category: String? { didSet { updateBuses() } }
    @objc private dynamic var bus:      String? { didSet { updateDevices() } }
    
    @IBOutlet private var devices:    NSArrayController!
    @IBOutlet private var categories: NSArrayController!
    @IBOutlet private var buses:      NSArrayController!
    
    private let allDevices:        [Device]
    private let completionHandler: ([Argument]) -> Void
    
    override var windowNibName: NSNib.Name? { "NewDeviceArgWindowController" }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.devices.sortDescriptors = [
            NSSortDescriptor( key: "category", ascending: true ),
            NSSortDescriptor( key: "bus",      ascending: true ),
            NSSortDescriptor( key: "title",    ascending: true ),
            NSSortDescriptor( key: "name",     ascending: true )
        ]
        
        let categories = NSOrderedSet(array: allDevices.compactMap { $0.category })
        let buses      = NSOrderedSet(array: allDevices.compactMap { $0.bus })
        
        self.device             = nil
        self.devices.content    = allDevices
        self.buses.content      = buses.array
        self.categories.content = categories.array
    }
    
    @IBAction private func cancel( _ sender: Any? ) {
        
        guard let window = self.window,
              let parent = self.window?.sheetParent else { return NSSound.beep() }
        
        parent.endSheet( window, returnCode: .cancel )
    }
    
    @IBAction private func createDevice( _ sender: Any? ) {
        
        guard let device, !self.loading,
              let window = self.window,
              let parent = self.window?.sheetParent else { return NSSound.beep() }
       
        self.loading = true
        
        let arguments: [Argument] = [
            .init(value: "-device"),
            .init(value: [device.name, self.params].compactMap { $0 }.joined(separator: ","))
        ]
        
        completionHandler(arguments)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            parent.endSheet(window, returnCode: .OK)
        }
    }
    
    private func updateDevices() {
        
        device = nil; devices.content = allDevices.filter {
            
            !( (category != nil && $0.category != category) ||
               (bus      != nil && $0.bus      != bus) )
        }
    }
    
    private func updateBuses() {
        
        let filteredDevices = allDevices.filter {
            !(category != nil && $0.category != category)
        }
        let busesOrderedSet = NSOrderedSet(
            array: filteredDevices.compactMap { $0.bus }
        )
        
        bus = nil; buses.content = busesOrderedSet.array; updateDevices()
    }
    
    init(vm: VirtualMachine, completionHandler: @escaping ([Argument]) -> Void) {
        self.vm                = vm
        self.params            = nil
        self.loading           = false
        self.completionHandler = completionHandler
        self.allDevices        = Device.allValues[vm.config.architecture] ?? []
        
        super.init(window: nil)
    }
    
    required init?(coder: NSCoder) { nil }
}
