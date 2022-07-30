// debugLog.swift
//
// Created by Bob Wakefield on 7/30/22.
// for TestPivoSDK
//
// Using Swift 5.0
// Running on macOS 12.5
//
// 
//

import Foundation

func debugLog(_ message: String) {

    #if DEBUG
    print(message)
    #endif
}
