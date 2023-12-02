import Foundation

enum FileAnalysisResult: Encodable {
    case swiftFile(types: TypeExtractionResult, content: String)
    case otherFile(content: String)
}
