//
//  TextCommand.swift
//  TextHandle
//
//  Created by apple on 2020/9/14.
//  Copyright © 2020 ym. All rights reserved.
//

import Cocoa

/// texthandle 命令类型
enum CommandType: String, CaseIterable {
    /// 指定文本
    case text
    /// 替换文本
    case replace
    /// 文件路径
    case file
    /// 正则匹配文本
    case regexText
}
