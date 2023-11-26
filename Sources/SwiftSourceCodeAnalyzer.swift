import Foundation

struct SwiftTypeAnalyser {

    // Heuristic based analysis a proper analyzer would
    // need to use the actual AST.
    func analyze(fileContents: String) -> TypeExtractionResult {
        let declaredTypes = extractDeclaredTypes(from: fileContents)
        let referencedTypes = extractReferencedTypes(from: fileContents)
        return TypeExtractionResult(declared: declaredTypes, referenced: referencedTypes)
    }

    private func extractDeclaredTypes(from source: String) -> [String] {
        let pattern = #"(class|struct|enum|protocol)\s+(\w+)"#
        return extractTypes(from: source, with: pattern, index: 2)
    }

    private func extractReferencedTypes(from source: String) -> [String] {
        // Regular expressions for referenced types
        let patterns = [
            #":\s*([A-Z]\w*)"#,                     // Type Annotations
            #"as\??\s+([A-Z]\w*)"#,                 // Type Casting
            #"->\s*([A-Z]\w*)"#,                    // Function Return Types
            #"<([A-Z]\w*)"#,                        // Generic Type Parameters
            #":\s*([A-Z]\w*(\s*,\s*[A-Z]\w*)*)"#,   // Type Inheritance and Protocol Conformance
            #"\(\s*[_\w]+\s*:\s*([A-Z]\w*)"#,       // Function Parameters
            #"\{\s*\(\s*[_\w]+\s*:\s*([A-Z]\w*)\s*\)\s*in"#  // Closure Expressions
        ]

        var referencedTypes = Set<String>()
        for pattern in patterns {
            let matches = extractTypes(from: source, with: pattern, index: 1)
            for match in matches {
                referencedTypes.insert(match)
            }
        }

        return Array(referencedTypes)
    }

    private func extractTypes(from source: String, with pattern: String, index: Int) -> [String] {
        guard let regex = try? Regex(pattern) else {
            fatalError("Invalid regex pattern: \(pattern)")
        }

        return source.matches(of: regex).compactMap { $0.output[index].value as? Substring }.map(String.init)
    }
}

struct TypeExtractionResult: Encodable {
    let declared: [String]
    let referenced: [String]
}

extension String {
    func matches<T>(of regex: Regex<T>) -> [Regex<T>.Match] {
        var matches: [Regex<T>.Match] = []
        var currentIndex = startIndex

        while let match = try? regex.firstMatch(in: self[currentIndex...]) {
            matches.append(match)
            currentIndex = match.range.upperBound
        }

        return matches
    }
}
