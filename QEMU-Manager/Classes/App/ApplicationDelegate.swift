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

@main
final class ApplicationDelegate: NSObject, NSApplicationDelegate {
    
    let aboutWindowController   = AboutWindowController()
    let libraryWindowController = LibraryWindowController()
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        self.showLibraryWindow(nil)
    }

    func applicationWillTerminate(_ notification: Notification) {
        Preferences.shared.lastStart = Date()
    }
    
    func application(_ application: NSApplication, open urls: [ URL ]) {
        self.libraryWindowController.addVirtualMachines(from: urls)
    }
    
    func applicationShouldTerminate( _ sender: NSApplication ) -> NSApplication.TerminateReply {
        
        if libraryWindowController.virtualMachines.contains(where: { $0.running }) {
            
            let alert = NSAlert()
            
            alert.messageText     = "Virtual Machines are running"
            alert.informativeText = "Please shut-down all virtual machines before quitting."
            alert.addButton(withTitle: "OK")
            
            alert.tryBeginSheetModal(
                for: self.libraryWindowController.window,
                completionHandler: nil
            )
            
            return .terminateCancel
            
        }
        
        return .terminateNow
    }
    
    @IBAction func showAboutWindow(_ sender: Any?) {
        
        guard let window = self.aboutWindowController.window else {
            NSSound.beep(); return
        }
        window.layoutIfNeeded()
        
        if window.isVisible == false { window.center() }
        
        window.makeKeyAndOrderFront(nil)
    }
    
    @IBAction func showLibraryWindow(_ sender: Any?) {
        
        guard let window = self.libraryWindowController.window else {
            NSSound.beep(); return
        }
        window.layoutIfNeeded()
        
        if window.isVisible == false &&
           Preferences.shared.lastStart == nil { window.center() }
        
        window.makeKeyAndOrderFront(nil)
    }
}
