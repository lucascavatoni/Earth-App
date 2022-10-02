//
//  SunNode.swift
//  Earth App
//
//  Created by Lucas Cavatoni on 03/12/2020.
//

import SceneKit

class SunNode: SCNNode {
    override init(){
        super.init()
        
        //Geometry is a plane (sprite)
        let size: CGFloat = 10
        self.geometry = SCNPlane(width: size, height: size)
        
        let sunTexture = UIImage(named: "sun")
        
        //Setting the sun's texture
        self.geometry?.firstMaterial?.emission.contents = sunTexture
        
        //Setting the sun's diffuse content
        self.geometry?.firstMaterial?.diffuse.contents = UIColor.black.withAlphaComponent(1)
        
        //Setting the inverted sun texture as transparency mask
        self.geometry?.firstMaterial?.transparent.contents = sunTexture?.invert()
        
        //Telling scenekit to take the image RGB colors as transparency mask
        self.geometry?.firstMaterial?.transparencyMode = .rgbZero
        
        self.geometry?.firstMaterial?.lightingModel = SCNMaterial.LightingModel.constant
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
