//
//  ShellService.swift
//  YMGit
//
//  Created by apple on 2020/9/16.
//  Copyright © 2020 GML. All rights reserved.
//

import Foundation

public extension ProcessService {
    func shell(_ command: String) -> GMLProcessResult {
        return process(path: "/bin/bash", arguments: [
            "-c",
            command
        ])
    }
}
