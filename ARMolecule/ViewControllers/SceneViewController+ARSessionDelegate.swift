//
//  SceneViewController+ARSessionDelegate.swift
//  ARMolecule
//
//  Created by Carlos De la mora on 1/8/18.
//  Copyright © 2018 carlosdelamora. All rights reserved.
//

import Foundation
import ARKit


extension SceneViewController: ARSCNViewDelegate{
    
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        objectNodes.append(node)
        placeMolecule(node:node)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        updateTrackingInfo()
        guard let currentFrame = sceneView.session.currentFrame else{
            return
        }
        
        if let lightEstimate = currentFrame.lightEstimate{
            light.intensity = lightEstimate.ambientIntensity
            ambient.intensity = lightEstimate.ambientIntensity
        }
    }
    
    // MARK: - ARSCNViewDelegate
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        statusLabel.text = "Session failed: \(error.localizedDescription)"
        visualEffectView.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if !self.statusLabel.text!.isEmpty{
                self.statusLabel.text = ""
                self.visualEffectView.isHidden = true
            }
        }
        run()
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        statusLabel.text = "Session was interrupted"
        visualEffectView.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if !self.statusLabel.text!.isEmpty{
                self.statusLabel.text = ""
                self.visualEffectView.isHidden = true
            }
        }
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        statusLabel.text = "Session interruption ended"
        visualEffectView.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if !self.statusLabel.text!.isEmpty{
                self.statusLabel.text = ""
                self.visualEffectView.isHidden = true
            }
        }
        removeAllObjects()
        run()
    }
    
    
    private func updateTrackingInfo(){
        guard let frame = sceneView.session.currentFrame else{
            return
        }
        
        var message: String = ""
        switch frame.camera.trackingState {
        case .limited(let reason):
            switch reason{
            case .excessiveMotion:
                message = "Limited tracking: Excesive Motion"
            case .insufficientFeatures:
                message = "Limited tracking: Insufficient details"
            case .initializing:
                message = "Initializing in progress"
            }
        case .notAvailable:
            message = "Tracking not available"
        default:
            message = ""
        }
        
        guard let lightEstimate = frame.lightEstimate?.ambientIntensity else {
            return
        }
        
        if lightEstimate < 100{
            message = "Limited tracking: Too dark"
        }
        DispatchQueue.main.async {
            self.statusLabel.text = message
            self.visualEffectView.isHidden = message.isEmpty
        }
    }
}
