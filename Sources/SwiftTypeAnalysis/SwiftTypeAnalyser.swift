import Foundation
import SwiftSyntax
import SwiftParser

struct SwiftTypeAnalyser {
    
    func analyze(fileContents: String) -> TypeExtractionResult {
        let syntaxTree = Parser.parse(source: fileContents)
        let visitor = TypeExtractionVisitor(viewMode: .fixedUp)
        visitor.walk(syntaxTree)
        
        return TypeExtractionResult(
            declaredClasses: visitor.declaredClasses,
            declaredStructs: visitor.declaredStructs,
            declaredEnums: visitor.declaredEnums,
            declaredProtocols: visitor.declaredProtocols,
            extendedTypes: visitor.extendedTypes,
            inheritedTypes: visitor.inheritedTypes,
            referencedTypes: visitor.referencedTypes
        )
    }
}

