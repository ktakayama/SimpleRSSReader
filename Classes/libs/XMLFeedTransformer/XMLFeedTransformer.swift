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

        for transform: XMLFeedTransformerTransformType in [
            XMLFeedTransformerTransformAtom(),
            XMLFeedTransformerTransformRSS()
        ] {
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

struct XMLFeedTransformerTransformAtom: XMLFeedTransformerTransformType {
    static var dateFormatter: NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return formatter
    }

    func isCompatibleType(xml: XMLIndexer) -> Bool {
        let xmlns = xml["feed"].element?.attributes["xmlns"] ?? ""
        if xmlns == "http://purl.org/atom/ns#" || xmlns == "http://www.w3.org/2005/Atom" {
            return true
        } else {
            return false
        }
    }

    func transform<T: XMLFeedTransformable where T.TransformType == T>(xml: XMLIndexer) throws -> T {
        let title = xml["feed"]["title"].element?.text ?? ""
        let identifier = xml["feed"]["id"].element?.text ?? title
        if title.characters.count == 0 || identifier.characters.count == 0 { throw XMLFeedTransformError.ParseError }
        let feedInfo = XMLFeedInfo(identifier: identifier, title: title)

        var feedItems = [ XMLFeedItem ]()
        xml["feed"]["entry"].all.forEach { item in
            if let id = item["id"].element?.text {
                var date: NSDate?
                if let dateString = item["created"].element?.text ?? item["updated"].element?.text {
                    date = self.dynamicType.dateFormatter.dateFromString(dateString)
                }
                let feedItem = XMLFeedItem(identifier: id, title: item["title"].element?.text,
                    summary: item["summary"].element?.text,
                    publicAt: date,
                    thumbnailURL: nil, linkURL: item["link"].element?.attributes["href"])
                feedItems.append(feedItem)
            }
        }

        return T.mapping(feedInfo, feedItems: feedItems)
    }
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

