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
            
        if !vm.config.tweaks.defaults {
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
        
        if let accel = vm.config.tweaks.accel {
            arguments += ["-accel", accel]
        }
        
        if vm.config.tweaks.localtime {
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
        
        if vm.config.tweaks.rng {
            arguments += ["-device", "virtio-rng-pci"]
        }
        
        if vm.config.tweaks.balloon {
            arguments += ["-device", "virtio-balloon-pci"]
        }
        
        if let ctrl = vm.config.usbDev {
            arguments += ["-device", ctrl + ",id=usb0"]
        }
        
        if vm.config.usbInput {
            arguments += ["-device", "usb-kbd,bus=usb0.0",
                          "-device", "usb-tablet,bus=usb0.0"]
        }
        
        if let video = vm.config.videoDev {
            arguments += ["-vga", "none", "-device", video]
        }
        
        if let sound = vm.config.soundDev {
            arguments += ["-device", sound]
            
            if sound.contains("hda") { arguments += ["-device", "hda-duplex"] }
        }
        
        if let network = vm.config.network.controller {
            arguments += ["-device", network +
                                     ",mac=\(vm.config.network.macAddress)" +
                                     ",netdev=net0"]
        }
        
        switch vm.config.network.kind {
        case .host:   arguments += ["-netdev", "user,restrict=yes,id=net0"]
        case .shared: arguments += ["-netdev", "user,id=net0"]
        }
        
        if vm.config.system.uefi, architecture.supportsUEFI {
            
            arguments += ["-drive", "if=pflash,format=raw,readonly=on,file="
                          + architecture.edkFirmwarePath]
        }
        
        arguments += ["-audio",   "driver=coreaudio"]
        arguments += ["-display", "cocoa"]
        arguments += ["-name",    vm.config.title]
        arguments += ["-boot",    vm.config.boot.priority.description]
        
        arguments += vm.config.arguments
                
        vm.disks.forEach { diskDrive in
                        
            var driveParams = [
                "file="   + diskDrive.url.path,
                "format=" + diskDrive.disk.format.description,
                "media="  + diskDrive.disk.type.description,
                "id="     + diskDrive.id
            ]
            
            if !diskDrive.disk.auto {
                driveParams.append("if=none")
            }
            
            arguments += ["-drive", driveParams.joined(separator: ",")]
        }
        
        vm.config.shares.forEach { share in
                        
            let shareParams = [
                "file=" + share.kind.description + ":rw:" + share.url.path,
                "format=raw",
                "media=disk"
            ]
            
            arguments += ["-drive", shareParams.joined(separator: ",")]
        }
        
        try qemu.execute(arguments: arguments)
    }
}
