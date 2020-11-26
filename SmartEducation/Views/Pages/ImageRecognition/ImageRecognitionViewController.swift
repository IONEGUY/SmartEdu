//
//  ImageRecognitionViewController.swift
//  SmartEducation
//
//  Created by MacBook on 11/6/20.
//

import UIKit
import SceneKit
import ARKit
import SmartHitTest
import AVFoundation
import AVKit

class ImageRecognitionViewController: BaseViewController, MVVMViewController,
                                      ARSCNViewDelegate {
    typealias ViewModelType = ImageRecognitionViewModel

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var focusFrame: UIView!
    
    var viewModel: ImageRecognitionViewModel?

    private let universeVideoPath = "art.scnassets/universe_video"
    private var recognizedImageName = String.empty

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRightBarButtonItem(UIImage(named: "cube"))
        sceneView.delegate = self
        addGestureRecognizers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setupImageTrackingConfiguration()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    private func addGestureRecognizers() {
        let tapgestureRecognizer =
            UITapGestureRecognizer(target: self,
                                   action: #selector(handleSceneViewTap(_:)))
        sceneView.addGestureRecognizer(tapgestureRecognizer)
    }
    
    @objc private func handleSceneViewTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: sceneView)
        let node = sceneView.hitTest(point).first?.node.parent
        guard node is VideoNode else { return }

        let player = recognizedImageName == "stream_trigger"
            ? SceneNodeBuilder.createPlayer(fromUrl: ApiConstants.streamURl)
            : SceneNodeBuilder.createPlayer(fromVideoName: universeVideoPath)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true) {
            playerViewController.player?.play()
        }
    }
    
    private func setupRightBarButtonItem(_ image: UIImage?) {
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(rightBarButtonItemPressed),
                         for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        let barButton = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = barButton
    }

    @objc func rightBarButtonItemPressed() {
        Router.show(VolumetricModeViewController.self)
    }

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let imageAnchor = anchor as? ARImageAnchor else { return nil }
        var node: SCNNode?
        DispatchQueue.main.async { [weak self] in
            switch imageAnchor.referenceImage.name {
            case "stream_trigger":
                node = self?.placeVideo(onImage: imageAnchor.referenceImage, ApiConstants.streamURl)
            case "universe":
                node = self?.placeVideo(onImage: imageAnchor.referenceImage,
                                        StringResources.universeVideoPath)
            case "conference":
                Router.show(ConferenceViewController.self)
            default:
                break
            }
            
            self?.recognizedImageName = imageAnchor.referenceImage.name ?? String.empty
            self?.focusFrame.isHidden = true
        }

        return node
    }

    private func setupImageTrackingConfiguration() {
        let configuration = ARImageTrackingConfiguration()

        guard let universe = initTrackingImage(withName: "universe"),
              let conference = initTrackingImage(withName: "conference"),
              let stream = initTrackingImage(withName: "stream_trigger")
        else { return }

        configuration.trackingImages = [ universe, conference, stream ]
        configuration.maximumNumberOfTrackedImages = 2
        sceneView.session.run(configuration)
    }

    private func placeVideo(onImage image: ARReferenceImage, _ videoSource: String) -> SCNNode {
        let videoNode = SceneNodeBuilder.createVideoNode(videoSource: videoSource)
        let planeNode = createPlaneNode(forVideoNode: videoNode?.videoNode, planeSize: image.physicalSize)

        let node = VideoNode()
        node.player = videoNode?.player
        node.addChildNode(planeNode)
        return node
    }

    private func createPlaneNode(forVideoNode videoNode: SKVideoNode?, planeSize: CGSize) -> SCNNode {
        guard let videoNode = videoNode else { return SCNNode() }
        let videoScene = SKScene(size: CGSize(width: 1280, height: 720))
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
