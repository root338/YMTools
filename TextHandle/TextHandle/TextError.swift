//
//  TextError.swift
//  TextHandle
//
//  Created by apple on 2020/9/14.
//  Copyright © 2020 ym. All rights reserved.
//

import Cocoa

enum TextError: Error {
    case isEmpty
    case noAction
    case noType(msg: String)
    case inputError(msg: String)
}


