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
    
    public func crawlSource() -> [String: FileAnalysisResult] {
        var results = [String: FileAnalysisResult]()

        if let enumerator = fileManager.enumerator(at: URL(fileURLWithPath: rootPath),
                                                    includingPropertiesForKeys: [.isRegularFileKey],
                                                    options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                if let analysisResult = processFile(fileURL) {
                    let relativePath = String(fileURL.path.dropFirst(rootPath.count))
                    results[relativePath] = analysisResult
                }
            }
        }

        return results
    }

    private func processFile(_ fileURL: URL) -> FileAnalysisResult? {
        do {
            let fileAttributes = try fileURL.resourceValues(forKeys: [.isRegularFileKey])
            if fileAttributes.isRegularFile ?? false {
                let fileExtension = fileURL.pathExtension
                if acceptedExtensions.contains(fileExtension) {
                    return analyzeFileContent(at: fileURL, withExtension: fileExtension)
                }
            }
        } catch {
            print("Failed to process file: \(fileURL.path), error: \(error)")
        }
        return nil
    }

    private func analyzeFileContent(at fileURL: URL, withExtension fileExtension: String) -> FileAnalysisResult? {
        if let fileContents = try? String(contentsOf: fileURL) {
            if fileExtension == "swift" {
                let typeAnalysis = analyzer.analyze(fileContents: fileContents)
                return .swiftFile(types: typeAnalysis, content: fileContents)
            } else {
                return .otherFile(content: fileContents)
            }
        } else {
            print("Failed to read contents of file: \(fileURL.path)")
            return nil
        }
    }

}


