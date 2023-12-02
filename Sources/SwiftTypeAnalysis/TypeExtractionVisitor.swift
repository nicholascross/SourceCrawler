import SwiftSyntax

class TypeExtractionVisitor: SyntaxVisitor {
    var declaredClasses: [String] = []
    var declaredStructs: [String] = []
    var declaredEnums: [String] = []
    var declaredProtocols: [String] = []
    
    var extendedTypes: [String] = []
    var inheritedTypes: [String] = []
    var referencedTypes: [String] = []
    
    // Visit class declarations
    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        declaredClasses.append(node.name.text)
        return .visitChildren
    }
    
    // Visit struct declarations
    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        declaredStructs.append(node.name.text)
        return .visitChildren
    }
    
    // Visit enum declarations
    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        declaredEnums.append(node.name.text)
        return .visitChildren
    }
    
    // Visit protocol declarations
    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        declaredProtocols.append(node.name.text)
        return .visitChildren
    }
    
    // Override for inherited types (e.g., superclass or protocol conformance)
    override func visit(_ node: InheritedTypeSyntax) -> SyntaxVisitorContinueKind {
        if let typeName = node.type.as(IdentifierTypeSyntax.self) {
            referencedTypes.append(typeName.name.text)
        }
        return .visitChildren
    }
    
    // Override for type annotations (e.g., variable types, function return types)
    override func visit(_ node: TypeAnnotationSyntax) -> SyntaxVisitorContinueKind {
        if let typeName = node.type.as(IdentifierTypeSyntax.self) {
            referencedTypes.append(typeName.name.text)
        }
        return .visitChildren
    }
    
    // Override for closure types
    override func visit(_ node: ClosureSignatureSyntax) -> SyntaxVisitorContinueKind {
        // Capture return type of closure if available
        if let returnType = node.returnClause?.type {
            if let typeName = returnType.as(IdentifierTypeSyntax.self) {
                referencedTypes.append(typeName.name.text)
            }
        }
        
        // Capture parameter types of closure if available
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
            // Here you could record that `extendedType` is being extended
            extendedTypes.append(extendedType.name.text)
        }
        return .visitChildren
    }
    
}
