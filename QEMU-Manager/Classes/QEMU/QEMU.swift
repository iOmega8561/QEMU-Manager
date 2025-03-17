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

struct QEMU {

    static var rootDirectoryURL: URL? {
        Bundle.main.resourceURL?
            .appendingPathComponent("QEMU")
    }
    
    let executableName: String
    
    private var executableURL:  URL? {
        QEMU.rootDirectoryURL?
            .appendingPathComponent("bin")
            .appendingPathComponent(executableName)
    }
    
    @discardableResult
    func execute(arguments: [String]) throws -> (out: String, err: String)? {
        
        guard let executableURL,
             FileManager.default.fileExists(atPath: executableURL.absoluteURL.path) else {
            
            throw Error.executableNotAvailable(executableName: executableName)
        }
        
        let out                     = Pipe()
        let err                     = Pipe()
        let process                 = Process()
        process.executableURL       = executableURL
        process.currentDirectoryURL = QEMU.rootDirectoryURL
        process.arguments           = arguments
        process.standardOutput      = out
        process.standardError       = err
        
        try process.run()
        process.waitUntilExit()
        
        let dataOut = try? out.fileHandleForReading.readToEnd()
        let dataErr = try? err.fileHandleForReading.readToEnd()
        let strOut  = String(data: dataOut ?? Data(), encoding: .utf8) ?? ""
        let strErr  = String(data: dataErr ?? Data(), encoding: .utf8) ?? ""
        
        guard process.terminationStatus == 0 else {
            
            throw Error.launchFailure(
                status: .init(process.terminationStatus),
                message: strErr
            )
        }
        
        return (out: strOut, err: strErr)
    }
}
