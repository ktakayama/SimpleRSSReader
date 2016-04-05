//
//  XMLFeedTransformable.swift
//  SimpleRSSReader
//
//  Created by Kyosuke Takayama on 2016/03/07.
//  Copyright © 2016年 aill inc. All rights reserved.
//

import Foundation

protocol XMLFeedTransformable {
    associatedtype TransformType = Self

    static func mapping(feedInfo: XMLFeedInfo, feedItems: [ XMLFeedItem ]) -> TransformType
}
