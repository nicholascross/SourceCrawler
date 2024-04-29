import Foundation
import SwiftSyntax

class ImportExtractionVisitor: SyntaxVisitor {
    var imports = [String]()

    override func visit(_ node: ImportDeclSyntax) -> SyntaxVisitorContinueKind {
        imports.append(node.path.description)
        return .skipChildren
    }
}
