//
//  Entry.swift
//  SimpleRSSReader
//
//  Created by Kyosuke Takayama on 2016/03/07.
//  Copyright © 2016年 aill inc. All rights reserved.
//

import Foundation
import RealmSwift

class Entry: Object {
    dynamic var identifier: String = ""
    dynamic var title: String?
    dynamic var summary: String?
    dynamic var publicAt: NSDate?
    dynamic var thumbnailURL: String?
    dynamic var linkURL: String?
    dynamic var unread: Bool = true

    override static func primaryKey() -> String? { return "identifier" }

    var feed: Feed? {
        return linkingObjects(Feed.self, forProperty: "entries").first
    }
}
