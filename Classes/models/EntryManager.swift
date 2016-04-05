//
//  EntryManager.swift
//  SimpleRSSReader
//
//  Created by Takayama Kyosuke on 2016/04/05.
//  Copyright © 2016年 aill inc. All rights reserved.
//

import UIKit
import RealmSwift

class EntryManager: NSObject {

    class func unreadCount() -> Int? {
        do {
            let realm = try Realm()
            return realm.objects(Entry).filter("unread == true").count
        } catch {
            return nil
        }
    }

}
