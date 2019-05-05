//
//  ImageDetectionVC.swift
//  ARKitDemo
//
//  Created by mobioapp on 4/4/18.
//  Copyright © 2018 mobioapp. All rights reserved.
//

import UIKit
import ARKit

class ImageDetectionVC: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        sceneView.session.delegate = self
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin];
        
        // addBox()
        //  addTapGestureToSceneView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.vertical, .horizontal]
        //configuration.detectionImages = ARReferenceImage.referenceImages(inGroupNamed:"AR Resources" , bundle: nil)
        
        sceneView.session.run(configuration)
    }
    
    /// Adds An SCNNode 3m Away From The Current Frame Of The Camera
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
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        let node = SCNNode()
        //let scene = SCNScene(named: "art.scnassets/auto_ac_right.scn")
        let scene = SCNScene(named: "art.scnassets/Lincoln_rigged.scn")
        let nodeArray = scene?.rootNode.childNodes
        
        for childNode in nodeArray! {
            node.addChildNode(childNode as SCNNode)
        }
        
        return node
        
       /* let anchorNode = SCNNode()
        anchorNode.name = "Anchor"
        sceneView.scene.rootNode.addChildNode(anchorNode)
        
        addNodeInFrontOfCamera()*/
        
        //return anchorNode
    }
    
    /*func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let imageAnchor = anchor as? ARImageAnchor else {return}
        
        print(anchor.transform)
        
        if let imageName = imageAnchor.referenceImage.name {
            
            print(imageName)
            
            if imageName == "basis_crest" {
                
                let sphere = SCNNode()
                sphere.geometry = SCNSphere(radius: 0.15)
                sphere.geometry?.firstMaterial?.diffuse.contents = UIColor.green.withAlphaComponent(0.6)
                sphere.position = SCNVector3(0, 0, 0)
                node.addChildNode(sphere)
                sceneView.scene.rootNode.addChildNode(node)
                
            }
        }
    }*/
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        let planGeometry = planeAnchor.geometry
        guard let device = MTLCreateSystemDefaultDevice() else {return}
        let plane = ARSCNPlaneGeometry(device: device)
        plane?.update(from: planGeometry)
        node.geometry = plane
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        node.geometry?.firstMaterial?.transparency = 1
        node.geometry?.firstMaterial?.fillMode = SCNFillMode.lines
        
    }
}
