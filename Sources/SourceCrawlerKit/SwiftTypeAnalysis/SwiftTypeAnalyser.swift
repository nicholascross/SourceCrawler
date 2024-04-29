import Foundation
import SwiftSyntax
import SwiftParser

struct SwiftTypeAnalyser {
    let includeBody: Bool
    
    func analyze(fileContents: String) -> TypeExtractionResult {
        let syntaxTree = Parser.parse(source: fileContents)
        let typeVisitor = TypeExtractionVisitor(viewMode: .fixedUp)
        typeVisitor.walk(syntaxTree)
        
        let functionVistor = FunctionExtractionVisitor(viewMode: .fixedUp)
        functionVistor.includeBody = includeBody
        functionVistor.walk(syntaxTree)
        
        let importVisitor = ImportExtractionVisitor(viewMode: .fixedUp)
        importVisitor.walk(syntaxTree)
        
        return TypeExtractionResult(
            declaredClasses: typeVisitor.declaredClasses.nullifyWhenEmpty(),
            declaredStructs: typeVisitor.declaredStructs.nullifyWhenEmpty(),
            declaredEnums: typeVisitor.declaredEnums.nullifyWhenEmpty(),
            declaredProtocols: typeVisitor.declaredProtocols.nullifyWhenEmpty(),
            extendedTypes: typeVisitor.extendedTypes.nullifyWhenEmpty(),
            inheritedTypes: typeVisitor.inheritedTypes.nullifyWhenEmpty(),
            referencedTypes: typeVisitor.referencedTypes.nullifyWhenEmpty(),
            nestTypes: typeVisitor.nestedTypes.nullifyWhenEmpty(),
            function: functionVistor.functions,
            imports: importVisitor.imports
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

