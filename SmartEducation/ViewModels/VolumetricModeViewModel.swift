//
//  VolumetricObjectsViewModel.swift
//  SmartEducation
//
//  Created by MacBook on 11/8/20.
//

import Foundation

class VolumetricModeViewModel {
    var volumetricObjects: [VolumetricObject] = [VolumetricObject]()
    var volumetricObjectsTypeChangedCommand: ((VolumetricItem) -> Void)?
    var volumetricItem: VolumetricItem?

    init() {
        volumetricObjectsTypeChangedCommand = volumetricObjectsTypeChanged
    }

    deinit {
        print("VolumetricModeViewModel has been released")
    }

    private func volumetricObjectsTypeChanged(volumetricItem: VolumetricItem) {
        self.volumetricItem = volumetricItem
        if volumetricItem == .volumetric {
            buildPlanets()
        } else if volumetricItem == .videos {
            buildVideos()
        }
    }

    private func buildPlanets() {
        volumetricObjects = [
            VolumetricObject(image: "earth", name: "Earth"),
            VolumetricObject(image: "mars", name: "Mars"),
            VolumetricObject(image: "moon", name: "Moon"),
            VolumetricObject(image: "solar_system", name: "Solar System")
        ]
    }

    private func buildVideos() {
        volumetricObjects = [
            VolumetricObject(image: "earth_video", name: "Earth"),
            VolumetricObject(image: "mars_video", name: "Mars"),
            VolumetricObject(image: "moon_video", name: "Moon"),
            VolumetricObject(image: "stream", name: "Stream")
        ]
    }
}
