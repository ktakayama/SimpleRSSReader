//
//  XMLFeedTransformerTransformRSSTests.swift
//  SimpleRSSReader
//
//  Created by Kyosuke Takayama on 2016/03/08.
//  Copyright © 2016年 aill inc. All rights reserved.
//

import XCTest
import RealmSwift
@testable import SimpleRSSReader

class XMLFeedTransformerTransformRSSTests: XCTestCase {

    let xmlString = "" +
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
    "<rss version=\"2.0\">\n" +
    "<channel>\n" +
    "<title>鷹の島のRSS</title>\n" +
    "<link>http://espion.just-size.jp/</link>\n" +
    "<description>FaviconizeTab出したりTrac本書いたりしました。</description>\n" +
    "<language>ja</language>\n" +
    "<copyright>Copyright 2014</copyright>\n" +
    "<lastBuildDate>Mon, 01 Jul 2013 00:12:53 +0900</lastBuildDate>\n" +
    "<pubDate>Thu, 27 Mar 2014 16:07:06 +0900</pubDate>\n" +
    "<generator>http://www.movabletype.org/?v=3.0D</generator>\n" +
    "<docs>http://blogs.law.harvard.edu/tech/rss</docs>\n" +

    "<item>\n" +
    "<title>Kindlizer Backendを使ってニュースをKindleに配信</title>\n" +
    "<description>先日諸事情の人（なんのこっちゃ）が突然</description>\n" +
    "<link>http://espion.just-size.jp/archives/13/182001253.html</link>\n" +
    "<guid>http://espion.just-size.jp/archives/13/182001253.html</guid>\n" +
    "<category></category>\n" +
    "<pubDate>Mon, 01 Jul 2013 00:12:53 +0900</pubDate>\n" +
    "</item>\n" +

    "<item>\n" +
    "<title>さくらVPSのデータのフルバックアップにCopyを使ってみる</title>\n" +
    "<description>最近 Copy っていう Dropbox ぽい感じ</description>\n" +
    "<link>http://espion.just-size.jp/archives/13/175151913.html</link>\n" +
    "<guid>http://espion.just-size.jp/archives/13/175151913.html</guid>\n" +
    "<category></category>\n" +
    "<pubDate>Mon, 24 Jun 2013 15:19:13 +0900</pubDate>\n" +
    "</item>\n" +

    "</channel>\n" +
    "</rss>\n" +
    ""

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testTransform() {
        guard let feed: Feed = try? XMLFeedTransformer.transform(xmlString) else {
            XCTFail("Failed to transform xmlString")
            return
        }

        XCTAssertEqual(feed.title, "鷹の島のRSS")
        XCTAssertEqual(feed.entries.count, 2)

        let entry: Entry = feed.entries.first!
        XCTAssertEqual(entry.identifier, "http://espion.just-size.jp//http://espion.just-size.jp/archives/13/182001253.html")
        XCTAssertEqual(entry.title, "Kindlizer Backendを使ってニュースをKindleに配信")
        XCTAssertEqual(entry.summary, "先日諸事情の人（なんのこっちゃ）が突然")
        XCTAssertNil(entry.thumbnailURL)
        XCTAssertEqual(entry.linkURL, "http://espion.just-size.jp/archives/13/182001253.html")
    }

}
