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
    private static var planetsConfig: [String: Float] = [
        "earth": 0.2,
        "mars": 0.1,
        "moon": 0.05
    ]
    
    private static var videosConfig: [String: String] = [
        "earth_video": "art.scnassets/earth_video",
        "moon_video": "art.scnassets/moon_video",
        "mars_video": "art.scnassets/mars_video",
        "stream": ApiConstants.streamURl
    ]
    
    static var solarSystem: VolumetricObjectSCNNode?
    
    class func buildPlaneVisualizer() -> VolumetricObjectSCNNode {
        let node = VolumetricObjectSCNNode()
        let plane = SCNPlane(width: 0.2, height: 0.2)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "plane")
        plane.materials = [material]
        node.geometry = plane
        node.eulerAngles.x = -Float.pi / 2
        return node
    }

    class func build(withId id: String?,
                     _ volumenricItem: VolumetricItem) -> VolumetricObjectSCNNode? {
        switch volumenricItem {
        case .volumetric:
            return buildVolumetricObject(id ?? String.empty)
        case .videos:
            return buildVideoObject(id ?? String.empty)
        case .avatar:
            return buildAvatar()
        }
    }
    
    class func createPlanet(radius: Float, image: String) -> RotatableSCNNode {
        let planet = SCNSphere(radius: CGFloat(radius))
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "\(image)_texture")
        planet.materials = [material]

        let planetNode = RotatableSCNNode()
        planetNode.geometry = planet

        return planetNode
    }
    
    class func createVideoNode(videoSource: String?)
        -> (videoNode: SKVideoNode, player: AVPlayer)? {
        guard let videoSource = videoSource,
              let videoPlayer = videoSource.isValidURL
            ? createPlayer(fromUrl: videoSource)
            : createPlayer(fromVideoName: videoSource)
        else { return nil }
        let videoNode = SKVideoNode(avPlayer: videoPlayer)
        videoPlayer.play()
        
        return (videoNode, videoPlayer)
    }

    private class func buildVolumetricObject(_ id: String) -> VolumetricObjectSCNNode? {
        if id == "solar_system" {
            solarSystem = SolarSystem()
            return solarSystem
        }
        
        guard let radius = planetsConfig[id] else { return nil }
        let node = createPlanet(radius: radius, image: id)
        node.draggingEnabled = true
        node.scalingEnabled = true
        node.rotatingEnabled = true
        
        return node
    }
    
    private class func buildVideoObject(_ id: String) -> VolumetricObjectSCNNode {
        let node = VolumetricObjectSCNNode()
        guard let videoNode = createVideoNode(videoSource: videosConfig[id])?.videoNode
        else { return node }
        
        node.draggingEnabled = true
        node.scalingEnabled = true
        node.rotatingEnabled = true
        
        let videoScene = SKScene(size: CGSize(width: 1920, height: 1080))
        videoScene.backgroundColor = .clear
        videoScene.scaleMode = .resizeFill
        videoNode.position = CGPoint(x: videoScene.size.width / 2,
                                     y: videoScene.size.height / 2)
        videoScene.addChild(videoNode)
        let plane = SCNPlane(width: 1, height: 0.5)

        plane.firstMaterial?.diffuse.contents = videoScene
        plane.firstMaterial?.isDoubleSided = true
        let planeNode = SCNNode(geometry: plane)
        videoNode.yScale = -1.0
        node.addChildNode(planeNode)
        return node
    }
    
    class func createPlayer(fromUrl url: String) -> AVPlayer? {
        guard let url = URL(string: url) else { return nil }
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        return buildPlayerWith(playerItem: playerItem)
    }
    
    class func createPlayer(fromVideoName name: String) -> AVPlayer? {
        guard let path = Bundle.main.path(forResource: name, ofType: "mp4") else { return nil }
        let playerItem = AVPlayerItem(url: URL(fileURLWithPath: path))
        return buildPlayerWith(playerItem: playerItem)
    }
    
    private class func buildPlayerWith(playerItem: AVPlayerItem) -> AVPlayer {
        let player = AVPlayer(playerItem: playerItem)
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem,
                                               queue: nil) { (_) in
            player.seek(to: CMTime.zero)
            player.play()
        }
        
        return player
    }

    private class func createRotationAction() -> SCNAction {
        let action = SCNAction.rotateBy(x: 0, y: CGFloat(360 * Double.pi / 180), z: 0, duration: 10)
        return SCNAction.repeatForever(action)
    }

    private class func buildAvatar() -> VolumetricObjectSCNNode? {
        let containerNode = VolumetricObjectSCNNode()
        containerNode.scalingEnabled = true
        containerNode.rotatingEnabled = true
        containerNode.draggingEnabled = true

        let nodesInFile = SCNScene(named: "art.scnassets/hakima.scn")
        
        containerNode.addChildNode(nodesInFile?.rootNode ?? SCNNode())
        
        return containerNode
    }
}
