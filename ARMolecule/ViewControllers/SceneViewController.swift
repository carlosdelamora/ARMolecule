//
//  ViewController.swift
//  ARMolecule
//
//  Created by Carlos De la mora on 12/27/17.
//  Copyright © 2017 carlosdelamora. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import simd
import GLKit

class SceneViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var molecules: [Molecule] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        /*
         Prevent the screen from being dimmed after a while as users will likely
         have long periods of interaction without touching the screen or buttons.
         */
        UIApplication.shared.isIdleTimerDisabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action:#selector(addAnAchor))
        sceneView.addGestureRecognizer(tapGesture)
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        //sceneView.scene = scene
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    @objc
    func addAnAchor(){
        guard let currentFrame = sceneView.session.currentFrame else{
            return
        }
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.30
        let rotation = float4x4.makeRotate(radians: -.pi/2, 0, 0, 1)
        let cameraTransform = currentFrame.camera.transform
        let firstProduct = matrix_multiply(translation,rotation)
        let product = matrix_multiply(cameraTransform, firstProduct)
        let anchor = ARAnchor(transform: product)
        sceneView.session.add(anchor: anchor)
    }
  
    
    func placeMolecule(node: SCNNode){
        guard let molecule = molecules.first else{
            return
        }
        //let normalizedConformers = molecule.normalizedConformers
        let moleculeNode = molecule.createSceneMolecule()
        moleculeNode.position = SCNVector3(0,0, -molecule.radiusOfTheMolecule - 0.40)
        node.addChildNode(moleculeNode)
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        placeMolecule(node:node)
    }
    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}


extension float4x4 {
  
    static func makeRotate(radians: Float, _ x: Float, _ y: Float, _ z: Float) -> float4x4 {
        return unsafeBitCast(GLKMatrix4MakeRotation(radians, x, y, z), to: float4x4.self)
    }
}
