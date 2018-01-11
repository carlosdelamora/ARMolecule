//
//  HelperFunctionsCGPoint.swift
//  ARMolecule
//
//  Created by Carlos De la mora on 1/9/18.
//  Copyright © 2018 carlosdelamora. All rights reserved.
//

import Foundation
import UIKit

extension CGPoint{
    
    func midPoint(point: CGPoint)-> CGPoint{
        return CGPoint(x: (x+point.x)/2, y: (y+point.y)/2)
    }
}
