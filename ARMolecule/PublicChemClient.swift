//
//  PublicChemClient.swift
//  ARMolecule
//
//  Created by Carlos De la mora on 12/30/17.
//  Copyright © 2017 carlosdelamora. All rights reserved.
//

import Foundation
import UIKit

class PublicChemClient{
    
    private var cidDataTask: URLSessionDataTask? = nil
    private var moleculeDataTask: URLSessionDataTask? = nil
    private(set) var state: State = .notSearchedYet
    typealias  searchComplete = (Molecule?) -> Void
    typealias haveCID = (Int?) -> Void
    
    enum State{
        case notSearchedYet
        case loading
        case noResults
        case results(Molecule)
    }
    
    //we use this function to get a cid
    func performCIDSearch(searchText: String, haveCID:@escaping haveCID){
        if !searchText.isEmpty{
            cidDataTask?.cancel()
            state = .loading
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            let url = nameURL(name: searchText)
            let session = URLSession.shared
            cidDataTask = session.dataTask(with: url, completionHandler: { (data,response, error) in
                
                var cid:Int? = nil
                
                if let error = error as NSError?, error.code == -999 {
                    return
                }else if let response = response as? HTTPURLResponse, 200 <= response.statusCode && response.statusCode <= 299{
                    
                    if let data = data, let jsonDictionary = self.parseJsonForCID(json: data){
                        
                        guard let values = jsonDictionary["PC_Compounds"] as? [Any] else{
                            return
                        }
                        
                        guard let firstValue = (values[0] as? [String: Any]),let idValues = firstValue["id"] as? [String:Any] else{
                            return
                        }
                        
                        guard let secondIdValues = idValues["id"] as? [String:Int] else{
                            return
                        }
                        
                        guard let theCid = secondIdValues["cid"] else{
                            return
                        }
                        cid = theCid//if cid is null we should have no results as the state
                        if cid == nil {
                            self.state = .noResults
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    haveCID(cid)
                }
            })
            
            cidDataTask?.resume()
        }
    }
    
    //https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/oxygens/cids/json?name_type=word
    func nameURL(name: String)-> URL {
        let stringURL = String(format: "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/%@/json", arguments: [name])
        let url = URL(string:stringURL)
        return url!
    }
    
    //we use this function to get a molecule
    func performMoleculeSearch(cid:Int?, completion:@escaping searchComplete){
        
        moleculeDataTask?.cancel()
        state = .loading
        
        guard let cid = cid else{
            state = .noResults
            return
        }
        
        func stopNetworkActivity(){
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let url = cidURL(cid: cid)
        let session = URLSession.shared
        moleculeDataTask = session.dataTask(with: url, completionHandler: { (data,response, error) in
            
            
            var molecule: Molecule? = nil
            if let error = error as NSError?, error.code == -999 {
                return
            }else if let response = response as? HTTPURLResponse, 200 <= response.statusCode && response.statusCode <= 299{
                
                if let data = data, let jsonDictionary = self.parseJsonForCID(json: data){
                    
                    
                    guard let values = jsonDictionary["PC_Compounds"] as? [Any] else{
                        completion(molecule)
                        stopNetworkActivity()
                        return
                    }
                    
                    guard let firstValue = (values[0] as? [String: Any]) else{
                        completion(molecule)
                        stopNetworkActivity()
                        return
                    }
                    
                    guard var atomsAndCharge = firstValue["atoms"] as? [String:Any] else{
                        completion(molecule)
                        stopNetworkActivity()
                        return
                    }
                    
                    atomsAndCharge["charge"] = nil
                    guard let atoms = atomsAndCharge as? [String: [Int]] else {
                        completion(molecule)
                        stopNetworkActivity()
                        return
                    }
                    
                    guard let bonds = firstValue["bonds"] as? [String: [Int]] else{
                        completion(molecule)
                        stopNetworkActivity()
                        return
                    }
                    
                    molecule = Molecule()
                    molecule!.atoms = atoms
                    molecule!.bonds = bonds
                    
                    guard let coords = firstValue["coords"] as? [Any], let coordsValue = coords[0] as? [String:Any] else{
                        stopNetworkActivity()
                        completion(molecule)
                        return
                    }
                    
                    guard let conformersInArray = coordsValue["conformers"] as? [Any], let conformersDicionary = conformersInArray[0] as? [String: Any] else{
                        stopNetworkActivity()
                        completion(molecule)
                        return
                    }
                    
                    guard let conformers = Conformers(dictionary: conformersDicionary) else{
                        stopNetworkActivity()
                        completion(molecule)
                        return
                    }
                    
                    molecule?.conformers = conformers
                }
            }
            
            
            stopNetworkActivity()
            completion(molecule)
           
        })
        
        moleculeDataTask?.resume()
        
    }
    //https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/977/record/JSON/?record_type=3d&response_type=display
    func cidURL(cid:Int)-> URL{
        let stringURL = String(format: "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/%@/record/JSON/?record_type=3d&response_type=display", arguments: ["\(cid)"])
        let url = URL(string:stringURL)
        return url!
    }
    
    private func parseJsonForCID(json data: Data)-> [String: Any]?{
        
        do{
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        }catch{
            print("Json Error \(error)")
            return nil
        }
    }
    
}
