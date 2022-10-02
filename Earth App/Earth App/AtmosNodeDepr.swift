//
//  EarthAtmNode.swift
//  Earth App
//
//  Created by Lucas Cavatoni on 20/11/2020.
//

import SceneKit

class AtmosNodeDepr: SCNNode {
    override init(){
        super.init()
        
        
        //Creating sphere
        let sphere = SCNSphere(radius: 1.010)
        //Number of segments
        sphere.segmentCount = 48
        //Geometry is this sphere
        self.geometry = sphere
        
        //Atmosphere color
        self.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 0.1, green: 0.2, blue: 0.3, alpha: 1)
        
        //Atmosphere transparency
        self.geometry?.firstMaterial?.transparency = 0.0

        self.geometry?.firstMaterial?.shininess = 0.0

                
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    


}
