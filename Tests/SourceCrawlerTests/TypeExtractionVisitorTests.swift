import XCTest
@testable import SourceCrawlerKit
import SwiftSyntax
import SwiftParser

class TypeExtractionVisitorTests: XCTestCase {

    func testClassDeclarationExtraction() {
        let source = "class MyClass {} class AnotherClass {}"
        let syntaxTree = Parser.parse(source: source)
        let visitor = TypeExtractionVisitor(viewMode: .fixedUp)
        visitor.walk(syntaxTree)
        XCTAssertEqual(visitor.declaredClasses, ["MyClass", "AnotherClass"], "Class declarations should be extracted correctly.")
    }

    func testStructDeclarationExtraction() {
        let source = "struct MyStruct {} struct AnotherStruct {}"
        let syntaxTree = Parser.parse(source: source)
        let visitor = TypeExtractionVisitor(viewMode: .fixedUp)
        visitor.walk(syntaxTree)
        XCTAssertEqual(visitor.declaredStructs, ["MyStruct", "AnotherStruct"], "Struct declarations should be extracted correctly.")
    }

    func testEnumDeclarationExtraction() {
        let source = "enum MyEnum {} enum AnotherEnum {}"
        let syntaxTree = Parser.parse(source: source)
        let visitor = TypeExtractionVisitor(viewMode: .fixedUp)
        visitor.walk(syntaxTree)
        XCTAssertEqual(visitor.declaredEnums, ["MyEnum", "AnotherEnum"], "Enum declarations should be extracted correctly.")
    }

    func testProtocolDeclarationExtraction() {
        let source = "protocol MyProtocol {} protocol AnotherProtocol {}"
        let syntaxTree = Parser.parse(source: source)
        let visitor = TypeExtractionVisitor(viewMode: .fixedUp)
        visitor.walk(syntaxTree)
        XCTAssertEqual(visitor.declaredProtocols, ["MyProtocol", "AnotherProtocol"], "Protocol declarations should be extracted correctly.")
    }

    func testTypeInheritanceAndExtensionExtraction() {
        let source = """
                     class MyClass: ParentClass {}
                     extension SomeStruct: AnInterface {}
                     """
        let syntaxTree = Parser.parse(source: source)
        let visitor = TypeExtractionVisitor(viewMode: .fixedUp)
        visitor.walk(syntaxTree)
        XCTAssertTrue(visitor.extendedTypes.contains("SomeStruct"), "Inherited types should be extracted correctly.")
        XCTAssertEqual(visitor.inheritedTypes, ["ParentClass", "AnInterface"], "Extended types should be extracted correctly.")
    }

    func testNestedTypeExtraction() {
        let source = "class MyClass { class NestedClass {} }"
        let syntaxTree = Parser.parse(source: source)
        let visitor = TypeExtractionVisitor(viewMode: .fixedUp)
        visitor.walk(syntaxTree)
        XCTAssertEqual(visitor.nestedTypes["MyClass"], ["NestedClass"], "Nested types should be extracted correctly.")
    }

    func testReferencedTypeExtraction() {
        let source = "class MyClass { var property: SomeType }"
        let syntaxTree = Parser.parse(source: source)
        let visitor = TypeExtractionVisitor(viewMode: .fixedUp)
        visitor.walk(syntaxTree)
        XCTAssertTrue(visitor.referencedTypes.contains("SomeType"), "Referenced types should be extracted correctly.")
    }
}
