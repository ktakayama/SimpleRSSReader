//
//  FeedTests.swift
//  SimpleRSSReader
//
//  Created by Takayama Kyosuke on 2016/03/21.
//  Copyright © 2016年 aill inc. All rights reserved.
//

import XCTest
import RealmSwift
@testable import SimpleRSSReader

class FeedTests: TestCaseBase {

    func testInitialUnreadCount() {
        let feed = Feed()
        XCTAssertEqual(feed.unreadCount, 0)
    }

    func testUnreadCountWithRealm() {
        let realm = try! Realm()
        let feed = Feed()
        let entry = Entry()
        try! realm.write {
            feed.entries.append(entry)
            realm.add(feed, update:true)
        }
        XCTAssertEqual(feed.unreadCount, 1)
    }

    func testUnreadCountWithoutRealm() {
        let feed = Feed()
        let entry = Entry()
        feed.entries.append(entry)
        XCTAssertEqual(feed.unreadCount, 1)
    }

}
