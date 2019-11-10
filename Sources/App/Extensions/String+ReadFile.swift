//
//  File.swift
//  
//
//  Created by Victor on 10.11.2019.
//

import Foundation

extension String {
    static func dataFromFile(_ filename: String) throws -> String? {
        var cache: [String: URL] = [:] // Save all local files in this cache
        let baseURL = urlForRestServicesTestsDir()

        guard let enumerator = FileManager.default.enumerator(
            at: baseURL,
            includingPropertiesForKeys: [.nameKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants],
            errorHandler: nil) else {
                fatalError("Could not enumerate \(baseURL)")
        }

        for case let url as URL in enumerator where url.isFileURL {
            cache[url.lastPathComponent] = url
        }
        do {
            guard let url = cache[filename] else {return nil}
            return try String(contentsOf: url)
        }
        catch {
            throw error
        }
    }
    
    static func urlForRestServicesTestsDir() -> URL {
        let currentFileURL = URL(fileURLWithPath: "\(#file)", isDirectory: false)
        return currentFileURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
