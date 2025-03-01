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

public class QEMUErrorWindowController: NSWindowController
{
                 private( set ) dynamic var error:       QEMU.QEMUError
    @objc public private( set ) dynamic var statusText:  String
    @objc public private( set ) dynamic var details:     String
    @objc public private( set ) dynamic var detailsFont: NSFont?
    
    init(error: QEMU.QEMUError) {
        
        self.error       = error
        
        switch error {
        case .launchFailure(let status, let message):
            self.statusText  = "Process exited with code \(status)"
            self.details     = message
            
        case .executableDirectoryNotAvailable:
            self.statusText  = "The executable location is not accessible"
            self.details     = ""
            
        case .executableNotAvailable(let executableName):
            self.statusText  = "The executable \(executableName) is not available"
            self.details     = ""
        }
        
        self.detailsFont = NSFont.userFixedPitchFont( ofSize: NSFont.systemFontSize )
        
        if self.details.count == 0
        {
            self.details = "No details available..."
        }
        
        super.init( window: nil )
    }
    
    required init?( coder: NSCoder )
    {
        nil
    }
    
    public override var windowNibName: NSNib.Name?
    {
        "QEMUErrorWindowController"
    }
    
    public override func windowDidLoad()
    {
        super.windowDidLoad()
        
        self.window?.title = "Cannot Launch QEMU"
    }
    
    @IBAction private func ok( _ sender: Any )
    {
        self.window?.close()
    }
}
