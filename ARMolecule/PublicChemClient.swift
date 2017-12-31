//
//  PublicChemClient.swift
//  ARMolecule
//
//  Created by Carlos De la mora on 12/30/17.
//  Copyright © 2017 carlosdelamora. All rights reserved.
//

import Foundation


class PublicChemClient{
    
    private var cidDataTask: URLSessionDataTask? = nil
    private(set) var state: State = .notSearchedYet
    typealias  SearchComplete = (Bool) -> Void
    
    enum State{
        case notSearchedYet //this is the state in case of an error
        case loading
        case noResults
        case results([Molecule])
    }
    
    
    
}
