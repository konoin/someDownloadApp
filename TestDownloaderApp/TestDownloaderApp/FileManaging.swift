//
//  FileManaging.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 22.08.24.
//

import Foundation

protocol FileManagingProtocol {
    func url(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask, appropriateFor url: URL?, create shouldCreate: Bool) throws -> URL
    func fileExists(atPath path: String) -> Bool
    func removeItem(at URL: URL) throws
    func moveItem(at srcURL: URL, to dstURL: URL) throws
    func createDirectoryIfNeeded(directoryURL: String)
}
