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
                do {
                    let fileAttributes = try fileURL.resourceValues(forKeys: [.isRegularFileKey])
                    if fileAttributes.isRegularFile ?? false {
                        let filePath = fileURL.path
                        let fileExtension = fileURL.pathExtension

                        if self.acceptedExtensions.contains(fileExtension) {
                            if let fileContents = try? String(contentsOf: fileURL) {
                                let analysisResult: FileAnalysisResult
                                
                                if fileExtension == "swift" {
                                    let typeAnalysis = analyzer.analyze(fileContents: fileContents)
                                    analysisResult = .swiftFile(types: typeAnalysis, content: fileContents)
                                } else {
                                    analysisResult = .otherFile(content: fileContents)
                                }
                               
                                let relativePath = String(filePath.dropFirst(rootPath.count))
                                results[relativePath] = analysisResult
                            }
                        }
                    }
                } catch {
                    print("Failed to process file: \(fileURL.path), error: \(error)")
                }
            }
        }

        return results
    }
}


