//
//  TestCaseBase.swift
//  SimpleRSSReader
//
//  Created by Takayama Kyosuke on 2016/03/21.
//  Copyright © 2016年 aill inc. All rights reserved.
//

import XCTest
import RealmSwift

class TestCaseBase: XCTestCase {

    // https://realm.io/jp/docs/swift/latest/#section-44
    override func setUp() {
        super.setUp()
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
    }

}
