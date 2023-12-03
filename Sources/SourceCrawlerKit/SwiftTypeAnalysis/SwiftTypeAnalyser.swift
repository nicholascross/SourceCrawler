import Foundation
import SwiftSyntax
import SwiftParser

struct SwiftTypeAnalyser {
    
    func analyze(fileContents: String) -> TypeExtractionResult {
        let syntaxTree = Parser.parse(source: fileContents)
        let visitor = TypeExtractionVisitor(viewMode: .fixedUp)
        visitor.walk(syntaxTree)
        
        return TypeExtractionResult(
            declaredClasses: visitor.declaredClasses.nullifyWhenEmpty(),
            declaredStructs: visitor.declaredStructs.nullifyWhenEmpty(),
            declaredEnums: visitor.declaredEnums.nullifyWhenEmpty(),
            declaredProtocols: visitor.declaredProtocols.nullifyWhenEmpty(),
            extendedTypes: visitor.extendedTypes.nullifyWhenEmpty(),
            inheritedTypes: visitor.inheritedTypes.nullifyWhenEmpty(),
            referencedTypes: visitor.referencedTypes.nullifyWhenEmpty(),
            nestTypes: visitor.nestedTypes.nullifyWhenEmpty()
        )
    }
}

private extension Array {
    func nullifyWhenEmpty() -> Array<Element>? {
        isEmpty ? nil : self
    }
}

private extension Dictionary {
    func nullifyWhenEmpty() -> Dictionary<Key,Value>? {
        isEmpty ? nil : self
    }
}
