#!/bin/sh

swift build -c release
cp -f ./.build/release/SourceCrawler ~/bin/source-crawler
