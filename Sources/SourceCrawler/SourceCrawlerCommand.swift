import Foundation
import ArgumentParser
import SourceCrawlerKit

@main
struct SourceCrawlerCommand: ParsableCommand {
    @Option(name: .shortAndLong, help: "The root path to start the file traversal.")
    var rootPath: String?

    @Option(name: .shortAndLong, help: "Comma-separated list of file extensions to include in the analysis.")
    var fileExtensions: String?

    @Option(name: [.customShort("o"), .long], help: "Output file path for the JSON results.")
    var outputPath: String?
    
    @Option(name: [.customShort("e"), .long], help: "Comma-separated list of paths to exclude. eg. **/Tests/*.swift")
    var excludedPaths: String?

    mutating func run() throws {
        let rootDirectory = rootPath ?? FileManager.default.currentDirectoryPath
        let defaultOutputName = URL(fileURLWithPath: rootDirectory).lastPathComponent
        let extensions = (fileExtensions ?? "swift,txt,md").components(separatedBy: ",")
        let exclusions = excludedPaths?.components(separatedBy: ",") ?? []
        let crawler = SwiftSourceCrawler(rootPath: rootDirectory, acceptedExtensions: extensions, excludedPaths: exclusions)
        let results = try crawler.crawlSource()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        
        if let jsonData = try? encoder.encode(results) {
            let outputURL = URL(fileURLWithPath: outputPath ?? "\(defaultOutputName).json")
            try jsonData.write(to: outputURL)
            print("Analysis results saved to \(outputURL)")
        } else {
            print("Failed to serialize results to JSON")
        }
    }
}
