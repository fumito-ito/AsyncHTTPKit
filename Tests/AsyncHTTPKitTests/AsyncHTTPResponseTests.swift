import Testing
import Foundation
#if os(macOS)
#elseif os(Linux)
import AsyncHTTPClient
#endif
@testable import AsyncHTTPKit

@Test("200 OK response handling")
func test200OKResponse() async throws {
    try await HTTPTestCase
        .get("https://example.com")
        .returningText("Success response")
        .returningStatus(200)
        .returningHeaders(["Content-Type": "text/plain", "Content-Length": "16"])
        .expectingStatus(200)
        .expectingText("Success response")
        .expectingHeader("Content-Type", "text/plain")
        .expectingHeader("Content-Length", "16")
        .run()
}

@Test("201 Created response handling")
func test201CreatedResponse() async throws {
    let responseJSON = """
    {
        "id": 123,
        "message": "Resource created successfully"
    }
    """
    
    try await HTTPTestCase
        .post("https://api.example.com/resources")
        .withJSONBody("{\"name\": \"Test Resource\"}")
        .withHeader("Content-Type", "application/json")
        .returningJSON(responseJSON)
        .returningStatus(201)
        .returningHeaders([
            "Content-Type": "application/json",
            "Location": "https://api.example.com/resources/123"
        ])
        .expectingStatus(201)
        .expectingJSON(responseJSON)
        .expectingHeader("Location", "https://api.example.com/resources/123")
        .run()
}

@Test("204 No Content response handling")
func test204NoContentResponse() async throws {
    try await HTTPTestCase
        .delete("https://example.com/resource/123")
        .returningData(Data())
        .returningStatus(204)
        .expectingStatus(204)
        .expectingData(Data())
        .run()
}

@Test("400 Bad Request error response")
func test400BadRequestResponse() async throws {
    let errorJSON = """
    {
        "error": "Bad Request",
        "message": "Invalid input parameters"
    }
    """
    
    try await HTTPTestCase
        .post("https://api.example.com")
        .withJSONBody("invalid json")
        .withHeader("Content-Type", "application/json")
        .returningJSON(errorJSON)
        .returningStatus(400)
        .returningHeaders(["Content-Type": "application/json"])
        .expectingStatus(400)
        .expectingJSON(errorJSON)
        .expectingHeader("Content-Type", "application/json")
        .run()
}

@Test("404 Not Found error response")
func test404NotFoundResponse() async throws {
    try await HTTPTestCase
        .get("https://example.com/missing")
        .returningText("Resource not found")
        .returningStatus(404)
        .returningHeaders(["Content-Type": "text/plain"])
        .expectingStatus(404)
        .expectingText("Resource not found")
        .run()
}

@Test("500 Internal Server Error response")
func test500InternalServerErrorResponse() async throws {
    try await HTTPTestCase
        .get("https://api.example.com/error")
        .returningText("Internal server error occurred")
        .returningStatus(500)
        .returningHeaders(["Content-Type": "text/plain"])
        .expectingStatus(500)
        .expectingText("Internal server error occurred")
        .run()
}

@Test("Empty response body")
func testEmptyResponseBody() async throws {
    try await HTTPTestCase
        .get("https://example.com/empty")
        .returningData(Data())
        .returningStatus(200)
        .returningHeaders(["Content-Length": "0"])
        .expectingStatus(200)
        .expectingData(Data())
        .expectingHeader("Content-Length", "0")
        .run()
}

@Test("Large response body")
func testLargeResponseBody() async throws {
    // Create 100KB of test data
    let largeData = TestData.binary(size: 102400, value: 0x41) // 'A' repeated 100KB times
    
    try await HTTPTestCase
        .get("https://example.com/large")
        .returningData(largeData)
        .returningStatus(200)
        .returningHeaders([
            "Content-Type": "application/octet-stream",
            "Content-Length": "102400"
        ])
        .expectingStatus(200)
        .expectingData(largeData)
        .expectingHeader("Content-Length", "102400")
        .run()
}