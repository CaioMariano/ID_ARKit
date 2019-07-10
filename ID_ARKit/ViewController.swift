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
    var idNode: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sceneView = SCNScene()
        self.sceneView.scene = sceneView
        self.sceneView.delegate = self        
        self.sceneView.showsStatistics = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let referenceImage = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else { fatalError() }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = referenceImage
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        
        let scene = SCNScene(named: "art.scnassets/plane.scn")!
        let idNode = scene.rootNode.childNode(withName: "planeRootNode", recursively: true)!
        
        let (min, max) = idNode.boundingBox
        let size = SCNVector3Make(max.x - min.x, max.y - min.y, max.z - min.z)
        let widthRatio = Float(imageAnchor.referenceImage.physicalSize.width) / size.x
        let heightRatio = Float(imageAnchor.referenceImage.physicalSize.height) / size.z
        let finalRatio = [widthRatio, heightRatio].min()!
        
        idNode.transform = SCNMatrix4(imageAnchor.transform)
        
        let appearenceAction = SCNAction.scale(by: CGFloat(finalRatio), duration: 0.4)
        appearenceAction.timingMode = .easeOut
        
        idNode.scale = SCNVector3Make(0.001, 0.001, 0.001)
        
        self.sceneView.scene.rootNode.addChildNode(idNode)

        idNode.runAction(appearenceAction)            
        self.idNode = idNode
    }
    
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
