//
//  NewsViewController.swift
//  ios-rss-reader
//
//  Created by Liubov Fedorchuk on 1/10/19.
//  Copyright © 2019 Liubov Fedorchuk. All rights reserved.
//

import UIKit
import WebKit

class NewsViewController: UIViewController {

    @IBOutlet var newsView: UIView!
    @IBOutlet weak var newsWebView: WKWebView!

    var urlToWebPage: String?
    var articleTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: urlToWebPage!)
        let request = URLRequest(url: url!)
        newsWebView.load(request)
        if (self.articleTitle != nil) {
            navigationItem.title = articleTitle!
        }
    }
}
