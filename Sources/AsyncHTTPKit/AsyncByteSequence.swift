//
//  AsyncByteSequence.swift
//  AsyncHTTPKit
//
//  Created by 伊藤史 on 2025/07/30.
//
import Foundation

public protocol AsyncByteSequence: AsyncSequence<UInt8, Error>, Sendable {
    var lines: AsyncLineSequence<Self> { get }
}
