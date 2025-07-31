//
//  AsyncByteSequence_macOS.swift
//  AsyncHTTPKit
//
//  Created by 伊藤史 on 2025/07/30.
//
import Foundation

extension URLSession.AsyncBytes: AsyncByteSequence {
    public var byteLines: any AsyncByteLineSequence<URLSession.AsyncBytes> {
        self.lines
    }
}

extension AsyncLineSequence: AsyncByteLineSequence {
    public typealias Base = URLSession.AsyncBytes
}
