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
    @StateObject var viewModel = MainViewModel()
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
                                viewModel: viewModel, episode: episode,
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
                            EpisodeRow(viewModel: viewModel, episode: Episode.preview, downloadButtonPressed: {
                            }, addToQueueButtonPressed: {})
                        }
                    }
                }
                .listStyle(.plain)
                
                .task {
                    try? await viewModel.fetchPodcast()
                }
                .onAppear {
                    viewModel.downloadUserDefaults()
                }
                .safeAreaInset(edge: .top, content: {
                    Color.white.frame(maxHeight: safeAreaInsets.top)
                })
                
                .ignoresSafeArea()
                .scrollIndicators(.hidden)
                
                NavigationLink(destination: DownloadList(queueEpisodes: $queueEpisodes, parallelEpisodes: $parallelEpisodes, progress: viewModel.progress)) {
                    Image(systemName: "arrow.down.circle")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}


private extension ContentView {
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
