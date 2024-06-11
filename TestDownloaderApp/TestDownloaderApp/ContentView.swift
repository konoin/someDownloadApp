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
    @EnvironmentObject var viewModelFactory: ViewModelFactory
    
    @ObservedObject var fetchViewModel: FetchRequestViewModel
    @ObservedObject var saveViewModel: SaveViewModel
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \History.title, ascending: true)], animation: .default)
    private var items: FetchedResults<History>
    
    init(fetchViewModel: FetchRequestViewModel, saveViewModel: SaveViewModel) {
         self.fetchViewModel = fetchViewModel
        self.saveViewModel = saveViewModel
    }
    
    @State private var selectedEpisodes: Set<Episode> = []
    @State var queueEpisodes: [Episode] = []
    @State var parallelEpisodes: [Episode] = []
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Header(podcast: fetchViewModel.podcast)
                    if let podcast = fetchViewModel.podcast {
                        ForEach(podcast.episodes) { episode in
                            EpisodeRow(
                                items: items, episode: episode,
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
                            EpisodeRow(items: items, episode: Episode.preview, downloadButtonPressed: {
                            }, addToQueueButtonPressed: {})
                            .environment(\.managedObjectContext, viewContext)
                        }
                    }
                }
                .listStyle(.plain)
                .task {
                    await fetchViewModel.fetchEpisodes()
                }
                .safeAreaInset(edge: .top, content: {
                    Color.white.frame(maxHeight: safeAreaInsets.top)
                })
                .ignoresSafeArea()
                .scrollIndicators(.hidden)
                HStack {
                    NavigationLink{
                        DownloadList(queueEpisodes: $queueEpisodes, parallelEpisodes: $parallelEpisodes, progress: viewModelFactory.downloadConroller.progress)
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
                        HistoryView()
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
        .environmentObject(fetchViewModel)
    }
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
            viewModelFactory.downloadConroller.pauseDownload(for: episode)
        } else {
            if episode.progress > 0 {
                viewModelFactory.downloadConroller.resumeDownload(for: episode)
            } else {
                Task { try? await viewModelFactory.downloadConroller.download(episode) }
            }
        }
    }
    
    private func togleSequential( for episode: Episode) {
        if episode.isDownloading {
            viewModelFactory.downloadConroller.pauseDownload(for: episode)
        } else {
            if episode.progress > 0 {
                viewModelFactory.downloadConroller.resumeDownload(for: episode)
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
        viewModelFactory.downloadConroller.addEpisodeToQueue(episode)
        if !queueEpisodes.contains(episode) {
            queueEpisodes.append(episode)
        }
    }
}
