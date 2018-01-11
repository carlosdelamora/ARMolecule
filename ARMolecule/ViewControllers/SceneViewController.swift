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
        
        let panGestureForRotation = UIPanGestureRecognizer(target: self, action: #selector(rotationForMolecule(gesture:)))
        panGestureForRotation.minimumNumberOfTouches = 1
        panGestureForRotation.maximumNumberOfTouches = 1
        sceneView.addGestureRecognizer(panGestureForRotation)
        run()
        understandEulerNagles()
    }
    
    
    func understandEulerNagles(){
        let yCylinder = SCNCylinder(radius: 0.002, height: 0.3)
        yCylinder.firstMaterial?.diffuse.contents = UIColor.yellow
        let yAxis = SCNNode(geometry: yCylinder)
        let xCylinder = SCNCylinder(radius: 0.002, height: 0.3)
        xCylinder.firstMaterial?.diffuse.contents = UIColor.red
        let xAxis = SCNNode(geometry: xCylinder)
        xAxis.eulerAngles.z = -(.pi/2)
        let zCylinder = SCNCylinder(radius: 0.002, height: 0.3)
        zCylinder.firstMaterial?.diffuse.contents = UIColor.blue
        let zAxis = SCNNode(geometry: zCylinder)
        zAxis.eulerAngles.x = -(.pi/2)
        let centerNode = SCNNode()
        centerNode.addChildNode(yAxis)
        centerNode.addChildNode(xAxis)
        centerNode.addChildNode(zAxis)
        centerNode.position = SCNVector3(0.0,0.0,-0.4)
        let rotationNode = centerNode.clone()
        sceneView.scene.rootNode.addChildNode(centerNode)
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
    
    @objc
    func rotationForMolecule(gesture: UIPanGestureRecognizer){
        
        
        switch gesture.state{
        
        case .began:
            
            let midPoint = gesture.location(ofTouch: 0, in: view)//.midPoint(point: gesture.location(ofTouch: 1, in: view))
            let hitTestOptions:[SCNHitTestOption: Any] = [.boundingBoxOnly: true]
            let hitresults = sceneView.hitTest(midPoint, options: hitTestOptions)
            nodeMolecule = hitresults.lazy.flatMap{Molecule.existingMoleculeContainingNode(node: $0.node)}.first
            guard let nodeMolecule = nodeMolecule else{
                print("begining node molecule is null")
                return
            }

            let nodePosition = nodeMolecule.position
            let positionOfTouch = sceneView.unprojectPoint(SCNVector3(midPoint.x,midPoint.y,0.0))
            //we calculate the vector from the gesture ray to the gravicenter
            //the initial vector
            initialVector = positionOfTouch - nodePosition
            
        case .changed:
            
            if gesture.numberOfTouches == 1{
                let midPoint = gesture.location(ofTouch: 0, in: view)//.midPoint(point: gesture.location(ofTouch: 1, in: view))
                guard let nodeMolecule = nodeMolecule else{
                    print("the node molecule is null")
                    return
                }
                let nodePosition = nodeMolecule.position
                let positionOfTouch = sceneView.unprojectPoint(SCNVector3(midPoint.x,midPoint.y,0.0))
                //we calculate the vector from the gesture ray to the gravicenter
                //the initial vector
                let currentVector = positionOfTouch - nodePosition
                //we need to get the object to rotate.
                let axisOfRotation = initialVector.crossProduct(currentVector).normalize
                if axisOfRotation.length() > 0.0{
                    let angleOfRotation = initialVector.angleBetweenVectors(currentVector)
                    let moleculePositionZ = sceneView.projectPoint(nodeMolecule.position).z
                    let cellAngle = atan(0.05/moleculePositionZ)*2
                    let angleToRotate = angleOfRotation/cellAngle*2*(.pi)
                    var smoothAngleOfRotation:[Float] = [nodeMolecule.eulerAngles.y]
                    smoothAngleOfRotation.append(angleToRotate)
                    let lastThen = Array(smoothAngleOfRotation.suffix(10))
                    let average = lastThen.reduce(0.0, {$0 + $1})/10.0
                    let quaternionImaginary = sin(average/2)*axisOfRotation
                    nodeMolecule.localRotate(by: SCNQuaternion(cos(average/2),quaternionImaginary.x,quaternionImaginary.y, quaternionImaginary.z))
                    //nodeMolecule.eulerAngles.y = 10*average
                    //nodeMolecule.rotation = SCNVector4(10*average, axisOfRotation.x,axisOfRotation.y, axisOfRotation.z)//angleO
                    initialVector = currentVector
                    
                    
                    print("angle \(average)")
                    
                }
                //we calculate the vector from the current position to the gravicenter
                //we calculate the normal vector and the angle btween node gravicenter and
                //the current position
                //we rotate the gravicenter by the computed transform
                
            }
            
        case .ended:
            print("velocity \(gesture.velocity(in: view))")
        default:
            break
        }
    }
    
    
    
}
