import Testing
import Foundation
import AsyncHTTPClient
@testable import AsyncHTTPKit

@Test("Basic streaming functionality")
func testBasicStreaming() async throws {
    let testData = "This is streaming test data".data(using: .utf8)!
    let mockResponse = AsyncHTTPResponse(
        statusCode: 200,
        url: URL(string: "https://example.com"),
        allHeaderFields: ["Content-Type": "text/plain"]
    )
    
    let adapter = MockSessionAdapter(mockData: testData, mockResponse: mockResponse)
    let httpKit = AsyncHTTPKit(adapter: adapter)
    
    struct StreamRequest: AsyncHTTPRequest {
        var method: AsyncHTTPMethod { .GET }
        var headers: [String: String] { [:] }
        var body: Data? { nil }
        var url: URL { URL(string: "https://example.com/stream")! }
        var contentType: String { "application/json" }

        func intercept(object: AsyncHTTPRequest, request: HTTPClientRequest) throws -> HTTPClientRequest {
            return request
        }
    }
    
    let request = StreamRequest()
    let (stream, response) = try await httpKit.bytes(for: request)
    
    var receivedData = Data()
    for try await byte in stream {
        receivedData.append(byte)
    }
    
    #expect(receivedData == testData)
    #expect(response.statusCode == 200)
}

@Test("Empty stream")
func testEmptyStream() async throws {
    let emptyData = Data()
    let mockResponse = AsyncHTTPResponse(
        statusCode: 204,
        url: URL(string: "https://example.com"),
        allHeaderFields: [:]
    )
    
    let adapter = MockSessionAdapter(mockData: emptyData, mockResponse: mockResponse)
    let httpKit = AsyncHTTPKit(adapter: adapter)
    
    struct EmptyStreamRequest: AsyncHTTPRequest {
        var method: AsyncHTTPMethod { .GET }
        var headers: [String: String] { [:] }
        var body: Data? { nil }
        var url: URL { URL(string: "https://example.com/empty")! }
        var contentType: String { "application/json" }

        func intercept(object: AsyncHTTPRequest, request: HTTPClientRequest) throws -> HTTPClientRequest {
            return request
        }
    }
    
    let request = EmptyStreamRequest()
    let (stream, response) = try await httpKit.bytes(for: request)
    
    var receivedData = Data()
    for try await byte in stream {
        receivedData.append(byte)
    }
    
    #expect(receivedData.isEmpty)
    #expect(response.statusCode == 204)
}

@Test("Large data streaming")
func testLargeDataStreaming() async throws {
    // Create a large test data (10KB)
    let largeData = Data(repeating: 0x42, count: 10240)
    let mockResponse = AsyncHTTPResponse(
        statusCode: 200,
        url: URL(string: "https://example.com"),
        allHeaderFields: ["Content-Length": "10240"]
    )
    
    let adapter = MockSessionAdapter(mockData: largeData, mockResponse: mockResponse)
    let httpKit = AsyncHTTPKit(adapter: adapter)
    
    struct LargeStreamRequest: AsyncHTTPRequest {
        var method: AsyncHTTPMethod { .GET }
        var headers: [String: String] { [:] }
        var body: Data? { nil }
        var url: URL { URL(string: "https://example.com/large")! }
        var contentType: String { "application/json" }

        func intercept(object: AsyncHTTPRequest, request: HTTPClientRequest) throws -> HTTPClientRequest {
            return request
        }
    }
    
    let request = LargeStreamRequest()
    let (stream, response) = try await httpKit.bytes(for: request)
    
    var receivedData = Data()
    var byteCount = 0
    for try await byte in stream {
        receivedData.append(byte)
        byteCount += 1
    }
    
    #expect(receivedData == largeData)
    #expect(byteCount == 10240)
    #expect(response.statusCode == 200)
}

@Test("Stream with different content types")
func testStreamWithDifferentContentTypes() async throws {
    let jsonData = """
    {
        "message": "Hello, streaming JSON!",
        "timestamp": "2025-06-04T08:00:00Z"
    }
    """.data(using: .utf8)!
    
    let mockResponse = AsyncHTTPResponse(
        statusCode: 200,
        url: URL(string: "https://api.example.com"),
        allHeaderFields: ["Content-Type": "application/json"]
    )
    
    let adapter = MockSessionAdapter(mockData: jsonData, mockResponse: mockResponse)
    let httpKit = AsyncHTTPKit(adapter: adapter)
    
    struct JSONStreamRequest: AsyncHTTPRequest {
        var method: AsyncHTTPMethod { .GET }
        var headers: [String: String] { ["Accept": "application/json"] }
        var body: Data? { nil }
        var url: URL { URL(string: "https://api.example.com/stream")! }
        var contentType: String { "application/json" }

        func intercept(object: AsyncHTTPRequest, request: HTTPClientRequest) throws -> HTTPClientRequest {
            return request
        }
    }
    
    let request = JSONStreamRequest()
    let (stream, response) = try await httpKit.bytes(for: request)
    
    var receivedData = Data()
    for try await byte in stream {
        receivedData.append(byte)
    }
    
    #expect(receivedData == jsonData)
    #expect(response.statusCode == 200)
    #expect(response.allHeaderFields["Content-Type"] == "application/json")
}

@Test("Stream error handling")
func testStreamErrorHandling() async throws {
    struct StreamError: Error {}
    let streamError = StreamError()
    
    let adapter = MockSessionAdapter(mockError: streamError)
    let httpKit = AsyncHTTPKit(adapter: adapter)
    
    struct ErrorStreamRequest: AsyncHTTPRequest {
        var method: AsyncHTTPMethod { .GET }
        var headers: [String: String] { [:] }
        var body: Data? { nil }
        var url: URL { URL(string: "https://example.com/error")! }
        var contentType: String { "application/json" }

        func intercept(object: AsyncHTTPRequest, request: HTTPClientRequest) throws -> HTTPClientRequest {
            return request
        }
    }
    
    let request = ErrorStreamRequest()
    
    await #expect(throws: StreamError.self) {
        try await httpKit.bytes(for: request)
    }
}

@Test("Stream byte-by-byte reading")
func testStreamByteByByteReading() async throws {
    let testBytes: [UInt8] = [0x48, 0x65, 0x6C, 0x6C, 0x6F] // "Hello"
    let testData = Data(testBytes)
    let mockResponse = AsyncHTTPResponse(
        statusCode: 200,
        url: URL(string: "https://example.com"),
        allHeaderFields: ["Content-Type": "application/octet-stream"]
    )
    
    let adapter = MockSessionAdapter(mockData: testData, mockResponse: mockResponse)
    let httpKit = AsyncHTTPKit(adapter: adapter)
    
    struct ByteStreamRequest: AsyncHTTPRequest {
        var method: AsyncHTTPMethod { .GET }
        var headers: [String: String] { [:] }
        var body: Data? { nil }
        var url: URL { URL(string: "https://example.com/bytes")! }
        var contentType: String { "application/json" }

        func intercept(object: AsyncHTTPRequest, request: HTTPClientRequest) throws -> HTTPClientRequest {
            return request
        }
    }
    
    let request = ByteStreamRequest()
    let (stream, response) = try await httpKit.bytes(for: request)
    
    var receivedBytes: [UInt8] = []
    for try await byte in stream {
        receivedBytes.append(byte)
    }
    
    #expect(receivedBytes == testBytes)
    #expect(response.statusCode == 200)
    #expect(String(data: Data(receivedBytes), encoding: .utf8) == "Hello")
}