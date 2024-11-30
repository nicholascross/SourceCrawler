import Foundation
import SwiftSyntax

class FunctionExtractionVisitor: SyntaxVisitor {
    var includeBody: Bool = false
    var functions = [FunctionDetail]()
    private var typeContextStack = [String]()

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        typeContextStack.append(node.name.text)
        return .visitChildren
    }

    override func visitPost(_: ClassDeclSyntax) {
        typeContextStack.removeLast()
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        typeContextStack.append(node.name.text)
        return .visitChildren
    }

    override func visitPost(_: StructDeclSyntax) {
        typeContextStack.removeLast()
    }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        typeContextStack.append(node.name.text)
        return .visitChildren
    }

    override func visitPost(_: EnumDeclSyntax) {
        typeContextStack.removeLast()
    }

    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        let parentType = typeContextStack.last
        let funcBody = includeBody ? node.description.trimmingCharacters(in: .whitespacesAndNewlines) : nil

        var funcDetail = FunctionDetail(
            name: node.name.text,
            parameters: [],
            returnType: node.signature.returnClause?.type.description.trimmingCharacters(in: .whitespacesAndNewlines),
            parentType: parentType,
            body: funcBody
        )

        for parameter in node.signature.parameterClause.parameters {
            let paramName = parameter.firstName.text
            let paramType = parameter.type.description.trimmingCharacters(in: .whitespacesAndNewlines)
            funcDetail.parameters.append(Parameter(name: paramName, type: paramType))
        }

        functions.append(funcDetail)
        return .skipChildren
    }
}
