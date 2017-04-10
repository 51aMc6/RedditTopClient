//
//  TopRedditListView.swift
//  RedditTopClient
//
//  Created by Siamac 6 on 4/6/17.
//  Copyright © 2017 Siamac6. All rights reserved.
//

import UIKit

extension String {
    
    public func isImage() -> Bool {
        let imgFormat = ["jpg", "jpeg", "png", "gif"]
        let extn = self.getExtension()
        if imgFormat.contains(extn) {
            return true
        }
        return false
    }
    public func getExtension() -> String {
        let ext = URL(string: (self as String))?.pathExtension
        if (ext?.isEmpty)! {
            return ""
        }
        return ext!
    }
}

class TopRedditListView : UITableViewController {
    var myData = [[String:Any]]()
    var afterPage = String()
    var domainUrl = "https://www.reddit.com/top.json?count=25&after="
    var itemLink : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(buttonClickedNotification),
                                               name: Notification.Name("notificationID"),
                                               object: nil
        )
        fetchRedditTopData(nextPage: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func buttonClickedNotification(_ note : Notification!) {
        if let urlStr = note.object {
            itemLink = urlStr as? String
        }
 //        if let urlStr = note.object {
//            let optionMenue = UIAlertController (title: nil,
//                                                 message: "Choose option",
//                                                 preferredStyle: .actionSheet
//            )
//            let viewImageAction = UIAlertAction(title: "View it", style: .default, handler: { (alert: UIAlertAction!) -> Void in
////                UIApplication.shared.open(URL(string: urlStr as! String)!, options: [:], completionHandler: nil)
//            })
//            let cancelAct = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//            optionMenue.addAction(viewImageAction)
//            if (urlStr as! String).isImage() {
//                let saveAction = UIAlertAction(title: "Save Image to gallery", style: .default, handler: { (alert: UIAlertAction!) -> Void in
//                    let data = NSData(contentsOf: URL(string: urlStr as! String)!)
//                    let myImage = UIImage.init(data: data as! Data)
//                    UIImageWriteToSavedPhotosAlbum(myImage!, nil, nil, nil)
//                })
//
//                optionMenue.addAction(saveAction)
//            }
//            optionMenue.addAction(cancelAct)
//            self.present(optionMenue, animated: true, completion: nil)
//        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowLink" {
            let webView = segue.destination as! WebViewController
            webView.webUrlStr = itemLink

        }
    }
    
    
    func fetchRedditTopData(nextPage: String?) {
        if self.myData.count < 50 {
            let url = URL(string: domainUrl+(nextPage ?? ""))
            let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, respond, error) in
                let data = data
                let error = error
                if error == nil && data != nil {
                    do {
                        if let theJson = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String:Any] {
                            let branches = theJson["data"] as? [String:Any]
                            if let childData = branches?["children"] as? [[String:Any]], let afterString = branches?["after"] as? String {
                    
                                DispatchQueue.main.async {
                                    if self.myData.isEmpty {
                                        self.myData = childData
                                        self.afterPage = afterString
                                    } else {
                                        self.myData += childData
                                    }
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            })
            task.resume()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_id", for: indexPath) as! RedditTableViewCell
        if let item = self.myData[indexPath.row]["data"] as? [String:Any]{
            
            cell.authorLbl.text = item["author"] as! String?
            let createdTime = calculateTime(utc_seconds: item["created_utc"] as! Double)
            cell.dateLbl.text = "\(createdTime) ago"
            cell.titleLbl.text = item["title"] as! String?
            cell.commentNumLbl.text = String(describing: item["num_comments"] as! NSNumber)
            if let itemURL = item["url"] as? String {
                cell.thumbnailBtn.layer.setValue(itemURL , forKey: "url")
            } else {
                cell.thumbnailBtn.layer.setValue(nil , forKey: "url")
            }
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: URL(string: item["thumbnail"] as! String)!)
                DispatchQueue.main.async {
                    if data == nil {
                        cell.thumbnailBtn.backgroundColor = UIColor.lightGray
                        cell.thumbnailBtn.setImage(nil, for: .normal)
                    } else {
                        cell.thumbnailBtn.setImage(UIImage(data: data!), for: .normal)
                    }
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndx = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndx) - 1
        if indexPath.section == lastSectionIndx && indexPath.row == lastRowIndex && self.myData.count < 50 {
            fetchRedditTopData(nextPage: afterPage)
        }
    }
    
    func calculateTime(utc_seconds : Double) -> String {
        let utcDate = Date(timeIntervalSince1970: TimeInterval(utc_seconds))
        let dateCompFormatter = DateComponentsFormatter()
        dateCompFormatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        dateCompFormatter.unitsStyle = .full
        dateCompFormatter.maximumUnitCount = 1
        return dateCompFormatter.string(from: utcDate, to: Date())!
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
    }
}
