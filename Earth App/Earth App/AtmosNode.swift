//
//  HaloNode.swift
//  Earth App
//
//  Created by Lucas Cavatoni on 16/07/2021.
//

import SceneKit

class AtmosNode: SCNNode {
    override init() {
        super.init()
    
        //64 km
        let sphere = SCNSphere(radius: 1.010)
        self.geometry = sphere
        sphere.segmentCount = 48
        
        //self.geometry?.firstMaterial?.isDoubleSided = true
        //self.geometry?.firstMaterial?.transparencyMode = .dualLayer
        
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
        float moonLum = sqrt(light.g*33.)/33.;
                
        float lum = max(sunLum,moonLum);

        float factor = ( _surface.normal.x * _surface.normal.x + _surface.normal.y * _surface.normal.y );
        
        //float factor4 = powr(factor,32);

        float red = srgbToLinear( 0.1 * (1.0 + 2.0 * factor ) ) ;
        float green = srgbToLinear( 0.2 * (1.0 + 1.0 * factor ) ) ;
        float blue = srgbToLinear( 0.3 * (1.0 + 0.5 * factor ) ) ;

        float nadirTransparency = 0.4 ;
        float edgeTransparency = 0.9 ;

        _output.color = vec4(red,green,blue,1.0) * lum * (nadirTransparency + (edgeTransparency - nadirTransparency) * (factor));

        """

        self.geometry?.firstMaterial?.shaderModifiers = [.fragment: ShaderModifier]
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
