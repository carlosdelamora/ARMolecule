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
    
    var nodeMolecule: SCNNode?//we use it for rotation
    var initialVector: SCNVector3 = SCNVector3Zero//we used for rotation
    //TODO: erase this
    let centerNode = SCNNode()
    
    //MARK- Outlets
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var fingerRotationView: UIImageView!
    
    @IBOutlet weak var gotItButon: UIButton!
    
    
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
        //add gesture recognizers
        let tapGesture = UITapGestureRecognizer(target: self, action:#selector(addAnAchor))
        sceneView.addGestureRecognizer(tapGesture)
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotationForMolecule(gesture:)))
        sceneView.addGestureRecognizer(rotationGesture)
        
        //add buttons
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(presentSearchViewController))
        navigationItem.rightBarButtonItem = button
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
        navigationItem.leftBarButtonItem = refreshButton
        run()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navigationController = navigationController as? CustomNavigationController{
            navigationController.isSceneView = true
        }
        
    }
    
  
    
    @IBAction func gotItAction(_ sender: Any) {
        
        gotItButon.isHidden = true
        fingerRotationView.isHidden = true 
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
    
    @objc
    func refresh(){
        removeAllObjects()
        run()
    }
    
    func run(){
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        // Run the view's session
        sceneView.session.run(configuration)
        // if we have a current frame we add the light there otherwise we add it at the almost above the origin of the scene
        guard let currentFrame = sceneView.session.currentFrame else{
            return
        }
        let cameraSimdPosition = currentFrame.camera.transform.columns.3
        let position = SCNVector3(cameraSimdPosition.x, cameraSimdPosition.y, cameraSimdPosition.z) + SCNVector3(0,2,-0.30)
        insertSpotLight(position: position)
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
        objectNodes.append(lightNode)
        
        //ambient type has the same intensity in all dirctions so light intensity and position angles do not apply
        ambient.type = .ambient
        let ambientNode = SCNNode()
        ambientNode.light = ambient
        ambientNode.position = SCNVector3(0,-2,0)
        sceneView.scene.rootNode.addChildNode(ambientNode)
        objectNodes.append(ambientNode)
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

extension SceneViewController{
    
    @objc
    func rotationForMolecule(gesture: UIRotationGestureRecognizer){
        
        switch gesture.state{
        case .began:
            
            let midPoint = gesture.location(ofTouch: 0, in: view).midPoint(point: gesture.location(ofTouch: 1, in: view))
            let hitTestOptions:[SCNHitTestOption: Any] = [.boundingBoxOnly: true]
            let hitresults = sceneView.hitTest(midPoint, options: hitTestOptions)
            nodeMolecule = hitresults.lazy.flatMap{Molecule.existingMoleculeContainingNode(node: $0.node)}.first
            guard let _ = nodeMolecule else {return}
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        case .changed:
            nodeMolecule?.eulerAngles.y -= Float(gesture.rotation)*0.2
        case .ended:
            print("velocity \(gesture.velocity)")
        default:
            break
        }
    }
    
    
    
}
