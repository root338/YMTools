//
//  main.swift
//  TextHandle
//
//  Created by apple on 2020/9/14.
//  Copyright © 2020 ym. All rights reserved.
//

import Foundation

do {
    let arguments = CommandLine.arguments
    if arguments.count <= 1 {
        throw TextError.isEmpty
    }
    let inputInfo = try ParserService().arguments(arguments)
    try TextService(inputInfo: inputInfo).handleCommend()
}
catch let error as TextError {
    let errorText: String
    switch error {
    case .noAction:
        errorText = "没有可执行的命令"
    case .noType(msg: let msg):
        fallthrough
    case .inputError(msg: let msg):
        errorText = msg
    case .isEmpty:
        errorText = "请输入内容"
    }
    print(errorText)
}
catch {
    print(error.localizedDescription)
    exit(1)
}

