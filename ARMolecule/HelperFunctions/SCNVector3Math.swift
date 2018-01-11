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
        if vectorB.magnitude == 0 || self.magnitude == 0{
            return 0
        }
        var cosineOfAngle = dotProduct(vectorB) / magnitudesProduct
        //because of inperfections of the computations we may get something outside the interval -1,1 we check everything goes smoothly 
        if cosineOfAngle > 1{
            cosineOfAngle = 1
        }else if cosineOfAngle < -1{
            cosineOfAngle = -1
        }
        
        let cosineAngle = acos(cosineOfAngle)
        let crossProductVector =  crossProduct(vectorB)
        let zvector = SCNVector3(0,0,1)
        let xvector = SCNVector3(1,0,0)
        let angle: SCNFloat
        let positiveZCone = crossProductVector.dotProduct(zvector)//we check if is positive or negative
        let positiveXcone = crossProductVector.dotProduct(xvector)//we need two cones to check for vectors perpendicular to z
        
        switch positiveZCone{
        case _ where positiveZCone > 0:
            angle = cosineAngle
        case _ where positiveZCone < 0:
            angle = SCNFloat(-cosineAngle)
        case 0:
            if positiveXcone >= 0{
                angle = cosineAngle
            }else{
                angle = SCNFloat( -cosineAngle)
            }
        default:
            fatalError()
        }
        
        return angle
    }
}


extension float4x4 {
    
    static func makeRotate(radians: Float, _ x: Float, _ y: Float, _ z: Float) -> float4x4 {
        return unsafeBitCast(GLKMatrix4MakeRotation(radians, x, y, z), to: float4x4.self)
    }
}

