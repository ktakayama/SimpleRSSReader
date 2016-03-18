//
//  EntryListCellView.swift
//  SimpleRSSReader
//
//  Created by Kyosuke Takayama on 2016/03/16.
//  Copyright © 2016年 aill inc. All rights reserved.
//

import UIKit
import CZDateFormatterCache

class EntryListCellView: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    var entry: Entry? {
        didSet {
            titleLabel.text = entry?.title
            dateLabel.text = CZDateFormatterCache.mainThreadCache()
            .localizedStringFromDate(entry?.publicAt, dateStyle:.MediumStyle, timeStyle:.MediumStyle)

            titleLabel.alpha = (entry?.unread == false) ? 0.5 : 1.0
            dateLabel.alpha = (entry?.unread == false) ? 0.5 : 1.0
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
