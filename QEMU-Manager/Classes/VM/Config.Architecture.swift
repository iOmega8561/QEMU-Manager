//
//  Config.Architecture.swift
//  QEMU Manager
//
//  Created by Giuseppe Rocco on 01/03/25.
//

extension Config {
    
    @objc enum Architecture: Int {
        
        case aarch64
        case arm
        case x86_64
        case i386
        case ppc64
        case ppc
        case riscv64
        case riscv32
        case m68k
        
        var isARM: Bool {
            self == .aarch64 || self == .arm
        }
        
        var isX86: Bool {
            self == .x86_64 || self == .i386
        }
        
        var supportsUEFI: Bool {
            self.isARM || self.isX86
        }
        
        var edkFirmwarePath: String? {
            
            Bundle.main.resourceURL?
                .appendingPathComponent("QEMU")
                .appendingPathComponent("share")
                .appendingPathComponent("qemu")
                .appendingPathComponent("edk2-\(self.description)-code.fd")
                .absoluteURL
                .path(percentEncoded: false)
        }
    }
}

extension Config.Architecture: CustomStringConvertible {

    init?( string: String ) {
        switch string {
        case "aarch64": self = .aarch64
        case "arm":     self = .arm
        case "i386":    self = .i386
        case "m68k":    self = .m68k
        case "ppc":     self = .ppc
        case "ppc64":   self = .ppc64
        case "riscv32": self = .riscv32
        case "riscv64": self = .riscv64
        case "x86_64":  self = .x86_64
        default:        return nil
        }
    }
    
    var description: String {
        switch self {
        case .aarch64: "aarch64"
        case .arm:     "arm"
        case .i386:    "i386"
        case .m68k:    "m68k"
        case .ppc:     "ppc"
        case .ppc64:   "ppc64"
        case .riscv32: "riscv32"
        case .riscv64: "riscv64"
        case .x86_64:  "x86_64"
        }
    }
}
