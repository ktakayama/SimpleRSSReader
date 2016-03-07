//
//  Feed.swift
//  SimpleRSSReader
//
//  Created by Kyosuke Takayama on 2016/03/07.
//  Copyright © 2016年 aill inc. All rights reserved.
//

import Foundation
import RealmSwift

class Feed: Object, XMLFeedTransformable {
    dynamic var identifier: String = ""
    dynamic var title: String = ""
    dynamic var feedURL: String = ""
    dynamic var updatedAt: NSDate = NSDate()
    var entries = List<Entry>()

    override static func primaryKey() -> String? { return "identifier" }

    static func mapping(feedInfo: XMLFeedInfo, feedItems: [ XMLFeedItem ]) -> Feed {
        let feed = Feed()
        feed.identifier = feedInfo.identifier
        feed.title = feedInfo.title
        feed.updatedAt = NSDate()

        feedItems.forEach { item in
            let entry = Entry()
            entry.identifier = feed.identifier + "/" + item.identifier
            entry.title = item.title
            entry.summary = item.summary
            entry.publicAt = item.publicAt
            entry.thumbnailURL = item.thumbnailURL
            entry.linkURL = item.linkURL
            feed.entries.append(entry)
        }

        return feed
    }
}
