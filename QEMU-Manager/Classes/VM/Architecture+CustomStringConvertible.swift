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

extension Architecture: CustomStringConvertible {

    init?(string: String) {
        
        guard let arch = Architecture.allCases.first(
            where: { $0.stringRawValue == string }
        
        ) else { return nil }
        
        self = arch
    }

    var stringRawValue: String {
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

    var displayName: String {
        switch self {
        case .aarch64:  "ARM 64-bits"
        case .arm:      "ARM 32-bits"
        case .x86_64:   "Intel 64-bits"
        case .i386:     "Intel 32-bits"
        case .ppc64:    "PowerPC 64-bits"
        case .ppc:      "PowerPC 32-bits"
        case .riscv64:  "RISC-V 64-bits"
        case .riscv32:  "RISC-V 32-bits"
        case .sparc64:  "SPARC 64-bits"
        case .sparc:    "SPARC 32-bits"
        case .mips64:   "MIPS 64-bits"
        case .mips:     "MIPS 32-bits"
        case .mips64el: "MIPS 64-bits (Little-Endian)"
        case .mipsel:   "MIPS 32-bits (Little-Endian)"
        case .m68k:     "Motorola 68k"
        }
    }
    
    var description: String { self.displayName + " - \(self.stringRawValue)" }
}
