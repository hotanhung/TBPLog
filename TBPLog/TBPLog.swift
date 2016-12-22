//
//  TBPLog.swift
//  TBPLog
//
//  Created by Macintosh on 12/21/16.
//  Copyright © 2016 Bigavu. All rights reserved.
//

import Foundation

public enum LogLevel: UInt {
    case error = 0
    case warning
    case info
    case debug
}

public class TBPLog {
    
    public var maxFileSize: UInt64 = 1024
    
    public var name = "Log.txt"
    
    public var minLevel: LogLevel = .error
    public static let log : TBPLog = {
        let instance = TBPLog()
        return instance
    }()

    //the date formatter
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .medium
        return formatter
    }
    
    public func write(text: String) {
        
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: self.defaultDirectory()) {
            do {
                try "".write(toFile: self.defaultDirectory(), atomically: true, encoding: String.Encoding.utf8)
            } catch _ {
            }
        }
        if let fileHandle = FileHandle(forWritingAtPath: self.defaultDirectory()) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(text.data(using: String.Encoding.utf8)!)
            fileHandle.closeFile()
            NSLog("%@", text)
        }
    }
    
    func fileSize() -> UInt64 {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: self.defaultDirectory()) {
            return 0
        }
        let attrs: NSDictionary? = try! fileManager.attributesOfItem(atPath: self.defaultDirectory()) as NSDictionary?
        if let dict = attrs {
            return dict.fileSize()
        }
        return 0
    }
    
    ///remove file if file.size > maxsize
    public func removeLogFileIfNeeded() {
        if fileSize() > maxFileSize*1024 {
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(atPath: self.defaultDirectory())
            } catch _ {
            }
            
        }
    }
    
    ///get the default log directory
    func defaultDirectory() -> String {
        let cachesDirectories = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as [String]
        let cachesDirectory = cachesDirectories[0]
        let url = cachesDirectory.appending("/\(name)")
        return url
    }
    
    func printLog(_ text: String, logLevel: String, file: String = #file, funcName: String = #function, line: Int = #line) {
        let dateStr = self.dateFormatter.string(from: Date())
        let lastPath = NSString.init(string: file)
        let writeText = "[\(dateStr)] [\(logLevel)] \(lastPath.lastPathComponent):\(line) \(text)\n"
        self.write(text: writeText)
    }
}

// using log mode debug
public func logDebug(_ text: String, file: String = #file, funcName: String = #function, line: Int = #line) {
    if TBPLog.log.minLevel.rawValue >= 3 {
        TBPLog.log.printLog(text, logLevel: "DEBUG", file: file, funcName: funcName, line: line)
    }
}

// using log mode error
public func logError(_ text: String, file: String = #file, funcName: String = #function, line: Int = #line) {
    if TBPLog.log.minLevel.rawValue >= 0 {
        TBPLog.log.printLog(text, logLevel: "ERROR", file: file, funcName: funcName, line: line)
    }
}

public func logInfo(_ text: String, file: String = #file, funcName: String = #function, line: Int = #line) {
    if TBPLog.log.minLevel.rawValue >= 2 {
        TBPLog.log.printLog(text, logLevel: "INFO", file: file, funcName: funcName, line: line)
    }
}

public func logWarning(_ text: String, file: String = #file, funcName: String = #function, line: Int = #line) {
    if TBPLog.log.minLevel.rawValue >= 1 {
        TBPLog.log.printLog(text, logLevel: "WARNING", file: file, funcName: funcName, line: line)
    }
}

