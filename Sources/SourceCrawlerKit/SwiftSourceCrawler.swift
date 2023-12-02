import Foundation

public struct SwiftSourceCrawler {
    
    let rootPath: String
    let acceptedExtensions: [String]
    let fileManager = FileManager.default
    let analyzer = SwiftTypeAnalyser()
    
    public init(rootPath: String, acceptedExtensions: [String]) {
        self.rootPath = rootPath
        self.acceptedExtensions = acceptedExtensions
    }
    
    public func crawlSource() throws -> [String: FileAnalysisResult] {
        var results = [String: FileAnalysisResult]()

        if let enumerator = fileManager.enumerator(at: URL(fileURLWithPath: rootPath),
                                                    includingPropertiesForKeys: [.isRegularFileKey],
                                                    options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator where acceptedExtensions.contains(fileURL.pathExtension) {
                let analysisResult = try processFile(fileURL)
                let relativePath = String(fileURL.path.dropFirst(rootPath.count))
                results[relativePath] = analysisResult
            }
        }

        return results
    }

    private func processFile(_ fileURL: URL) throws -> FileAnalysisResult {
        let fileAttributes = try fileURL.resourceValues(forKeys: [.isRegularFileKey])
        
        guard fileAttributes.isRegularFile ?? false else {
            throw SwiftSourceCrawlerError.unprocessibleFile(fileURL)
        }
        
        return try analyzeFileContent(at: fileURL)
    }

    private func analyzeFileContent(at fileURL: URL) throws -> FileAnalysisResult {
        if let fileContents = try? String(contentsOf: fileURL) {
            if fileURL.pathExtension == "swift" {
                let typeAnalysis = analyzer.analyze(fileContents: fileContents)
                return .swiftFile(types: typeAnalysis, content: fileContents)
            } else {
                return .otherFile(content: fileContents)
            }
        } else {
            print("Failed to read contents of file: \(fileURL.path)")
            throw SwiftSourceCrawlerError.failedToReadContents(fileURL)
        }
    }

}

enum SwiftSourceCrawlerError: Error {
    case failedToReadContents(URL)
    case unprocessibleFile(URL)
}
