//
//  SCNVector3Math.swift
//  ARMolecule
//
//  Created by Carlos De la mora on 1/3/18.
//  Copyright © 2018 carlosdelamora. All rights reserved.
//

import Foundation
import SceneKit


func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}

func +(left:SCNVector3, right:SCNVector3) -> SCNVector3 {
    
    return SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
}

func *( multiplier:SCNFloat, vector:SCNVector3) -> SCNVector3 {
    
    return SCNVector3(vector.x * multiplier, vector.y * multiplier, vector.z * multiplier)
}

//some of this functions are a modificayion to jeremyconkin found in here
//https://gist.github.com/jeremyconkin/a3909b2d3276d1b6fbff02cefecd561a
extension SCNVector3 {
    
    
    func dotProduct(_ vectorB:SCNVector3) -> SCNFloat {
        
        return (x * vectorB.x) + (y * vectorB.y) + (z * vectorB.z)
    }
    
    func length() -> Float {
        return sqrtf(x * x + y * y + z * z)
    }
    
    func distanceTo(_ vector: SCNVector3) -> Float {
        return SCNVector3(x: self.x - vector.x, y: self.y - vector.y, z: self.z - vector.z).length()
    }
    
    /// Calculate the magnitude of this vector
    var magnitude:SCNFloat {
        get {
            return sqrt(dotProduct(self))
        }
    }
    
    /// Vector in the same direction as this vector with a magnitude of 1
    var normalize:SCNVector3 {
        get {
            let localMagnitude = magnitude
            let localX = x / localMagnitude
            let localY = y / localMagnitude
            let localZ = z / localMagnitude
            
            return SCNVector3(localX, localY, localZ)
        }
    }
    
    func crossProduct(_ vectorB:SCNVector3) -> SCNVector3 {
        
        let computedX = (y * vectorB.z) - (z * vectorB.y)
        let computedY = -((x * vectorB.z)-(z * vectorB.x))
        let computedZ = (x * vectorB.y) - (y * vectorB.x)
        
        return SCNVector3(computedX, computedY, computedZ)
    }
    
    func angleBetweenVectors(_ vectorB:SCNVector3) -> SCNFloat {
        let magnitudesProduct = magnitude * vectorB.magnitude
        //cos(angle) = (A.B)/(|A||B|)
        let cosineAngle = acos(dotProduct(vectorB) / magnitudesProduct)
        let crossProductVector =  crossProduct(vectorB)
        let zvector = SCNVector3(0,0,1)
        let angle: SCNFloat
        let positiveCone = crossProductVector.dotProduct(vectorB)
        if positiveCone >= 0{
            angle = cosineAngle
        }else{
            angle = SCNFloat(2*(.pi) - cosineAngle)
        }
        return angle
    }
    
    
}

