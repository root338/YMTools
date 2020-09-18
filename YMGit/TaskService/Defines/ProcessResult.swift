//
//  ProcessResult.swift
//  YMGit
//
//  Created by apple on 2020/9/15.
//  Copyright © 2020 GML. All rights reserved.
//

import Cocoa

public enum ShellError: Error {
    case error(msg: String)
}
public enum PipeError: Error {
    case readDataIsNil
    case encodingFaild
}
