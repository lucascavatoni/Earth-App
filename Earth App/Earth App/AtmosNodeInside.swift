//
//  HaloNode.swift
//  Earth App
//
//  Created by Lucas Cavatoni on 16/07/2021.
//

import SceneKit


class AtmosNodeInside: SCNNode {
    override init() {
        super.init()
        
        self.categoryBitMask = LightType.earth
    
        //64 km
        let sphere = SCNSphere(radius: CGFloat(AtmosphereRadius))
        sphere.segmentCount = segments
        self.geometry = sphere
        
        self.geometry?.firstMaterial?.cullMode = .front
        self.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 1.0, green: 0.6, blue: 0.4, alpha: 0.5)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
