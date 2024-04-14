import Foundation

public enum FileAnalysisResult: Encodable {
    case swiftFile(types: TypeExtractionResult, content: String?)
    case otherFile(content: String?)
}
