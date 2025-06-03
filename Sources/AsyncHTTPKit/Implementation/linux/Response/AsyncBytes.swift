//
//  AsyncBytes.swift
//  AsyncHTTPKit
//
//  Created by 伊藤史 on 2025/05/28.
//
import Foundation
import AsyncHTTPClient
import NIOCore
import NIOFoundationCompat

public struct AsyncBytes: AsyncSequence {
    public typealias Element = UInt8
    public typealias SourceStreamType = AsyncThrowingStream<ByteBuffer, Error>

    private let stream: SourceStreamType

    init(stream: SourceStreamType) {
        self.stream = stream
    }

    public func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator(stream: stream.makeAsyncIterator())
    }

    public struct AsyncIterator: AsyncIteratorProtocol {
        private var streamIterator: SourceStreamType.AsyncIterator
        private var currentBuffer: [UInt8] = []
        private var currentIndex: Int = 0
        init(stream: SourceStreamType.AsyncIterator) {
            self.streamIterator = stream
        }
        public mutating func next() async throws -> UInt8? {
            // 現在のバッファにまだデータがある場合はそこから取得
            if currentIndex < currentBuffer.count {
                let byte = currentBuffer[currentIndex]
                currentIndex += 1
                return byte
            }
            // 新しいバッファを取得
            guard let nextBuffer = try await streamIterator.next() else {
                return nil
            }
            // ByteBufferを[UInt8]に変換
            currentBuffer = Array(nextBuffer.readableBytesView)
            currentIndex = 0
            // 空のバッファが来た場合は次を取得
            if currentBuffer.isEmpty {
                return try await next()
            }
            // 最初のバイトを返す
            let byte = currentBuffer[currentIndex]
            currentIndex += 1
            return byte
        }
    }
}

extension AsyncBytes {
    var lines: LinesCollection {
        return LinesCollection(bytes: self)
    }
    struct LinesCollection: AsyncSequence {
        typealias Element = String
        private let bytes: AsyncBytes
        init(bytes: AsyncBytes) {
            self.bytes = bytes
        }
        func makeAsyncIterator() -> LinesIterator {
            return LinesIterator(bytes: bytes.makeAsyncIterator())
        }
        struct LinesIterator: AsyncIteratorProtocol {
            private var bytesIterator: AsyncBytes.AsyncIterator
            private var lineBuffer: [UInt8] = []
            init(bytes: AsyncBytes.AsyncIterator) {
                self.bytesIterator = bytes
            }
            mutating func next() async throws -> String? {
                while let byte = try await bytesIterator.next() {
                    // 改行文字を見つけたら行を返す
                    if byte == 10 { // LF (Line Feed)
                        // CRを取り除く（CRLF対応）
                        let line: [UInt8]
                        if lineBuffer.last == 13 { // CR (Carriage Return)
                            line = Array(lineBuffer.dropLast())
                        } else {
                            line = lineBuffer
                        }
                        // バッファをリセットして文字列を返す
                        let result = String(bytes: line, encoding: .utf8) ?? ""
                        lineBuffer = []
                        return result
                    }
                    lineBuffer.append(byte)
                }
                // ストリームの終わりに達した場合、残りのバッファを返す
                if !lineBuffer.isEmpty {
                    let result = String(bytes: lineBuffer, encoding: .utf8) ?? ""
                    lineBuffer = []
                    return result
                }
                return nil
            }
        }
    }
}
