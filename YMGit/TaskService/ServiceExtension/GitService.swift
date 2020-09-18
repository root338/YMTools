//
//  GitService.swift
//  YMGit
//
//  Created by apple on 2020/9/16.
//  Copyright © 2020 GML. All rights reserved.
//

import Foundation

public extension ProcessService {
    /// 调用 /usr/bin/git 下的 git
    /// - Parameter command: 执行的命令，不需要前边追加 git
    func git(_ command: String) -> GMLProcessResult {
        return shell(command)
    }
}
