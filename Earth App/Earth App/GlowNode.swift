//
//  glowNode.swift
//  Earth App
//
//  Created by Lucas Cavatoni on 06/11/2021.
//

import SceneKit

class GlowNode: SCNNode {
    override init() {
        super.init()
    
        let sphere = SCNSphere(radius: 1.017)
        self.geometry = sphere
        sphere.segmentCount = 48

        self.geometry?.firstMaterial?.diffuse.contents = UIColor.black
        self.geometry?.firstMaterial?.reflective.contents = UIColor(red: 0.1, green: 0.2, blue: 0.3, alpha: 1)
        self.geometry?.firstMaterial?.reflective.intensity = 10
        self.geometry?.firstMaterial?.transparent.contents = UIImage(named: "transparency")
        self.geometry?.firstMaterial?.transparencyMode = .rgbZero
        //higher value means more intense but more narrow circle
        self.geometry?.firstMaterial?.fresnelExponent = 10

    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

