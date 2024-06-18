//
//  Header.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 15.05.24.
//

import SwiftUI

struct Header: View {
    let podcast: Podcast?
    
    var body: some View {
        HStack {
            AsyncImage(url: podcast?.imageURL) { image in
                image
                    .resizable()
                    .cornerRadius(16.0)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 70, height: 70)
            
            VStack(alignment: .leading) {
                Text(podcast?.title ?? "Podcast title")
                    .font(.title)
                    .bold()
                Text(podcast?.artist ?? "Podcast artist")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom)
            .alignmentGuide(.listRowSeparatorTrailing) { _ in 0 }
            .redacted(reason: podcast == nil ? .placeholder : [])
            Spacer()
        }
    }
}
