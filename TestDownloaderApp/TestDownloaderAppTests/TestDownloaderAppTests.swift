//
//  TestDownloaderAppTests.swift
//  TestDownloaderAppTests
//
//  Created by Mikita Palyka on 19.06.24.
//

import XCTest
import CoreData
import Combine
//import SwiftUI
@testable import TestDownloaderApp

final class TestDownloaderAppTests: XCTestCase {
    
    var mainViewModel: MainViewModel!
    var downloadManager: DownloadManager!
    var mockDownloadManager: MockDownloadManager!
    var mockEpisode: Episode!
    var persistentContainer: NSPersistentContainer!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        mainViewModel = MainViewModel()
        downloadManager = DownloadManager()
        setUpPersistentContainer()
        mockDownloadManager = MockDownloadManager()
        cancellables = []
    }
    
    override func tearDown() {
        mainViewModel = nil
        persistentContainer = nil
        mockDownloadManager = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testFetchPodcast() async throws {
        let expectedPodcast = Podcast.test
        await mockDownloadManager.fetchPodcast()
        
        XCTAssertEqual(mockDownloadManager.mockPodcast, expectedPodcast)
    }
    
    func testDownloadEpisode() async throws {
        let expextedEpisode = Episode.test
        
        await mockDownloadManager.downloadEpisode(expextedEpisode, downloadQueue: .idle)
        
        guard let first = mockDownloadManager.mockPodcast?[expextedEpisode.id] else {
            XCTAssertThrowsError("Not working")
            return
        }
        XCTAssertEqual(first.downloadState, .downloaded)
    }
    
    @MainActor func testAddInAQueue() {
        let expectedEpisode = Episode.test
        
        mockDownloadManager.addEpisodeToQueue(expectedEpisode, queue: .sequential)
        
        guard let testEpisode = mockDownloadManager.mockPodcast?[expectedEpisode.id] else {
            XCTAssertThrowsError("Not working")
            return
        }

        XCTAssertEqual(testEpisode.downloadState, .inQueue)
    }
    
    func testPauseDownloadEpisode() {
        let expectedEpisode = Episode.test
        
        mockDownloadManager.pauseDownload(for: expectedEpisode)
        
        guard let testEpisode = mockDownloadManager.mockPodcast?[expectedEpisode.id] else {
            XCTAssertThrowsError("Not working")
            return
        }
        
        XCTAssertEqual(testEpisode.downloadState, .paused)
    }
    
    func testResumeDownloadEpisode() {
        let expectedEpisode = Episode.test
        
        mockDownloadManager.resumeDownload(for: expectedEpisode)
        
        guard let testEpisode = mockDownloadManager.mockPodcast?[expectedEpisode.id] else {
            XCTAssertThrowsError("Not working")
            return
        }
        
        XCTAssertEqual(testEpisode.downloadState, .inProgress)
    }
    
    func setUpPersistentContainer() {
        persistentContainer = NSPersistentContainer(name: "DownloadHistory")
        
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]
        
        persistentContainer.loadPersistentStores { (description, error) in
            XCTAssertNil(error, "Load error: \(String(describing: error))")
        }
    }
    
    func testCreateAndSaveEntity() {
        let context = persistentContainer.viewContext
        
        let entity = NSEntityDescription.insertNewObject(forEntityName: "History", into: context)
        entity.setValue("Test Value", forKey: "title")
        
        do {
            try context.save()
        } catch {
            XCTFail("Save error \(error)")
        }
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "History")
        
        do {
            let results = try context.fetch(fetchRequest)
            XCTAssertEqual(results.count, 1)
            XCTAssertEqual(results.first?.value(forKey: "title") as? String, "Test Value")
        } catch {
            XCTFail("Request error: \(error)")
        }
    }
    
    func testCheckFile() {
        let context = persistentContainer.viewContext
        let entity = NSEntityDescription.insertNewObject(forEntityName: "History", into: context)
        let entityFileURL = NSEntityDescription.insertNewObject(forEntityName: "EpisodeFileURL", into: context)
        
        let episodeURL: String = Episode.preview.url.absoluteString
        
        
        entity.setValue(Episode.preview.id, forKey: "id")
        entity.setValue(Episode.preview.title, forKey: "title")
        entity.setValue(Episode.preview.date, forKey: "date")
        entity.setValue(Episode.preview.isDownloading, forKey: "downloaded")
        entityFileURL.setValue(episodeURL, forKey: "fileURL")
        
        do {
            try context.save()
        } catch {
            XCTFail("Failed to save context: \(error)")
        }
        
        let fetchRequest = NSFetchRequest<History>(entityName: "History")
        
        do {
            let testArray = try context.fetch(fetchRequest)
            XCTAssertEqual(testArray.count, 1)
            
            mainViewModel.checkFile(historyItems: testArray)
        } catch {
            XCTFail("Failed to fetch entity: \(error)")
        }
        
    }
    
    override func setUpWithError() throws {
        
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func testExample() throws {
        
    }
    
    func testPerformanceExample() throws {
        
        measure {
            
        }
    }
    
}
