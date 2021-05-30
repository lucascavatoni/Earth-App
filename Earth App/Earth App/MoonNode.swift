//
//  MoonNode.swift
//  Earth App
//
//  Created by Lucas Cavatoni on 16/12/2020.
//


import SceneKit

class MoonNode: SCNNode {
    override init(){
        super.init()
        
        //Creating sphere
        //Moon radius is 1737 km = 0.27264165751 Earth Radii so ~0.273
        let sphere = SCNSphere(radius: 0.273)
        //Number of segments
        sphere.segmentCount = 10
        //Geometry is this sphere
        self.geometry = sphere
        
        //Color of the moon
        self.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        self.light = SCNLight()
        
        //Moonlight temperature
        self.light?.temperature = 4100
        self.light?.type = .directional
        
        self.castsShadow = false
        
//        let moonShadow = SCNNode()
//        let shadowSphere = SCNSphere(radius: 0.03)
//        shadowSphere.segmentCount = 10
//        moonShadow.geometry = shadowSphere
//        moonShadow.castsShadow = true
//
//        self.addChildNode(moonShadow)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
