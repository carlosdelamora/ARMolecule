//
//  UIImageView+DownloadingImage.swift
//  ARMolecule
//
//  Created by Carlos De la mora on 1/2/18.
//  Copyright © 2018 carlosdelamora. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView{
    
    func loadImge(cid: Int){
        DispatchQueue.main.async {
            //set the content to aspect fit
            self.contentMode = .scaleAspectFill
            //we check if we have an activity indicator with the tag 200, if we do not we create one
            let activityIndicator = self.viewWithTag(200) as? UIActivityIndicatorView
            if activityIndicator == nil{
                let activity = UIActivityIndicatorView()
                activity.translatesAutoresizingMaskIntoConstraints = false
                self.addSubview(activity)
                self.centerXAnchor.constraint(equalTo: activity.centerXAnchor).isActive = true
                self.centerYAnchor.constraint(equalTo: activity.centerYAnchor).isActive = true
                activity.startAnimating()
                activity.color = UIColor.darkGray
                activity.tag = 200
            }else{
                activityIndicator?.startAnimating()
            }
        }
        
        let url = cidURL(cid: cid)
        let datatask = URLSession.shared.dataTask(with: url) {  [weak self] (data, response, error) in
            guard error == nil else{
                return
            }
            
            if let data = data, let image = UIImage(data:data){
                DispatchQueue.main.async {
                    if let strongSelf = self{
                        let activity = strongSelf.viewWithTag(200) as? UIActivityIndicatorView
                        strongSelf.image = image
                        activity?.stopAnimating()
                    }
                }
            }else{
                //show that nothing was found
                DispatchQueue.main.async {
                    if let strongSelf = self{
                        //TODO: missing image image
                    }
                }
            }
        }
        datatask.resume()
    }
    
    func cidURL(cid:Int)-> URL{
        let stringURL = String(format: "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/%@/PNG", arguments: ["\(cid)"])
        let url = URL(string:stringURL)
        return url!
    }
}
