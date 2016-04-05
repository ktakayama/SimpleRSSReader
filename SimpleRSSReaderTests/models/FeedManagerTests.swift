//
//  FeedManagerTests.swift
//  SimpleRSSReader
//
//  Created by Takayama Kyosuke on 2016/03/22.
//  Copyright © 2016年 aill inc. All rights reserved.
//

import XCTest
import RealmSwift
import Mockingjay
@testable import SimpleRSSReader

class FeedManagerTests: TestCaseBase {

    let testFeedURL = "http://espion.just-size.jp/atom.xml"
    let testFeedTitle = "鷹の島のATOM"
    let testFeedEntryCount = 15

    var xmlString: String {
        let path = NSBundle(forClass:self.dynamicType).pathForResource("test_sample_atom", ofType:"xml")
        return try! String(contentsOfFile:path!, encoding:NSUTF8StringEncoding)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testFetchSingleFeed() {
        let expectation = self.expectationWithDescription("fetch single feed")

        self.stub(uri(testFeedURL), builder:http(data:xmlString.dataUsingEncoding(NSUTF8StringEncoding)))

        let feed = Feed()
        feed.feedURL = testFeedURL

        FeedManager.fetchFeed(feed).success { (feed) in
            XCTAssertEqual(feed.title, self.testFeedTitle)
            XCTAssertEqual(feed.entries.count, self.testFeedEntryCount)
            expectation.fulfill()
        }

        self.waitForExpectationsWithTimeout(5, handler: nil)
    }

    func testNotFoundFeed() {
        let expectation = self.expectationWithDescription("not found")

        let error = NSError(domain:"error", code:404, userInfo:nil)
        self.stub(uri(testFeedURL), builder:failure(error))

        let feed = Feed()
        feed.feedURL = testFeedURL

        FeedManager.fetchFeed(feed).success { (feed) in
            XCTFail("do not execute here... " + feed.feedURL)
        }.failure { (error: NSError?, isCancelled: Bool) -> Void in
            XCTAssertEqual(error?.code, 404)
        }.then { (_) in
            expectation.fulfill()
        }

        self.waitForExpectationsWithTimeout(5, handler: nil)
    }

    func testParseErrorFeed() {
        let expectation = self.expectationWithDescription("parse error")

        let str = "<feed xmlns=\"http://purl.org/atom/ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xml:lang=\"ja\">\n"
        self.stub(uri(testFeedURL), builder:http(data:str.dataUsingEncoding(NSUTF8StringEncoding)))

        let feed = Feed()
        feed.feedURL = testFeedURL

        FeedManager.fetchFeed(feed).success { (feed) in
            XCTFail("do not execute here... " + feed.feedURL)
        }.failure { (error: NSError?, isCancelled: Bool) -> Void in
            XCTAssertEqual(error, XMLFeedTransformError.ParseError as NSError)
        }.then { (_) in
            expectation.fulfill()
        }

        self.waitForExpectationsWithTimeout(5, handler: nil)
    }

    func testFetchMultiFeed() {
        let expectation = self.expectationWithDescription("fetch multi feed")

        let customTestFeedCount = 10

        func customId(index: Int) -> String {
            return "custom_id_" + String(index)
        }

        func customURL(index: Int) -> String {
            return testFeedURL + "?" + String(index)
        }

        for i in 1...customTestFeedCount {
            let str = xmlString.stringByReplacingOccurrencesOfString("tag:espion.just-size.jp,2006://1",
                                                                         withString:customId(i))
            self.stub(uri(customURL(i)), builder:http(data:str.dataUsingEncoding(NSUTF8StringEncoding)))
        }

        let realm = try! Realm()
        try! realm.write {
            for i in 1...customTestFeedCount {
                let feed = Feed()
                feed.identifier = customId(i)
                feed.feedURL = customURL(i)
                realm.add(feed, update:true)
            }
        }

        FeedManager.fetchAllFeeds().success { (feeds) in
            XCTAssertEqual(feeds.count, customTestFeedCount)

            for feed in feeds {
                XCTAssertEqual(feed.title, self.testFeedTitle)
                XCTAssertEqual(feed.entries.count, self.testFeedEntryCount)
            }

            expectation.fulfill()
        }

        self.waitForExpectationsWithTimeout(5, handler: nil)
    }

}
