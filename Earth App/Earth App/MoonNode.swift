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
        let sphere = SCNSphere(radius: 0.3)
        //Number of segments
        sphere.segmentCount = 8
        //Geometry is this sphere
        self.geometry = sphere
        
        let diffuseTexture = UIImage(named: "moon")!
        
        let diffuse = SCNMaterialProperty(contents: diffuseTexture)
        
        self.geometry?.firstMaterial?.setValue(diffuse, forKey: "diffuseTexture")
        
        let ShaderModifier =

        """
        uniform sampler2D diffuseTexture;

        vec3 light = _lightingContribution.diffuse;
        
        float sunLum = light.r;
        
        vec4 diffuse = texture2D(diffuseTexture, _surface.diffuseTexcoord) * min(1.0,sunLum) ;

        _output.color = diffuse;

        """


        self.geometry?.firstMaterial?.shaderModifiers = [.fragment: ShaderModifier]
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
