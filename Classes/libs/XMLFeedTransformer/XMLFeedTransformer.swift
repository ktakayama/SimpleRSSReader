//
//  XMLFeedTransformer.swift
//  SimpleRSSReader
//
//  Created by Kyosuke Takayama on 2016/03/07.
//  Copyright © 2016年 aill inc. All rights reserved.
//

import Foundation
import SWXMLHash

enum XMLFeedTransformError: ErrorType {
   case UnkownFeedType, ParseError
}

struct XMLFeedInfo {
   let identifier: String
   let title: String
}

struct XMLFeedItem {
   let identifier: String
   let title: String?
   let summary: String?
   let publicAt: NSDate?
   let thumbnailURL: String?
   let linkURL: String?
}

class XMLFeedTransformer: NSObject {
    class func transform<T: XMLFeedTransformable where T.TransformType == T>(xmlData: String) throws -> T {
        let xml = SWXMLHash.parse(xmlData)

        for transform: XMLFeedTransformerTransformType in [ XMLFeedTransformerTransformRSS() ] {
            if transform.isCompatibleType(xml) {
                return try transform.transform(xml)
            }
        }

        throw XMLFeedTransformError.UnkownFeedType
    }
}

protocol XMLFeedTransformerTransformType {
    func isCompatibleType(xml: XMLIndexer) -> Bool
    func transform<T: XMLFeedTransformable where T.TransformType == T>(xml: XMLIndexer) throws -> T
}

struct XMLFeedTransformerTransformRSS: XMLFeedTransformerTransformType {
    static var dateFormatter: NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss ZZ"
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return formatter
    }

    func isCompatibleType(xml: XMLIndexer) -> Bool {
        if let rss = xml["rss"].element?.attributes["version"] where rss == "2.0" {
            return true
        } else {
            return false
        }
    }

    func transform<T: XMLFeedTransformable where T.TransformType == T>(xml: XMLIndexer) throws -> T {
        let title = xml["rss"]["channel"]["title"].element?.text ?? ""
        let identifier = xml["rss"]["channel"]["link"].element?.text ?? title
        if title.characters.count == 0 || identifier.characters.count == 0 { throw XMLFeedTransformError.ParseError }
        let feedInfo = XMLFeedInfo(identifier: identifier, title: title)

        var feedItems = [ XMLFeedItem ]()
        xml["rss"]["channel"]["item"].all.forEach { item in
            if let guid = item["guid"].element?.text {
                var date: NSDate?
                if let dateString = item["pubDate"].element?.text {
                    date = self.dynamicType.dateFormatter.dateFromString(dateString)
                }
                let feedItem = XMLFeedItem(identifier: guid, title: item["title"].element?.text,
                    summary: item["description"].element?.text,
                    publicAt: date,
                    thumbnailURL: nil, linkURL: item["link"].element?.text)
                feedItems.append(feedItem)
            }
        }

        return T.mapping(feedInfo, feedItems: feedItems)
    }
}

