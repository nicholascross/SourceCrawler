import Foundation

public struct TypeExtractionResult: Encodable {
    public let declaredClasses: [String]
    public let declaredStructs: [String]
    public let declaredEnums: [String]
    public let declaredProtocols: [String]
    
    public let extendedTypes: [String]
    public let inheritedTypes: [String]
    public let referencedTypes: [String]
    public let nestTypes: [String: [String]]
}
