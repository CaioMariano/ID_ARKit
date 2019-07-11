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
    private var planeNode: SCNNode?
    private var imageNode: SCNNode?
    
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
        
        guard let referenceImage = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else { fatalError() }
        
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
                
                let planeScene = SCNScene(named: "art.scnassets/plane.scn")!
                let planeNode = planeScene.rootNode.childNode(withName: "planeRootNode", recursively: true)!
                
                
                DispatchQueue.main.async {
                    
                    // rotate the planeNode
                    let rotationAction = SCNAction.rotateBy(x: 0, y: 0.5, z: 0, duration: 1)
                    let inifiniteAction = SCNAction.repeatForever(rotationAction)
                    planeNode.runAction(inifiniteAction)
                    
                    
                    let (min, max) = planeNode.boundingBox
                    let size = SCNVector3Make(max.x - min.x, max.y - min.y, max.z - min.z)
                    let widthRatio = Float(imageAnchor.referenceImage.physicalSize.width)/size.x
                    let heightRatio = Float(imageAnchor.referenceImage.physicalSize.height)/size.z
                    let finalRatio = [widthRatio, heightRatio].min()!
                    planeNode.transform = SCNMatrix4(imageAnchor.transform)
                    let appearanceAction = SCNAction.scale(to: CGFloat(finalRatio), duration: 0.4)
                    appearanceAction.timingMode = .easeOut
                    planeNode.scale = SCNVector3Make(0.001, 0.001, 0.001)
                    self.sceneView.scene.rootNode.addChildNode(planeNode)
                    planeNode.runAction(appearanceAction)
                    
                    self.planeNode = planeNode
                    self.imageNode = node
                }
            }
        }
    }
    
}
