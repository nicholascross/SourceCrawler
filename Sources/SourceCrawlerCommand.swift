import Foundation
import ArgumentParser

@main
struct SourceCrawlerCommand: ParsableCommand {
    @Option(name: .shortAndLong, help: "The root path to start the file traversal.")
    var rootPath: String?

    @Option(name: .shortAndLong, help: "Comma-separated list of file extensions to include in the analysis.")
    var fileExtensions: String?

    @Option(name: [.customShort("o"), .long], help: "Output file path for the JSON results.")
    var outputPath: String?

    mutating func run() throws {
        let rootDirectory = rootPath ?? FileManager.default.currentDirectoryPath
        let extensions = (fileExtensions ?? "swift,txt,md").components(separatedBy: ",")
        let manager = SourceCrawler(rootPath: rootDirectory, acceptedExtensions: extensions)
        let results = manager.crawlSource()

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        
        if let jsonData = try? encoder.encode(results) {
            try jsonData.write(to: URL(fileURLWithPath: outputPath ?? "output.json"))
            print("Analysis results saved to \(outputPath ?? "output.json")")
        } else {
            print("Failed to serialize results to JSON")
        }
    }
}
