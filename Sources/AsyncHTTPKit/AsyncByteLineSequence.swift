//
//  AsyncByteLineSequence.swift
//  AsyncHTTPKit
//
//  Created by 伊藤史 on 2025/08/01.
//

public protocol AsyncByteLineSequence<Base>: AsyncSequence where Element == String {
    associatedtype Base: AsyncSequence where Base.Element == UInt8
    func makeAsyncIterator() -> Self.AsyncIterator
}
