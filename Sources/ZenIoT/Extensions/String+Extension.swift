//
//  String+Extension.swift
//  
//
//  Created by Gerardo Grisolini on 22/11/20.
//

import Foundation

extension String {
    
    public func shell(arguments: [String] = []) -> String? {
        let envs = ["/bin", "/sbin", "/usr/sbin", "/usr/bin", "/usr/local/bin"]
        let fileManager = FileManager.default
        var launchPath = self
        if launchPath.first != "/" {
            for env in envs {
                let path = "\(env)/\(launchPath)"
                if fileManager.fileExists(atPath: path) {
                    launchPath = path
                }
            }
        }
        if launchPath.first != "/" {
            return nil
        }
        
        //print("shell: \(launchPath) \(arguments.joined(separator: " "))")
        if !fileManager.fileExists(atPath: launchPath) {
            return nil
        }
        
        let task = Process()
        task.executableURL = URL(fileURLWithPath: launchPath)
        task.arguments = arguments
        let pipe = Pipe()
        task.standardOutput = pipe
        do { try task.run() } catch { return nil }
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
            return output
        }
        
        return ""
    }
}
