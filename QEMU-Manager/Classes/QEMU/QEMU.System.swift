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

extension QEMU.System
{
    public static func start( vm: VirtualMachine ) throws
    {
        var arguments: [ String ] = []
        
        arguments.append( "-m" )
        arguments.append( SizeFormatter().string( from: NSNumber( value: vm.config.memory ), style: .qemu ) )
        
        if let machine = vm.config.machine, machine.count > 0
        {
            arguments.append( "-M" )
            arguments.append( machine )
        }
        
        if let cpu = vm.config.cpu, cpu.count > 0
        {
            arguments.append( "-cpu" )
            arguments.append( cpu )
        }
        
        if vm.config.cores > 0
        {
            arguments.append( "-smp" )
            arguments.append( "\( vm.config.cores )" )
        }
        else
        {
            arguments.append( "-smp" )
            arguments.append( "1" )
        }
        
        var boot = vm.config.boot
        
        if let cd = vm.config.cdImage, FileManager.default.fileExists( atPath: cd.path )
        {
            arguments.append( "-drive" )
            arguments.append( "file=\( cd.path ),media=cdrom" )
        }
        else if boot == "d"
        {
            boot = "c"
        }
        
        arguments.append( "-boot" )
        arguments.append( boot )
            
        vm.disks.forEach
        {
            arguments.append( "-drive" )
            arguments.append( "file=\( $0.url.path ),format=\( $0.disk.format ),media=disk" )
        }
        
        vm.config.sharedFolders.forEach
        {
            switch $0.kind
            {
                case .fat:
                    
                    arguments.append( "-drive" )
                    arguments.append( "file=fat:rw:\( $0.url.path ),format=raw,media=disk" )
                    
                case .floppy:
                    
                    arguments.append( "-drive" )
                    arguments.append( "file=fat:floppy:rw:\( $0.url.path ),format=raw,media=disk" )
                    
                case .smb:
                
                    arguments.append( "-smb" )
                    arguments.append( $0.url.path )
            }
        }
                
        arguments.append("-audiodev")
        arguments.append("coreaudio,id=snd0")
        
        arguments.append("-nic")
        arguments.append("user")
        
        arguments.append("-device")
        arguments.append("qemu-xhci,id=xhci")
        
        arguments.append("-device")
        arguments.append("usb-tablet")
        
        arguments.append("-device")
        arguments.append("usb-kbd")
                
        arguments.append("-device")
        arguments.append("intel-hda")
        
        arguments.append("-device")
        arguments.append("hda-duplex,audiodev=snd0")
        
        if vm.config.architecture == .aarch64 {
            arguments.append("-device")
            arguments.append("ramfb")
            
            let edk2firmware = Bundle.main.resourceURL?
                .appendingPathComponent("QEMU")
                .appendingPathComponent("share")
                .appendingPathComponent("qemu")
                .appendingPathComponent("edk2-\(vm.config.architecture.description)-code.fd")
                .absoluteURL.path(percentEncoded: false)
                    
            if let edk2firmware, FileManager.default.fileExists(atPath: edk2firmware) {
                arguments.append("-bios")
                arguments.append(edk2firmware)
            }
            
            arguments.append("-accel")
            arguments.append("hvf")
        }
        
        arguments.append("-display")
        arguments.append("cocoa")
                
        arguments.append( contentsOf: vm.config.arguments )
        
        let _ = try QEMU.System( architecture: vm.config.architecture ).execute( arguments: arguments )
    }
    
    public static func machines( for architecture: Config.Architecture ) -> [ ( String, String ) ]
    {
        return QEMU.System.help( for: architecture, command: "machine", skipLines: [ "Supported machines are:" ], skipPrefixes: [] )
    }
    
    public static func cpus( for architecture: Config.Architecture ) -> [ ( String, String ) ]
    {
        return QEMU.System.help( for: architecture, command: "cpu", skipLines: [ "Available CPUs:" ], skipPrefixes: [ "x86", "PowerPC" ] )
    }
    
    private static func help( for architecture: Config.Architecture, command: String, skipLines: [ String ], skipPrefixes: [ String ] ) -> [ ( String, String ) ]
    {
        do
        {
            let res = try QEMU.System( architecture: architecture ).execute( arguments: [ "-\( command )", "help" ] )
            
            guard let lines = res?.out.components( separatedBy: .newlines ) else
            {
                return []
            }
            
            var values: [ ( String, String ) ] = []
            
            for var line in lines
            {
                line = line.trimmingCharacters( in: .whitespaces )
                
                if skipLines.contains( line )
                {
                    continue
                }
                
                if line.count == 0
                {
                    if values.isEmpty
                    {
                        continue
                    }
                    else
                    {
                        break
                    }
                }
                
                skipPrefixes.forEach
                {
                    if line.hasPrefix( "\( $0 ) " )
                    {
                        line = String( line.dropFirst( $0.count + 1 ) )
                    }
                }
                
                do
                {
                    let regex = try NSRegularExpression( pattern: #"([^\s]+)\s+(.*)"#, options: [] )
                    
                    guard let match = regex.matches( in: line, options: [], range: NSRange( location: 0, length: line.count ) ).first else
                    {
                        values.append( ( line, line ) )
                        
                        continue
                    }
                    
                    if match.numberOfRanges != 3
                    {
                        break;
                    }
                    
                    let s1 = ( line as NSString ).substring( with: match.range( at: 1 ) )
                    let s2 = ( line as NSString ).substring( with: match.range( at: 2 ) )
                    
                    values.append( ( s1, s2 ) )
                }
                catch
                {
                    break
                }
            }
            
            return values
        }
        catch
        {
            return []
        }
    }
}
