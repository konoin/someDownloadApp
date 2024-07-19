//
//  EpisodeRow.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 15.05.24.
//

import SwiftUI
import SwiftData
import Combine

struct EpisodeRow: View {
    
//    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \History.title, ascending: true)], animation: .default)
    
    @Query(sort: [SortDescriptor(\History.title)]) private var items: [History]
    
    var episode: Episode
    let downloadButtonPressed: () -> Void
    let addToQueueButtonPressed: () -> Void
    
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 16.0) {
                VStack(alignment: .leading, spacing: 8.0) {
                    Text(episode.title)
                        .font(.headline)
                    Text(details ?? "Episode details")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                if items.isEpisodeDownloaded(title: episode.title) {
                    VStack(spacing: 0) {
                        Image(systemName: "checkmark.circle.fill")
                            .frame(maxWidth: 24, maxHeight: 24)
                            .foregroundColor(.white)
                        Text("Done")
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                    }
                    .padding(12)
                    .background(.blue)
                    .cornerRadius(16)
                    .accessibility(addTraits: .isButton)
                    .accessibilityIdentifier("Done")
                } else {
                    DownloadButtons(downloadButtonPressed: downloadButtonPressed, addToQueueButtonPressed: addToQueueButtonPressed, episode: episode)
                        .accessibilityIdentifier(DownloadStateTransformer(downloadState: episode.downloadState).identifier)
                }
            }
            
            if progress > 0 && progress < 1.0 {
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(Int((progress) * 100))%")
                            .font(.system(size: 13))
                            .frame(width: 80, height: 15, alignment: .leading)
                        Text("\(String(format: "%.1f", downloadSpeed)) MB/s")
                            .font(.system(size: 13))
                            .frame(width: 80, height: 15, alignment: .leading)
                    }
                    
                    ProgressView(value: progress)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

private extension EpisodeRow {
    
//    func convertItems(items: FetchedResults<History>) -> [History] {
//        return Array(items)
//    }
    
    var details: String? {
        return episode.date.formatted(date: .long, time: .omitted)
        + " - " + episode.duration.formatted()
    }
    
    var progress: Double {
        episode.progress
    }
    
    var downloadSpeed: Double {
        episode.speed
    }
    
    func buttonImageName() -> String {
        DownloadStateTransformer(downloadState: episode.downloadState).image
    }
}

enum DownloadQueue {
    case idle
    case parallel
    case sequential
}


struct DownloadButtons: View {
    
    @EnvironmentObject var mainViewModel: MainViewModel
    
    let downloadButtonPressed: () -> Void
    let addToQueueButtonPressed: () -> Void
    var episode: Episode
    
    var body: some View {
        switch episode.downloadQueue {
        case .idle:
            HStack {
                Button {
                    downloadButtonPressed()
                } label: {
                    VStack {
                        Image(systemName: buttonImageName())
                            .font(.title3)
                            .frame(width: 24.0, height: 24.0)
                        Text("Parallel")
                            .font(.system(size: 10))
                    }
                }
                .buttonStyle(.borderedProminent)
                Button {
                    addToQueueButtonPressed()
                } label: {
                    VStack {
                        Image(systemName: buttonImageName())
                            .font(.title3)
                            .frame(width: 24.0, height: 24.0)
                        Text("Sequential")
                            .font(.system(size: 10))
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.top, 8.0)
            .padding(.bottom, 4.0)
            
        case .parallel, .sequential:
            Button {
                episode.downloadQueue == .parallel ? downloadButtonPressed() : addToQueueButtonPressed()
            } label: {
                VStack {
                    Image(systemName: buttonImageName())
                        .font(.title3)
                        .frame(width: 24.0, height: 24.0)
                    Text(episode.downloadQueue == .parallel ? "Parallel" : "Sequential")
                        .font(.system(size: 10))
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private func buttonImageName() -> String {
        DownloadStateTransformer(downloadState: episode.downloadState).image
    }
}
