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
        //we create the atom nodes
        for i in 0..<atomsArray.count{
            let radius = pow(Double(atomsArray[i]),1.0/3.0)/100*2
            let sphere = SCNSphere(radius:CGFloat(radius))
            sphere.firstMaterial?.diffuse.contents = UIColor.magenta
            if let color = dictionaryOfColors[atomsArray[i]]{
                 sphere.firstMaterial?.diffuse.contents = color
            }
            //let sphereNode = SCNNode(geometry: sphere)
            let atomNode = SCNNode(geometry: sphere)
            atomNode.name = "\(i + 1)"//this is the id of the atom we start at 1
            gravicenterNode.addChildNode(atomNode)
            atomNode.position = SCNVector3(CGFloat(normalizedConformers.x[i]), CGFloat(normalizedConformers.y[i]), CGFloat(normalizedConformers.z[i]))
        }
        
        guard let bondsArray = bonds["aid1"] else{return gravicenterNode}
        //we create the bond nodes
        for i in 0..<bondsArray.count{
            let aid1 = bonds["aid1"]![i]
            let aid2 = bonds["aid2"]![i]
            if let firstNode = gravicenterNode.childNode(withName:"\(aid1)" , recursively: true),
                let secondNode = gravicenterNode.childNode(withName: "\(aid2)", recursively: true){
                let bondNode = createBondNode(vector1: (firstNode.position), vector2: secondNode.position)
                gravicenterNode.addChildNode(bondNode)
            }
           
        }
        
        
        //gravicenterNode.position = SCNVector3(0, 0, -radiusOfTheMolecule - 0.50)
        return gravicenterNode
    }
    
    func createBondNode(vector1:SCNVector3, vector2:SCNVector3) -> SCNNode{
        let radius:CGFloat = 0.001
        let height = vector1.distanceTo(vector2)
        let cylinder = SCNCylinder(radius: radius, height: CGFloat(height))
        cylinder.firstMaterial?.diffuse.contents = UIColor.lightGray
        let cylinderNode = SCNNode(geometry: cylinder)
        let vector = vector1 - vector2
        let pitchXAngle = SCNVector3(1,0,0).angleBetweenVectors(vector)
        let yawnYAngle = SCNVector3(0,1,0).angleBetweenVectors(vector)
        let rollZAngle = SCNVector3(0,0,1).angleBetweenVectors(vector)
        cylinderNode.eulerAngles = SCNVector3(pitchXAngle,yawnYAngle,rollZAngle)
        cylinderNode.position = SCNFloat(0.5)*(vector1 + vector2)
        return cylinderNode
    }
    
    func cylinderGeometry(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]
        
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        
        return SCNGeometry(sources: [source], elements: [element])
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
