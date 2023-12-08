# SourceCrawler

SourceCrawler is a tool designed for Swift projects, leveraging SwiftSyntax and SwiftParser to extract detailed type information.
It's tailored for analyzing and collating source information from git repositories, providing context to large language models like ChatGPT.
This makes it a valuable tool for developers working with Swift codebases, aiming to improve understanding and documentation of complex projects.

## Features

- **Swift Code Analysis and Type Information Extraction**: Employs SwiftSyntax and SwiftParser for analysis of Swift code, enabling the extraction of detailed type information such as classes, structs, enums, protocols.
- **Aggregate Output**: Generates analysis results in a structured JSON format for easy integration and review.

## Configuration Options

- `--rootPath`: Specifies the root path of the project to analyze. Defaults to the current directory if not provided.
- `--fileExtensions`: Comma-separated list of file extensions to include in the analysis. Defaults to "swift,txt,md".
- `--outputPath`: Path for the JSON output file. Defaults to the name of the root directory with `.json` extension.
- `--excludedPaths`: Comma-separated list of paths to exclude from analysis (supports glob patterns).

## Usage Example

This command instructs SourceCrawler to:

- Analyze the Swift project located at `/path/to/your/swift/project`.
- Focus on files with the .swift extension.
- Exclude any files that match the pattern `**/Tests/*.swift` from the analysis.
- Output the analysis results in a JSON file named result.json in the current directory.

```bash
source-crawler --rootPath /path/to/your/swift/project --fileExtensions swift --outputPath result.json --excludedPaths "**/Tests/*.swift"
```

## Default Usage Example

You can also run SourceCrawler without specifying any parameters. Here's how you do it:

```bash
source-crawler
```

This command will execute SourceCrawler with its default settings:

- The root path for analysis will be set to the current working directory.
- It will analyze files with the default extensions: swift, txt, and md.
- The results will be saved in a JSON file named after the last component of the current directory path, in the current directory itself.
- No paths will be excluded from the analysis unless specified.

## Install

```sh
git clone https://github.com/nicholascross/SourceCrawler
cd SourceCrawler
swift build -c release
# Assumes ~/bin is in environment PATH
cp ./.build/release/SourceCrawler ~/bin/source-crawler
```

## License

SourceCrawler is released under the MIT License.

## Acknowledgements

This project has utilized generative AI tools in various aspects of its development, including coding assistance and documentation enhancement. The use of these tools has contributed to the efficiency and effectiveness of the development process.
