//
//  Shaders.swift
//  Earth App
//
//  Created by Lucas Cavatoni on 25/01/2023.
//

import Foundation

let sunSurfaceShader =
"""
_surface.emission.r *= 1.0;
_surface.emission.g *= 0.1;
_surface.emission.b *= 0.0;
"""

let sunFragmentShader =
"""
_output.color = vec4(_output.color.r,0.0*_output.color.g,0.0*_output.color.b,1.0);
"""

let glareSurfaceShader =
"""
vec2 uv = _surface.diffuseTexcoord;
float dist = distance(uv, vec2(0.5, 0.5));
float amount = 10000*smoothstep(0.3, 0.0, dist);
vec3 color = mix(_surface.diffuse.rgb, vec3(1.0), amount);
_surface.diffuse = vec4(color, 1.0);
"""

let earthSurfaceShader =
"""
float factor = dot(_surface.view,_surface.normal);

float factor1 = max(pow(factor,0.25),0.0);
float factor2 = max(pow(factor,0.5),0.0);

_surface.emission.g *= 0.3*factor1;
_surface.emission.b *= 0.1*factor2;

_surface.diffuse.rgb *= 0.5;

_surface.diffuse.g *= factor1;
_surface.diffuse.b *= factor2;

_surface.specular.g *= factor1;
//_surface.specular.b *= factor2;
"""

let terminatorFragmentShader =
"""
vec3 light = _lightingContribution.diffuse;
float lum = 0.2126*light.r + 0.7152*light.g + 0.0722*light.b;
if (lum > 0.01) {
    lum = lum/100;
    float lum2 = pow(lum,0.5);
    lum = pow(lum,0.3);
    _output.color.g *= lum;
    _output.color.b *= lum2;
}
"""

let atmosphereSurfaceShader =
"""
//Function to convert sRGB values to Linear Color Space values, function found on stackOverflow, see link below
//https://stackoverflow.com/questions/44033605/why-is-metal-shader-gradient-lighter-as-a-scnprogram-applied-to-a-scenekit-node/44045637#44045637
//Formula available here :
//https://en.wikipedia.org/wiki/SRGB#Theory_of_the_transformation

float sRGBtoLinear(float c) {
    if (c <= 0.04045)
        return c / 12.92;
    else
        return pow((c + 0.055) / 1.055, 2.4);
}

#pragma transparent
#pragma body

float factor = dot(_surface.view,_surface.normal);

// 1deg 0.01745240643
//10 deg 0.17364817766
float minCos = 0.2;
if (factor > minCos) {
    factor = 1/factor;
} else {
    factor = 1/minCos;
}

//vec3 sun = (1.0,0.0,0.5);
//float factor2 = dot(_surface.view,sun);
//if (factor2 < 0){
//    factor2 = 0.0;
//}

//549 nm for green, 612 nm for red and 464 nm for blue
//https://www.researchgate.net/figure/Peak-wavelengths-are-blue-440-nm-green-500-nm-red-625-nm_fig7_259354674

//Red light has a wavelength of approximately 620 to 750 nanometers (nm).
//Green light has a wavelength of approximately 495 to 570 nm.
//Blue light has a wavelength of approximately 450 to 495 nm.

//vec3 wavelengths = vec3(625,500,440);

vec3 wavelengths = vec3(560,500,440); //changed red wavelength

//vec3 wavelengths = vec3(600,500,400);
//vec3 wavelengths = vec3(612,549,464);
//vec3 wavelengths = vec3(700,530,440);
//vec3 wavelengths = vec3(560,530,430);
//vec3 wavelengths = vec3(650,570,475); //Sean O'Neil values

float  intensity = 0.5;

float red = sRGBtoLinear(pow(wavelengths.b/wavelengths.r,4)*factor) * minCos;
float green = sRGBtoLinear(pow(wavelengths.b/wavelengths.g,4)*factor) * minCos;
float blue = sRGBtoLinear(1.0*factor) * minCos;

//float red = pow(wavelengths.b/wavelengths.r,4)*factor*intensity;
//float green = pow(wavelengths.b/wavelengths.g,4)*factor*intensity;
//float blue = 1.0*factor*intensity;

_surface.diffuse = vec4(red,green,blue,1.0) * 0.2;
"""

let atmosphereSurfaceShader2 =
"""
//
// Atmospheric scattering vertex shader
//
// Author: Sean O'Neil
//
// Copyright (c) 2004 Sean O'Neil
//

uniform vec3 v3CameraPos;        // The camera's current position
uniform vec3 v3LightPos;        // The direction vector to the light source
uniform vec3 v3InvWavelength;    // 1 / pow(wavelength, 4) for the red, green, and blue channels
uniform float fCameraHeight;    // The camera's current height
uniform float fCameraHeight2;    // fCameraHeight^2
uniform float fOuterRadius;        // The outer (atmosphere) radius
uniform float fOuterRadius2;    // fOuterRadius^2
uniform float fInnerRadius;        // The inner (planetary) radius
uniform float fInnerRadius2;    // fInnerRadius^2
uniform float fKrESun;            // Kr * ESun
uniform float fKmESun;            // Km * ESun
uniform float fKr4PI;            // Kr * 4 * PI
uniform float fKm4PI;            // Km * 4 * PI
uniform float fScale;            // 1 / (fOuterRadius - fInnerRadius)
uniform float fScaleDepth;        // The scale depth (i.e. the altitude at which the atmosphere's average density is found)
uniform float fScaleOverScaleDepth;    // fScale / fScaleDepth

const int nSamples = 2;
const float fSamples = 2.0;

varying vec3 v3Direction;


float scale(float fCos)
{
    float x = 1.0 - fCos;
    return fScaleDepth * exp(-0.00287 + x*(0.459 + x*(3.83 + x*(-6.80 + x*5.25))));
}

void main(void)
{
    // Get the ray from the camera to the vertex and its length (which is the far point of the ray passing through the atmosphere)
    vec3 v3Pos = gl_Vertex.xyz;
    vec3 v3Ray = v3Pos - v3CameraPos;
    float fFar = length(v3Ray);
    v3Ray /= fFar;

    // Calculate the closest intersection of the ray with the outer atmosphere (which is the near point of the ray passing through the atmosphere)
    float B = 2.0 * dot(v3CameraPos, v3Ray);
    float C = fCameraHeight2 - fOuterRadius2;
    float fDet = max(0.0, B*B - 4.0 * C);
    float fNear = 0.5 * (-B - sqrt(fDet));

    // Calculate the ray's starting position, then calculate its scattering offset
    vec3 v3Start = v3CameraPos + v3Ray * fNear;
    fFar -= fNear;
    float fStartAngle = dot(v3Ray, v3Start) / fOuterRadius;
    float fStartDepth = exp(-1.0 / fScaleDepth);
    float fStartOffset = fStartDepth*scale(fStartAngle);

    // Initialize the scattering loop variables
    //gl_FrontColor = vec4(0.0, 0.0, 0.0, 0.0);
    float fSampleLength = fFar / fSamples;
    float fScaledLength = fSampleLength * fScale;
    vec3 v3SampleRay = v3Ray * fSampleLength;
    vec3 v3SamplePoint = v3Start + v3SampleRay * 0.5;

    // Now loop through the sample rays
    vec3 v3FrontColor = vec3(0.0, 0.0, 0.0);
    for(int i=0; i<nSamples; i++)
    {
        float fHeight = length(v3SamplePoint);
        float fDepth = exp(fScaleOverScaleDepth * (fInnerRadius - fHeight));
        float fLightAngle = dot(v3LightPos, v3SamplePoint) / fHeight;
        float fCameraAngle = dot(v3Ray, v3SamplePoint) / fHeight;
        float fScatter = (fStartOffset + fDepth*(scale(fLightAngle) - scale(fCameraAngle)));
        vec3 v3Attenuate = exp(-fScatter * (v3InvWavelength * fKr4PI + fKm4PI));
        v3FrontColor += v3Attenuate * (fDepth * fScaledLength);
        v3SamplePoint += v3SampleRay;
    }

    // Finally, scale the Mie and Rayleigh colors and set up the varying variables for the pixel shader
    gl_FrontSecondaryColor.rgb = v3FrontColor * fKmESun;
    gl_FrontColor.rgb = v3FrontColor * (v3InvWavelength * fKrESun);
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
    v3Direction = v3CameraPos - v3Pos;
}

"""


let auroraGeometryShader =
"""
uniform float Amplitude = 0.1;
 
_geometry.position *= _geometry.position.y;
"""


//self.geometry?.firstMaterial?.shaderModifiers = [.geometry: geometryShader]

//Phong highlights always appear circular (on flat surfaces) and Blinns stretch out if you are viewing the surface from a shallow angle
//self.geometry?.firstMaterial?.lightingModel = SCNMaterial.LightingModel.phong

//let ShaderModifier =

//        """
//        uniform sampler2D diffuseTexture;
//
//        uniform vec3 direction = _light.direction;
//
//        uniform float scalar = dot(direction,_surface.normal)*_light.intensity.rgb;
//
//        vec3 light = _lightingContribution.diffuse;
//        //float lum = 0.2126*light.r + 0.7152*light.g + 0.0722*light.b;
//        float sunLum = light.r;
//        float moonLum = light.g;
//        vec4 ground = texture2D(diffuseTexture, _surface.diffuseTexcoord);
//
//        //ground.r = powr(ground.r,0.7);
//        //ground.g = powr(ground.g,1.0);
//        //ground.b = powr(ground.b,1.4);
//
//        float ambient = 0.002;
//
//        //epsilon = 0.01;
//
//        //if ((ground.r - ground.g > 0.03) || (ground.g - ground.b > 0.03)){
//        //    ground.g = 0.7*ground.g;
//        //    ground.b = 0.2*ground.b;
//        //} else {
//        //    //ground.b = 0.8 * ground.b;
//        //}
//
//        if (sunLum > 0.001){
//            ground.r = ground.r * sunLum * sunLum;
//            ground.g = ground.g * sunLum * powr(sunLum,1.4);
//            ground.b = ground.b * sunLum * powr(sunLum,2.0);
//        } else {
//            ground.r = ground.r * max(moonLum,ambient);
//            ground.g = ground.g * max(moonLum,ambient);
//            ground.b = ground.b * max(moonLum,ambient);
//        }
//
//        vec4 diffuse = ground;
//
//        _output.color = diffuse;
//
//        uniform sampler2D specularTexture;
//
//        float factor = ( _surface.normal.x * _surface.normal.x + _surface.normal.y * _surface.normal.y );
//
//        vec3 specular = _lightingContribution.specular;
//        float lumSpecular = 0.2126*specular.r + 0.7152*specular.g + 0.0722*specular.b;
//        vec4 specularColor = texture2D(specularTexture, _surface.specularTexcoord) * lumSpecular * (1.0 + 100 * powr(factor,4));
//        specularColor = vec4(specularColor.r,specularColor.g*(1.0-0.6*factor),0.9*specularColor.b*(1.0-1.0*factor),1.0);
//        _output.color += specularColor;
//
//        //uniform sampler2D normalTexture;
//        //vec4 normal = texture2D(normalTexture, _surface.normalTexcoord);
//        //_output.color += normal;
//
//                uniform sampler2D emissionTexture;
//
//                float lum = max(0.0, 1.0 - 100.0 * sunLum);
//                vec4 emission = texture2D(emissionTexture, _surface.emissionTexcoord) * lum;
//
//                //vec4 lights = vec4(emission.r*emission.r,emission.r*0.2*(1.0-0.5*factor),0.1*emission.r*(1.0-emission.r)*(1.0-factor),1.0);
//                //vec4 lights = vec4(emission.r,0.1*log(10*emission.r+1),0.01*log(100*emission.r+1),1.0);
//
//                factor = factor*factor;
//
//                //HP sodium sRGB : 255, 183, 76
//                //in Linear sRGB : 1, 0.47353149614801, 0.0722718506823175 -> 1, 0.47, 0.072
//
//                //HPS is 2200K -> https://andi-siess.de/rgb-to-color-temperature/ -> 255, 147, 44 -> 1, 0.291770649817536, 0.0251868596273616
//                // 1, 0.29, 0.026 -> 255, 147, 44
//                // other source https://academo.org/demos/colour-temperature-relationship/ : 255, 146, 39 -> 1, 0.287440837726917, 0.0202885630566524
//
//                vec4 lights = vec4(emission.r,0.5*emission.g,0.1*emission.b,1.0);
//
//                _output.color += lights;
//
//        """

//self.geometry?.firstMaterial?.shaderModifiers = [.fragment: ShaderModifier]


//let ShaderModifier =
//
//"""
////Function to convert sRGB values to Linear Color Space values, function found on stackOverflow, see link below
////https://stackoverflow.com/questions/44033605/why-is-metal-shader-gradient-lighter-as-a-scnprogram-applied-to-a-scenekit-node/44045637#44045637
////Formula available here :
////https://en.wikipedia.org/wiki/SRGB#Theory_of_the_transformation
//
//float srgbToLinear(float c) {
//    if (c <= 0.04045)
//        return c / 12.92;
//    else
//        return powr((c + 0.055) / 1.055, 2.4);
//}
//
//float linearToSrgb(float c) {
//    if (c <= 0.0031308)
//        return c * 12.92;
//    else
//        return 1.055 * powr(c, 1.0/2.4) - 0.055;
//}
//
//#pragma body
//#pragma transparent
//
//uniform sampler2D diffuseTexture;
//
//vec3 light = _lightingContribution.diffuse;
////float lum = 0.2126*light.r + 0.7152*light.g + 0.0722*light.b;
//
//float sunLum = sqrt(light.r);
//float moonLum = light.g;
//
//vec4 diffuse = texture2D(diffuseTexture, _surface.diffuseTexcoord);
//
//float color = diffuse.r;
//
//if (color > 0.9){
//    color = 0.2;
//}
//// 70 and 220
////
//float minValue = 0.061;
//float maxValue = 0.716;
//
//color = (color - minValue)/(maxValue-minValue);
//
//if (color > 1.0){
//    color = 1.0;
//}
//
//if (color < 0.0){
//    color = 0.0;
//}
//
//float factor = ( _surface.normal.x * _surface.normal.x + _surface.normal.y * _surface.normal.y );
//
//factor = factor*factor;
//
//color = sqrt(color);
//
//float alpha = color;
////float alpha = powr(color,0.1);
//
//float red = color ;
//float green = color * (1 - 0.5 * factor);
//float blue = 0.9 * color * (1.0 - factor);
//
//float ambient = 0.002;
//
//if (sunLum > 0.001){
//    red = red * sunLum * sunLum;
//    green = green * sunLum * powr(sunLum,1.4);
//    blue = blue * sunLum * powr(sunLum,2.0);
//} else {
//    red = red * max(moonLum,ambient);
//    green = green * max(moonLum,ambient);
//    blue = blue * max(moonLum,ambient);
//}
//
//_output.color = vec4(red,green,blue,1.0) * alpha;
//
//"""


//                        """
//                        #pragma transparent
//
//                        uniform sampler2D auroraTexture;
//                        //uniform sampler2D auroraLinesTexture;
//
//                        vec3 light = _lightingContribution.diffuse;
//                        float sunLum = light.r;
//                        float lum = max(0.0, 1.0 - 100.0 * sunLum);
//
//                        vec4 aurora = texture2D(auroraTexture, _surface.emissionTexcoord);
//                        //vec4 auroraLines = texture2D(auroraLinesTexture, _surface.emissionTexcoord);
//
//                        float alpha = 0.2126*aurora.r + 0.7152*aurora.g + 0.0722*aurora.b;
//
//                        aurora = aurora * lum * alpha ;
//
//                        _output.color = aurora ;
//
//                        """

//                let geoShader =
//
//                """
//
//                uniform sampler2D auroraTexture;
//                uniform sampler2D auroraLinesTexture;
//
//                #pragma body
//
//                //vec4 aurora = texture2D(auroraTexture, _geometry.texcoords[0]);
//                vec4 auroraLines = texture2D(auroraLinesTexture, _geometry.texcoords[0]);
//
//                float intensity = auroraLines.r;
//
//                _geometry.position.xyz *= (1.0 + 0.1*intensity);
//
//                """

//        """
//        //Function to convert sRGB values to Linear Color Space values, function found on stackOverflow, see link below
//        //https://stackoverflow.com/questions/44033605/why-is-metal-shader-gradient-lighter-as-a-scnprogram-applied-to-a-scenekit-node/44045637#44045637
//        //Formula available here :
//        //https://en.wikipedia.org/wiki/SRGB#Theory_of_the_transformation
//        float srgbToLinear(float c) {
//            if (c <= 0.04045)
//                return c / 12.92;
//            else
//                return powr((c + 0.055) / 1.055, 2.4);
//        }
//
//        #pragma transparent
//        #pragma body
//
//        //float test = _light.intensity.rgb;
//
//        vec3 light = _lightingContribution.diffuse;
//
//        //float lum = min((0.2126*light.r + 0.7152*light.g + 0.0722*light.b)/50.0,1.0);
//
//        //float lum = sqrt((0.2126*light.r + 0.7152*light.g + 0.0722*light.b)/100); //intensity 1000 -> shader lum 1
//
//        float lum = (0.2126*light.r + 0.7152*light.g + 0.0722*light.b)/100;
//
//        //lum = srgbToLinear(lum);
//
//        //float lum = sqrt(sqrt((0.2126*light.r + 0.7152*light.g + 0.0722*light.b)/100.0));
//
//        float factor = dot(_surface.view,_surface.normal);
//
//        // 1deg 0.01745240643
//        //10 deg 0.17364817766
//        float minCos = 0.1;
//        if (factor > minCos) {
//            factor = 1/factor;
//        } else {
//            factor = 1/minCos;
//        }
//
//        //factor = sqrt(factor/10)*10;
//
//        float red = srgbToLinear( 0.5 * factor ) ; //2.0
//        float green = srgbToLinear( 0.7 * factor ) ; //1.0
//        float blue = srgbToLinear( 1.0 * factor ) ; //0.5
//
//        //https://www.researchgate.net/figure/Peak-wavelengths-are-blue-440-nm-green-500-nm-red-625-nm_fig7_259354674
//
//        //float red = srgbToLinear(0.5 * (1.0 + factor*(1+factor)));
//        //float green = srgbToLinear(0.7 * (1.0 + factor*(1+factor)));
//        //float blue = srgbToLinear(1.0 * (1.0 + factor*(1+factor)));
//
//        float nadirTransparency = 0.5 ; //=0.5 in non-linear sRGB
//        float edgeTransparency = 1.0 ;
//
//        float intensity = 5;
//
//        _output.color = vec4(intensity*red,intensity*green,intensity*blue,1.0) * 0.5 * lum;
//        """
