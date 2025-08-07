//
//  AsyncByteLineSequence.swift
//  AsyncHTTPKit
//
//  Created by 伊藤史 on 2025/08/01.
//

public struct AsyncByteLineSequence: AsyncSequence, Sendable {
    public typealias Element = String
    
    private let _makeAsyncIterator: @Sendable () -> AsyncIterator
    
    public init<Wrapped: AsyncSequence>(_ wrapped: Wrapped) where Wrapped.Element == String, Wrapped: Sendable {
        self._makeAsyncIterator = { AsyncIterator(wrapped.makeAsyncIterator()) }
    }
    
    public func makeAsyncIterator() -> AsyncIterator {
        _makeAsyncIterator()
    }
    
    public struct AsyncIterator: AsyncIteratorProtocol {
        private var wrappedIterator: any AsyncIteratorProtocol
        
        init<Wrapped: AsyncIteratorProtocol>(_ wrapped: Wrapped) where Wrapped.Element == String {
            self.wrappedIterator = wrapped
        }
        
        public mutating func next() async throws -> String? {
            try await wrappedIterator.next() as? String
        }
    }
}
