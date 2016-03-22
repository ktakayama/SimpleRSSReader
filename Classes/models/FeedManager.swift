//
//  FeedManager.swift
//  SimpleRSSReader
//
//  Created by Kyosuke Takayama on 2016/03/09.
//  Copyright © 2016年 aill inc. All rights reserved.
//

import UIKit
import Alamofire
import SwiftTask
import RealmSwift

final class FeedManager: NSObject {

    typealias FeedTask = Task<Void, Feed, NSError>
    typealias BulkFeedTask = Task<FeedTask.BulkProgress, [Feed], NSError>

    static let sharedInstance: FeedManager = FeedManager()

    private static let lastSelectedFeedKey = "lastSelectedFeed"
    static var lastSelectedFeed: Feed? {
        set {
            if let feed = newValue {
                NSUserDefaults.standardUserDefaults().setObject(feed.identifier, forKey:lastSelectedFeedKey)
            } else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey(lastSelectedFeedKey)
            }
        }

        get {
            if let feedIdentifier = NSUserDefaults.standardUserDefaults().objectForKey(lastSelectedFeedKey) {
                do {
                    let realm = try Realm()
                    return realm.objectForPrimaryKey(Feed.self, key:feedIdentifier)
                } catch {
                }
            }
            return nil
        }
    }

    private var taskCache = [ String:FeedTask ]()

    class func fetchFeed(feed: Feed) -> FeedTask {
        return FeedManager.sharedInstance.fetchFeed(feed)
    }

    class func fetchAllFeeds() -> BulkFeedTask {
        let task = Task<Void, Results<Feed>, NSError> { progress, fulfill, reject, configure in
            do {
                let realm = try Realm()
                fulfill(realm.objects(Feed))
            } catch let error as NSError {
                reject(error)
            }
        }

        return task.success { (feeds) -> BulkFeedTask in
            var tasks: [FeedTask] = Array()
            for feed in feeds {
                tasks.append(self.fetchFeed(feed))
            }
            return FeedTask.all(tasks)
        }
    }

    func fetchFeed(feed: Feed) -> FeedTask {
        if feed.identifier.characters.count > 0, let task = taskCache[feed.identifier] { return task }

        let task = FeedTask { progress, fulfill, reject, configure in
            Alamofire.request(.GET, feed.feedURL)
            .validate()
            .responseFeed { [unowned self] (response: Response<Feed, NSError>) in
                if let newFeed: Feed = response.result.value {
                    do {
                        let realm = try Realm()
                        try realm.write {
                            if feed.realm == nil { feed.identifier = newFeed.identifier }
                            feed.title = newFeed.title
                            feed.insertRecentEntries(newFeed.entries)
                            feed.updatedAt = NSDate()
                        }
                        fulfill(feed)
                    } catch let error as NSError {
                        reject(error)
                    }
                } else {
                    reject(response.result.error!)
                }
                self.taskCache[feed.identifier] = nil
            }
        }

        taskCache[feed.identifier] = task
        return task
    }

}

extension Alamofire.Request {
    func responseFeed(completionHandler: Response<Feed, NSError> -> Void) -> Self {
        let responseSerializer = ResponseSerializer<Feed, NSError> { request, response, data, error in
            guard error == nil else { return .Failure(error!) }

            if let data = data {
                do {
                    let xmlData = String(NSString(data:data, encoding:NSUTF8StringEncoding)!)
                    let object: Feed = try XMLFeedTransformer.transform(xmlData)
                    return Alamofire.Result.Success(object)
                } catch {
                }
            }

            let e = Error.errorWithCode(0, failureReason: "xml feed transform error")
            return Alamofire.Result.Failure(e)
        }

        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
}
