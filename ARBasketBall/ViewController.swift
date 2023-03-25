//
//  ViewController.swift
//  ARBasketBall
//
//  Created by Luis Javier Canto Hurtado on 25/03/23.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var currentNode: SCNNode?
    
    private lazy var startRoundBtn: UIButton = {
        let button = UIButton()
        button.contentMode = .scaleAspectFill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("<~~>", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .lightGray
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(roundA), for: .touchUpInside)
        button.layer.cornerRadius = 10.0
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2.0
        return button
    }()
    
    @objc func roundA() {
        roundAction(node: currentNode!)
    }
    
    private lazy var startHorizontalBtn: UIButton = {
        let button = UIButton()
        button.contentMode = .scaleAspectFill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("<-->", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .lightGray
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(horizontalA), for: .touchUpInside)
        button.layer.cornerRadius = 10.0
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2.0
        return button
    }()
    
    @objc func horizontalA() {
        horizontalAction(node: currentNode!)
    }
    
    private lazy var stopBtn: UIButton = {
        let button = UIButton()
        button.contentMode = .scaleAspectFill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("STOP", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .lightGray
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(stopA), for: .touchUpInside)
        button.layer.cornerRadius = 10.0
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2.0
        return button
    }()
    
    @objc func stopA() {
        currentNode?.removeAllActions()
    }
    
    private lazy var addHoopBtn: UIButton = {
        let button = UIButton()
        button.contentMode = .scaleAspectFill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("ADD HOOP", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .blue
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(addHoop), for: .touchUpInside)
        button.layer.cornerRadius = 10.0
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2.0
        return button
    }()
    
    @objc func addHoop() {
        addBackBoard()
        addHoopBtn.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = false
        
        view.addSubview(stopBtn)
        view.addSubview(startHorizontalBtn)
        view.addSubview(startRoundBtn)
        view.addSubview(addHoopBtn)
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        registerGestureRecognizer()
        constraintsSetup()
    }
    
    private func constraintsSetup() {
        NSLayoutConstraint.activate([
            stopBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            stopBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stopBtn.widthAnchor.constraint(equalToConstant: 100),
            stopBtn.heightAnchor.constraint(equalToConstant: 60),
            
            startHorizontalBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startHorizontalBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            startHorizontalBtn.widthAnchor.constraint(equalToConstant: 90),
            startHorizontalBtn.heightAnchor.constraint(equalToConstant: 60),
            
            startRoundBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            startRoundBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            startRoundBtn.widthAnchor.constraint(equalToConstant: 90),
            startRoundBtn.heightAnchor.constraint(equalToConstant: 60),
            
            addHoopBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addHoopBtn.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            addHoopBtn.widthAnchor.constraint(equalToConstant: 100),
            addHoopBtn.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    private func registerGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(gesturerecognizer: UITapGestureRecognizer) {
        guard let sceneView = gesturerecognizer.view as? ARSCNView else { return }
        guard let centerPoint = sceneView.pointOfView else { return }
        // tranform matrix (orientation and location of the camera)
        let cameraTranform = centerPoint.transform
        let cameraLoaction = SCNVector3(x: cameraTranform.m41, y: cameraTranform.m42, z: cameraTranform.m43)
        let cameraOrientation = SCNVector3(x: -cameraTranform.m31, y: -cameraTranform.m32, z: -cameraTranform.m33)
        let cameraPosition = SCNVector3Make(cameraLoaction.x + cameraOrientation.x, cameraLoaction.y + cameraOrientation.y, cameraLoaction.z + cameraOrientation.z)
        
        let ball = SCNSphere(radius: 0.15)
        let ballMaterial = SCNMaterial()
        ballMaterial.diffuse.contents = UIImage(named: "basketballSkin.png")
        ball.materials = [ballMaterial]
        let ballNode = SCNNode(geometry: ball)
        ballNode.position = cameraPosition
        
        let physicsShape = SCNPhysicsShape(node: ballNode, options: nil)
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: physicsShape)
        ballNode.physicsBody = physicsBody
        let forceVector: Float = 6
        ballNode.physicsBody?.applyForce(SCNVector3(x: cameraPosition.x * forceVector, y: cameraPosition.y * forceVector, z: cameraPosition.z * forceVector), asImpulse: true)
        
        sceneView.scene.rootNode.addChildNode(ballNode)
    }
    
    func addBackBoard() {
        guard let backBoardScene = SCNScene(named: "art.scnassets/hoop.scn") else { return }
        guard let backBoardNode = backBoardScene.rootNode.childNode(withName: "backboard", recursively: false) else { return }
        backBoardNode.position = SCNVector3(x: 0, y: 0.5, z: -3)
        
        let physyicsShape = SCNPhysicsShape(node: backBoardNode, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron])
        let physicsBody = SCNPhysicsBody(type: .static, shape: physyicsShape)
        backBoardNode.physicsBody = physicsBody
        
        sceneView.scene.rootNode.addChildNode(backBoardNode)
        
        currentNode = backBoardNode
    }
    
    func horizontalAction(node: SCNNode) {
        let leftAction = SCNAction.move(by: SCNVector3(x: -1, y: 0, z: 0), duration: 3)
        let rightAction = SCNAction.move(by: SCNVector3(x: 1, y: 0, z: 0), duration: 3)
        let actionSequence = SCNAction.sequence([leftAction, rightAction])
        node.runAction(SCNAction.repeat(actionSequence, count: 4))
    }
    
    func roundAction(node: SCNNode) {
        let upRight = SCNAction.move(by: SCNVector3(x: 1, y: 1, z: 0), duration: 2)
        let downRight = SCNAction.move(by: SCNVector3(x: 1, y: -1, z: 0), duration: 2)
        let upLeft = SCNAction.move(by: SCNVector3(x: -1, y: 1, z: 0), duration: 2)
        let downLeftt = SCNAction.move(by: SCNVector3(x: -1, y: -1, z: 0), duration: 2)
        
        let actionSequence = SCNAction.sequence([upRight, downRight, downLeftt, upLeft])
        node.runAction(SCNAction.repeat(actionSequence, count: 3))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
}
