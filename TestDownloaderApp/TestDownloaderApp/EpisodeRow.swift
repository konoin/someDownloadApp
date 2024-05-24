//
//  EpisodeRow.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 15.05.24.
//

import SwiftUI
import Combine

struct EpisodeRow: View {
    let episode: Episode?
    let downloadButtonPressed: () -> Void
    let addToQueueButtonPressed: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 16.0) {
            VStack(alignment: .leading, spacing: 8.0) {
                Text(episode?.title ?? "Episode title")
                    .font(.headline)
                Text(details ?? "Episode details")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if progress > 0 && progress < 1.0 {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(Int((progress) * 100))%")
                            Text("\(String(format: "%.1f", downloadSpeed)) MB/s")
                        }
                        ProgressView(value: progress)
                    }
                }
            }
            Spacer()
            Button(action: downloadButtonPressed) {
                Image(systemName: buttonImageName)
                    .font(.title3)
                    .frame(width: 24.0, height: 24.0)
            }
            .buttonStyle(.borderedProminent)
            .contextMenu {
                Button(action: addToQueueButtonPressed) {
                    HStack {
                        Text("Add to Queue")
                        Image(systemName: "plus")
                    }
                }
                Button(action: downloadButtonPressed) {
                    HStack {
                        Text("Download")
                        Image(systemName: buttonImageName)
                            .font(.title3)
                            .frame(width: 24.0, height: 24.0)
                    }
                }
            }
        }
        .padding(.top, 8.0)
        .padding(.bottom, 4.0)
        .redacted(reason: episode == nil ? .placeholder : [])
    }
}

private extension EpisodeRow {
    var details: String? {
        guard let episode else { return nil }
        return episode.date.formatted(date: .long, time: .omitted)
        + " - " + episode.duration.formatted()
    }

    var progress: Double {
        episode?.progress ?? 0.0
    }
    
    var downloadSpeed: Double {
        episode?.speed ?? 0.0
    }

    var buttonImageName: String {
        switch (progress, episode?.isDownloading ?? false) {
            case (1.0, _): return "checkmark.circle.fill"
            case (_, true): return "pause.fill"
            default: return "tray.and.arrow.down"
        }
    }
}
