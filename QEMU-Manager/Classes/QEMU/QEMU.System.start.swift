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
            
        if !vm.config.extra.defaults {
            arguments += ["-nodefaults"]
        }
        
        arguments.append("-m")
        arguments.append(SizeFormatter().string(from: NSNumber(value: vm.config.system.memory), style: .qemu))
        
        if let machine = vm.config.system.machine, machine.count > 0 {
            
            var machineParams = [ machine ]
            
            if let params = vm.config.system.params, params.count > 0 {
                machineParams.append(params)
            }
            
            arguments += ["-M", machineParams.joined(separator: ",")]
        }
        
        if let cpu = vm.config.system.cpu, cpu.count > 0 {
            arguments += ["-cpu", cpu]
        }
        
        if vm.config.system.cores > 0 {
            arguments += ["-smp", vm.config.system.cores.description]
        }
        
        if let accel = vm.config.extra.accel {
            arguments += ["-accel", accel]
        }
        
        if vm.config.extra.localtime {
            arguments += ["-rtc", "base=localtime"]
        }
        
        if let bios = vm.config.system.bios {
            arguments += ["-bios", bios.path]
        }
        
        if let kernel = vm.config.boot.kernel {
            arguments += ["-kernel", kernel.path]
            
            if let kernelAppend = vm.config.boot.append {
                arguments += ["-append", kernelAppend]
            }
            
            if let initrd = vm.config.boot.initrd {
                arguments += ["-initrd", initrd.path]
            }
        }
        
        if let dbt = vm.config.system.dbt {
            arguments += ["-dbt", dbt.path]
        }
        
        if vm.config.extra.rng {
            arguments += ["-device", "virtio-rng-pci"]
        }
        
        if vm.config.extra.balloon {
            arguments += ["-device", "virtio-balloon-pci"]
        }
        
        if let ctrl = vm.config.peripherals.usbctrl {
            arguments += ["-device", ctrl + ",id=usb0"]
        }
        
        if vm.config.peripherals.usbdevs {
            arguments += ["-device", "usb-kbd,bus=usb0.0",
                          "-device", "usb-tablet,bus=usb0.0"]
        }
        
        if let video = vm.config.peripherals.video {
            arguments += ["-vga", "none", "-device", video]
        }
        
        if let sound = vm.config.peripherals.sound {
            arguments += ["-device", sound]
            
            if sound.contains("hda") { arguments += ["-device", "hda-duplex"] }
        }
        
        if vm.config.peripherals.usernic,
           let network = vm.config.peripherals.network {
            
            arguments += ["-nic", "user,model=" + network]
            
        } else if vm.config.peripherals.usernic { arguments += ["-nic", "user"] }
        
        if vm.config.system.uefi, architecture.supportsUEFI,
           let firmwarePath = vm.config.architecture.edkFirmwarePath {
            
            arguments += ["-drive", "if=pflash,format=raw,readonly=on,file=" + firmwarePath]
        }
        
        arguments += ["-audio",   "driver=coreaudio"]
        arguments += ["-display", "cocoa"]
        arguments += ["-name",    vm.config.title]
        arguments += vm.config.arguments
        arguments += ["-boot", vm.config.boot.priority.description]
                
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
