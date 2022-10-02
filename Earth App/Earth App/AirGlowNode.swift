//
//  AirGlowNode.swift
//  Earth App
//
//  Created by Lucas Cavatoni on 21/02/2022.
//

import SceneKit
import Foundation

class AirGlowNode: SCNNode {
    override init() {
        super.init()
    
        //96 km
        let sphere = SCNSphere(radius: 1.015)
        self.geometry = sphere
        sphere.segmentCount = 48
        
        let ShaderModifier =
        
        """

        //Function to convert sRGB values to Linear Color Space values, function found on stackOverflow, see link below
        //https://stackoverflow.com/questions/44033605/why-is-metal-shader-gradient-lighter-as-a-scnprogram-applied-to-a-scenekit-node/44045637#44045637
        //Formula available here :
        //https://en.wikipedia.org/wiki/SRGB#Theory_of_the_transformation
        float srgbToLinear(float c) {
            if (c <= 0.04045)
                return c / 12.92;
            else
                return powr((c + 0.055) / 1.055, 2.4);
        }
        
        #pragma transparent
        #pragma body

        vec3 light = _lightingContribution.diffuse;

        float sunLum = sqrt(light.r);
        float lum = max(0.0, 1.0 - 1.0 * sunLum);

        float factor = ( _surface.normal.x * _surface.normal.x + _surface.normal.y * _surface.normal.y );
        
        factor = powr(factor,64.);

        float red = srgbToLinear(1.) ;
        float green = srgbToLinear(1.) ;
        float blue = 0.;

        _output.color = vec4(red,green,blue,1.0) * lum * factor * 0.1;

        """

        self.geometry?.firstMaterial?.shaderModifiers = [.fragment: ShaderModifier]
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
