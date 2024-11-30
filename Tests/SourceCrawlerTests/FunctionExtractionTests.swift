@testable import SourceCrawlerKit
import SwiftParser
import SwiftSyntax
import XCTest

class FunctionExtractionTests: XCTestCase {
    // Helper to parse Swift code and return the function details
    func extractFunctions(from source: String) -> [FunctionDetail] {
        let syntaxTree = Parser.parse(source: source)
        let visitor = FunctionExtractionVisitor(viewMode: .fixedUp)
        visitor.walk(syntaxTree)
        return visitor.functions
    }

    func testBasicFunctionExtraction() {
        let source = """
        func greet(name: String) -> String {
            return "Hello, \\(name)!"
        }
        """
        let functions = extractFunctions(from: source)
        XCTAssertEqual(functions.count, 1)
        XCTAssertEqual(functions.first?.name, "greet")
        XCTAssertEqual(functions.first?.returnType, "String")
    }

    func testFunctionParametersExtraction() {
        let source = """
        func add(a: Int, b: Int) -> Int {
            return a + b
        }
        """
        let functions = extractFunctions(from: source)
        XCTAssertEqual(functions.first?.parameters.count, 2)
        XCTAssertEqual(functions.first?.parameters[0].name, "a")
        XCTAssertEqual(functions.first?.parameters[0].type, "Int")
        XCTAssertEqual(functions.first?.parameters[1].name, "b")
        XCTAssertEqual(functions.first?.parameters[1].type, "Int")
    }

    func testIgnoreNestedFunctions() {
        let source = """
        class MyClass {
            func outerFunc() {
                func innerFunc() {}
            }

            func anotherFunc() {}
        }
        """

        let functions = extractFunctions(from: source)
        XCTAssertEqual(functions.count, 2)
        XCTAssertEqual(functions[0].name, "outerFunc")
        XCTAssertEqual(functions[0].parentType, "MyClass")
        XCTAssertEqual(functions[1].name, "anotherFunc")
        XCTAssertEqual(functions[1].parentType, "MyClass")
    }

    func testFunctionExtractionWithoutBody() {
        let source = """
        func simpleFunc() -> Int { return 1 }
        """
        let visitor = FunctionExtractionVisitor(viewMode: .sourceAccurate)
        visitor.includeBody = false
        let syntaxTree = Parser.parse(source: source)
        visitor.walk(syntaxTree)
        XCTAssertNil(visitor.functions.first?.body)
    }

    func testFunctionExtractionWithBody() {
        let source = """
        func simpleFunc() -> Int { return 1 }
        """
        let visitor = FunctionExtractionVisitor(viewMode: .sourceAccurate)
        visitor.includeBody = true
        let syntaxTree = Parser.parse(source: source)
        visitor.walk(syntaxTree)
        XCTAssertEqual(visitor.functions.first?.body, "func simpleFunc() -> Int { return 1 }")
    }
}
