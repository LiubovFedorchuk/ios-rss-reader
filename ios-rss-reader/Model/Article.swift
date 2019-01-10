//
//  Article.swift
//  ios-rss-reader
//
//  Created by Liubov Fedorchuk on 1/10/19.
//  Copyright © 2019 Liubov Fedorchuk. All rights reserved.
//

import Foundation
import XMLMapper

class Article: XMLMappable {
    
    var nodeName: String!
    
    var title: String!
    var description: String?
    var link: String?
    var publishingDate: String?
    
    required init?(map: XMLMap) {
    
    }
    
    func mapping(map: XMLMap) {
        title               <- map["title"]
        description         <- map["description"]
        link                <- map["link"]
        publishingDate      <- map["pubDate"]
    }
}
