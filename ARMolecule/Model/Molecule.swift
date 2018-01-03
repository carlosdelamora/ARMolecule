//
//  Molecule.swift
//  ARMolecule
//
//  Created by Carlos De la mora on 12/30/17.
//  Copyright © 2017 carlosdelamora. All rights reserved.
//

import Foundation
import ARKit
class Molecule{
    var name = ""
    var conformers:Conformers = Conformers()
    var atoms: [String: [Int]] = [:]//should have keys "aid", "element", element is given by the number of protons of the atom
    var bonds:[String: [Int]] = [:]// should have keys "aid1" "aid2" and "order"
    var normalizedConformers:Conformers {
        var conformer = Conformers()
        conformer.x = self.conformers.x.map({$0/7})
        conformer.y = self.conformers.y.map({$0/7})
        conformer.z = self.conformers.z.map({$0/7})
        return conformer
    }
    var dictionaryOfColors:[Int:UIColor] = [1:.white, 6:.black,7:.blue, 8:.red,9:.orange, 15:.brown, 16:.yellow, 17:.green, 35:.darkGray, 53:.purple]
    var gravicenter:SCNVector3{
        let x = self.normalizedConformers.x.reduce(0, {$0 + $1})/Float(conformers.x.count)
        let y = self.normalizedConformers.y.reduce(0, {$0 + $1})/Float(conformers.y.count)
        let z = self.normalizedConformers.z.reduce(0, {$0 + $1})/Float(conformers.z.count)
        let vector = SCNVector3(CGFloat(x),CGFloat(y), CGFloat(z))
        return vector
    }
    var radiusOfTheMolecule: Float{
        guard let maxX = normalizedConformers.x.map({abs($0 - Float(gravicenter.x))}).max(),let maxY = normalizedConformers.y.map({abs($0 - Float(gravicenter.y))}).max() ,let maxZ = normalizedConformers.z.map({abs($0 - Float(gravicenter.z))}).max() else{
            return 0.0
        }
        return sqrt(maxX*maxX + maxY*maxY + maxZ*maxZ)
    }
    
    func createSceneMolecule()-> SCNNode{
        let gravicenterNode = SCNNode(geometry: nil)
        guard let atomsArray = atoms["element"] else{return gravicenterNode}
        for i in 0..<atomsArray.count{
            let radius = pow(Double(atomsArray[i]),1.0/3.0)/100
            let sphere = SCNSphere(radius:CGFloat(radius))
            sphere.firstMaterial?.diffuse.contents = UIColor.magenta
            if let color = dictionaryOfColors[atomsArray[i]]{
                 sphere.firstMaterial?.diffuse.contents = color
            }
            //let sphereNode = SCNNode(geometry: sphere)
            let atomNode = SCNNode(geometry: sphere)
            gravicenterNode.addChildNode(atomNode)
            atomNode.position = SCNVector3(CGFloat(normalizedConformers.x[i]), CGFloat(normalizedConformers.y[i]), CGFloat(normalizedConformers.z[i]))
        }
        gravicenterNode.position = SCNVector3(0, 0, -radiusOfTheMolecule - 0.50)
        return gravicenterNode
    }
    
    
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
