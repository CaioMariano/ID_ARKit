//
//  ViewController.swift
//  ID_ARKit
//
//  Created by Caio Araujo Mariano on 10/07/19.
//  Copyright © 2019 Caio Araujo Mariano. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    private var logoNode: SCNNode?
    private var imageNode: SCNNode?
    private var animationInfo: AnimationInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = SCNScene()
        sceneView.scene = scene
        self.sceneView.delegate = self
        sceneView.isPlaying = true
        self.sceneView.showsStatistics = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let referenceImage = ARReferenceImage.referenceImages(inGroupNamed: "Osvaldo", bundle: nil) else { fatalError() }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = referenceImage
        sceneView.session.run(configuration)
    }
    
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if anchor is ARImageAnchor {
            
            guard let imageAnchor = anchor as? ARImageAnchor else {
                return
            }
            
            DispatchQueue.global().async {

                let planeScene = SCNScene(named: "art.scnassets/logo_scene.scn")!
                let planeNode = planeScene.rootNode.childNode(withName: "logo", recursively: true)!
                let planeNodeChucks = planeScene.rootNode.childNode(withName: "chucks", recursively: true)!

                DispatchQueue.main.async {
                    
                    let (min, max) = planeNode.boundingBox
                    let size = SCNVector3Make(max.x - min.x, max.y - min.y, max.z - min.z)
                    let widthRatio = Float(imageAnchor.referenceImage.physicalSize.width)/size.x
                    let heightRatio = Float(imageAnchor.referenceImage.physicalSize.height)/size.z
                    let finalRatio = [widthRatio, heightRatio].min()!
                    let rotationAction = SCNAction.rotateBy(x: 0.5, y: 0.0, z: 0, duration: 1)
                    let inifiniteAction = SCNAction.repeatForever(rotationAction)
                   
                    
                    
                    planeNode.transform = SCNMatrix4(imageAnchor.transform)
                    let appearanceAction = SCNAction.scale(to: CGFloat(finalRatio), duration: 0.4)
                    appearanceAction.timingMode = .easeOut
                    planeNode.scale = SCNVector3Make(0.001, 0.001, 0.001)
                    self.sceneView.scene.rootNode.addChildNode(planeNode)
                    planeNodeChucks.runAction(inifiniteAction)
                    planeNode.runAction(appearanceAction)
                    
                    self.logoNode = planeNode
                    self.imageNode = node
                }
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let imageNode = imageNode, let logoNode = logoNode else { return
}
        guard let animationInfo = animationInfo else {
            refreshAnimationVariables(startTime: time, initialPosition: logoNode.simdWorldPosition, finalPosition: imageNode.simdWorldPosition, initialOrientation: logoNode.simdWorldOrientation, finalOrientation: imageNode.simdWorldOrientation)
            return
        }
        
        if !simd_equal(animationInfo.finalModelPosition, imageNode.simdWorldPosition) || animationInfo.finalModelOrientation != imageNode.simdWorldOrientation {
            refreshAnimationVariables(startTime: time, initialPosition: logoNode.simdWorldPosition, finalPosition: imageNode.simdWorldPosition, initialOrientation: logoNode.simdWorldOrientation, finalOrientation: imageNode.simdWorldOrientation)
        }
        
        let passedTime = time - animationInfo.startTime
        var t = min(Float(passedTime/animationInfo.duration), 1)
        t = sin(t * .pi * 0.5)
        
        let f3t = simd_make_float3(t, t, t)
        logoNode.simdWorldPosition = simd_mix(animationInfo.initialModelPosition, animationInfo.finalModelPosition, f3t)
        logoNode.simdWorldOrientation = simd_slerp(animationInfo.initialModelOrientation, animationInfo.finalModelOrientation, t)
        logoNode.simdWorldOrientation = imageNode.simdWorldOrientation
        
    }
    
    func refreshAnimationVariables(startTime: TimeInterval, initialPosition: float3, finalPosition: float3, initialOrientation: simd_quatf, finalOrientation: simd_quatf) {
        let distance = simd_distance(initialPosition, finalPosition)
        let speed = Float(0.15)
        let animationDuration = Double(min(max(0.1, distance/speed), 2))
        animationInfo = AnimationInfo(startTime: startTime, duration: animationDuration, initialModelPosition: initialPosition, finalModelPosition: finalPosition, initialModelOrientation: initialOrientation, finalModelOrientation: finalOrientation)        
    }
}

struct AnimationInfo {
    var startTime: TimeInterval
    var duration: TimeInterval
    var initialModelPosition: simd_float3
    var finalModelPosition: simd_float3
    var initialModelOrientation: simd_quatf
    var finalModelOrientation: simd_quatf
}
