/*******************************************************************************
 * Copyright (c) 2021 Jean-David Gadina - www.xs-labs.com
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

public class ConfigDisksViewController: ConfigViewController, NSTableViewDataSource, NSTableViewDelegate
{
    
    @IBOutlet private var disks: NSArrayController!
 
    @objc private dynamic var vm: VirtualMachine
    
    @objc private dynamic var bootKernel: Bool {
        didSet { bootKernel == false ? vm.config.boot.kernel = nil : () }
    }
    
    @objc private dynamic var bootPriority: Int {
        didSet { vm.config.boot.priority = .init(rawValue: bootPriority) ?? .disk }
    }
    
    private var newDiskWindowController: NewDiskWindowController?
    
    public init( vm: VirtualMachine, sorting: Int )
    {
        self.vm = vm
        self.bootKernel = vm.config.boot.kernel != nil
        self.bootPriority = vm.config.boot.priority.rawValue
        super.init( title: "Disks", icon: NSImage( named: "DiskTemplate" ), sorting: sorting )
    }
    
    required init?( coder: NSCoder )
    {
        nil
    }
    
    public override var nibName: NSNib.Name?
    {
        "ConfigDisksViewController"
    }
    
    public override func viewDidLoad()
    {
        super.viewDidLoad()
        self.reloadDisks()
    }
    
    @IBAction private func chooseFile(_ sender: NSButton) {
        
        NSOpenPanel.filePicker(self) { [weak self] url in
            switch sender.tag {
            case 0: self?.vm.config.boot.kernel = url
            case 1: self?.vm.config.boot.initrd = url
            default: return
            }
        }
    }
    
    @IBAction func removeAttachment(_ sender: NSButton) {
        switch sender.tag {
        case 0: vm.config.boot.kernel = nil
        case 1: vm.config.boot.initrd = nil
        default: return
        }
    }
    
    @IBAction private func addRemoveDisk( _ sender: Any? )
    {
        guard let button = sender as? NSSegmentedControl else
        {
            NSSound.beep()
            
            return
        }
        
        switch button.selectedSegment
        {
            case 0:  self.addDisk( sender )
            case 1:  self.removeDisk( sender )
            default: NSSound.beep()
        }
    }
    
    @IBAction private func addDisk( _ sender: Any? )
    {
        if self.newDiskWindowController != nil
        {
            NSSound.beep()
            
            return
        }
        
        let controller = NewDiskWindowController( vm: self.vm )
        
        guard let window = self.view.window,
              let sheet  = controller.window
        else
        {
            NSSound.beep()
            
            return
        }
        
        self.newDiskWindowController = controller
        
        window.beginSheet( sheet )
        {
            r in
            
            self.newDiskWindowController = nil
            
            if r == .OK
            {
                self.reloadDisks()
            }
        }
    }
    
    @IBAction private func removeDisk( _ sender: Any? )
    {
        guard let disk = self.disks.selectedObjects.first as? DiskInfo else
        {
            NSSound.beep()
            
            return
        }
        
        guard disk.disk.url == nil else {
            self.vm.config.removeDisk( disk.disk )
            try? self.vm.save()
            self.reloadDisks()
            return
        }
        
        let alert             = NSAlert()
        alert.messageText     = "Delete Disk"
        alert.informativeText = "Are you sure you want to delete the selected disk? All data will be permanently lost."
        
        alert.addButton( withTitle: "Delete" )
        alert.addButton( withTitle: "Cancel" )
        
        alert.tryBeginSheetModal( for: self.view.window )
        {
            r in if r != .alertFirstButtonReturn
            {
                return
            }
            
            do
            {
                try FileManager.default.removeItem( at: disk.url )
                self.vm.config.removeDisk( disk.disk )
                try self.vm.save()
                self.reloadDisks()
            }
            catch let error
            {
                NSAlert( error: error ).tryBeginSheetModal( for: self.view.window, completionHandler: nil )
            }
        }
    }
    
    private func reloadDisks()
    {
        if let existing = self.disks.content as? [ DiskInfo ]
        {
            existing.forEach { self.disks.removeObject( $0 ) }
        }
        
        self.disks.add( contentsOf: self.vm.disks )
    }
    
    @IBAction func importDisk(_ sender: Any) {
        
        NSOpenPanel.filePickerWithAccessoryView(
            self,
            controllerType: DiskAccessoryViewController.self
            
        ) { [weak self] url, accessoryViewController in
            
            self?.vm.config.addDisk(
                .init(url: url, type: accessoryViewController.mediaType)
            )
            
            self?.reloadDisks()
        }
    }
    
    @IBAction public func revealDisk( _ sender: Any? )
    {
        guard let disk = sender as? DiskInfo else
        {
            NSSound.beep()
            
            return
        }
        
        NSWorkspace.shared.selectFile( disk.url.path, inFileViewerRootedAtPath: "" )
    }
}
