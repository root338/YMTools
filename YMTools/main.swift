//
//  main.swift
//  YMTools
//
//  Created by apple on 2020/9/11.
//  Copyright © 2020 ym. All rights reserved.
//

import Foundation

let args = CommandLine.arguments
var mStr = "您输入的内容如下：\n"
for value in args {
    mStr.append(value)
    mStr.append("\n")
}

let folderURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).last
let writeToURL = folderURL!.appendingPathComponent("test.txt")
try mStr.write(to: writeToURL, atomically: true, encoding: .utf8)

