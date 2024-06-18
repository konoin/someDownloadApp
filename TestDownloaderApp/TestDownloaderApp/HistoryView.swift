//
//  HistoryView.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 31.05.24.
//

import SwiftUI

struct HistoryView: View {
    
    @StateObject private var filePicker = FilePickerManager()
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var mainViewModel: MainViewModel
    @Environment(\.scenePhase) private var scenePhase
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \History.title, ascending: true)], animation: .default)
    private var items: FetchedResults<History>
    
    var body: some View {
        List {
            if (items.isEmpty) {
                Text("History is empty")
            } else {
                ForEach(items, id: \.self) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.title ?? "not working")
                            Text("\(item.date?.formatted(date: .long, time: .shortened) ?? Date().formatted(date: .long, time: .shortened))")
                            if (item.fileURL != nil) {
                                Text(item.fileURL?.fileURL ?? "file url missing")
                            } else {
                                Text("Deleted")
                            }
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
        .onAppear {
            mainViewModel.checkFile(historyItems: Array(items))
        }
        .onChange(of: scenePhase) { newPhase in
            mainViewModel.checkFile(historyItems: Array(items))
         }
    }
}

#Preview {
    HistoryView()
}
