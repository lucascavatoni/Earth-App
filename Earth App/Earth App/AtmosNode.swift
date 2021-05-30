//
//  EarthAtmNode.swift
//  Earth App
//
//  Created by Lucas Cavatoni on 20/11/2020.
//

import SceneKit

class AtmosNode: SCNNode {
    override init(){
        super.init()
        
        
        //Creating sphere
        let sphere = SCNSphere(radius: 1.010)
        //Number of segments
        sphere.segmentCount = 48
        //Geometry is this sphere
        self.geometry = sphere
        
        //Atmosphere color
        self.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 0.4, green: 0.6, blue: 0.9, alpha: 1)
        
        //Atmosphere transparency (between 0.1 and 0.3 is good)
        self.geometry?.firstMaterial?.transparency = 0.1

        self.geometry?.firstMaterial?.shininess = 0.0
        
        self.castsShadow = false
                
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    


}
