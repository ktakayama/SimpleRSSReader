//
//  FeedListViewController.swift
//  SimpleRSSReader
//
//  Created by Kyosuke Takayama on 2016/03/14.
//  Copyright © 2016年 aill inc. All rights reserved.
//

import UIKit
import RealmSwift
import RealmResultsController
import UIAlertControllerExtension
import SVProgressHUD
import SwiftTask

class FeedListViewController: UITableViewController, RealmResultsControllerDefaultDelegate {

    var realm: Realm
    var rrc: RealmResultsController<Feed, Feed>
    var feedSelectionHandler: ((feed: Feed) -> (Void))?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }

    required init?(coder aDecoder: NSCoder) {
        realm = try! Realm()
        let request = RealmRequest<Feed>(predicate: NSPredicate(value: true), realm:realm, sortDescriptors: [ SortDescriptor(property: "title") ])
        rrc = try! RealmResultsController(request:request, sectionKeyPath:nil)
        super.init(coder:aDecoder)
        rrc.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        rrc.performFetch()
    }

    // MARK: - actions

    @IBAction func performActionAddFeed(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Feed URL", message:nil, preferredStyle:.Alert)
        alertController.addTextFieldWithConfigurationHandler { (text: UITextField!) in text.placeholder = "http://" }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Default) { action in })

        alertController.addAction(UIAlertAction(title: "Add", style: .Default) { action in
            if let urlForm = alertController.textFields?.first, urlString = urlForm.text where urlString.characters.count > 0 {
                if self.realm.objects(Feed).filter("feedURL == %@", urlString).count == 0 {
                    self.prepareAddingNewFeed(urlString)
                } else {
                    self.presentAlert(title:"This feed already exists", message:nil, actionTitles: [ "OK" ])
                }
            } else {
                self.presentAlert(title:"Invalid url", message:nil, actionTitles: [ "OK" ])
            }
        })

        self.presentViewController(alertController, animated: true) {}
    }

    func prepareAddingNewFeed(urlString: String) {
        SVProgressHUD.showWithMaskType(.Clear)

        let feed = Feed()
        feed.feedURL = urlString

        FeedManager.fetchFeed(feed).success { [unowned self] (_) in
            do {
                try self.realm.write {
                    self.realm.addNotified(feed)
                }
            } catch let error as NSError {
                self.presentAlert(title:String(error.code), message:error.localizedDescription, actionTitles: [ "OK" ])
            }
            SVProgressHUD.showSuccessWithStatus(nil)
        }.failure { [unowned self] (error: NSError?, isCancelled: Bool) -> Void in
            SVProgressHUD.dismiss()
            self.presentAlert(title:String(error?.code), message:error?.localizedDescription, actionTitles: [ "OK" ])
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return rrc.numberOfSections
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rrc.numberOfObjectsAt(section)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("feedCell", forIndexPath: indexPath) as! FeedListViewCell
        cell.feed = rrc.objectAt(indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedFeed = rrc.objectAt(indexPath)
        if let feed = realm.objectForPrimaryKey(Feed.self, key:selectedFeed.identifier) {
            self.feedSelectionHandler?(feed: feed)
        }
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let feed = rrc.objectAt(indexPath)
            do {
                try realm.write {
                    if let f = realm.objectForPrimaryKey(Feed.self, key: feed.identifier) {
                        realm.deleteNotified(f.entries)
                        realm.deleteNotified(f)
                    }
                }
            } catch let error as NSError {
                presentAlert(title:String(error.code), message:error.localizedDescription, actionTitles: [ "OK" ])
            }
        }
    }

}
