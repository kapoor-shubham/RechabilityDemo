//
//  Helper.swift
//  RechableDemo
//
//  Created by mpllc on 5/30/19.
//  Copyright © 2019 mpllc. All rights reserved.
//

import UIKit
import SystemConfiguration.CaptiveNetwork

var hostLabelName: String? {
    didSet {
        print(hostLabelName)
    }
}
var networkStatus: String? {
    didSet {
        print(networkStatus)
        if networkStatus == "No Connection" {
            if let topVC = UIApplication.topViewController() {
//                topVC.showAlert(title: "Alert", msg: "Network Lost")
            }
        }
    }
}

public class RechabilityHelper {
    
    var reachability: Reachability?
    let hostNames = [nil, "google.com", "invalidhost"]
    var hostIndex = 0
    
    func startHost(at index: Int) {
        stopNotifier()
        setupReachability(hostNames[index], useClosures: true)
        startNotifier()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.startHost(at: (index + 1) % 3)
        }
    }
    
    func setupReachability(_ hostName: String?, useClosures: Bool) {
        let reachability: Reachability?
        if let hostName = hostName {
            reachability = Reachability(hostname: hostName)
            hostLabelName = hostName
        } else {
            reachability = Reachability()
            hostLabelName = "No host name"
        }
        self.reachability = reachability
        print("--- set up with host name: \(hostLabelName)")
        
        if useClosures {
            reachability?.whenReachable = { reachability in
                self.updateLabelColourWhenReachable(reachability)
            }
            reachability?.whenUnreachable = { reachability in
                self.updateLabelColourWhenNotReachable(reachability)
            }
        } else {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(reachabilityChanged(_:)),
                name: .reachabilityChanged,
                object: reachability
            )
        }
    }
    
    func startNotifier() {
        print("--- start notifier")
        do {
            try reachability?.startNotifier()
        } catch {
//            networkStatus.textColor = .red
            networkStatus = "Unable to start\nnotifier"
            return
        }
    }
    
    func stopNotifier() {
        print("--- stop notifier")
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
        reachability = nil
    }
    
    func updateLabelColourWhenReachable(_ reachability: Reachability) {
        print("\(reachability.description) - \(reachability.connection)")
        if reachability.connection == .wifi {
//            self.networkStatus.textColor = .green
        } else {
//            self.networkStatus.textColor = .blue
        }
        
        
        if let topVC = UIApplication.topViewController() as? ViewController, networkStatus != "\(reachability.connection)" {
            networkStatus = "\(reachability.connection)"
            topVC.timer = Timer.scheduledTimer(timeInterval: 5.0, target: topVC, selector: #selector(topVC.timerAction), userInfo: nil, repeats: true)
            DispatchQueue.main.async {
                topVC.networkIndicatorLabel.backgroundColor = UIColor.green
                topVC.networkIndicatorLabel.isHidden = false
            }
        }
    }
    
    func updateLabelColourWhenNotReachable(_ reachability: Reachability) {
        print("\(reachability.description) - \(reachability.connection)")
        
        if let topVC = UIApplication.topViewController() as? ViewController, networkStatus != "\(reachability.connection)" {
            networkStatus = "\(reachability.connection)"
            topVC.timer = Timer.scheduledTimer(timeInterval: 5.0, target: topVC, selector: #selector(topVC.timerAction), userInfo: nil, repeats: true)
            DispatchQueue.main.async {
                topVC.networkIndicatorLabel.backgroundColor = UIColor.red
                topVC.networkIndicatorLabel.isHidden = false
            }
        }
    }
    
    @objc func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Reachability
        
        if reachability.connection != .none {
            updateLabelColourWhenReachable(reachability)
        } else {
            updateLabelColourWhenNotReachable(reachability)
        }
    }
    
    deinit {
        stopNotifier()
    }
}

