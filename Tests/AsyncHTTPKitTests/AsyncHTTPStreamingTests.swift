import Testing
import Foundation
#if os(macOS) || os(iOS)
#elseif os(Linux)
import AsyncHTTPClient
#endif
@testable import AsyncHTTPKit

@Test("Basic streaming functionality")
func testBasicStreaming() async throws {
    try await HTTPTestCase
        .get("https://example.com/stream")
        .returningText("This is streaming test data")
        .returningStatus(200)
        .returningHeaders(["Content-Type": "text/plain"])
        .expectingStatus(200)
        .expectingText("This is streaming test data")
        .runStream()
}

@Test("Empty stream")
func testEmptyStream() async throws {
    try await HTTPTestCase
        .get("https://example.com/empty")
        .returningData(Data())
        .returningStatus(204)
        .expectingStatus(204)
        .expectingData(Data())
        .runStream()
}

@Test("Large data streaming")
func testLargeDataStreaming() async throws {
    // Create a large test data (10KB)
    let largeData = TestData.binary(size: 10240)
    
    try await HTTPTestCase
        .get("https://example.com/large")
        .returningData(largeData)
        .returningStatus(200)
        .returningHeaders(["Content-Length": "10240"])
        .expectingStatus(200)
        .expectingData(largeData)
        .runStream()
}

@Test("Stream with different content types")
func testStreamWithDifferentContentTypes() async throws {
    let jsonData = """
    {
        "message": "Hello, streaming JSON!",
        "timestamp": "2025-06-04T08:00:00Z"
    }
    """
    
    try await HTTPTestCase
        .get("https://api.example.com/stream")
        .withHeader("Accept", "application/json")
        .returningJSON(jsonData)
        .returningStatus(200)
        .returningHeaders(["Content-Type": "application/json"])
        .expectingStatus(200)
        .expectingJSON(jsonData)
        .expectingHeader("Content-Type", "application/json")
        .runStream()
}

@Test("Stream error handling")
func testStreamErrorHandling() async throws {
    struct StreamError: Error {}
    
    try await HTTPTestCase
        .get("https://example.com/error")
        .returningError(StreamError())
        .expectingError(StreamError.self)
        .runStream()
}

@Test("Stream byte-by-byte reading")
func testStreamByteByByteReading() async throws {
    let testData = TestData.text("Hello")
    
    try await HTTPTestCase
        .get("https://example.com/bytes")
        .returningData(testData)
        .returningStatus(200)
        .returningHeaders(["Content-Type": "application/octet-stream"])
        .expectingStatus(200)
        .expectingData(testData)
        .runStream()
}