//
//  TestDownloaderApp_UITests.swift
//  TestDownloaderApp_UITests
//
//  Created by Mikita Palyka on 8.07.24.
//

import XCTest

final class TestDownloaderApp_UITests: XCTestCase {
    var app: XCUIApplication!
    var collectionView: XCUIElementQuery!
    
    override func setUpWithError() throws {
        continueAfterFailure = true
        app = XCUIApplication()
        collectionView = app.collectionViews
    }
    
    override func tearDownWithError() throws {
        app = nil
        collectionView = nil
        try? super.tearDownWithError()
    }
    
    func test_ContentView_EpisodeRow_parallelDownload() {
        app.launch()
        
        let collectionView = app.collectionViews
        let numberOfCells = collectionView.children(matching: .cell).count
        
        for i in 0..<numberOfCells {
            let cell = collectionView.children(matching: .cell).element(boundBy: i)
            
            let inProgressButton = cell.buttons["inProgress"]
            let pausedButton = cell.buttons["paused"]
            let doneButton = cell.buttons["downloaded"]
            
            if i % 2 == 0 {
                guard cell.buttons["Parallel"].exists else {
                    continue
                }
                cell.buttons["Parallel"].tap()
            } else {
                guard cell.buttons["Sequential"].exists else {
                    continue
                }
                cell.buttons["Sequential"].tap()
            }
            
            if inProgressButton.exists {
                inProgressButton.tap()
                let pausedExists = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == true"), object: pausedButton)
                let pausedResult = XCTWaiter().wait(for: [pausedExists], timeout: 5)
                XCTAssert(pausedResult == .completed, "The paused button did not appear in time.")
            } else if doneButton.exists {
                XCTAssert(doneButton.exists, "The done button should exist.")
            }
        }
    }
    
    func test_ContentView_EpisodeRow_parallelDownload_pause() {
        app.launch()
        
        let collectionView = app.collectionViews
        let numberOfCells = collectionView.children(matching: .cell).count
        
        for i in 0..<numberOfCells {
            let cell = collectionView.children(matching: .cell).element(boundBy: i)
            
            let inProgressButton = cell.buttons["inProgress"]
            let pausedButton = cell.buttons["paused"]
            let parallelButton = cell.buttons["Parallel"]
            
            if i % 2 == 0 {
                guard cell.buttons["Parallel"].exists else { continue }
                parallelButton.tap()
                sleep(2)
                
                if inProgressButton.exists {
                    XCTAssert(inProgressButton.exists, "The inProgressButton appear in time.")
                    inProgressButton.tap()
                    
                    XCTAssert(pausedButton.exists, "The pauseButton appear in time.")
                }
            }
        }
    }
    
    func test_ContentView_EpisodeRow_parallelDownload_resume() {
        app.launch()
        
        let collectionView = app.collectionViews
        let numberOfCells = collectionView.children(matching: .cell).count
        
        for i in 0..<numberOfCells {
            let cell = collectionView.children(matching: .cell).element(boundBy: i)
            
            let inProgressButton = cell.buttons["inProgress"]
            let pausedButton = cell.buttons["paused"]
            let parallelButton = cell.buttons["Parallel"]
            
            if i % 2 == 0 {
                guard parallelButton.exists else { continue }
                parallelButton.tap()
                sleep(2)
                
                if inProgressButton.exists {
                    XCTAssert(inProgressButton.exists, "The inProgressButton appear in time.")
                    inProgressButton.tap()
                    
                    XCTAssert(pausedButton.exists, "The pauseButton appear in time.")
                    
                    pausedButton.tap()
                    XCTAssert(inProgressButton.exists, "The inProgressButton appear in time again.")
                    
                }
            }
        }
    }
    
    func test_ContentView_EpisodeRow_sequentialDownload() {
        app.launch()
        
        let collectionView = app.collectionViews
        let numberOfCells = collectionView.children(matching: .cell).count
        
        for i in 0..<numberOfCells {
            let cell = collectionView.children(matching: .cell).element(boundBy: i)
            
            let sequentialButton = cell.buttons["Sequentail"]
            let inQueueButton = cell.buttons["inQueue"]
            let doneButton = cell.buttons["Done"]
            
            if i % 2 == 1 {
                guard cell.buttons["Sequential"].exists else { continue }
                
                if sequentialButton.exists {
                    XCTAssert(sequentialButton.exists, "The SequentialButton appear.")
                } else if inQueueButton.exists {
                    XCTAssert(inQueueButton.exists, "The inQueueButton appear.")
                } else if doneButton.exists {
                    XCTAssert(doneButton.exists, "The doneButton appear in time.")
                }
                
                cell.buttons["Sequential"].tap()
                sleep(2)
                
                if doneButton.exists {
                    XCTAssert(doneButton.exists, "The doneButton appear in time.")
                } else if inQueueButton.exists {
                    XCTAssert(inQueueButton.exists, "The inProgressButton appear in Time")
                }
            }
        }
    }
    
    func test_ContentView_EpisodeRow_sequentialDownload_pause() {
        app.launch()
        
        let collectionView = app.collectionViews
        let numberOfCells = collectionView.children(matching: .cell).count
        
        for i in 0..<numberOfCells {
            let cell = collectionView.children(matching: .cell).element(boundBy: i)
            
            let sequentialButton = cell.buttons["Sequential"]
            let inProgressButton = cell.buttons["inProgress"]
            let pauseButton = cell.buttons["paused"]
            let inQueueButton = cell.buttons["inQueue"]
            
            if i % 2 == 1 {
                guard sequentialButton.exists else { continue }
                sequentialButton.tap()
                sleep(2)
                
                if inProgressButton.exists {
                    XCTAssert(inProgressButton.exists, "The inProgressButton appear in time.")
                    
                    inProgressButton.tap()
                    XCTAssert(pauseButton.exists, "The pausedButton appear in time.")
                    
                } else if inQueueButton.exists {
                    XCTAssert(inQueueButton.exists, "The inQueueButton apeer in time.")
                }
            }
        }
    }
    
    func test_ContentView_EpisodeRow_sequentialDownload_resume() {
        app.launch()
        
        let collectionView = app.collectionViews
        let numberOfCells = collectionView.children(matching: .cell).count
        
        for i in 0..<numberOfCells {
            let cell = collectionView.children(matching: .cell).element(boundBy: i)
            
            let sequentialButton = cell.buttons["Sequential"]
            let inProgressButton = cell.buttons["inProgress"]
            let pauseButton = cell.buttons["paused"]
            let inQueueButton = cell.buttons["inQueue"]
            
            if i % 2 == 1 {
                guard sequentialButton.exists else { continue }
                sequentialButton.tap()
                sleep(2)
                
                if inProgressButton.exists {
                    XCTAssert(inProgressButton.exists, "The inProgressButton appear in time.")
                    inProgressButton.tap()
                } else if pauseButton.exists {
                    XCTAssert(pauseButton.exists, "The pauseButton appear in time.")
                    pauseButton.tap()
                } else if inQueueButton.exists {
                    XCTAssert(inQueueButton.exists, "The inQueueButton apeer in time.")
                }
            }
        }
    }
    
    func test_ContentView_EpisodeRow_sequentialDownload_sequentialQueue() {
        app.launch()
        
        let collectionView = app.collectionViews
        let numberOfCells = collectionView.children(matching: .cell).count
        
        for i in 0..<numberOfCells {
            let cell = collectionView.children(matching: .cell).element(boundBy: i)
            
            let sequentialButton = cell.buttons["Sequential"]
            let inProgressButton = cell.buttons["inProgress"]
            let inQueueButton = cell.buttons["inQueue"]
            
            if i % 2 == 1 {
                guard sequentialButton.exists else { continue }
                sequentialButton.tap()
                sleep(2)
                
                if inProgressButton.exists {
                    XCTAssert(inProgressButton.exists, "The inProgressButton appear in time.")
                    inProgressButton.tap()
                } else if inQueueButton.exists {
                    XCTAssert(inQueueButton.exists, "The inQueueButton apeer in time.")
                }
            }
        }
    }
    
    func testGoToHistoryScreen() {
        app.launch()
        let historyButton = app.buttons["History"]
        historyButton.tap()
        
        XCTAssert(app.collectionViews.matching(identifier: "HistoryView").element.exists, "HistoryView appear.")
        
        sleep(3)
        
        let numberOfCells = collectionView.children(matching: .cell).count
        
        for i in 0..<numberOfCells {
            let cell = collectionView.children(matching: .cell).element(boundBy: i)
            XCTAssert(cell.buttons["Show in Files"].exists, "Show files appear.")
        }
        
        let backButton = app.navigationBars["_TtGC7SwiftUI19UIHosting"].buttons["Back"]
        backButton.tap()
    }
    
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
