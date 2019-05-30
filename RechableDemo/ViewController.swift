//
//  ViewController.swift
//  RechableDemo
//
//  Created by mpllc on 5/30/19.
//  Copyright © 2019 mpllc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var wifiNameLabel: UILabel!
    @IBOutlet weak var networkIndicatorLabel: UILabel!
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.networkChanged(_:)), name: Notification.Name("rechabilityChanged"), object: nil)
        let rechabilityObj = RechabilityHelper()
        rechabilityObj.startHost(at: 0)
    }
    
    @objc func networkChanged(_ notification: Notification) {
        if let netName = notification.userInfo?["wifiName"] as? String {
            DispatchQueue.main.async {
                if netName != self.wifiNameLabel.text && self.wifiNameLabel.text != "" && netName != "" {
                    self.showAlert(title: "Alert", msg: "Network Changed")
                }
                self.wifiNameLabel.text = netName
            }
        }
    }
    
    @objc func timerAction() {
        UIView.animate(withDuration: 1.0) {
            self.networkIndicatorLabel.alpha = 0
        }
        timer?.invalidate()
    }
}

