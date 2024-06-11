//
//  ViewModelFactory.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 11.06.24.
//

import Foundation
import CoreData
import SwiftUI

class ViewModelFactory: ObservableObject {
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \History.title, ascending: true)], animation: .default)
    private var items: FetchedResults<History>
    
    let downloadConroller = DownloadController()
    
    func makeSaveViewModel() -> SaveViewModel {
        
        return SaveViewModel(downloadController: downloadConroller, historyItems: Array(items))
    }
    
    func makeFetchViewModel() -> FetchRequestViewModel {
        return FetchRequestViewModel(downloadController: downloadConroller)
    }
}
