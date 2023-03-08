//
//  MoonNode.swift
//  Earth App
//
//  Created by Lucas Cavatoni on 16/12/2020.
//


import SceneKit

let moonRadius: Float = 0.273 ///1737/6371

class MoonNode: SCNNode {
    override init(){
        super.init()
        
        self.categoryBitMask = LightType.moon
        
        //texture from https://richardandersson.net/?p=331
            
        //Creating sphere
        //Moon radius is 1737 km = 0.27264165751 Earth Radii so ~0.273
        let sphere = SCNSphere(radius: CGFloat(moonRadius))
        //Number of segments
        sphere.segmentCount = segments
        //Geometry is this sphere
        self.geometry = sphere
        
        //diffuse
        self.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "moon")
        self.geometry?.firstMaterial?.diffuse.mipFilter = SCNFilterMode.linear
        self.geometry?.firstMaterial?.diffuse.maxAnisotropy = anisotropy
        
        //normal
        self.geometry?.firstMaterial?.normal.contents = UIImage(named: "moon-normal")
        self.geometry?.firstMaterial?.normal.intensity = 0.1
        self.geometry?.firstMaterial?.normal.mipFilter = SCNFilterMode.linear
        self.geometry?.firstMaterial?.normal.maxAnisotropy = anisotropy
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
