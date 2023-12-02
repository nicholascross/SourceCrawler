# SourceCrawler

A source crawler for Swift projects that uses SwiftSyntax and SwiftParser to extract type information.

This tool was created for the purpose of collating source information from git repositories to provide additional context to large language models such as ChatGPT.

## Install

```sh
git clone https://github.com/nicholascross/SourceCrawler
cd SourceCrawler
swift build -c release
# Assumes ~/bin is in environment PATH
cp ./.build/release/SourceCrawler ~/bin/source-crawler
```

## License

See LICENSE file.
