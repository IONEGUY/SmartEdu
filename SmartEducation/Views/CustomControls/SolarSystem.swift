//
//  SolarSystem.swift
//  SmartEducation
//
//  Created by MacBook on 11/13/20.
//

import Foundation
import SceneKit
import ARKit
import SwiftUI

class SolarSystem: VolumetricObjectSCNNode {
    private var orbits: [RotatableSCNNode] = []
    private var planets: [RotatableSCNNode] = []

    override init() {
        super.init()

        buildPlanets()
        addChildNode(createSolarSysterProperties())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func buildPlanets() {
        createSun()
        createMercury()
        createVenus()
        createEarth()
        createMars()
        createJupiter()
        createSaturn()
        createUranus()
        createNeptune()
        createPluton()
    }

    private func createSolarSysterProperties() -> SCNNode {
        let plane = SCNPlane(width: 0.5, height: 0.7)
        let material = SCNMaterial()
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 140))
        container.backgroundColor = .blue
        let orbitSpeedLabel = createLabel("Orbit speed", CGRect(x: 0, y: 0, width: 100, height: 30))
        let rotationSpeedLabel = createLabel("Rotation speed", CGRect(x: 0, y: 60, width: 100, height: 30))
        let rotationSpeedSlider =
            createSlider(CGRect(x: 5, y: 90, width: 90, height: 30), handler: { [weak self]
                newValue in
                self?.planets.forEach { $0.updateRotationSpeed(newValue) }
            })
        let orbitSpeedSlider =
            createSlider(CGRect(x: 5, y: 30, width: 90, height: 30), handler: { [weak self]
                newValue in
                self?.orbits.forEach { $0.updateRotationSpeed(newValue) }
            })

        container.addSubview(orbitSpeedLabel)
        container.addSubview(rotationSpeedSlider)
        container.addSubview(orbitSpeedSlider)
        container.addSubview(rotationSpeedLabel)
        material.diffuse.contents = container
        plane.materials = [material]

        let boxNode = SCNNode(geometry: plane)
        boxNode.position = SCNVector3(x: 0.0, y: 0.7, z: 0)

        return boxNode
    }

    private func createLabel(_ text: String, _ frame: CGRect) -> UILabel {
        let label = UILabel(frame: frame)
        label.text = text
        label.textColor = .white
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        return label
    }

    private func createSlider( _ frame: CGRect, handler: @escaping (Float) -> Void) -> UISlider {
        let slider = UISlider(frame: frame)
        slider.onChange(handler: handler)
        slider.minimumValue = 1
        slider.maximumValue = 9
        slider.value = 5
        slider.isEnabled = true
        let circleImage = makeCircleWith(size: CGSize(width: 20, height: 20),
                                         backgroundColor: .brown)
        slider.setThumbImage(circleImage, for: .normal)
        slider.setThumbImage(circleImage, for: .highlighted)
        return slider
    }

    private func makeCircleWith(size: CGSize, backgroundColor: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(backgroundColor.cgColor)
        context?.setStrokeColor(UIColor.clear.cgColor)
        let bounds = CGRect(origin: .zero, size: size)
        context?.addEllipse(in: bounds)
        context?.drawPath(using: .fill)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    private func createOrbit(orbitSize: Float) -> RotatableSCNNode {
        let orbit = SCNTorus(ringRadius: CGFloat(orbitSize), pipeRadius: 0.001)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.darkGray
        orbit.materials = [material]
        let orbitNode = RotatableSCNNode()
        orbitNode.geometry = orbit
        return orbitNode
    }

    // MARK: - planets

    private func createSun() {
        let sun = SceneNodeBuilder.createPlanet(radius: 0.25, image: "sun")
        sun.name = "sun"
        sun.position = SCNVector3(x: 0, y: 0, z: 0)
        sun.addRotationAction(duration: 1, rotation: -0.3)
        addChildNode(sun)
        planets.append(sun)
    }

    private func createMercury() {
        let mercuryOrbit = createOrbit(orbitSize: 0.3)
        let mercury = SceneNodeBuilder.createPlanet(radius: 0.03, image: "mercury")
        mercury.name = "mercury"
        mercury.position = SCNVector3(x: 0.3, y: 0, z: 0)
        mercury.addRotationAction(duration: 0.4, rotation: 0.6)
        mercuryOrbit.addRotationAction(duration: 1, rotation: 0.6)
        mercuryOrbit.addChildNode(mercury)
        addChildNode(mercuryOrbit)
        planets.append(mercury)
        orbits.append(mercuryOrbit)
    }

    private func createVenus() {
        let venusOrbit = createOrbit(orbitSize: 0.5)
        let venus = SceneNodeBuilder.createPlanet(radius: 0.04, image: "venus")
        venus.name = "venus"
        venus.position = SCNVector3(x: 0.5, y: 0, z: 0)
        venus.addRotationAction(duration: 0.4, rotation: 0.4)
        venusOrbit.addRotationAction(duration: 1, rotation: 0.4)
        venusOrbit.addChildNode(venus)
        addChildNode(venusOrbit)
        planets.append(venus)
        orbits.append(venusOrbit)
    }

    private func createEarth() {
        let earthOrbit = createOrbit(orbitSize: 0.7)
        let earth = SceneNodeBuilder.createPlanet(radius: 0.05, image: "earth")
        earth.name = "earth"
        earth.position = SCNVector3(x: 0.7, y: 0, z: 0)
        earth.addRotationAction(duration: 0.4, rotation: 0.25)
        earthOrbit.addRotationAction(duration: 1, rotation: 0.25)
        planets.append(earth)
        orbits.append(earthOrbit)

        let moon = SceneNodeBuilder.createPlanet(radius: 0.01, image: "moon")
        moon.name = "moon"
        let moonOrbit = SCNTorus(ringRadius: 0.08, pipeRadius: 0.001)
        let moonOrbitNode = RotatableSCNNode()
        moonOrbitNode.geometry = moonOrbit
        moon.position = SCNVector3(x: 0.08, y: 0, z: 0)
        moonOrbitNode.position = SCNVector3(x: 0, y: 0, z: 0)
        orbits.append(moonOrbitNode)

        earthOrbit.addChildNode(earth)
        earth.addChildNode(moonOrbitNode)
        addChildNode(earthOrbit)
        moonOrbitNode.addChildNode(moon)
    }

    private func createMars() {
        let marsOrbit = createOrbit(orbitSize: 0.8)
        let mars = SceneNodeBuilder.createPlanet(radius: 0.03, image: "mars")
        mars.name = "mars"
        mars.position = SCNVector3(x: 0.8, y: 0, z: 0)
        mars.addRotationAction(duration: 0.4, rotation: 0.2)
        marsOrbit.addRotationAction(duration: 1, rotation: 0.2)
        planets.append(mars)
        orbits.append(marsOrbit)
        addChildNode(marsOrbit)
        marsOrbit.addChildNode(mars)
    }

    private func createJupiter() {
        let jupiterOrbit = createOrbit(orbitSize: 1.0)
        let jupiter = SceneNodeBuilder.createPlanet(radius: 0.03, image: "jupiter")
        jupiter.name = "jupiter"
        jupiter.position = SCNVector3(x: 1.0, y: 0, z: 0)
        jupiter.addRotationAction(duration: 0.4, rotation: 0.15)
        jupiterOrbit.addRotationAction(duration: 1, rotation: 0.15)
        planets.append(jupiter)
        orbits.append(jupiterOrbit)
        jupiterOrbit.addChildNode(jupiter)
        addChildNode(jupiterOrbit)
    }

    private func createSaturn() {
        let saturnOrbit = createOrbit(orbitSize: 1.2)
        let saturn = SceneNodeBuilder.createPlanet(radius: 0.03, image: "saturn")
        saturn.name = "saturn"
        saturn.position = SCNVector3(x: 1.2, y: 0, z: 0)
        saturn.addRotationAction(duration: 0.4, rotation: 0.1)
        saturnOrbit.addRotationAction(duration: 1, rotation: 0.1)
        planets.append(saturn)
        orbits.append(saturnOrbit)
        saturnOrbit.addChildNode(saturn)
        addChildNode(saturnOrbit)
    }

    private func createUranus() {
        let uranusOrbit = createOrbit(orbitSize: 1.4)
        let uranus = SceneNodeBuilder.createPlanet(radius: 0.03, image: "uranus")
        uranus.name = "uranus"
        uranus.position = SCNVector3(x: 1.4, y: 0, z: 0)
        uranus.addRotationAction(duration: 0.4, rotation: 0.05)
        uranusOrbit.addRotationAction(duration: 1, rotation: 0.05)
        planets.append(uranus)
        orbits.append(uranusOrbit)
        uranusOrbit.addChildNode(uranus)
        addChildNode(uranusOrbit)
    }

    private func createNeptune() {
        let neptuneOrbit = createOrbit(orbitSize: 1.6)
        let neptune = SceneNodeBuilder.createPlanet(radius: 0.03, image: "neptune")
        neptune.name = "neptune"
        neptune.position = SCNVector3(x: 1.6, y: 0, z: 0)
        neptune.addRotationAction(duration: 0.4, rotation: 0.01)
        neptuneOrbit.addRotationAction(duration: 1, rotation: 0.01)
        planets.append(neptune)
        orbits.append(neptuneOrbit)
        neptuneOrbit.addChildNode(neptune)
        addChildNode(neptuneOrbit)
    }

    private func createPluton() {
        let plutoOrbit = createOrbit(orbitSize: 1.7)
        let pluto = SceneNodeBuilder.createPlanet(radius: 0.03, image: "pluton")
        pluto.name = "pluton"
        pluto.position = SCNVector3(x: 1.7, y: 0, z: 0)
        pluto.addRotationAction(duration: 0.4, rotation: 0.005)
        plutoOrbit.addRotationAction(duration: 1, rotation: 0.005)
        planets.append(pluto)
        orbits.append(plutoOrbit)
        plutoOrbit.addChildNode(pluto)
        addChildNode(plutoOrbit)
    }
}
