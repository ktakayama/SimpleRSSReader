//
//  EntryListViewController.swift
//  SimpleRSSReader
//
//  Created by Kyosuke Takayama on 2016/03/14.
//  Copyright © 2016年 aill inc. All rights reserved.
//

import UIKit
import SafariServices
import RealmSwift
import RealmResultsController
import UIAlertControllerExtension
import SwiftTask

class EntryListViewController: UITableViewController, RealmResultsControllerDefaultDelegate {

    var rrc: RealmResultsController<Entry, Entry>?

    var feed: Feed? {
        didSet {
            self.title = feed?.title

            let predicate = NSPredicate(format:"identifier BEGINSWITH %@", feed!.identifier)
            let sort = [ SortDescriptor(property:"publicAt", ascending:false) ]
            do {
                let realm = try Realm()
                let request = RealmRequest<Entry>(predicate:predicate, realm:realm, sortDescriptors:sort)
                rrc = try RealmResultsController(request:request, sectionKeyPath:nil)
                rrc?.delegate = self
                rrc?.performFetch()
                self.tableView.reloadData()
                FeedManager.lastSelectedFeed = feed

                if let ref = self.refreshControl {
                    ref.beginRefreshing()
                    let y = self.tableView.contentOffset.y - ref.frame.height
                    self.tableView.setContentOffset(CGPoint(x:0, y:y), animated:true)
                    self.performActionRefresh(ref)
                }
            } catch let error as NSError {
                presentAlert(title:String(error.code), message:error.localizedDescription, actionTitles: [ "OK" ])
            }
        }
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let feed = FeedManager.lastSelectedFeed {
            self.feed = feed
        } else {
            performSegueWithIdentifier("feedListViewController", sender:self)
        }
    }

    // MARK: - actions

    @IBAction func performActionRefresh(sender: UIRefreshControl) {
        if let f = self.feed {
            FeedManager.fetchFeed(f).success { (_) in
                sender.endRefreshing()
            }.failure { [unowned self] (error: NSError?, isCancelled: Bool) -> Void in
                sender.endRefreshing()
                self.presentAlert(title:String(error?.code), message:error?.localizedDescription, actionTitles: [ "OK" ])
            }
        } else {
            sender.endRefreshing()
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return rrc?.numberOfSections ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rrc?.numberOfObjectsAt(section) ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("entryCell", forIndexPath: indexPath) as! EntryListCellView
        cell.entry = rrc?.objectAt(indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let entry = rrc?.objectAt(indexPath) else { return }

        if let linkURLString = entry.linkURL, url = NSURL(string:linkURLString) {
            let safari = SFSafariViewController(URL:url)
            safari.title = entry.title
            safari.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(safari, animated:true)
        }

        if entry.unread == false { return }

        do {
            let realm = try Realm()
            try realm.write {
                if let e = realm.objectForPrimaryKey(Entry.self, key:entry.identifier) {
                    e.unread = false
                    e.notifyChange()
                }
            }
        } catch let error as NSError {
            presentAlert(title:String(error.code), message:error.localizedDescription, actionTitles: [ "OK" ])
        }
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "feedListViewController" {
            guard let viewController = segue.destinationViewController as? UINavigationController else {
                return
            }

            viewController.popoverPresentationController?.delegate = self
            if let feedListViewController = viewController.topViewController as? FeedListViewController {
                feedListViewController.feedSelectionHandler = { [unowned self] feed in
                    self.feed = feed
                    viewController.dismissViewControllerAnimated(true) {}
                }
            }
        }
    }

}

extension EntryListViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }

}
