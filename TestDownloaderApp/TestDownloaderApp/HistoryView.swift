//
//  HistoryView.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 31.05.24.
//

import SwiftUI

struct HistoryView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \History.title, ascending: true)], animation: .default)
    private var items: FetchedResults<History>
    
    var body: some View {
        List {
            if items.isEmpty {
                Text("History is empty")
            } else {
                ForEach(items, id: \.self) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.title ?? "not working")
                            Text("\(item.date?.formatted(date: .long, time: .shortened) ?? Date().formatted(date: .long, time: .shortened))")
                        }
                        Spacer()
                        if item.fileURL != nil {
                            Button {
//                                mainViewModel?.openFilePicker()
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
    }
}

#Preview {
    HistoryView()
}
