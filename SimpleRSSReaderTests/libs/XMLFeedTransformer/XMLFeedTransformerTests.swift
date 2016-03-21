//
//  XMLFeedTransformerTests.swift
//  SimpleRSSReader
//
//  Created by Takayama Kyosuke on 2016/03/21.
//  Copyright © 2016年 aill inc. All rights reserved.
//

import XCTest
import RealmSwift
@testable import SimpleRSSReader

class XMLFeedTransformerTests: TestCaseBase {

    func testTransformAtom() {
        let path = NSBundle(forClass:self.dynamicType).pathForResource("test_sample_atom", ofType:"xml")
        let xmlString =  try! String(contentsOfFile:path!, encoding:NSUTF8StringEncoding)

        guard let feed: Feed = try? XMLFeedTransformer.transform(xmlString) else {
            XCTFail("Failed to transform xmlString")
            return
        }

        XCTAssertEqual(feed.title, "鷹の島のATOM")
        XCTAssertEqual(feed.entries.count, 15)
    }

    func testTransformRSS() {
        let path = NSBundle(forClass:self.dynamicType).pathForResource("test_sample_rss2.0", ofType:"xml")
        let xmlString = try! String(contentsOfFile:path!, encoding:NSUTF8StringEncoding)

        guard let feed: Feed = try? XMLFeedTransformer.transform(xmlString) else {
            XCTFail("Failed to transform xmlString")
            return
        }

        XCTAssertEqual(feed.title, "鷹の島のRSS")
        XCTAssertEqual(feed.entries.count, 15)
    }

}
