//
//  ViewController.swift
//  AR Ruler
//
//  Created by Cory Carte on 12/8/22.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    let dotRadius = 0.005
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            textNode.removeFromParentNode()
            dotNodes = [SCNNode]()
        } else {
            if let touchLocation = touches.first?.location(in: sceneView) {
                // TODO: Use raycasting
                let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
                
                if let hitResult = hitTestResults.first {
                    addDot(at: hitResult)
                }
            }
        }
    }
    
    // TODO: Use raycasting
    func addDot(at location : ARHitTestResult) {
        // Create sphere
        let dot = SCNSphere(radius: dotRadius)

        // Create material and assign to geometry
        let dotMaterial = SCNMaterial()
        dotMaterial.diffuse.contents = UIColor.red
        
        dot.materials = [dotMaterial]
        
        // Create node and assign geometry to it
        let dotNode = SCNNode(geometry: dot)
        dotNode.position = SCNVector3(x: location.worldTransform.columns.3.x,
                                      y: (location.worldTransform.columns.3.y + Float(dotRadius / 2)),
                                       z: location.worldTransform.columns.3.z)

        sceneView.scene.rootNode.addChildNode(dotNode)
                
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 { calculate() }
    }
    
    func calculate() {
        print("Calculate distance")
        let start = dotNodes[0]
        let end = dotNodes[1]
                
        // Calculate distance in 3D space
        // with a, b, c known
        // distance = sqrt(a^2 + b^2 + c^2)
        
        let a = end.position.x - start.position.x
        let b = end.position.y - start.position.y
        let c = end.position.z - start.position.z
        
        let distance = sqrt(Double(
            pow(a, 2) +
            pow(b,2) +
            pow(c,2)
        ))
        
        updateText(String(abs(distance)), at: end.position)
    }
    
    func updateText(_ text: String, at position: SCNVector3) {
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        textNode = SCNNode(geometry: textGeometry)
        
        textNode.position = SCNVector3(x: position.x, y: position.y + 0.01, z: position.z)
        textNode.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }
}
