/*******************************************************************************
 * Copyright (c) Giuseppe Rocco
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

extension NSOpenPanel {
    
    static func filePicker(_ sender: NSViewController, _ onCompletion: @escaping (URL) throws -> Void) {
        
        guard let window = sender.view.window else {
            return NSSound.beep()
        }
        
        let panel                     = NSOpenPanel()
        panel.canChooseFiles          = true
        panel.canChooseDirectories    = true
        panel.allowsMultipleSelection = false
        
        panel.beginSheetModal(for: window) { result in
            
            guard result == .OK, let url = panel.url else {
                return
            }

            do {
                try onCompletion(url)
                
            } catch { NSAlert(error: error).beginSheetModal(for: window) }
        }
    }
    
    static func filePickerWithAccessoryView<T: NSViewController>(_ sender: NSViewController, controllerType: T.Type, _ onCompletion: @escaping (URL, T) throws -> Void) {
        
        guard let window = sender.view.window else {
            return NSSound.beep()
        }
        
        let panel                     = NSOpenPanel()
        let accessoryViewController   = T()
        panel.canChooseFiles          = true
        panel.canChooseDirectories    = true
        panel.allowsMultipleSelection = false
        panel.accessoryView           = accessoryViewController.view
        
        panel.beginSheetModal(for: window) { result in
            
            guard result == .OK, let url = panel.url else {
                return
            }

            do {
                try onCompletion(url, accessoryViewController)
                
            } catch { NSAlert(error: error).beginSheetModal(for: window) }
        }
    }
}
