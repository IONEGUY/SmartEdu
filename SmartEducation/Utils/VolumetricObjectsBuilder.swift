//
//  VolumetricObjectsBuilder.swift
//  SmartEducation
//
//  Created by MacBook on 11/10/20.
//

import Foundation
import UIKit
import SceneKit
import AVFoundation
import ARKit

class SceneNodeBuilder {
    private static var planetsConfig: [String: (radius: CGFloat, textureName: String)] = [
        "earth": (radius: 0.2, textureName: "earth_texture"),
        "mars": (radius: 0.1, textureName: "mars_texture"),
        "moon": (radius: 0.05, textureName: "moon_texture")
    ]

    private static var videosConfig: [String: String] = [
        "earth_video": "http://51.141.49.208:8080/sport-ar-be-video/api/videos/QMb_tUcxesM.mp4",
        "moon_video": "http://51.141.49.208:8080/sport-ar-be-video/api/videos/QMb_tUcxesM.mp4",
        "mars_video": "http://51.141.49.208:8080/sport-ar-be-video/api/videos/QMb_tUcxesM.mp4",
        "stream": "http://51.141.49.208:8080/sport-ar-be-video/api/videos/QMb_tUcxesM.mp4"
    ]

    class func buildPlaneVisualizer() -> VolumetricObjectSCNNode {
        let node = VolumetricObjectSCNNode()
        let plane = SCNPlane(width: 0.4, height: 0.4)
        let imageView = UIImageView(image: UIImage(named: "plane"))
        imageView.alpha = 0.7
        plane.firstMaterial?.diffuse.contents = imageView
        node.geometry = plane
        node.eulerAngles.x = -Float.pi / 2
        return node
    }

    class func build(withId id: String?, _ volumenricItem: VolumetricItem?) -> VolumetricObjectSCNNode? {
        switch volumenricItem {
        case .volumetric:
            return buildVolumetricObject(id ?? String.empty)
        case .videos:
            return buildVideoObject(id ?? String.empty)
        case .avatar:
            return buildAvatar()
        case .none:
            return nil
        }
    }

    private class func buildVolumetricObject(_ id: String) -> VolumetricObjectSCNNode? {
        if id == "solar_system" {
            return buildSolarSystem()
        }

        guard let planetConfig = planetsConfig[id] else { return nil }
        let node = VolumetricObjectSCNNode()
        node.geometry = SCNSphere(radius: planetConfig.radius)
        node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: planetConfig.textureName)
        node.surfaceElevation = 0.3
        node.runAction(createRotationAction())
        return node
    }

    private class func buildVideoObject(_ id: String) -> VolumetricObjectSCNNode {
        let node = VolumetricObjectSCNNode()

        guard let urlString = videosConfig[id]
               else { return node }
        let videoItem = AVPlayerItem(asset: AVAsset(url: URL(string: urlString)!))
        let player = AVPlayer(playerItem: videoItem)
        let videoNode = SKVideoNode(avPlayer: player)
        player.play()

        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem, queue: nil) { (_) in
            player.seek(to: CMTime.zero)
            player.play()
        }

        let videoScene = SKScene(size: CGSize(width: 1920, height: 1080))
        videoScene.backgroundColor = .clear
        videoScene.scaleMode = .resizeFill
        videoNode.position = CGPoint(x: videoScene.size.width / 2, y: videoScene.size.height / 2)
        videoScene.addChild(videoNode)
        let plane = SCNPlane(width: 1, height: 0.5)

        plane.firstMaterial?.diffuse.contents = videoScene
        plane.firstMaterial?.isDoubleSided = true
        let planeNode = SCNNode(geometry: plane)
        videoNode.yScale = -1.0
        node.addChildNode(planeNode)
        return node
    }

    private class func buildAvatar() -> VolumetricObjectSCNNode? {
        return nil
    }

    private class func buildSolarSystem() -> VolumetricObjectSCNNode? {
        return nil
    }

    private class func createRotationAction() -> SCNAction {
        let action = SCNAction.rotateBy(x: 0, y: CGFloat(360 * Double.pi / 180), z: 0, duration: 10)
        return SCNAction.repeatForever(action)
    }
}
