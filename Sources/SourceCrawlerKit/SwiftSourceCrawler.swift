import Foundation
import FilenameMatcher

public struct SwiftSourceCrawler {
    
    private let rootPath: String
    private let acceptedExtensions: [String]
    private let excludedPaths: [String]
    private let fileManager = FileManager.default
    private let analyzer: SwiftTypeAnalyser
    private let includeContents: Bool
    
    public init(rootPath: String, acceptedExtensions: [String], excludedPaths: [String] = [], includeContents: Bool = true, includeBody: Bool = false) {
        self.rootPath = rootPath
        self.acceptedExtensions = acceptedExtensions
        self.excludedPaths = excludedPaths
        self.includeContents = includeContents
        self.analyzer = SwiftTypeAnalyser(includeBody: includeBody)
    }
    
    public func crawlSource() throws -> [String: FileAnalysisResult] {
        var results = [String: FileAnalysisResult]()

        if let enumerator = fileEnumerator() {
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
        lazy var excludedPath = excludedPaths.isFilenameMatch(fileURL: fileURL)
        return validExtension && !excludedPath && fileURL.isFileURL
    }

    private func analyzeFileContent(at fileURL: URL) throws -> FileAnalysisResult {
        if let fileContents = try? String(contentsOf: fileURL) {
            if fileURL.pathExtension == "swift" {
                let typeAnalysis = analyzer.analyze(fileContents: fileContents)
                return .swiftFile(types: typeAnalysis, content: includeContents ? fileContents : nil)
            } else {
                return .otherFile(content: includeContents ? fileContents : nil)
            }
        } else {
            print("Failed to read contents of file: \(fileURL.path)")
            throw SwiftSourceCrawlerError.failedToReadContents(fileURL)
        }
    }
    
    private func fileEnumerator() -> FileManager.DirectoryEnumerator? {
        fileManager.enumerator(at: URL(fileURLWithPath: rootPath),
                               includingPropertiesForKeys: [.isRegularFileKey],
                               options: [.skipsHiddenFiles, .skipsPackageDescendants]
        )
    }
}

enum SwiftSourceCrawlerError: Error {
    case failedToReadContents(URL)
}

private extension URL {
    var simplePath: String {
        pathComponents.joined(separator: "/").replacingOccurrences(of: "//", with: "/")
    }
    
    var isFile: Bool {
        (try? resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) ?? false
    }
}

private extension Collection<String> {
    func isFilenameMatch(fileURL: URL) -> Bool {
        contains(where: {
            FilenameMatcher(pattern: $0).match(filename: fileURL.simplePath)
        })
    }
}
