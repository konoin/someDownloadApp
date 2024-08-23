//
//  ContentView.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 13.05.24.
//

import SwiftUI
import SwiftData
import Combine

struct ContentView: View {
    
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var contentViewViewModel: ContentViewViewModel
    
    @State private var selectedEpisodes: Set<Episode> = []
    @State var queueEpisodes: [Episode] = []
    @State var parallelEpisodes: [Episode] = []
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Header(podcast: contentViewViewModel.podcast)
                    if let podcast = contentViewViewModel.podcast {
                        ForEach(podcast.episodes!) { episode in
                            EpisodeRow(episode: episode, items: contentViewViewModel.historyItems,
                                       downloadButtonPressed: {
                                addToParallel(episode)
                                toggleDownload(for: episode)},
                                       addToQueueButtonPressed: {
                                togleSequential(for: episode)
                            }
                            )
                            .environmentObject(contentViewViewModel)
                        }
                    } else {
                        
                    }
                }
                .listStyle(.plain)
                
                .onAppear {
                    contentViewViewModel.updateHistoryItems()
                    contentViewViewModel.checkFile()
                }
                
                .safeAreaInset(edge: .top, content: {
                    Color.white.frame(maxHeight: safeAreaInsets.top)
                })
                .ignoresSafeArea()
                .scrollIndicators(.hidden)
                HStack {
                    NavigationLink{
                        DownloadList(parallelEpisodes: parallelEpisodes)
                            .environmentObject(contentViewViewModel)
                            .accessibilityIdentifier("SpeedInfo")
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
                        HistoryView(items: contentViewViewModel.historyItems)
                            .environmentObject(contentViewViewModel)
                            .accessibilityIdentifier("HistoryView")
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
        
//        .onChange(of: scenePhase) { newPhase in
//            switch newPhase {
//            case .inactive:
//                contentViewViewModel.checkFile(historyItems: Array(items))
//            case .active:
//                contentViewViewModel.checkFile(historyItems: Array(items))
//            case .background:
//                contentViewViewModel.checkFile(historyItems: Array(items))
//            }
//        }
        .accessibilityIdentifier("ContentView")
    }
}

private extension ContentView {
    
    func toggleDownload(for episode: Episode) {
        if episode.isDownloading {
            contentViewViewModel.pauseDownload(for: episode)
        } else {
            if episode.progress > 0 {
                contentViewViewModel.resumeDownload(for: episode)
            } else {
                Task {
                    try? await contentViewViewModel.downloadEpisode(episode, downloadQueue: .parallel)
                }
            }
        }
    }
    
    private func togleSequential( for episode: Episode) {
        if episode.isDownloading {
            contentViewViewModel.pauseDownload(for: episode)
        } else {
            if episode.progress > 0 {
                contentViewViewModel.resumeDownload(for: episode)
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
        contentViewViewModel.addEpisodeToQueue(episode, queue: .sequential)
        if !contentViewViewModel.queueEpisodes.contains(episode) {
            contentViewViewModel.queueEpisodes.append(episode)
        }
    }
}
