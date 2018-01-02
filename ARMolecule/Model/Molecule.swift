//
//  Molecule.swift
//  ARMolecule
//
//  Created by Carlos De la mora on 12/30/17.
//  Copyright © 2017 carlosdelamora. All rights reserved.
//

import Foundation

class Molecule{
    var name = ""
    var conformers:Conformers = Conformers()
    var atoms: [String: [Int]] = [:]//should have keys "aid", "element", element is given by the number of protons of the atom
    var bonds:[String: [Int]] = [:]// should have keys "aid1" "aid2" and "order"
}


struct Conformers {
    var x: [Float] = []
    var y: [Float] = []
    var z: [Float] = []
    
    init(){
        
    }
    
    init?(dictionary:[String:Any]){
        guard let x = dictionary["x"] as? [Float], let y = dictionary["y"] as? [Float], let z = dictionary["z"] as? [Float] else{
            return nil 
        }
        self.x = x
        self.y = y
        self.z = z
    }
}
