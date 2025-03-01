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

import Foundation
    
@objc enum Architecture: Int, CaseIterable {
        
    case aarch64
    case arm
    case x86_64
    case i386
    case ppc64
    case ppc
    case riscv64
    case riscv32
    case sparc64
    case sparc
    case mips64
    case mips
    case mips64el
    case mipsel
    case m68k
    
    var isARM: Bool { self == .aarch64 || self == .arm }
    
    var isX86: Bool { self == .x86_64 || self == .i386 }
    
    var isPPC: Bool { self == .ppc64 || self == .ppc }
    
    var isRISC: Bool { self == .riscv64 || self == .riscv32 }
    
    var supportsUEFI: Bool { self.isARM || self.isX86 }
    
    var supportsPCI: Bool { self.isARM || self.isX86 || self.isPPC || self.isRISC }
    
    var edkFirmwarePath: String? {
        
        Bundle.main.resourceURL?
            .appendingPathComponent("QEMU")
            .appendingPathComponent("share")
            .appendingPathComponent("qemu")
            .appendingPathComponent("edk2-\(self.stringRawValue)-code.fd")
            .absoluteURL
            .path
    }
}
