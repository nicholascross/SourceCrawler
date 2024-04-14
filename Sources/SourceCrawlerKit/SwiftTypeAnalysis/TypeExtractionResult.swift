import Foundation

public struct TypeExtractionResult: Encodable {
    public let declaredClasses: [String]?
    public let declaredStructs: [String]?
    public let declaredEnums: [String]?
    public let declaredProtocols: [String]?
    
    public let extendedTypes: [String]?
    public let inheritedTypes: [String]?
    public let referencedTypes: [String]?
    public let nestTypes: [String: [String]]?
    public let function: [FunctionDetail]
}

public struct FunctionDetail: Encodable {
    var name: String
    var parameters: [Parameter]
    var returnType: String?
    var parentType: String?
    var body: String?
}

public struct Parameter: Encodable {
    var name: String
    var type: String
}
