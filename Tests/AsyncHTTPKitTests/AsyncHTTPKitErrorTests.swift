import Testing
import Foundation
#if os(macOS)
#elseif os(Linux)
import AsyncHTTPClient
#endif
@testable import AsyncHTTPKit

@Test("AsyncHTTPKitError.networkRequestFailed")
func testNetworkRequestFailedError() async throws {
    struct NetworkError: Error {}
    
    try await HTTPTestCase
        .get("https://example.com")
        .returningError(NetworkError())
        .expectingError(NetworkError.self)
        .run()
}

@Test("AsyncHTTPKitError properties and error description")
func testAsyncHTTPKitErrorProperties() throws {
    struct TestRequest: AsyncHTTPRequest {
        var method: AsyncHTTPMethod { .GET }
        var headers: [String: String] { [:] }
        var body: Data? { nil }
        var url: URL { URL(string: "https://example.com/test")! }
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
    
    // Test networkRequestFailed error
    let networkError = AsyncHTTPKitError.networkRequestFailed(request: request)
    #expect(networkError.failedRequest.url == request.url)
    #expect(networkError.failedRequest.method.rawValue == "get")
    #expect(networkError.errorDescription?.contains("Network request failed") == true)
    #expect(networkError.errorDescription?.contains("get") == true)
    #expect(networkError.errorDescription?.contains("https://example.com/test") == true)
    
    // Test responseStreamEmpty error
    let streamError = AsyncHTTPKitError.responseStreamEmpty(request: request)
    #expect(streamError.failedRequest.url == request.url)
    #expect(streamError.errorDescription?.contains("Response stream contains no data") == true)
}

@Test("Error thrown during data request")
func testErrorThrownDuringDataRequest() async throws {
    struct CustomError: Error, Equatable {
        let message: String
    }
    
    try await HTTPTestCase
        .post("https://api.example.com")
        .withJSONBody("test")
        .withHeader("Content-Type", "application/json")
        .returningError(CustomError(message: "Custom network error"))
        .expectingError(CustomError.self)
        .run()
}

@Test("Error thrown during stream request")
func testErrorThrownDuringStreamRequest() async throws {
    struct StreamError: Error {}
    
    try await HTTPTestCase
        .get("https://example.com/stream")
        .returningError(StreamError())
        .expectingError(StreamError.self)
        .runStream()
}

@Test("Multiple different error types")
func testMultipleDifferentErrorTypes() async throws {
    struct NetworkTimeoutError: Error {}
    struct DNSResolutionError: Error {}
    struct SSLError: Error {}
    
    let errors: [Error] = [
        NetworkTimeoutError(),
        DNSResolutionError(),
        SSLError()
    ]
    
    for error in errors {
        try await HTTPTestCase
            .get("https://example.com")
            .returningError(error)
            .expectingError()
            .run()
    }
}
