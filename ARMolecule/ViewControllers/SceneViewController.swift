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

class SceneViewController: UIViewController{
    
    var molecules: [Molecule] = []
    var light = SCNLight()
    let ambient = SCNLight()
    var objectNodes: [SCNNode] = []
    
    //MARK- Outlets
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var statusLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        //set the style of the visual effect
        visualEffectView.layer.cornerRadius = 8
        visualEffectView.clipsToBounds = true
        /*
         Prevent the screen from being dimmed after a while as users will likely
         have long periods of interaction without touching the screen or buttons.
         */
        UIApplication.shared.isIdleTimerDisabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action:#selector(addAnAchor))
        sceneView.addGestureRecognizer(tapGesture)
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(presentSearchViewController))
        navigationItem.rightBarButtonItem = button
        run()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navigationController = navigationController as? CustomNavigationController{
            navigationController.isSceneView = true
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        //sceneView.session.pause()
    }
    
    @objc
    func presentSearchViewController(){
         let searchViewController = storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController
        if let searchViewController = searchViewController{
            searchViewController.sceneViewController = self
            navigationController?.pushViewController(searchViewController, animated: true)
        }
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
    
    func run(){
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        // Run the view's session
        sceneView.session.run(configuration)
        insertSpotLight(position: SCNVector3(0,2,-0.30))
        sceneView.autoenablesDefaultLighting = true
    }
  
    
    func insertSpotLight(position: SCNVector3){
        light.type = .spot
        light.spotInnerAngle = 70//iluminated by the ligh fully
        light.spotOuterAngle = 100//iluminated partialy by the light
        light.castsShadow = true
        light.automaticallyAdjustsShadowProjection = true
        // By default the stop light points directly down the negative
        // z-axis, we want to shine it down so rotate 90deg around the
        // x-axis to point it down
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.transform = SCNMatrix4MakeRotation(-.pi/2, 1, 0, 0)
        lightNode.position = position
        sceneView.scene.rootNode.addChildNode(lightNode)
        
        //ambient type has the same intensity in all dirctions so light intensity and position angles do not apply
        ambient.type = .ambient
        let ambientNode = SCNNode()
        ambientNode.light = ambient
        ambientNode.position = SCNVector3(0,-2,0)
        sceneView.scene.rootNode.addChildNode(ambientNode)
        
    }
    
    
    func placeMolecule(node: SCNNode){
        guard let molecule = molecules.first else{
            return
        }
        //let normalizedConformers = molecule.normalizedConformers
        let moleculeNode = molecule.createSceneMolecule()
        moleculeNode.position = SCNVector3(0,0, -molecule.radiusOfTheMolecule - 0.20)
        node.addChildNode(moleculeNode)
    }
    

    
    func removeAllObjects() {
        for object in objectNodes {
            object.removeFromParentNode()
        }
        objectNodes = []
    }
}


extension float4x4 {
  
    static func makeRotate(radians: Float, _ x: Float, _ y: Float, _ z: Float) -> float4x4 {
        return unsafeBitCast(GLKMatrix4MakeRotation(radians, x, y, z), to: float4x4.self)
    }
}


extension SceneViewController{
    
    
}
