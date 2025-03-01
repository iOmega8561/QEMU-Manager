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
    
    enum QEMUError: Swift.Error {
        case launchFailure(status: Int, message: String)
        case executableDirectoryNotAvailable
        case executableNotAvailable(executableName: String)
    }

    let executableName: String
    
    private var executableDirectoryURL: URL? {
        Bundle.main.resourceURL?
            .appendingPathComponent("QEMU")
            .appendingPathComponent("bin")
    }
    
    private var executableURL:  URL? {
        executableDirectoryURL?.appendingPathComponent(executableName)
    }
    
    private func checkExecutableAvailability() throws {
        
        guard executableDirectoryURL != nil else {
            throw QEMUError.executableDirectoryNotAvailable
        }
        
        guard let executableURL,
              FileManager.default.fileExists(
                atPath: executableURL.absoluteURL.path
        ) else {
            
            throw QEMUError.executableNotAvailable(
                executableName: executableName
            )
        }
    }
    
    @discardableResult
    func execute(arguments: [String]) throws -> (out: String, err: String)? {
        
        try checkExecutableAvailability()
        
        let out                     = Pipe()
        let err                     = Pipe()
        let process                 = Process()
        process.executableURL       = executableURL
        process.currentDirectoryURL = executableDirectoryURL
        process.arguments           = arguments
        process.standardOutput      = out
        process.standardError       = err
        
        try ObjC.catchException {
            process.launch()
            process.waitUntilExit()
        }
        
        let dataOut = try? out.fileHandleForReading.readToEnd()
        let dataErr = try? err.fileHandleForReading.readToEnd()
        let strOut  = String( data: dataOut ?? Data(), encoding: .utf8 ) ?? ""
        let strErr  = String( data: dataErr ?? Data(), encoding: .utf8 ) ?? ""
        
        if process.terminationStatus != 0 {
            
            throw QEMUError.launchFailure(
                status: Int( process.terminationStatus ),
                message: strErr
            )
        }
        
        return (out: strOut, err: strErr)
    }
}
