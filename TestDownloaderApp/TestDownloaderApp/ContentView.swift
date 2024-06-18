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
    
    @EnvironmentObject var mainViewModel: MainViewModel
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \History.title, ascending: true)], animation: .default)
    var items: FetchedResults<History>
    
    @State private var selectedEpisodes: Set<Episode> = []
    @State var queueEpisodes: [Episode] = []
    @State var parallelEpisodes: [Episode] = []
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Header(podcast: mainViewModel.podcast)
                    if let podcast = mainViewModel.podcast {
                        ForEach(podcast.episodes) { episode in
                            EpisodeRow(episode: episode,
                                       downloadButtonPressed: {
                                addToParallel(episode)
                                toggleDownload(for: episode)},
                                addToQueueButtonPressed: {
                                    togleSequential(for: episode)
                                }
                            )
                            .environmentObject(mainViewModel)
                        }
                    } else {
                        
                    }
                }
                .listStyle(.plain)
                
                .onAppear {
                    mainViewModel.updateHistoryItems(with: items)
                    mainViewModel.checkFile(historyItems: Array(items))
                }
                .safeAreaInset(edge: .top, content: {
                    Color.white.frame(maxHeight: safeAreaInsets.top)
                })
                .ignoresSafeArea()
                .scrollIndicators(.hidden)
                HStack {
                    NavigationLink{
                        DownloadList(parallelEpisodes: parallelEpisodes)
                            .environmentObject(mainViewModel)
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
                            .environmentObject(mainViewModel)
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
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .inactive:
                mainViewModel.checkFile(historyItems: Array(items))
            case .active:
                mainViewModel.checkFile(historyItems: Array(items))
            case .background:
                mainViewModel.checkFile(historyItems: Array(items))
            }
            
            
         }
    }
}

private extension ContentView {

    func toggleDownload(for episode: Episode) {
        if episode.isDownloading {
            mainViewModel.pauseDownload(for: episode)
        } else {
            if episode.progress > 0 {
                mainViewModel.resumeDownload(for: episode)
            } else {
                Task {
                    try? await mainViewModel.downloadEpisode(episode, downloadQueue: .parallel)
                }
            }
        }
    }
    
    private func togleSequential( for episode: Episode) {
        if episode.isDownloading {
            mainViewModel.pauseDownload(for: episode)
        } else {
            if episode.progress > 0 {
                mainViewModel.resumeDownload(for: episode)
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
        mainViewModel.addEpisodeToQueue(episode, queue: .sequential)
        if !mainViewModel.queueEpisodes.contains(episode) {
            mainViewModel.queueEpisodes.append(episode)
        }
    }
}
