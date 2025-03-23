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
    
@objc enum Architecture: Int, StringCodable {
        
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
    
    var supportsUEFI: Bool {
    
        guard let edkFirmwarePath else {
            return false
        }
        
        return FileManager.default.fileExists(atPath: edkFirmwarePath)
    }
        
    var edkFirmwarePath: String? {
        QEMU.rootDirectoryURL?
            .appendingPathComponent("share")
            .appendingPathComponent("qemu")
            .appendingPathComponent("edk2-\(self.description)-code.fd")
            .absoluteURL.path
    }

    var description: String {
        switch self {
        case .aarch64:  "aarch64"
        case .arm:      "arm"
        case .x86_64:   "x86_64"
        case .i386:     "i386"
        case .ppc64:    "ppc64"
        case .ppc:      "ppc"
        case .riscv64:  "riscv64"
        case .riscv32:  "riscv32"
        case .sparc64:  "sparc64"
        case .sparc:    "sparc"
        case .mips64:   "mips64"
        case .mips:     "mips"
        case .mips64el: "mips64el"
        case .mipsel:   "mipsel"
        case .m68k:     "m68k"
        }
    }
}
