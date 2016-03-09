//
//  XMLFeedTransformerTransformAtomTests.swift
//  SimpleRSSReader
//
//  Created by Kyosuke Takayama on 2016/03/08.
//  Copyright © 2016年 aill inc. All rights reserved.
//

import XCTest
import RealmSwift
@testable import SimpleRSSReader

class XMLFeedTransformerTransformAtomTests: XCTestCase {

    let xmlString = "" +
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
    "<feed version=\"0.3\" xmlns=\"http://purl.org/atom/ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xml:lang=\"ja\">" +
    "<title>鷹の島のATOM</title>" +
    "<link rel=\"alternate\" type=\"text/html\" href=\"http://espion.just-size.jp/\" />" +
    "<modified>2013-07-01T14:38:34Z</modified>" +
    "<tagline>FaviconizeTab出したりTrac本書いたりしました。最近はiPhoneアプリ開発ばかり。 要約はRSSで、全文はATOMで配信中</tagline>" +
    "<id>tag:espion.just-size.jp,2006://1</id>" +
    "<generator url=\"http://www.movabletype.org/\" version=\"3.0D\">Movable Type</generator>" +
    "<copyright>Copyright (c) 2013, Kyosuke Takayama</copyright>" +
    "<entry>" +
    "<title>さくらVPSのデータのフルバックアップにCopyを使ってみる</title>" +
    "<link rel=\"alternate\" type=\"text/html\" href=\"http://espion.just-size.jp/archives/13/175151913.html\" />" +
    "<modified>2013-07-11T12:02:52Z</modified>" +
    "<issued>2013-06-24T06:19:13Z</issued>" +
    "<id>tag:espion.just-size.jp,2013://1.759</id>" +
    "<created>2013-06-24T06:19:13Z</created>" +
    "<summary type=\"text/plain\">最近 Copy っていう Dropbox ぽい感じのオンラインストレージが出てきました</summary>" +
    "<author>" +
    "<name>Kyosuke Takayama</name>" +
    "" +
    "<email>loiseau+nos@gmail.com</email>" +
    "</author>" +
    "" +
    "<content type=\"text/html\" mode=\"escaped\" xml:lang=\"en\" xml:base=\"http://espion.just-size.jp/\">" +
    "<![CDATA[<p>最近 <a href=\"https://copy.com?r=j2ON7f\">Copy</a> っていう Dropbox ぽい感じのオンラインストレージが出てきました</p>" +
    "<p>データベース使ってる場合は、ダンプしたデータを /mnt/encfs 以下に定期的に出力するとより安心かもしれないですね。</p>]]>" +
    "" +
    "</content>" +
    "</entry>" +
    "<entry>" +
    "<title>XUL/Migemo の Firefox20 対応</title>" +
    "<link rel=\"alternate\" type=\"text/html\" href=\"http://espion.just-size.jp/archives/13/096000050.html\" />" +
    "<modified>2013-04-10T13:49:01Z</modified>" +
    "<issued>2013-04-05T15:00:50Z</issued>" +
    "<id>tag:espion.just-size.jp,2013://1.758</id>" +
    "<created>2013-04-05T15:00:50Z</created>" +
    "<summary type=\"text/plain\"><![CDATA[XUL/Migemo にどっかで見つけたパッチあてて使えてたんだけど...]]></summary>" +
    "<author>" +
    "<name>Kyosuke Takayama</name>" +
    "" +
    "<email>loiseau+nos@gmail.com</email>" +
    "</author>" +
    "" +
    "<content type=\"text/html\" mode=\"escaped\" xml:lang=\"en\" xml:base=\"http://espion.just-size.jp/\">" +
    "<![CDATA[<p><a href=\"https://addons.mozilla.org/ja/firefox/addon/xulmigemo/\">XUL/Migemo</a> にどっかで見つけたパッチあてて使えてたんだけど</p>" +
    "<ul >" +
    "<li> <a href=\"http://piro.sakura.ne.jp/xul/xpi/nightly/\"  >http://piro.sakura.ne.jp/xul/xpi/nightly/</a></li>" +
    "</ul>]]>" +
    "" +
    "</content>" +
    "</entry>" +
    "" +
    "</feed>" +
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

        XCTAssertEqual(feed.title, "鷹の島のATOM")
        XCTAssertEqual(feed.entries.count, 2)

        let entry: Entry = feed.entries.first!
        XCTAssertEqual(entry.identifier, "tag:espion.just-size.jp,2006://1/tag:espion.just-size.jp,2013://1.759")
        XCTAssertEqual(entry.title, "さくらVPSのデータのフルバックアップにCopyを使ってみる")
        XCTAssertEqual(entry.summary, "最近 Copy っていう Dropbox ぽい感じのオンラインストレージが出てきました")
        XCTAssertNil(entry.thumbnailURL)
        XCTAssertEqual(entry.linkURL, "http://espion.just-size.jp/archives/13/175151913.html")
    }

}
