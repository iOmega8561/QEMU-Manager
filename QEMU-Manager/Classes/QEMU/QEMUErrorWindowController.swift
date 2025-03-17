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

final class QEMUErrorWindowController: NSWindowController {
        
    @objc private dynamic var statusText:  String
    @objc private dynamic var details:     String  = "No details available..."
    @objc private dynamic var detailsFont: NSFont? = .userFixedPitchFont(ofSize: NSFont.systemFontSize)
    
    override var windowNibName: NSNib.Name? { "QEMUErrorWindowController" }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.title = "Cannot Launch QEMU"
    }
    
    @IBAction private func ok(_ sender: Any) {
        self.window?.close()
    }
    
    init(error: QEMU.Error) {
                
        switch error {
        case .launchFailure(_, let message):
            self.details = message; fallthrough
            
        default: self.statusText  = error.statusMessage
        }
                
        super.init(window: nil)
    }
    
    required init?(coder: NSCoder) { nil }
}
