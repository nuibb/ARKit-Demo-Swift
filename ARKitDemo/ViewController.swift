//
//  ViewController.swift
//  ARKitDemo
//
//  Created by mobioapp on 8/3/18.
//  Copyright © 2018 mobioapp. All rights reserved.
//

import UIKit
import ARKit

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        sceneView.session.delegate = self
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
        //sceneView.allowsCameraControl = true;
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin];
        
        // addBox()
        //  addTapGestureToSceneView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configuration)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    func addNodeInFrontOfCamera(){
        
        //1. Get The Current Frame Of The Camera
        guard let currentTransform = sceneView.session.currentFrame?.camera.transform else { return }
        
        //2. Create An SCNNode
        let nodeToAdd = SCNNode()
        let boxGeometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        boxGeometry.firstMaterial?.diffuse.contents = UIColor.red
        nodeToAdd.geometry = boxGeometry
        
        // Create A Transform With A Translation 1m In Front Of The Camera
        var translation = matrix_identity_float4x4
        
        //Change The X Value
        translation.columns.3.x = 0
        
        //Change The Y Value
        translation.columns.3.y = 0
        
        //Change The Z Value
        translation.columns.3.z = -1
        
        nodeToAdd.simdTransform = matrix_multiply(currentTransform, translation)
        sceneView?.scene.rootNode.addChildNode(nodeToAdd)
        
    }
    
    var planes: [SCNNode] = []
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        let size = planes.count
        print("Size : \(size)")
        
        if size > 0 {
            return nil
        }
        
        let node = SCNNode()
        let scene = SCNScene(named: "art.scnassets/Lincoln_rigged.scn")
        let nodeArray = scene?.rootNode.childNodes
        
        for childNode in nodeArray! {
            
            node.addChildNode(childNode as SCNNode)
            
        }
        
        planes.append(node)
        
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        let anchor = anchor as? ARPlaneAnchor
        let planeNode = node.childNodes.first
        planeNode?.geometry = SCNPlane(width: CGFloat((anchor?.extent.x)!), height: CGFloat((anchor?.extent.z)!))
        planeNode?.position = SCNVector3((anchor?.center.x)!, 0, (anchor?.center.z)!)
       // planeNode?.geometry?.firstMaterial?.diffuse.contents = UIColor.cyan.withAlphaComponent(0.5)
        
    }
    
    func addBox() {
        
        let box = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0)
        box.firstMaterial?.diffuse.contents = UIColor(red: 30.0 / 255.0, green: 150.0 / 255.0, blue: 30.0 / 255.0, alpha: 1)
        
        let boxNode = SCNNode()
        boxNode.geometry = box
        boxNode.position = SCNVector3(0, 0, -0.2)
        
        let scene = SCNScene()
        scene.rootNode.addChildNode(boxNode)
        sceneView.scene = scene
        
    }
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTap(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func didTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
        
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation)
        guard let node = hitTestResults.first?.node else { return }
        node.removeFromParentNode()
        
        print("\(tapLocation)")
    }
    
}

