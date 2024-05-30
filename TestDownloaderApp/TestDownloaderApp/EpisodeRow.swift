//
//  EpisodeRow.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 15.05.24.
//

import SwiftUI
import Combine

struct EpisodeRow: View {
    
    @State var hideParallelButton: Bool = false
    @State var hideSequantelButton: Bool = false
    
//    let downloadStateTransformer = DownloadStateTransformer(downloadState: <#DownloadState#>)
    let viewModel: MainViewModel
    let episode: Episode
    let downloadButtonPressed: () -> Void
    let addToQueueButtonPressed: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 16.0) {
            VStack(alignment: .leading, spacing: 8.0) {
                Text(episode.title)
                    .font(.headline)
                Text(details ?? "Episode details")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
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
            Spacer()
            
            if viewModel.downloadEpisodes[episode.title] != nil {
                VStack {
                    Image(systemName: "checkmark.circle.fill")
                        .frame(maxWidth: 24, maxHeight: 24)
                        .foregroundColor(.white)
                        .padding(12)
                }
                .background(.blue)
                .cornerRadius(16)
            } else {
                HStack {
                    if !hideParallelButton {
                        Button {
                            downloadButtonPressed()
                            hideSequantelButton = true
                        } label: {
                            VStack {
                                Image(systemName: buttonImageName())
                                    .font(.title3)
                                    .frame(width: 24.0, height: 24.0)
                                    Text("Parallel")
                                    .font(.system(size: 12))
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(hideParallelButton)
                    }
                    
                    if !hideSequantelButton {
                        Button {
                            addToQueueButtonPressed()
                            hideParallelButton = true
                        } label: {
                            VStack {
                                Image(systemName: buttonImageName())
                                    .font(.title3)
                                    .frame(width: 24.0, height: 24.0)
                                Text("Sequential")
                                    .font(.system(size: 12))
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(hideSequantelButton)
                    }
                }
            }
        }
        .padding(.top, 8.0)
        .padding(.bottom, 4.0)
    }
}

#Preview {
    EpisodeRow(hideParallelButton: false, hideSequantelButton: false, viewModel: MainViewModel(), episode: Episode.preview) {
        print("")
    } addToQueueButtonPressed: {
        print("")
    }

}

private extension EpisodeRow {
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
