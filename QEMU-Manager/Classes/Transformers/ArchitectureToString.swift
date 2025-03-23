/*******************************************************************************
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

@objc(ArchitectureToString) final class ArchitectureToString: StringCodableValueTransformer {
    
    override func transformEnum(from intValue: Int) -> String? {
        
        guard let arch = Architecture(rawValue: intValue) else {
            return nil
        }
        
        switch arch {
        case .aarch64:  return "ARM 64-bits"
        case .arm:      return "ARM 32-bits"
        case .x86_64:   return "Intel 64-bits"
        case .i386:     return "Intel 32-bits"
        case .ppc64:    return "PowerPC 64-bits"
        case .ppc:      return "PowerPC 32-bits"
        case .riscv64:  return "RISC-V 64-bits"
        case .riscv32:  return "RISC-V 32-bits"
        case .sparc64:  return "SPARC 64-bits"
        case .sparc:    return "SPARC 32-bits"
        case .mips64:   return "MIPS 64-bits"
        case .mips:     return "MIPS 32-bits"
        case .mips64el: return "MIPS 64-bits (Little-Endian)"
        case .mipsel:   return "MIPS 32-bits (Little-Endian)"
        case .m68k:     return "Motorola 68k"
        }
    }
}

