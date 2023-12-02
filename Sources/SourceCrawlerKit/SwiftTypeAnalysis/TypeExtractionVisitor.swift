import SwiftSyntax

class TypeExtractionVisitor: SyntaxVisitor {
    var declaredClasses: [String] = []
    var declaredStructs: [String] = []
    var declaredEnums: [String] = []
    var declaredProtocols: [String] = []
    
    var extendedTypes: [String] = []
    var inheritedTypes: [String] = []
    var referencedTypes: [String] = []
    
    var typeContextStack: [String] = []
    
    var nestedTypes: [String: [String]] = [:]
    
    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        declaredClasses.append(node.name.text)
        walkChildrenForNode(node, inTypeContext: node.name.text)
        return .skipChildren
    }
    
    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        declaredStructs.append(node.name.text)
        walkChildrenForNode(node, inTypeContext: node.name.text)
        return .skipChildren
    }
    
    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        declaredEnums.append(node.name.text)
        walkChildrenForNode(node, inTypeContext: node.name.text)
        return .skipChildren
    }
    
    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        declaredProtocols.append(node.name.text)
        walkChildrenForNode(node, inTypeContext: node.name.text)
        return .skipChildren
    }
    
    override func visit(_ node: InheritedTypeSyntax) -> SyntaxVisitorContinueKind {
        if let typeName = node.type.as(IdentifierTypeSyntax.self) {
            inheritedTypes.append(typeName.name.text)
        }
        return .visitChildren
    }
    
    override func visit(_ node: TypeAnnotationSyntax) -> SyntaxVisitorContinueKind {
        if let typeName = node.type.as(IdentifierTypeSyntax.self) {
            referencedTypes.append(typeName.name.text)
        }
        return .visitChildren
    }
    
    override func visit(_ node: ClosureSignatureSyntax) -> SyntaxVisitorContinueKind {
        if let returnType = node.returnClause?.type {
            if let typeName = returnType.as(IdentifierTypeSyntax.self) {
                referencedTypes.append(typeName.name.text)
            }
        }
        
        if let input = node.parameterClause {
            if let parameterList = input.as(FunctionParameterClauseSyntax.self) {
                for parameter in parameterList.parameters {
                    if let typeName = parameter.type.as(IdentifierTypeSyntax.self) {
                        referencedTypes.append(typeName.name.text)
                    }
                }
            }
        }
        
        return .visitChildren
    }
    
    override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        if let extendedType = node.extendedType.as(IdentifierTypeSyntax.self) {
            extendedTypes.append(extendedType.name.text)
            walkChildrenForNode(node, inTypeContext: extendedType.name.text)
            return .skipChildren
        }
        return .visitChildren
    }
    
    private func walkChildrenForNode(_ node: SyntaxProtocol, inTypeContext typeName: String) {
        if let parentType = typeContextStack.last {
            let nestedTypesForParent = nestedTypes[parentType] ?? []
            nestedTypes[parentType] = nestedTypesForParent + [typeName]
        }
        
        typeContextStack.append(typeName)
        
        for child in node.children(viewMode: .fixedUp) {
            walk(child)
        }
        
        typeContextStack.removeLast()
    }
}
