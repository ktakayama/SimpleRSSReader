//
//  RealmResultsControllerDefaultDelegate.swift
//  SimpleRSSReader
//
//  Created by Kyosuke Takayama on 2016/03/16.
//  Copyright © 2016年 aill inc. All rights reserved.
//

import UIKit
import RealmResultsController

protocol RealmResultsControllerDefaultDelegate: RealmResultsControllerDelegate {
    var tableView: UITableView! { get set }
}

extension RealmResultsControllerDefaultDelegate {
    func willChangeResults(controller: AnyObject) {
        tableView.beginUpdates()
    }

    func didChangeObject<U>(controller: AnyObject, object: U, oldIndexPath: NSIndexPath, newIndexPath: NSIndexPath, changeType: RealmResultsChangeType) {
        switch changeType {
        case .Delete:
            tableView.deleteRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Top)
            break
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Top)
            break
        case .Move:
            tableView.deleteRowsAtIndexPaths([oldIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            break
        case .Update:
            tableView.reloadRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            break
        }
    }

    func didChangeSection<U>(controller: AnyObject, section: RealmSection<U>, index: Int, changeType: RealmResultsChangeType) {
        switch changeType {
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: index), withRowAnimation: UITableViewRowAnimation.Automatic)
            break
        case .Insert:
            tableView.insertSections(NSIndexSet(index: index), withRowAnimation: UITableViewRowAnimation.Automatic)
            break
        default:
            break
        }
    }

    func didChangeResults(controller: AnyObject) {
        tableView.endUpdates()
    }
}
