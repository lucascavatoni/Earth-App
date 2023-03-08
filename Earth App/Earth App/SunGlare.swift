//
//  SunGlare.swift
//  Earth App
//
//  Created by Lucas Cavatoni on 20/02/2023.
//

import SceneKit

class SunGlare: SCNNode {
    override init() {
        super.init()
        
        self.categoryBitMask = LightType.emission
        
        let glareRadius = CGFloat(140)
    
        self.geometry = SCNPlane(width: 2*glareRadius*CGFloat(sunRadius), height: 2*glareRadius*CGFloat(sunRadius))
        
        let emissionTexture = UIImage(named: "glare")
//        let transparentTexture = emissionTexture?.modifyContrastAndInvert(value: 0.1, context: myContext)
        let transparentTexture = emissionTexture?.invert(context: myContext)
        
        self.geometry?.firstMaterial?.emission.contents = emissionTexture
        self.geometry?.firstMaterial?.emission.mipFilter = SCNFilterMode.linear
        self.geometry?.firstMaterial?.emission.maxAnisotropy = anisotropy
        //self.geometry?.firstMaterial?.emission.intensity = 100
        
        self.geometry?.firstMaterial?.transparent.contents = transparentTexture
        self.geometry?.firstMaterial?.transparent.mipFilter = SCNFilterMode.linear
        self.geometry?.firstMaterial?.transparent.maxAnisotropy = anisotropy
        self.geometry?.firstMaterial?.transparencyMode = .rgbZero //0.0 is opaque
//        self.geometry?.firstMaterial?.transparency = 0.5
        
        self.renderingOrder = 100
        self.geometry?.firstMaterial?.writesToDepthBuffer = false
        self.geometry?.firstMaterial?.readsFromDepthBuffer = false

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


