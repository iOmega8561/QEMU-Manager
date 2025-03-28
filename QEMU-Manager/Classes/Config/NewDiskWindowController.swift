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

public class NewDiskWindowController: NSWindowController
{
    @objc public private( set ) dynamic var vm:      VirtualMachine
    @objc public private( set ) dynamic var label:   String
    @objc public private( set ) dynamic var size:    UInt64
    @objc public private( set ) dynamic var min:     UInt64
    @objc public private( set ) dynamic var max:     UInt64
    @objc public private( set ) dynamic var loading: Bool
    @objc        private( set ) dynamic var format:  Int
    
    @IBOutlet private var formatter: SizeFormatter!
    
    public init( vm: VirtualMachine )
    {
        self.vm      = vm
        self.label   = "Untitled"
        self.size    = 1024 * 1024 * 1024 * 20
        self.min     = 1024 * 1024
        self.max     = 1024 * 1024 * 1024 * 500
        self.loading = false
        self.format  = 0
        
        super.init( window: nil )
    }
    
    required init?( coder: NSCoder )
    {
        nil
    }
    
    public override var windowNibName: NSNib.Name?
    {
        "NewDiskWindowController"
    }
    
    public override func windowDidLoad()
    {
        super.windowDidLoad()
        
        self.formatter.min = self.min
        self.formatter.max = self.max
    }
    
    @IBAction private func cancel( _ sender: Any? )
    {
        guard let window = self.window,
              let parent = self.window?.sheetParent
        else
        {
            NSSound.beep()
            
            return
        }
        
        parent.endSheet( window, returnCode: .cancel )
    }
    
    @IBAction private func createDisk( _ sender: Any? )
    {
        guard let window = self.window,
              let parent = self.window?.sheetParent,
              let url    = self.vm.url
        else
        {
            NSSound.beep()
            
            return
        }
        
        if self.loading
        {
            return
        }
        
        self.loading = true
        
        DispatchQueue.global( qos: .userInitiated ).async
        {
            let format  = Config.Disk.ImageFormat(rawValue: self.format) ?? .qcow2
            let disk    = Config.Disk(label: self.label, format: format)
            let path    = url.appendingPathComponent( disk.uuid.uuidString ).appendingPathExtension( format.description ).path
            
            do
            {
                try QEMU.Img().create( url: URL( fileURLWithPath: path ), size: self.size, format: format.description )
                self.vm.config.addDisk( disk )
                try self.vm.save()
                
                DispatchQueue.main.asyncAfter( deadline: .now() + .milliseconds( 500 ) )
                {
                    parent.endSheet( window, returnCode: .OK )
                }
            }
            catch let error
            {
                try? FileManager.default.removeItem( atPath: path )
                
                DispatchQueue.main.async
                {
                    self.loading = false
                    
                    NSAlert( error: error ).beginSheetModal( for: window, completionHandler: nil )
                }
            }
        }
    }
}
