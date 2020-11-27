//
//  ExtendedARSceneView.swift
//  SmartEducation
//
//  Created by MacBook on 11/12/20.
//

import Foundation
import SceneKit
import ARKit
import Closures
import SmartHitTest

class ExtendedARSceneView: ARSCNView, ARSmartHitTest, ARSCNViewDelegate,
                           ARCoachingOverlayViewDelegate {
    private var planeVisualizer = SceneNodeBuilder.buildPlaneVisualizer()
    private var currentRotationY: CGFloat = 0
    private var defaulfPlaneVisualizerYOffset: Float = -0.3

    func setup() {
        delegate = self

        appLighting()
        addCoaching()
        configueARSceneView()
        addGestureRecognizers()
    }

    deinit {
        print("ExtendedARSceneView has been released")
    }

    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        planeVisualizer.isHidden = false
        setPositionToCenterOf(planeVisualizer)
    }

    func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
        planeVisualizer.isHidden = true
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        updatePlaneVisualizerPosition()
    }

    func add(_ newNode: VolumetricObjectSCNNode?) {
        guard let node = newNode else { return }

        node.orientation.y = pointOfView?.orientation.y ?? node.orientation.y
        setPositionToCenterOf(node)
    }

    private func addCoaching() {
        let coachingOverlay = ARCoachingOverlayView()
        addSubview(coachingOverlay)
        coachingOverlay.fillSuperview()
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.session = session
        coachingOverlay.delegate = self
    }

    private func appLighting() {
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.castsShadow = true
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 35)
        scene.rootNode.addChildNode(lightNode)

        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.castsShadow = true
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.black
        scene.rootNode.addChildNode(ambientLightNode)
    }

    private func configueARSceneView() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        session.run(configuration)
    }

    private func addGestureRecognizers() {
        let panRecognizer =
            UIPanGestureRecognizer(target: self, action: #selector(handleDragAction(panGesture:)))
        let pinchRecognizer =
            UIPinchGestureRecognizer(target: self, action: #selector(handleScaleAction(pinchGesture:)))
        let rotationGesture =
            UIRotationGestureRecognizer(target: self,
                                        action: #selector(handleRotationAction(rotationGesture:)))
        let longPressGesture =
            UILongPressGestureRecognizer(target: self,
                                        action: #selector(handleLongPressAction(longPressGesture:)))
        addGestureRecognizer(panRecognizer)
        addGestureRecognizer(pinchRecognizer)
        addGestureRecognizer(rotationGesture)
        addGestureRecognizer(longPressGesture)
    }

    private func updatePlaneVisualizerPosition() {
        setPositionToCenterOf(planeVisualizer, yOffset: defaulfPlaneVisualizerYOffset)
    }

    private func setPositionToCenterOf(_ node: VolumetricObjectSCNNode?, yOffset: Float = 0) {
        guard let node = node else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
            self.setNodePositionFromPoint(node: node, point: center, yOffset: yOffset)
        }
    }

    private func setNodePositionFromPoint(node: VolumetricObjectSCNNode,
                                          point: CGPoint, yOffset: Float = 0) {
        guard let raycastQuesry = raycastQuery(from: point,
                                               allowing: .estimatedPlane,
                                               alignment: .horizontal),
              var worldTransform = session.raycast(raycastQuesry).first?.worldTransform
            else { return }
        worldTransform.columns.3.y += yOffset
        node.position = SCNVector3(worldTransform.columns.3.x,
                                   worldTransform.columns.3.y,
                                   worldTransform.columns.3.z)
        scene.rootNode.addChildNode(node)
    }

    @objc private func handleDragAction(panGesture: UIPanGestureRecognizer) {
        guard let node = getNodeFromHitTest(panGesture), node.draggingEnabled
            else { return }
        setNodePositionFromPoint(node: node, point: panGesture.location(in: self))
    }

    @objc private func handleScaleAction(pinchGesture: UIPinchGestureRecognizer) {
        guard let node = getNodeFromHitTest(pinchGesture), node.scalingEnabled
            else { return }
        if pinchGesture.state == .changed {
            let newScale = Float(pinchGesture.scale)
            let nodeScale = node.scale
            node.scale = SCNVector3(newScale * nodeScale.x,
                                    newScale * nodeScale.y,
                                    newScale * nodeScale.z)
            pinchGesture.scale = 1
        }
    }

    @objc private func handleRotationAction(rotationGesture: UIRotationGestureRecognizer) {
        guard let node = getNodeFromHitTest(rotationGesture), node.rotatingEnabled
            else { return }
        if rotationGesture.state == .ended {
            currentRotationY = -CGFloat(node.eulerAngles.y)
        } else if rotationGesture.state == .changed {
            node.eulerAngles.y = Float(-(currentRotationY + rotationGesture.rotation))
        }
    }

    @objc private func handleLongPressAction(longPressGesture: UILongPressGestureRecognizer) {
        guard let node = getNodeFromHitTest(longPressGesture) else { return }
        node.removeFromParentNode()
    }

    private func getNodeFromHitTest(_ gesture: UIGestureRecognizer)
        -> VolumetricObjectSCNNode? {
        let point = gesture.location(in: self)
        guard let node = hitTest(point).first?.node else { return nil}
        return getParentVolumetricObjectSCNNode(node) as? VolumetricObjectSCNNode
    }

    private func getParentVolumetricObjectSCNNode(_ node: SCNNode?) -> SCNNode? {
        if node is VolumetricObjectSCNNode { return node }
        return getParentVolumetricObjectSCNNode(node?.parent)
    }
}
