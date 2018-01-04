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

class SceneViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var molecules: [Molecule] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action:#selector(placeMolecule))
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
    func placeMolecule(){
        
        guard let molecule = molecules.first else{
            return
        }
        
        guard let currentFrame = sceneView.session.currentFrame else{
            return
        }
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.30
        
        //let normalizedConformers = molecule.normalizedConformers
        let moleculeNode = molecule.createSceneMolecule()
        moleculeNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        
        sceneView.scene.rootNode.addChildNode(moleculeNode)
        
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
