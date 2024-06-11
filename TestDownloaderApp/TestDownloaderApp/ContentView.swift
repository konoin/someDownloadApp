//
//  ContentView.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 13.05.24.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var viewModel: MainViewModel
    @StateObject private var fetchResultManager = FetchedResultsManager(context: PersistenceController.shared.container.viewContext)
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \History.title, ascending: true)], animation: .default)
    
    private var items: FetchedResults<History>
    
    init() {
        let historyArray: [History] = []
        _viewModel = StateObject(wrappedValue: MainViewModel(historyItems: historyArray))
    }
    
    @State private var selectedEpisodes: Set<Episode> = []
    @State var queueEpisodes: [Episode] = []
    @State var parallelEpisodes: [Episode] = []
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Header(podcast: viewModel.podcast)
                    if let podcast = viewModel.podcast {
                        ForEach(podcast.episodes) { episode in
                            EpisodeRow(
                                items: items, viewModel: viewModel, episode: episode,
                                downloadButtonPressed: {
                                    addToParallel(episode)
                                    toggleDownload(for: episode) },
                                addToQueueButtonPressed: {
                                    togleSequential(for: episode)
                                }
                            )
                            .background(selectedEpisodes.contains(episode) ? Color.gray.opacity(0.2) : Color.clear)
                            .onTapGesture {
                                toggleSelection(for: episode)
                            }
                        }
                    } else {
                        ForEach(0..<10) { _ in
                            EpisodeRow(items: items, viewModel: viewModel, episode: Episode.preview, downloadButtonPressed: {
                            }, addToQueueButtonPressed: {})
                            .environment(\.managedObjectContext, viewContext)
                        }
                    }
                }
                .listStyle(.plain)
                
                .task {
                    try? await viewModel.fetchPodcast()
                }
                
                .onAppear {
                    viewModel.checkFile()
                }
                .safeAreaInset(edge: .top, content: {
                    Color.white.frame(maxHeight: safeAreaInsets.top)
                })
                .ignoresSafeArea()
                .scrollIndicators(.hidden)
                HStack {
                    NavigationLink{
                        DownloadList(queueEpisodes: $queueEpisodes, parallelEpisodes: $parallelEpisodes, progress: viewModel.progress)
                    } label: {
                        VStack {
                            Image(systemName: "gear")
                                .resizable()
                                .frame(width: 25, height: 25)
                            Text("Speed info")
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    
                    NavigationLink {
                        HistoryView(mainViewModel: viewModel)
                            .environment(\.managedObjectContext, viewContext)
                    } label: {
                        VStack {
                            Image(systemName: "arrow.down.circle")
                                .resizable()
                                .frame(width: 25, height: 25)
                            Text("History")
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    
                }
            }
        }
        .onAppear {
            viewModel.historyItems = Array(items)
        }
    }
}

#Preview {
    ContentView()
}


private extension ContentView {
    
    func fetchUpdatedData() {
        do {
//            try viewContext.fetch(.init(entityName: "DownloadHistory"))
        } catch {
            print("Failed to fetch updated data: \(error)")
        }
    }
    
    func toggleDownload(for episode: Episode) {
        if episode.isDownloading {
            viewModel.pauseDownload(for: episode)
        } else {
            if episode.progress > 0 {
                viewModel.resumeDownload(for: episode)
            } else {
                Task { try? await viewModel.download(episode) }
            }
        }
    }
    
    private func togleSequential( for episode: Episode) {
        if episode.isDownloading {
            viewModel.pauseDownload(for: episode)
        } else {
            if episode.progress > 0 {
                viewModel.resumeDownload(for: episode)
            } else {
                addToQueue(episode)
            }
        }
    }
    
    private func toggleSelection(for episode: Episode) {
        if selectedEpisodes.contains(episode) {
            selectedEpisodes.remove(episode)
        } else {
            selectedEpisodes.insert(episode)
        }
    }
    
    private func addToParallel(_ episode: Episode) {
        if !parallelEpisodes.contains(episode) {
            parallelEpisodes.append(episode)
        }
    }
    
    private func addToQueue(_ episode: Episode) {
        viewModel.addEpisodeToQueue(episode)
        if !queueEpisodes.contains(episode) {
            queueEpisodes.append(episode)
        }
    }
}
