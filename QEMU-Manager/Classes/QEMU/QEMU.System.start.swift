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

extension QEMU.System {
    
    func start(vm: VirtualMachine) throws {
        
        var arguments: [String] = []
        
        arguments.append("-m")
        arguments.append(SizeFormatter().string(from: NSNumber(value: vm.config.memory), style: .qemu))
        
        if let machine = vm.config.machine, machine.count > 0 {
            arguments += ["-M", machine]
        }
        
        if let cpu = vm.config.cpu, cpu.count > 0 {
            arguments += ["-cpu", cpu]
        }
        
        if let vga = vm.config.vga {
            arguments += ["-vga", vga]
        }
        
        if vm.config.cores > 0 {
            arguments += ["-smp", vm.config.cores.description]
        }
        
        if let accel = vm.config.emulation.accel {
            arguments += ["-accel", accel]
        }
        
        if let bios = vm.config.emulation.bios {
            arguments += ["-bios", bios.path]
        }
        
        if let kernel = vm.config.emulation.kernel {
            arguments += ["-kernel", kernel.path]
        }
        
        if let kernelAppend = vm.config.emulation.append {
            arguments += ["-append", kernelAppend]
        }
        
        if let initrd = vm.config.emulation.initrd {
            arguments += ["-initrd", initrd.path]
        }
        
        if let dbt = vm.config.emulation.dbt {
            arguments += ["-accel", dbt.path]
        }
        
        if vm.config.emulation.rng {
            arguments += ["-device", "virtio-rng-pci"]
        }
        
        if vm.config.emulation.balloon {
            arguments += ["-device", "virtio-balloon-pci"]
        }
        
        if vm.config.emulation.ehci {
            arguments += ["-device", "usb-ehci",
                          "-device", "usb-kbd",
                          "-device", "usb-tablet"]
        }
        
        if vm.config.emulation.uefi, architecture.supportsUEFI,
           let firmwarePath = vm.config.architecture.edkFirmwarePath {
            
            arguments += ["-drive", "if=pflash,format=raw,readonly=on,file=" + firmwarePath]
        }
        
        arguments += ["-audio",   "driver=coreaudio"]
        arguments += ["-nic",     "user"]
        arguments += ["-display", "cocoa"]
        arguments += ["-name",    vm.config.title]
        arguments += vm.config.arguments
        arguments += ["-boot", vm.config.boot]
                
        vm.disks.forEach { diskDrive in
                        
            var driveParams = [
                "file="   + diskDrive.url.path,
                "format=" + diskDrive.disk.format.description,
                "media="  + diskDrive.disk.type.description,
                "id="     + diskDrive.disk.uuid.uuidString
            ]
            
            if !diskDrive.disk.auto {
                driveParams.append("if=none")
            }
            
            arguments += ["-drive", driveParams.joined(separator: ",")]
        }
        
        vm.config.sharedFolders.forEach { dirShare in
                        
            let shareParams = [
                "file=" + dirShare.kind.description + ":rw:" + dirShare.url.path,
                "format=raw",
                "media=disk"
            ]
            
            arguments += ["-drive", shareParams.joined(separator: ",")]
        }
        
        try qemu.execute(arguments: arguments)
    }
}
