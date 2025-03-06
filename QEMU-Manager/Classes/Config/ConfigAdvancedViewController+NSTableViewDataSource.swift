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

extension ConfigAdvancedViewController: NSTableViewDataSource {
    
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        
        guard let arranged = self.arguments.arrangedObjects as? [ Argument ] else {
            return nil
        }
        
        if row < 0 || row >= arranged.count {
            return nil
        }
        
        let item = NSPasteboardItem()
        
        item.setPropertyList(row, forType: Self.pasteboardType)
        
        return item
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        
        return dropOperation == .above ? .move : []
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        
        guard let item     = info.draggingPasteboard.pasteboardItems?.first,
              let moved    = item.propertyList(forType: Self.pasteboardType) as? Int,
              let arranged = self.arguments.arrangedObjects as? [Argument]
        
        else { return false }
        
        if moved < 0 || moved >= arranged.count {
            return false
        }
        
        let new = moved < row ? row - 1 : row
        let arg = arranged[moved]
        
        self.arguments.remove(     atArrangedObjectIndex: moved)
        self.arguments.insert(arg, atArrangedObjectIndex: new)
        
        return true
    }
}
