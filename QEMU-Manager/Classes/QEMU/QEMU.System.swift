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
    
    func start(vm: VirtualMachine) throws {
        
        var arguments: [String] = []
        
        arguments.append( "-m" )
        arguments.append(SizeFormatter().string(from: NSNumber(value: vm.config.memory), style: .qemu))
        
        if let machine = vm.config.machine, machine.count > 0 {
            arguments.append(contentsOf: ["-M", machine])
        }
        
        if let cpu = vm.config.cpu, cpu.count > 0 {
            arguments.append(contentsOf: ["-cpu", cpu])
        }
        
        arguments.append("-smp")
        arguments.append(vm.config.cores > 0 ? "\(vm.config.cores)" : "1")
        
        if let accel = vm.config.accel {
            arguments.append(contentsOf: ["-accel", accel])
        }
        
        arguments.append(contentsOf: vm.config.arguments)
        
        var boot = vm.config.boot
        
        if architecture.isARM {
            arguments.append(contentsOf: ["-device", "qemu-xhci,id=xhci0"])
        }
        
        if let cd = vm.config.cdImage,
           FileManager.default.fileExists(atPath: cd.path) {
            
            let cdromParam = architecture.isARM ? ",if=none,id=cd0":""
            
            arguments.append("-drive")
            arguments.append("file=\(cd.path),media=cdrom\(cdromParam)")
            
            if architecture.isARM {
                arguments.append(contentsOf: ["-device", "usb-storage,drive=cd0"])
            }
            
        } else if boot == "d" { boot = "c" }
        
        arguments.append(contentsOf: ["-boot", boot])
        
        var diskCount: Int = 0
        
        vm.disks.forEach {
            
            let diskParam = architecture.isARM ? ",if=none,id=disk\(diskCount)" : ""
            
            arguments.append("-drive")
            arguments.append("file=\($0.url.path),format=\( $0.disk.format ),media=disk\(diskParam)")
            
            if architecture.isARM {
                
                arguments.append("-device")
                arguments.append("nvme,drive=disk\(diskCount),id=nvme\(diskCount),serial=\($0.url.lastPathComponent)")
            }
            
            diskCount += 1
        }
        
        vm.config.sharedFolders.forEach {
            
            arguments.append("-drive")
            
            arguments.append("file=fat\($0.kind == .floppy ? ":floppy" : ""):rw:\($0.url.path),format=raw,media=disk")
        }
        
        arguments.append(contentsOf: ["-audio", "driver=coreaudio"])
        
        if let vga = vm.config.vga {
            arguments.append(contentsOf: ["-vga", vga])
        }
        
        if vm.config.architecture.isARM {
            arguments.append(contentsOf: ["-device", "usb-tablet"])
            arguments.append(contentsOf: ["-device", "usb-kbd"])
        }
        
        if vm.config.enableUEFI,
           let firmware = vm.config.architecture.edkFirmwarePath,
           FileManager.default.fileExists(atPath: firmware) {
            
            arguments.append("-drive")
            arguments.append("if=pflash,format=raw,readonly=on,file=\(firmware)")
        }
        
        if architecture.supportsPCI {
            arguments.append(contentsOf: ["-nic", "user"])
        }
        
        arguments.append(contentsOf: ["-display", "cocoa"])
        arguments.append(contentsOf: ["-name", vm.config.title])
        
        try qemu.execute(arguments: arguments)
    }
}


extension QEMU.System {
    
    func help<T: InfoValue>(command: String, skipLines: [String] = [], skipPrefixes: [String] = []) -> [T] {
        
        let result = try? qemu.execute(arguments: ["-\(command)", "help"])
        
        guard let result  else { return [] }
        
        let lines = result.out.components(separatedBy: .newlines)
        var values: [T] = []
        
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
                values.append(.init(name: key, title: value))
                
            } else { values.append(.init(name: line)) }
        }
        
        return values
    }
}



extension QEMU.System {
    
    func help() -> [Device] {
        
        let result = try? qemu.execute(arguments: ["-device", "help"])
        
        guard let result else { return [] }
        
        let lines = result.out.components(separatedBy: .newlines)
        
        var currentCategoryName: String?
        var currentDevices:      [Device] = []
        
        for line in lines {
            
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            guard trimmedLine.isEmpty == false else { continue }
            
            guard trimmedLine.hasSuffix("devices:") == false else {
                
                let components      = trimmedLine.split(separator: " ")
                currentCategoryName = components.first.map { .init($0) }
                continue
            }
            
            let tokens = trimmedLine.split(separator: ",")
            
            var deviceName: String?
            var deviceBus: String?
            var deviceDesc: String?
            
            for token in tokens {
                
                let tokenTrimmed = token.trimmingCharacters(in: .whitespaces)
                
                if tokenTrimmed.hasPrefix("name ") {
                    
                    let value = tokenTrimmed.dropFirst("name ".count)
                    deviceName = value.trimmingCharacters(in: .init(charactersIn: "\""))
                    
                } else if tokenTrimmed.hasPrefix("bus ") {
                    
                    let value = tokenTrimmed.dropFirst("bus ".count)
                    deviceBus = value.trimmingCharacters(in: .init(charactersIn: "\""))
                    
                } else if tokenTrimmed.hasPrefix("desc ") {
                    
                    let value = tokenTrimmed.dropFirst("desc ".count)
                    deviceDesc = value.trimmingCharacters(in: .init(charactersIn: "\""))
                }
            }
            
            guard let currentCategoryName, let deviceName else { continue }
            
            currentDevices.append(.init(
                name: deviceName,
                category: currentCategoryName,
                title: deviceDesc,
                bus: deviceBus
            ))
        }
        
        return currentDevices
    }
}
