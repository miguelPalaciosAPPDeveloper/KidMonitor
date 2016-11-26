//
//  ViewController.swift
//  KidMonitor
//
//  Created by Miguel Palacios on 23/11/15.
//  Copyright © 2015 Miguel Palacios. All rights reserved.
//

import UIKit

class ViewSplash: UIViewController {
    let SPLASH_SECONDS:Double = 4

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Thread.sleep(forTimeInterval: SPLASH_SECONDS)
        self.performSegue(withIdentifier: "ViewPrincipal", sender: self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

