//
//  DownloadList.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 15.05.24.
//

import SwiftUI

struct DownloadList: View {
    
    var downloadViewModel: MainViewModel
    
    var body: some View {
        VStack {
            List {
                ForEach(downloadViewModel.testEpisode) { episode in
                    Text(episode.title)
                    
                }
            }
        }
    }
}
//#Preview {
//    DownloadList()
//}
