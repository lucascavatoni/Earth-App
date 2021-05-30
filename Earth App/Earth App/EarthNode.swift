//
//  EarthNode.swift
//  Earth App
//
//  Created by Lucas Cavatoni on 21/11/2020.
//


import SceneKit

class EarthNode: SCNNode {
    override init() {
        super.init()
        
        //creating the surface node
        
        
        let surfaceNode = SurfaceNode(key: "bluemarble")
        self.addChildNode(surfaceNode)
        
        
        
        //creating the clouds node
        
//        let cloudsNodelw = CloudsNode(key: "vis")
//        self.addChildNode(cloudsNodelw)
        
        let cloudsNode = CloudsNode(key: "lw")
        self.addChildNode(cloudsNode)

        
        //creating the atmosphere node
        
        let atmosNode = AtmosNode()
        self.addChildNode(atmosNode)

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
