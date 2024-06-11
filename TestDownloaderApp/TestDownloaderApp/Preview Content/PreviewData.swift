//
//  PreviewData.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 15.05.24.
//

import Foundation

extension Podcast {
    static var preview: Podcast {
        let url = Bundle.main.url(forResource: "JSON", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try! decoder.decode(Podcast.self, from: data)
    }
}

extension [Episode] {
    static var preview: [Episode] {
        Podcast.preview.episodes
    }
}

extension Episode {
    static var preview: Episode {
        var episode = [Episode].preview[0]
        episode.update(currentBytes: 90, totalBytes: 100, speed: 643.0)
        return episode
    }
}

import SwiftUI

extension UITabBarController {
    var height: CGFloat {
        return self.tabBar.frame.size.height
    }
    
    var width: CGFloat {
        return self.tabBar.frame.size.width
    }
}


extension UIApplication {
    var keyWindow: UIWindow? {
        connectedScenes
            .compactMap {
                $0 as? UIWindowScene
            }
            .flatMap {
                $0.windows
            }
            .first {
                $0.isKeyWindow
            }
    }
    
}

private struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        UIApplication.shared.keyWindow?.safeAreaInsets.swiftUiInsets ?? EdgeInsets()
    }
}


private extension UIEdgeInsets {
    var swiftUiInsets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}

extension FileManager {
    class func fileExists(filePath: String) -> Bool {
        var isDirectory = ObjCBool(false)
        return self.default.fileExists(atPath: filePath, isDirectory: &isDirectory)
    }
}

extension EnvironmentValues {
    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}

enum DownloadState {
    case inProgress
    case inQueue
    case downloaded
    case idle
    case paused
    case sendRequest
}

struct DownloadStateTransformer {
    
    private let downloadState: DownloadState
    
    init(downloadState: DownloadState) {
        self.downloadState = downloadState
    }
    
    var image: String {
        switch downloadState {
        case .inProgress:
            return "pause.fill"
        case .inQueue:
            return "stopwatch"
        case .sendRequest:
            return "paperplane"
        case .idle:
            return "tray.and.arrow.down"
        case .paused:
            return "play"
        case .downloaded:
            return "checkmark.circle.fill"
        }
    }
}

extension Array where Element == History {
    func isEpisodeDownloaded(title: String) -> Bool {
        return self.first(where: { $0.title == title })?.downloaded ?? false
    }
}

extension URL: Comparable {
    public static func < (lhs: URL, rhs: URL) -> Bool {
        return lhs.absoluteString < rhs.absoluteString
    }
}
