import Foundation

struct SourceCrawler {
    let rootPath: String
    let acceptedExtensions: [String]
    let fileManager = FileManager.default
    let analyzer = SwiftTypeAnalyser()
    
    func crawlSource() -> [String: FileAnalysisResult] {
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
                                
                                results[filePath] = analysisResult
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

enum FileAnalysisResult: Encodable {
    case swiftFile(types: TypeExtractionResult, content: String)
    case otherFile(content: String)
}
