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

final class ConfigDevicesViewController: ConfigViewController, NSTableViewDataSource, NSTableViewDelegate
{
    
    @IBOutlet private var devices: NSArrayController!
    
    @objc private dynamic var vm: VirtualMachine
    
    init(vm: VirtualMachine, sorting: Int) {
        self.vm   = vm
        
        super.init(title: "Devices",icon: NSImage(named: "FolderTemplate"), sorting: sorting)
    }
    
    required init?(coder: NSCoder) { nil }
    
    override var nibName: NSNib.Name? { "ConfigDevicesViewController" }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadDevices()
    }
    
    
    @IBAction func addRemoveDevice(_ sender: Any) {
        guard let button = sender as? NSSegmentedControl else {
            NSSound.beep()
            
            return
        }
        
        switch button.selectedSegment {
        case 1:  self.removeDevice( sender )
        default: NSSound.beep()
        }
    }
    
    @IBAction private func removeDevice( _ sender: Any? )
    {
        guard let device = self.devices.selectedObjects.first as? Config.Device else
        {
            NSSound.beep()
            
            return
        }
        
        do
        {
            self.vm.config.removeDevice(device)
            try self.vm.save()
            self.reloadDevices()
        }
        catch let error
        {
            NSAlert( error: error ).tryBeginSheetModal( for: self.view.window, completionHandler: nil )
        }
    }
    
    private func reloadDevices()
    {
        if let existing = self.devices.content as? [ Config.Device ]
        {
            existing.forEach { self.devices.removeObject( $0 ) }
        }
        
        self.devices.add( contentsOf: self.vm.config.devices )
    }
}
