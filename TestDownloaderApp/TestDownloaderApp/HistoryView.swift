//
//  HistoryView.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 31.05.24.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var filePicker = FilePickerManager()
    @EnvironmentObject var contentViewViewModel: ContentViewViewModel
    
    var items: [History]
    
    var body: some View {
        List {
            if (items.isEmpty) {
                Text("History is empty")
            } else {
                ForEach(items, id: \.self) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.title)
                            Text("\(item.date.formatted(date: .long, time: .shortened))")
                                Text(item.fileURL?.fileURL ?? "Deleted")
                        }
                        Spacer()
                        if item.downloaded {
                            Button {
                                filePicker.openFilePicker()
                            } label: {
                                Text("Show in Files")
                                    .padding()
                                    .background(Color.green.opacity(0.4))
                                    .cornerRadius(16)
                            }
                        } else {
                            Text("is deleted")
                                .padding()
                                .background(Color.red.opacity(0.4))
                                .cornerRadius(16)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
//        .onAppear {
//            contentViewViewModel.checkFile(historyItems: Array(items))
//        }
//        .onChange(of: scenePhase) { newPhase in
//            contentViewViewModel.checkFile(historyItems: Array(items))
//         }
    }
}
