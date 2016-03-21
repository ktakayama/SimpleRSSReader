//
//  XMLFeedTransformerTransformRSSTests.swift
//  SimpleRSSReader
//
//  Created by Kyosuke Takayama on 2016/03/08.
//  Copyright © 2016年 aill inc. All rights reserved.
//

import XCTest
import RealmSwift
import SWXMLHash
@testable import SimpleRSSReader

class XMLFeedTransformerTransformRSSTests: XCTestCase {

    var xmlData: XMLIndexer {
        get {
            let path = NSBundle(forClass:self.dynamicType).pathForResource("test_sample_rss2.0", ofType:"xml")
            let xmlString = try! String(contentsOfFile:path!, encoding:NSUTF8StringEncoding)

            return SWXMLHash.parse(xmlString)
        }
    }

    func testCompatibility() {
        XCTAssertTrue(XMLFeedTransformerTransformRSS().isCompatibleType(xmlData))
    }

    func testNoCompatible() {
        let xmlString = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<xmlBody>\n</xmlBody>\n"
        let invalidData = SWXMLHash.parse(xmlString)
        XCTAssertFalse(XMLFeedTransformerTransformRSS().isCompatibleType(invalidData))
    }

    func testBasicTransform() {
        guard let feed: Feed = try? XMLFeedTransformerTransformRSS().transform(xmlData) else {
            XCTFail("Failed to transform xmlString")
            return
        }

        XCTAssertEqual(feed.title, "鷹の島のRSS")
        XCTAssertEqual(feed.entries.count, 15)

        let entry: Entry = feed.entries.first!
        XCTAssertEqual(entry.identifier, "http://espion.just-size.jp//http://espion.just-size.jp/archives/13/182001253.html")
        XCTAssertEqual(entry.title, "Kindlizer Backendを使ってニュースをKindleに配信")
        XCTAssertTrue(entry.summary?.hasPrefix("先日諸事情の人（なんのこっちゃ）が突然「最近、ネットのニュースは SmartNews からしか読んでないから意見が偏ってこのままだとネットイナゴになる") ?? false)
        XCTAssertNil(entry.thumbnailURL)
        XCTAssertEqual(entry.linkURL, "http://espion.just-size.jp/archives/13/182001253.html")
    }

}
