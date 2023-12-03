import Foundation
import FilenameMatcher

public struct SwiftSourceCrawler {
    
    let rootPath: String
    let acceptedExtensions: [String]
    let excludedPaths: [String]
    let fileManager = FileManager.default
    let analyzer = SwiftTypeAnalyser()
    
    public init(rootPath: String, acceptedExtensions: [String], excludedPaths: [String] = []) {
        self.rootPath = rootPath
        self.acceptedExtensions = acceptedExtensions
        self.excludedPaths = excludedPaths
    }
    
    public func crawlSource() throws -> [String: FileAnalysisResult] {
        var results = [String: FileAnalysisResult]()

        if let enumerator = fileManager.enumerator(at: URL(fileURLWithPath: rootPath),
                                                    includingPropertiesForKeys: [.isRegularFileKey],
                                                    options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                guard acceptFileForProcessing(fileURL: fileURL) else { continue }
                
                let analysisResult = try analyzeFileContent(at: fileURL)
                let relativePath = String(fileURL.path.dropFirst(rootPath.count))
                results[relativePath] = analysisResult
            }
        }

        return results
    }
    
    private func acceptFileForProcessing(fileURL: URL) -> Bool {
        let validExtension = acceptedExtensions.contains(fileURL.pathExtension)
        lazy var excludedPath = excludedPaths.first(where: {
            FilenameMatcher(pattern: $0).match(filename: fileURL.pathComponents.joined(separator: "/").replacingOccurrences(of: "//", with: "/"))
        }) != nil
        lazy var isRegularFile = (try? fileURL.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) ?? false
        return validExtension && !excludedPath && isRegularFile
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
