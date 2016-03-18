//
//  FeedListViewCell.swift
//  SimpleRSSReader
//
//  Created by Kyosuke Takayama on 2016/03/17.
//  Copyright © 2016年 aill inc. All rights reserved.
//

import UIKit

class FeedListViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var unreadCountLabel: UILabel?

    var feed: Feed? {
        didSet {
            titleLabel?.text = feed?.title
            unreadCountLabel?.text = String(feed?.unreadCount ?? 0)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
