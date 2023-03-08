//
//  AirGlowNode.swift
//  Earth App
//
//  Created by Lucas Cavatoni on 21/02/2022.
//

import SceneKit
import Foundation

class AirGlowNode: SCNNode {
    override init() {
        super.init()
    
        self.categoryBitMask = LightType.emission
        
        //96 km
        let sphere = SCNSphere(radius: 1.015)
        self.geometry = sphere
        sphere.segmentCount = segments
        
        self.geometry?.firstMaterial?.diffuse.contents = UIColor.black
        self.geometry?.firstMaterial?.reflective.contents = UIColor(red: 0.2, green: 0.2, blue: 0.0, alpha: 1)
        self.geometry?.firstMaterial?.reflective.intensity = 1.0
        self.geometry?.firstMaterial?.transparent.contents = UIColor.black.withAlphaComponent(0.1)
        self.geometry?.firstMaterial?.transparencyMode = .default
        self.geometry?.firstMaterial?.fresnelExponent = 10

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
