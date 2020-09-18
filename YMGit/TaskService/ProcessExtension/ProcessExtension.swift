//
//  ProcessExtension.swift
//  YMGit
//
//  Created by apple on 2020/9/15.
//  Copyright © 2020 GML. All rights reserved.
//

import Foundation

extension Process {
    func addOutputAndError() -> (output: Pipe, error: Pipe) {
        let output = Pipe()
        self.standardOutput = output
        let error = Pipe()
        self.standardError = error
        return (output, error)
    }
}
