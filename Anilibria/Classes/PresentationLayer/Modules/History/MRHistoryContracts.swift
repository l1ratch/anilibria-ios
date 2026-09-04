import UIKit

// MARK: - Models

public struct HistoryItemModel: Hashable {
    public let series: Series
    public let episodeID: String?
    public let playlistItem: PlaylistItem?
    public let timeCode: TimeCodeData?

    public init(
        series: Series,
        episodeID: String?,
        playlistItem: PlaylistItem?,
        timeCode: TimeCodeData?
    ) {
        self.series = series
        self.episodeID = episodeID
        self.playlistItem = playlistItem
        self.timeCode = timeCode
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(series.id)
        hasher.combine(episodeID)
        hasher.combine(timeCode?.time)
        hasher.combine(timeCode?.isWatched)
    }

    public static func == (lhs: HistoryItemModel, rhs: HistoryItemModel) -> Bool {
        lhs.series.id == rhs.series.id &&
        lhs.episodeID == rhs.episodeID &&
        lhs.timeCode?.time == rhs.timeCode?.time &&
        lhs.timeCode?.isWatched == rhs.timeCode?.isWatched
    }
}

// MARK: - Helper

public enum HistoryTimecodeHelper {
    public static func formatTime(_ seconds: TimeInterval) -> String {
        let totalSeconds = max(0, Int(seconds))
        let s = totalSeconds % 60
        let m = (totalSeconds / 60) % 60
        let h = totalSeconds / 3600
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        } else {
            return String(format: "%02d:%02d", m, s)
        }
    }

    public static func formatEpisodeAndDuration(
        playlistItem: PlaylistItem?,
        timeCode: TimeCodeData?,
        totalDuration: TimeInterval?
    ) -> (text: String, progress: Float) {
        let epText: String? = {
            if let ord = playlistItem?.ordinal {
                let num = ord.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(ord))" : "\(ord)"
                return Language.isEnglish ? "Ep. \(num)" : "Серия \(num)"
            }
            return nil
        }()

        var parts: [String] = []
        if let ep = epText {
            parts.append(ep)
        }

        var progress: Float = 0
        let duration = (totalDuration ?? playlistItem?.duration) ?? 0

        if let tc = timeCode {
            if tc.isWatched {
                parts.append(Language.isEnglish ? "Watched" : "Просмотрено")
                progress = 1.0
            } else if tc.time > 5 {
                let timeStr = formatTime(tc.time)
                if duration > 0 {
                    let durationStr = formatTime(duration)
                    parts.append("\(timeStr) / \(durationStr)")
                    progress = Float(min(max(tc.time / duration, 0.0), 1.0))
                } else {
                    parts.append(timeStr)
                    progress = 0.5
                }
            }
        }

        let text = parts.isEmpty
            ? (Language.isEnglish ? "Tap to play" : "Нажмите для воспроизведения")
            : parts.joined(separator: " • ")

        return (text, progress)
    }
}

// MARK: - Contracts

protocol HistoryViewBehavior: WaitingBehavior {
    func set(items: [HistoryItemModel])
}

protocol HistoryEventHandler: ViewControllerEventHandler {
    func bind(view: HistoryViewBehavior, router: HistoryRoutable)

    func delete(item: HistoryItemModel)
    func select(item: HistoryItemModel)
    func continueWatching(item: HistoryItemModel)
    func search(query: String)
}
