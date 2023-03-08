//
//  EarthNode.swift
//  Earth App
//
//  Created by Lucas Cavatoni on 21/11/2020.
//

import SceneKit

class EarthNode: SCNNode {
    //init(lon: Float) {
    override init() {
        super.init()
        
        // SURFACE
        let surfaceNode = SurfaceNode()
        surfaceNode.renderingOrder = 0
        self.addChildNode(surfaceNode)
        
        // CLOUDS
        let cloudsNode = CloudsNode()
        cloudsNode.renderingOrder = 1
        self.addChildNode(cloudsNode)
        
        // INSIDE OF ATMOSPHERE
        let atmosphereInside = AtmosNodeInside()
        atmosphereInside.renderingOrder = 2
        self.addChildNode(atmosphereInside)
        
        // ATMOSPHERE
        let atmosphere = AtmosNode()
        atmosphere.renderingOrder = 3
        self.addChildNode(atmosphere)
        
        // AIRGLOW
        let airGlow = AirGlowNode()
        airGlow.renderingOrder = 4
        self.addChildNode(airGlow)

        // AURORA
        let aurora = AuroraNode()
        aurora.renderingOrder = 5
        self.addChildNode(aurora)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
