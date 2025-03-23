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

import Foundation

public class InfoValue: NSObject
{
    @objc public private( set ) dynamic var name:    String
    @objc public private( set ) dynamic var title:   String?
    @objc public private( set ) dynamic var sorting: Int
    
    static let sortDescriptors = [
        NSSortDescriptor(key: "sorting", ascending: true),
        NSSortDescriptor(key: "title",   ascending: true),
        NSSortDescriptor(key: "name",    ascending: true)
    ]
    
    public required init( name: String, title: String? = nil, sorting: Int = 0 )
    {
        self.name    = name
        self.title   = title
        self.sorting = sorting
    }
    
    public override var description: String
    {
        if let title = self.title, title.count > 0
        {
            return "\( title ) (\( self.name ))"
        }
        
        return self.name
    }
    
    public override func isEqual( _ object: Any? ) -> Bool
    {
        return false    
    }
}
