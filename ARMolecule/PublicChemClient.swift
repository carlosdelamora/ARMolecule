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
    private(set) var state: State = .notSearchedYet
    typealias  SearchComplete = (Bool) -> Void
    typealias haveCID = (Int?) -> Void
    enum State{
        case notSearchedYet
        case loading
        case noResults
        case results([Molecule])
    }
    
    func performCIDSearch(searchText: String, haveCID:@escaping haveCID){
        if !searchText.isEmpty{
            cidDataTask?.cancel()
            state = .loading
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            let url = cidURL(name: searchText)
            let session = URLSession.shared
            cidDataTask = session.dataTask(with: url, completionHandler: { (data,response, error) in
                
                var cid:Int? = nil
                
                if let error = error as NSError?, error.code == -999 {
                    return
                }else if let response = response as? HTTPURLResponse, 200 <= response.statusCode && response.statusCode <= 299{
                    
                    if let data = data, let jsonDictionary = self.parseJsonForCID(json: data){
                        
                        print(jsonDictionary)
                        /*var searchResults = self.parseDictionary(dictionary: jsonDictionary)
                        if searchResults.isEmpty {
                            
                            self.state = .noResults
                        }else{
                            searchResults.sort(by: <)
                            
                            self.state = .results(searchResults)
                        }
                        success = true*/
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
    
    func cidURL(name: String)-> URL {
        let stringURL = String(format: "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/%@/json", arguments: [name])
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
