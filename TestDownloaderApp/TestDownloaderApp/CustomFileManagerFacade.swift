//
//  CustomFileManager.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 22.08.24.
//

import Foundation

final class CustomFileManagerFacade: FileManagingProtocol {

    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func url(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask, appropriateFor url: URL?, create shouldCreate: Bool) throws -> URL {
        return try fileManager.url(for: directory, in: domainMask, appropriateFor: url, create: shouldCreate)
    }

    func fileExists(atPath path: String) -> Bool {
        return fileManager.fileExists(atPath: path)
    }

    func removeItem(at URL: URL) throws {
        try fileManager.removeItem(at: URL)
    }

    func moveItem(at srcURL: URL, to dstURL: URL) throws {
        try fileManager.moveItem(at: srcURL, to: dstURL)
    }
    
    func createDirectoryIfNeeded(directoryURL: String) {
        
        if !fileManager.fileExists(atPath: directoryURL) {
            do {
                try fileManager.createDirectory(atPath: directoryURL, withIntermediateDirectories: true)
                print("Directory created at: \(directoryURL)")
            } catch {
                print("Failed to create directory: \(error.localizedDescription)")
            }
        }
    }
}
