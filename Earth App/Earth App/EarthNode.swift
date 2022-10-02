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
        let surfaceNode = SurfaceNode()
        self.addChildNode(surfaceNode)
        
        //creating the clouds node
        let cloudsNode = CloudsNode(key: "eumetsat")
        self.addChildNode(cloudsNode)
        
        //Creating atmosphere
        let atmosphere = AtmosNode()
        self.addChildNode(atmosphere)
        
        //Adding AirGlow
        //let airGlow = AirGlowNode()
        //self.addChildNode(airGlow)

        //Adding Aurora Borealis
        let auroraBorealis = AuroraNode()
        self.addChildNode(auroraBorealis)


    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
