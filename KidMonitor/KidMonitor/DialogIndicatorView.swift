//
//  DialogIndicatorView.swift
//  KidMonitor
//
//  Created by Miguel Palacios on 06/12/15.
//  Copyright © 2015 Miguel Palacios. All rights reserved.
//

import Foundation
import UIKit
class DialogIndicatorView:NSObject {
    fileprivate var mTableViewController:UIViewController?
    
    init(viewController:UITableViewController) {
        super.init()
        mTableViewController = viewController
    }
    
    func crearDialog(_ titulo:String) ->UIAlertView{
        let indicatorViewAlert = UIAlertView(title: titulo, message: nil, delegate: nil, cancelButtonTitle: nil);
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 50, y: 10, width: 37, height: 37)) as UIActivityIndicatorView
        loadingIndicator.center = mTableViewController!.view.center;
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        loadingIndicator.color = UIColor(red: 0.9569, green: 0.686, blue: 0.353, alpha: 1.0)
        loadingIndicator.startAnimating();
        
        indicatorViewAlert.setValue(loadingIndicator, forKey: "accessoryView")
        loadingIndicator.startAnimating()
        
        //indicatorViewAlert.show();
        //indicatorViewAlert.dismissWithClickedButtonIndex(0, animated: true)
        return indicatorViewAlert
    }
}
