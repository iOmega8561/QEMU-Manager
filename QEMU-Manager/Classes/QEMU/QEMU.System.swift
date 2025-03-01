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

extension QEMU {
    
    struct System {
        
        private let architecture: Architecture
        
        private let qemu: QEMU
        
        init(arch: Architecture) {
            self.architecture = arch
            self.qemu = QEMU(executableName: "qemu-system-\(arch.stringRawValue)")
        }
    }
}

extension QEMU.System {

    func vga() -> [(String, String)] { self.help(command: "vga") }
    
    func machines() -> [(String, String)] {
        
        self.help(command: "machine", skipLines: ["Supported machines are:"])
    }
    
    func cpus() -> [(String, String)] {
        
        self.help(
            command: "cpu",
            skipLines: ["Available CPU", "CPU feature flags", "Numerical features"],
            skipPrefixes: ["x86", "PowerPC"]
        )
    }
    
    func start(vm: VirtualMachine) throws {
        
        var arguments: [String] = []
        
        arguments.append( "-m" )
        arguments.append(SizeFormatter().string(from: NSNumber(value: vm.config.memory), style: .qemu))
        
        if let machine = vm.config.machine, machine.count > 0 {
            
            arguments.append("-M")
            arguments.append(machine)
        }
        
        if let cpu = vm.config.cpu, cpu.count > 0 {
            
            arguments.append( "-cpu" )
            arguments.append( cpu )
        }
        
        arguments.append( "-smp" )
        arguments.append(vm.config.cores > 0 ? "\(vm.config.cores)" : "1")
        
        var boot = vm.config.boot
        
        if vm.config.architecture.isARM {
            
            arguments.append("-device")
            arguments.append("qemu-xhci,id=xhci0")
        }
        
        if let cd = vm.config.cdImage,
           FileManager.default.fileExists(atPath: cd.path) {
            
            let cdromParam = vm.config.architecture.isARM ? ",if=none,id=cd0":""
            
            arguments.append( "-drive" )
            arguments.append("file=\(cd.path),media=cdrom\(cdromParam)")
            
            if vm.config.architecture.isARM {
                
                arguments.append( "-device" )
                arguments.append( "usb-storage,drive=cd0" )
            }
            
        } else if boot == "d" { boot = "c" }
        
        arguments.append( "-boot" )
        arguments.append( boot )
        
        var diskCount: Int = 0
        
        vm.disks.forEach {
            
            let diskParam = vm.config.architecture.isARM ? ",if=none,id=disk\(diskCount)" : ""
            
            arguments.append("-drive")
            arguments.append("file=\($0.url.path),format=\( $0.disk.format ),media=disk\(diskParam)")
            
            if vm.config.architecture.isARM {
                
                arguments.append("-device")
                arguments.append("nvme,drive=disk\(diskCount),id=nvme\(diskCount),serial=\($0.url.lastPathComponent)")
            }
            
            diskCount += 1
        }
        
        vm.config.sharedFolders.forEach {
            
            arguments.append("-drive")
            
            arguments.append("file=fat\($0.kind == .floppy ? ":floppy" : ""):rw:\($0.url.path),format=raw,media=disk")
        }
        
        if vm.config.architecture.supportsPCI {
            arguments.append("-device")
            arguments.append("ac97")
            
            arguments.append("-audio")
            arguments.append("driver=coreaudio")
            
            arguments.append("-nic")
            arguments.append("user")
        }
        
        if let vga = vm.config.vga {
            arguments.append("-vga")
            arguments.append(vga)
        }
        
        if vm.config.architecture.isARM {
            
            arguments.append("-device")
            arguments.append("ramfb")
            
            arguments.append("-device")
            arguments.append("usb-tablet")
            
            arguments.append("-device")
            arguments.append("usb-kbd")
        }
        
        if (vm.config.enableUEFI && vm.config.architecture.supportsUEFI),
           let firmware = vm.config.architecture.edkFirmwarePath,
           FileManager.default.fileExists(atPath: firmware) {
            
            arguments.append("-drive")
            arguments.append("if=pflash,format=raw,readonly=on,file=\(firmware)")
        }
        
        arguments.append("-accel")
        arguments.append(vm.config.architecture == .aarch64 ? "hvf" : "tcg")
        
        arguments.append("-display")
        arguments.append("cocoa")
        
        arguments.append("-name")
        arguments.append(vm.config.title)
                
        arguments.append( contentsOf: vm.config.arguments )
        
        try qemu.execute(arguments: arguments)
    }
    
    func help(
        command: String,
        skipLines: [String] = [],
        skipPrefixes: [String] = []
        
    ) -> [(String, String)] {

        let result = try? qemu.execute(arguments: ["-\(command)", "help"])

        guard let result  else { return [] }
        
        let lines = result.out.components(separatedBy: .newlines)
        var values: [(String, String)] = []
        
        for rawLine in lines {

            var line = rawLine.trimmingCharacters(in: .whitespaces)
            
            if skipLines.contains(where: { line.contains($0) }) {
                continue
            }
            
            if line.isEmpty {
                if values.isEmpty { continue }; break
            }
            
            for prefix in skipPrefixes where line.hasPrefix(prefix + " ") {
                line.removeFirst(prefix.count + 1)
            }
            
            let parts = line.split(
                separator: " ",
                maxSplits: 1,
                omittingEmptySubsequences: false
            )
            
            if parts.count == 2 {
                
                let key   = String(parts[0])
                let value = String(parts[1]).trimmingCharacters(in: .whitespaces)
                values.append((key, value))
                
            } else { values.append((line, line)) }
        }
        
        return values
    }
}
