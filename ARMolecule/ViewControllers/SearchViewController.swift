//
//  SearchViewController.swift
//  ARMolecule
//
//  Created by Carlos De la mora on 12/30/17.
//  Copyright © 2017 carlosdelamora. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController{

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var moleculeName: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    
    var molecule: Molecule? = nil
    let client = PublicChemClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchBar.delegate = self
        navigationItem.titleView = searchBar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButton(_ sender: Any) {
        let sceneViewController = storyboard?.instantiateViewController(withIdentifier: "SceneViewController") as! SceneViewController
        if let molecule = molecule{
            sceneViewController.molecules = [molecule]
        }
        navigationController?.pushViewController(sceneViewController, animated: true)
    }
    
    
}

extension SearchViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchtext = searchBar.text!.replacingOccurrences(of: " ", with: "-")
        client.performCIDSearch(searchText: searchtext) { (cid) in
            guard let cid = cid else{
                self.moleculeName.text = "We could not find the compound \(searchtext)"
                return
            }
            
            self.client.performMoleculeSearch(cid: cid, completion: { (molecule) in
                if let molecule = molecule{
                    self.molecule = molecule
                    DispatchQueue.main.async {
                        self.moleculeName.text = searchtext
                    }
                    
                    self.imageView.loadImge(cid: cid)
                  
                }else{
                    DispatchQueue.main.async {
                        self.moleculeName.text = "We could not find the molecule in 3D"
                    }
                    
                    self.imageView.image = nil
                }
            })
        }
        searchBar.resignFirstResponder()
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}


