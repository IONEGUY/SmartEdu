//
//  ImageRecognitionViewController.swift
//  SmartEducation
//
//  Created by MacBook on 11/6/20.
//

import UIKit
import SceneKit
import ARKit

class ImageRecognitionViewController: UIViewController, MVVMViewController, ARSCNViewDelegate {
    typealias ViewModelType = AnyObject

    @IBOutlet weak var sceneView: ARSCNView!

    var viewModel: AnyObject?

    private let universeVideoPath = "Resources/Videos/universe"
    private let videoUrl = "http://51.141.49.208:8080/sport-ar-be-video/api/videos/QMb_tUcxesM.mp4"

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBaseNavBarStyle()

        sceneView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupRightBarButtonItem()
        setupImageTrackingConfiguration()
    }

    private func setupRightBarButtonItem() {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "cube"), for: .normal)
        button.addTarget(self, action: #selector(navigateTo3DModePage), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 53, height: 51)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }

    private func setupImageTrackingConfiguration() {
        let configuration = ARImageTrackingConfiguration()

        guard let universe = initTrackingImage(withName: "universe"),
              let conference = initTrackingImage(withName: "conference")
        else { return }

        configuration.trackingImages = [ universe, conference ]
        configuration.maximumNumberOfTrackedImages = 2
        sceneView.session.run(configuration)
    }

    @objc func navigateTo3DModePage() {
        Router.show(VolumetricObjectsViewController.self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneView.session.pause()
    }

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let imageAnchor = anchor as? ARImageAnchor else { return nil }
        switch imageAnchor.referenceImage.name {
        case "universe":
            return placeVideo(onImage: imageAnchor.referenceImage)
        case "conference":
            navigateToConference()
        default:
            return nil
        }

        return nil
    }

    private func navigateToConference() {
        Router.show(ConferenceViewController.self)
    }

    private func placeVideo(onImage image: ARReferenceImage) -> SCNNode {
        let videoNode = createVideoNode(withUrl: videoUrl)
        let planeNode = createPlaneNode(forVideoNode: videoNode, planeSize: image.physicalSize)

        let node = SCNNode()
        node.addChildNode(planeNode)
        return planeNode
    }

    private func createVideoNode(withUrl url: String) -> SKVideoNode {
        let videoItem = AVPlayerItem(asset: AVAsset(url: URL(string: url)!))
        let player = AVPlayer(playerItem: videoItem)
        let videoNode = SKVideoNode(avPlayer: player)
        player.play()

        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil) { (_) in
            player.seek(to: CMTime.zero)
            player.play()
        }

        return videoNode
    }

    private func createPlaneNode(forVideoNode videoNode: SKVideoNode, planeSize: CGSize) -> SCNNode {
        let videoScene = SKScene(size: CGSize(width: 480, height: 360))
        videoNode.position = CGPoint(x: videoScene.size.width / 2, y: videoScene.size.height / 2)
        videoNode.yScale = -1.0
        videoScene.addChild(videoNode)

        let plane = SCNPlane(width: planeSize.width, height: planeSize.height)
        plane.firstMaterial?.diffuse.contents = videoScene
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = -Float.pi / 2

        return planeNode
    }

    private func initTrackingImage(withName name: String) -> ARReferenceImage? {
        guard let image = UIImage(named: name),
              let imageToCIImage = CIImage(image: image),
              let cgImage = convertCIImageToCGImage(inputImage: imageToCIImage)
            else { return nil }
        let trackingImage = ARReferenceImage(cgImage,
                                       orientation: CGImagePropertyOrientation.up,
                                       physicalWidth: 0.2)
        trackingImage.name = name
        return trackingImage
    }

    func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
        return CIContext(options: nil)
            .createCGImage(inputImage, from: inputImage.extent)
    }
}
