//
//  WebViewController.swift
//  RedditTopClient
//
//  Created by Siamac 6 on 4/10/17.
//  Copyright © 2017 Siamac6. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    var webUrlStr : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if webUrlStr != nil {
            setUpWebOrImageVIew()
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        if self.webUrlStr!.isImage() {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save to Gallery",
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(saveToGallery)
            )
        }
    }

    func setUpWebOrImageVIew() {
        if let urlStr = self.webUrlStr {
            if urlStr.isImage() {
                let data = NSData(contentsOf: URL(string: urlStr)!)
                let myImage = UIImage.init(data: data as! Data)
                let imageView = UIImageView(frame: UIScreen.main.bounds)
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.contentMode = .scaleAspectFit
                imageView.image = myImage
                self.view.addSubview(imageView)
                imageView.topAnchor.constraint(equalTo: webView.topAnchor).isActive = true
                imageView.leadingAnchor.constraint(equalTo: webView.leadingAnchor).isActive = true
                imageView.trailingAnchor.constraint(equalTo: webView.trailingAnchor).isActive = true
                imageView.centerXAnchor.constraint(equalTo: webView.centerXAnchor).isActive = true
                imageView.centerYAnchor.constraint(equalTo: webView.centerYAnchor).isActive = true
                imageView.widthAnchor.constraint(equalTo: webView.widthAnchor).isActive = true
                imageView.heightAnchor.constraint(equalTo: webView.heightAnchor).isActive = true
            } else {
                let url = URL(string: urlStr)
                let req = URLRequest(url: url!)
                self.webView.loadRequest(req)
            }
        }

    }
    func saveToGallery() {
        let data = NSData(contentsOf: URL(string: self.webUrlStr!)!)
        if let myImage = UIImage.init(data: data as! Data) {
            UIImageWriteToSavedPhotosAlbum(myImage, nil, nil, nil)
        }

    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(self.webUrlStr, forKey: "urlString")
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        self.webUrlStr = coder.decodeObject(forKey: "urlString") as! String?
        setUpWebOrImageVIew()
        super.decodeRestorableState(with: coder)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
