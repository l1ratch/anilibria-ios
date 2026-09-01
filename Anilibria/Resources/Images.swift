//
//  Images.swift
//  AniLiberty
//

import UIKit

extension UIImage {
    enum System {
        private static func create(system: String) -> UIImage {
            UIImage(systemName: system) ?? UIImage()
        }

        static var feed: UIImage {
            UIImage(systemName: "sparkles.tv") ?? UIImage(systemName: "play.tv.fill") ?? create(system: "newspaper")
        }
        static var catalog: UIImage {
            UIImage(systemName: "square.grid.2x2.fill") ?? create(system: "magnifyingglass")
        }
        static var media: UIImage {
            UIImage(systemName: "play.rectangle.fill") ?? UIImage(systemName: "tv.fill") ?? create(system: "play.fill")
        }
        static var collections: UIImage {
            UIImage(systemName: "bookmark.fill") ?? create(system: "book")
        }
        static var more: UIImage {
            UIImage(systemName: "ellipsis.circle.fill") ?? UIImage(systemName: "gearshape.fill") ?? create(system: "ellipsis")
        }

        static var book: UIImage { create(system: "book") }
        static var play: UIImage { create(system: "play.fill") }
        static var pause: UIImage { create(system: "pause.fill") }
        static var share: UIImage { create(system: "square.and.arrow.up") }
        static var search: UIImage { create(system: "magnifyingglass") }
        static var news: UIImage { create(system: "newspaper") }
        static var history: UIImage { create(system: "memories") }
        static var star: UIImage { create(system: "star.fill") }
        static var calendar: UIImage { create(system: "calendar") }
        static var xmark: UIImage { create(system: "xmark") }
        static var checkmark: UIImage { create(system: "checkmark") }
        static var upDownArrows: UIImage { create(system: "arrow.up.arrow.down") }
        static var app: UIImage { create(system: "app") }
        static var checkmarkApp: UIImage { create(system: "checkmark.app") }
        static var checkmarkAppFill: UIImage { create(system: "checkmark.app.fill") }

        static var pencil: UIImage {
            create(system: "pencil")
                .applyingSymbolConfiguration(.init(weight: .semibold)) ?? UIImage()
        }

        static var dots: UIImage {
            create(system: "ellipsis")
                .applyingSymbolConfiguration(.init(weight: .bold)) ?? UIImage()
        }

        static var web: UIImage {
            create(system: "network")
                .applyingSymbolConfiguration(.init(weight: .bold)) ?? UIImage()
        }

        static var refresh: UIImage {
            create(system: "arrow.clockwise")
                .applyingSymbolConfiguration(.init(scale: .medium)) ?? UIImage()
        }

        enum Chevrone {
            static var right: UIImage { create(system: "chevron.right") }
            static var down: UIImage { create(system: "chevron.down") }
        }
    }
}
