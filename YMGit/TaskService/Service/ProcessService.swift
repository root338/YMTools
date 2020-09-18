//
//  ProcessService.swift
//  YMGit
//
//  Created by apple on 2020/9/15.
//  Copyright © 2020 GML. All rights reserved.
//

import Foundation

public class ProcessService: NSObject {
    
    public typealias GMLProcessResult = Result<String, Error>
    
    func process(path: String, arguments: [String]) -> GMLProcessResult {
        let task = Process()
        task.launchPath = path
        task.arguments = arguments
        let (output, error) = task.addOutputAndError()
        task.launch()
        return handle(output: output, error: error)
    }
}

private extension ProcessService {
    
    func handle(readPipe: Pipe) -> GMLProcessResult {
        do {
            guard let readData = try readPipe.fileHandleForReading.readToEnd() else {
                return Result.failure(PipeError.readDataIsNil)
            }
            guard let result = String(data: readData, encoding: .utf8) else {
                return Result.failure(PipeError.encodingFaild)
            }
            return Result.success(result)
        } catch {
            return Result.failure(error)
        }
    }
    
    func handle(output: Pipe, error: Pipe) -> GMLProcessResult {
        
        let outputResult = handle(readPipe: output)
        switch outputResult {
        case .success(_):
            return outputResult
        case .failure(_):
            return handle(readPipe: error)
        }
    }
}
