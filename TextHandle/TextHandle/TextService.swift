//
//  TextService.swift
//  TextHandle
//
//  Created by apple on 2020/9/14.
//  Copyright © 2020 ym. All rights reserved.
//

import Cocoa

class TextService: NSObject {
    
    var inputInfo: InputInfo
    
    init(inputInfo: InputInfo) {
        self.inputInfo = inputInfo
        super.init()
    }
    
    func handleCommend() throws {
        
        for commandItem in inputInfo.commendContent {
            guard
                let key = commandItem.key,
                let type = CommandType(rawValue: key) else {
                continue
            }
            switch type {
            case .replace:
                try replace(item: commandItem)
            default:
                continue
            }
        }
        
    }
    
    func replace(item: CommendItem) throws {
        
        func stringValue(type: CommandType) throws -> String {
            return try value(type: type, item: commandItem(type: type))
        }
        
        let file = try stringValue(type: .file)
        let (replaceType, mText) = try text()
        let replace = try value(type: .replace, item: item)
        
        let fileURL = URL(fileURLWithPath: file)
        let fileContent = try String(contentsOf: fileURL)
        let result: String
        if replaceType == .text {
            result = fileContent.replacingOccurrences(of: mText, with: replace)
        }else {
            let regularExpression = try NSRegularExpression(pattern: mText, options: NSRegularExpression.Options(rawValue: 0))
            result = regularExpression.stringByReplacingMatches(in: fileContent, options: .reportCompletion, range: NSRange(location: 0, length: fileContent.count), withTemplate: replace)
        }
        
        try result.write(to: fileURL, atomically: true, encoding: .utf8)
    }
    
    
}

private extension TextService {
    
    func value(type: CommandType, item: CommendItem) throws -> String {
        guard
            let value = item.value
            else {
                throw TextError.inputError(msg: errorMsg(type: type))
        }
        if type == .file && !FileManager.default.fileExists(atPath: value) {
            throw TextError.inputError(msg: "输入的文件路径不存在")
        }
        return value
    }
    
    func commandItem(type: CommandType) throws -> CommendItem {
        for item in inputInfo.commendContent {
            guard
                let key = item.key,
                let commandType = CommandType(rawValue: key) else {
                continue
            }
            if type == commandType {
                return item
            }
        }
        throw TextError.noType(msg: errorMsg(type: type))
    }
    
    func errorMsg(type: CommandType) -> String {
        switch type {
        case .text:
            return "没有输入文本"
        case .replace:
            return "没有输入替换文本"
        case .file:
            return "没有指定文件路径"
        case .regexText:
            return "没有正则表达式"
        }
    }
    
    func text() throws -> (type: CommandType, text: String) {
        var textType = CommandType.text
        if let text = try? value(type: textType, item: commandItem(type: textType)) {
            return (textType, text)
        }
        textType = .regexText
        do {
            let text = try value(type: textType, item: commandItem(type: textType))
            return (textType, text)
        }
        catch {
            throw TextError.inputError(msg: "没有指定需要替换的文本")
        }
    }
}
