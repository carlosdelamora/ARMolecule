//
//  ViewController.swift
//  ARMolecule
//
//  Created by Carlos De la mora on 1/7/18.
//  Copyright © 2018 carlosdelamora. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationBar.isTranslucent = true
    }

    var isSceneView:Bool = false{
        didSet{
            custom()
        }
    }
    let barTintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return isSceneView ? .lightContent : .default
    }
    
    func custom(){
        if isSceneView{
            navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            navigationBar.shadowImage = UIImage()
            view.backgroundColor = UIColor.clear
            navigationBar.tintColor = barTintColor
        }else{
            navigationBar.barTintColor = barTintColor
            navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
            navigationBar.shadowImage = nil
            view.backgroundColor = nil
            navigationBar.tintColor = .black
        }
    }

}
