//
//  NewsTableViewController.swift
//  ios-rss-reader
//
//  Created by Liubov Fedorchuk on 1/9/19.
//  Copyright © 2019 Liubov Fedorchuk. All rights reserved.
//

import UIKit

class NewsTableViewController: UITableViewController {
    
    var articlesList: [Article]?
    let articleManager = ArticleManager()
    let alertSetUp = AlertSetUp()
    var timer: Timer?
    var refreshBarButtonItem: UIBarButtonItem?
    var refreshBarButtonItemActivityIndicator: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpRefreshBarButton()
        getAllArticles()
    }
    
    private func setUpRefreshBarButton() {
        let image = UIImage(named: "icons8-rotate-50")?.withRenderingMode(.alwaysOriginal)
        refreshBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(refreshNewsByTapped))
        self.navigationItem.rightBarButtonItem  = refreshBarButtonItem

        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        refreshBarButtonItemActivityIndicator = UIBarButtonItem(customView: activityIndicator)
        activityIndicator.startAnimating()
        toogleIndicator()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func toogleIndicator() {
        timer = Timer.scheduledTimer(timeInterval: 600, target: self, selector: #selector(refreshNewsAutomatically), userInfo: nil, repeats: true)
    }
    
    @objc func refreshNewsByTapped(sender: AnyObject) {
        getAllArticles()
        self.navigationItem.rightBarButtonItem = refreshBarButtonItemActivityIndicator
        //Delay is created for example
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.navigationItem.rightBarButtonItem = self.refreshBarButtonItem
        }
        log.debug("News view has been refreshed.")
    }
    
    @objc func refreshNewsAutomatically() {
        getAllArticles()
        self.navigationItem.rightBarButtonItem = refreshBarButtonItemActivityIndicator
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.navigationItem.rightBarButtonItem = self.refreshBarButtonItem
        }
        
        log.debug("News view has been automatically refreshed after 10 minutes.")
    }
    
    private func getAllArticles() {
        articleManager.getArticle(completionHandler: { article, status in
            if (article != nil && status == 200) {
                self.articlesList = article!
                self.tableView.reloadData()
            } else {
                guard status != nil else {
                    let alert = self.alertSetUp.showAlert(alertTitle: "Unexpected error", alertMessage: "Please, try again later.")
                    self.present(alert, animated: true, completion: nil)
                    log.error("Unexpected error without status code.")
                    return
                }
                
                self.alertSetUp.showAlertAccordingToStatusCode(fromController: self, statusCode: status!)
            }
        })
    }
    
    private func convertDateFormater(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm"
        return  dateFormatter.string(from: date!)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articlesList?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = "NewsTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? NewsTableViewCell  else {
            fatalError("The dequeued cell is not an instance of NewsTableViewCell.")
        }
        
        let article = articlesList?[indexPath.row]
        let publishingDate = convertDateFormater((article?.publishingDate)!)
        cell.articleTitleLabel.text = article?.title
        cell.articleDescriptionLabel.text = article?.description
        cell.publishingDateLabel.text = publishingDate

        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "ShowSelectedWebpage":
            guard let newsViewController = segue.destination as? NewsViewController else {
                log.error("Unexpected destination: \(segue.destination)")
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedNewsTableViewCell = sender as? NewsTableViewCell else {
                log.error("Unexpected sender: \(String(describing: sender))")
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedNewsTableViewCell) else {
                log.error("The selected cell is not being displayed by the table")
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedNewsWebpage = articlesList?[indexPath.row]
            newsViewController.urlToWebPage = selectedNewsWebpage?.link
            newsViewController.articleTitle = selectedNewsWebpage?.title
        default:
            log.error("Unexpected Segue Identifier. \(String(describing: segue.identifier))")
            fatalError("Unexpected Segue Identifier. \(String(describing: segue.identifier))")
        }
    }
}
