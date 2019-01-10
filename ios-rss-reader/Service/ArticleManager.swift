//
//  ArticleManager.swift
//  ios-rss-reader
//
//  Created by Liubov Fedorchuk on 1/10/19.
//  Copyright © 2019 Liubov Fedorchuk. All rights reserved.
//

import Foundation
import Alamofire
import XMLMapper

class ArticleManager {
    
    let BASE_URL = "https://www.wired.com/feed/rss"
    
    func getArticle(completionHandler: @escaping ([Article]?, Int?) -> Void) {
        Alamofire.request(BASE_URL,
            method: .get,
            parameters: nil,
            encoding: XMLEncoding.default)
            .validate()
            .responseXMLArray(keyPath: "channel.item") {
                (response: DataResponse<[Article]>) in
                let status = response.response?.statusCode
                switch response.result {
                case .success:
                    guard status == 200 else {
                        log.debug("Request passed with status code, but not 200 OK: \(status!)")
                        completionHandler(nil, status!)
                        return
                    }
                    
                    let articleData = response.result.value!
                    completionHandler(articleData, status!)
                case .failure(let error):
                    guard status == nil else {
                        log.debug("Request failure with status code: \(status!)")
                        completionHandler(nil, status!)
                        return
                    }
                    
                    log.error("Request failure with error: \(error as! String)")
                    completionHandler(nil, nil);
                }
        }
    }
}
