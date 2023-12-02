import Foundation

struct TypeExtractionResult: Encodable {
    let declaredClasses: [String]
    let declaredStructs: [String]
    let declaredEnums: [String]
    let declaredProtocols: [String]
    
    let extendedTypes: [String]
    let inheritedTypes: [String]
    let referencedTypes: [String]
}
