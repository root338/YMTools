//
//  main.swift
//  YMGit
//
//  Created by apple on 2020/9/15.
//  Copyright © 2020 GML. All rights reserved.
//

import Foundation

func git(_ command: String) {
    let result = ProcessService().git(command)
    switch result {
    case .success(let msg):
        print(msg)
    case .failure(let err):
        print(err.localizedDescription)
    }
}

func shell(_ command: String) {
    let result = ProcessService().shell(command)
    switch result {
    case .success(let msg):
        print(msg)
    case .failure(let err):
        print(err.localizedDescription)
    }
}

let targetPath = "/Users/apple/dev/yuemeiProject/YMMainApp"

shell("""
cd \(targetPath)
""")

//git("""
//git init
//""")

//git("""
//git branch -v
//""")


//shell("""
//pwd
//""")
