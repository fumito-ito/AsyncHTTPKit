import Testing
import Foundation
import AsyncHTTPClient
@testable import AsyncHTTPKit

@Test("GET request method")
func testGETMethod() async throws {
    try await HTTPTestCase
        .get("https://example.com")
        .returningText("GET response")
        .returningStatus(200)
        .expectingStatus(200)
        .expectingText("GET response")
        .run()
}

@Test("POST request with body")
func testPOSTMethodWithBody() async throws {
    try await HTTPTestCase
        .post("https://example.com")
        .withTextBody("POST request body")
        .withHeader("Content-Type", "text/plain")
        .returningText("POST response")
        .returningStatus(201)
        .expectingStatus(201)
        .expectingText("POST response")
        .run()
}

@Test("POST request without body")
func testPOSTMethodWithoutBody() async throws {
    try await HTTPTestCase
        .post("https://example.com")
        .returningText("POST response")
        .returningStatus(200)
        .expectingStatus(200)
        .expectingText("POST response")
        .run()
}

@Test("PUT request")
func testPUTMethod() async throws {
    try await HTTPTestCase
        .put("https://example.com")
        .withTextBody("PUT request body")
        .withHeader("Content-Type", "text/plain")
        .returningText("PUT response")
        .returningStatus(200)
        .expectingStatus(200)
        .expectingText("PUT response")
        .run()
}

@Test("DELETE request")
func testDELETEMethod() async throws {
    try await HTTPTestCase
        .delete("https://example.com")
        .returningData(Data())
        .returningStatus(204)
        .expectingStatus(204)
        .expectingData(Data())
        .run()
}

@Test("PATCH request")
func testPATCHMethod() async throws {
    try await HTTPTestCase
        .patch("https://example.com")
        .withTextBody("PATCH request body")
        .withHeader("Content-Type", "text/plain")
        .returningText("PATCH response")
        .returningStatus(200)
        .expectingStatus(200)
        .expectingText("PATCH response")
        .run()
}

@Test("HEAD request")
func testHEADMethod() async throws {
    try await HTTPTestCase
        .head("https://example.com")
        .returningData(Data())
        .returningStatus(200)
        .returningHeaders(["Content-Length": "100"])
        .expectingStatus(200)
        .expectingData(Data())
        .expectingHeader("Content-Length", "100")
        .run()
}