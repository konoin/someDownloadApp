//
//  FilePickerManager.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 13.06.24.
//

import UIKit

final class FilePickerManager: NSObject, ObservableObject {
    func openFilePicker() {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.item])
        documentPicker.delegate = UIApplication.shared.windows.first?.rootViewController as? UIDocumentPickerDelegate
        documentPicker.allowsMultipleSelection = false
        let casefileUrl = documentsUrl.appendingPathComponent("Casefile True Crime")
        documentPicker.directoryURL = casefileUrl
        
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            rootViewController.present(documentPicker, animated: true, completion: nil)
        }
    }
}

