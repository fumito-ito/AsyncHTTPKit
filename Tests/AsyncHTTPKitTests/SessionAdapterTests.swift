import Testing
import Foundation
#if os(macOS)
#elseif os(Linux)
import AsyncHTTPClient
#endif
@testable import AsyncHTTPKit

@Test("MockSessionAdapter data method basic functionality")
func mockSessionAdapterDataMethod() async throws {
    let mockData = "Hello, World!".data(using: .utf8)!
    let mockResponse = AsyncHTTPResponse(
        statusCode: 200,
        url: URL(string: "https://example.com"),
        allHeaderFields: ["Content-Type": "text/plain"]
    )
    
    let adapter = MockSessionAdapter(mockData: mockData, mockResponse: mockResponse)
    
    struct TestRequest: AsyncHTTPRequest {
        var method: AsyncHTTPMethod { .GET }
        var headers: [String: String] { [:] }
        var body: Data? { nil }
        var url: URL { URL(string: "https://example.com")! }
        var contentType: String { "application/json" }

        #if os(macOS) || os(iOS)
        func intercept(object: AsyncHTTPRequest, request: URLRequest) throws -> URLRequest {
            return request
        }
        #elseif os(Linux)
        func intercept(object: AsyncHTTPRequest, request: HTTPClientRequest) throws -> HTTPClientRequest {
            return request
        }
        #endif
    }
    
    let request = TestRequest()
    let (data, response) = try await adapter.data(for: request)
    
    #expect(data == mockData)
    #expect(response.statusCode == 200)
}

@Test("MockSessionAdapter stream method basic functionality")
func mockSessionAdapterStreamMethod() async throws {
    let mockData = "Hello, World!".data(using: .utf8)!
    let mockResponse = AsyncHTTPResponse(
        statusCode: 200,
        url: URL(string: "https://example.com"),
        allHeaderFields: ["Content-Type": "text/plain"]
    )
    
    let adapter = MockSessionAdapter(mockData: mockData, mockResponse: mockResponse)
    
    struct TestRequest: AsyncHTTPRequest {
        var method: AsyncHTTPMethod { .GET }
        var headers: [String: String] { [:] }
        var body: Data? { nil }
        var url: URL { URL(string: "https://example.com")! }
        var contentType: String { "application/json" }

        #if os(macOS) || os(iOS)
        func intercept(object: AsyncHTTPRequest, request: URLRequest) throws -> URLRequest {
            return request
        }
        #elseif os(Linux)
        func intercept(object: AsyncHTTPRequest, request: HTTPClientRequest) throws -> HTTPClientRequest {
            return request
        }
        #endif
    }
    
    let request = TestRequest()
    let (stream, response) = try await adapter.stream(for: request)
    
    var receivedData = Data()
    for try await byte in stream {
        receivedData.append(byte)
    }
    
    #expect(receivedData == mockData)
    #expect(response.statusCode == 200)
}

@Test("MockSessionAdapter error throwing")
func mockSessionAdapterErrorThrowing() async throws {
    struct TestError: Error {}
    let testError = TestError()
    
    let adapter = MockSessionAdapter(mockError: testError)
    
    struct TestRequest: AsyncHTTPRequest {
        var method: AsyncHTTPMethod { .GET }
        var headers: [String: String] { [:] }
        var body: Data? { nil }
        var url: URL { URL(string: "https://example.com")! }
        var contentType: String { "application/json" }

        #if os(macOS) || os(iOS)
        func intercept(object: AsyncHTTPRequest, request: URLRequest) throws -> URLRequest {
            return request
        }
        #elseif os(Linux)
        func intercept(object: AsyncHTTPRequest, request: HTTPClientRequest) throws -> HTTPClientRequest {
            return request
        }
        #endif
    }
    
    let request = TestRequest()
    
    await #expect(throws: TestError.self) {
        try await adapter.data(for: request)
    }
    
    await #expect(throws: TestError.self) {
        try await adapter.stream(for: request)
    }
}
