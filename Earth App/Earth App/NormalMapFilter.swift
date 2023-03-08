//
//  NormalMapFilter.swift
//  SceneKitProceduralNormalMapping
//
//  Created by Simon Gladman on 11/04/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//
import CoreImage

//from https://github.com/FlexMonkey/SceneKitProceduralNormalMapping
//class NormalMapFilter: CIFilter
//{
//    var inputImage: CIImage?
//
//    override var attributes: [String : Any]
//    {
//        return [
//            kCIAttributeFilterDisplayName: "NormalMap",
//
//            "inputImage": [kCIAttributeIdentity: nil,
//                kCIAttributeClass: "CIImage",
//                kCIAttributeDisplayName: "Image",
//                kCIAttributeType: kCIAttributeTypeImage]
//        ]
//    }
//
//    let normalMapKernel = CIKernel(source:
//        """
//        float lumaAtOffset(sampler source, vec2 origin, vec2 offset) {
//          vec3 pixel = sample(source, samplerTransform(source, origin + offset)).rgb;
//          float luma = dot(pixel, vec3(0.2126, 0.7152, 0.0722));
//          return luma;
//        }
//
//        kernel vec4 normalMap(sampler image) {
//          vec2 d = destCoord()
//          float northLuma = lumaAtOffset(image, d, vec2(0.0, -1.0));
//          float southLuma = lumaAtOffset(image, d, vec2(0.0, 1.0));
//          float westLuma = lumaAtOffset(image, d, vec2(-1.0, 0.0));
//          float eastLuma = lumaAtOffset(image, d, vec2(1.0, 0.0));
//          float horizontalSlope = ((westLuma - eastLuma) + 1.0) * 0.5;
//          float verticalSlope = ((northLuma - southLuma) + 1.0) * 0.5;
//          return vec4(horizontalSlope, verticalSlope, 1.0, 1.0);
//        }
//        """
//    )
//
//    override var outputImage: CIImage?
//    {
//        guard let inputImage = inputImage,
//              let normalMapKernel = normalMapKernel else
//        {
//            return nil
//        }
//
//        return normalMapKernel.apply(extent: inputImage.extent,
//                                                roiCallback:
//            {
//                (index, rect) in
//                return rect
//            },
//                                                arguments: [inputImage])
//    }
//}
//
//class CustomFiltersVendor: NSObject, CIFilterConstructor
//{
//    static func registerFilters()
//    {
//        CIFilter.registerName("NormalMap",
//                                    constructor: CustomFiltersVendor(),
//                                    classAttributes: [
//                                        kCIAttributeFilterCategories: ["CustomFilters"]
//            ])
//}
//
//    func filter(withName name: String) -> CIFilter?
//    {
//        switch name
//        {
//        case "NormalMap":
//            return NormalMapFilter()
//        default:
//            return nil
//        }
//    }
//}


//from the book Core Image for Swift, Simon J Gladman
//class NormalMapFilter: CIFilter
//{
//    var inputImage : CIImage?
//
//    var generalKernel = CIKernel(source:
//    """
//    float lumaAtOffset(sampler source, vec2 origin, vec2 offset) {
//      vec3 pixel = sample(source, samplerTransform(source, origin + offset)).rgb;
//      float luma = dot(pixel, vec3(0.2126, 0.7152, 0.0722));
//      return luma;
//    }
//
//    kernel vec4 normalMap(sampler image) {
//      vec2 d = destCoord()
//      float northLuma = lumaAtOffset(image, d, vec2(0.0, -1.0));
//      float southLuma = lumaAtOffset(image, d, vec2(0.0, 1.0));
//      float westLuma = lumaAtOffset(image, d, vec2(-1.0, 0.0));
//      float eastLuma = lumaAtOffset(image, d, vec2(1.0, 0.0));
//      float horizontalSlope = ((westLuma - eastLuma) + 1.0) * 0.5;
//      float verticalSlope = ((northLuma - southLuma) + 1.0) * 0.5;
//      return vec4(horizontalSlope, verticalSlope, 1.0, 1.0);
//    }
//    """
//    )
//
//    override var outputImage : CIImage!
//    {
//        if let inputImage = inputImage,
//           let generalKernel = generalKernel
//        {
//            let extent = inputImage.extent
//            let arguments = [inputImage]
//
//            return generalKernel.apply(extent: extent,
//                roiCallback:
//                {
//                    (index, rect) in
//                    return rect
//                },
//                arguments: arguments)
//        }
//        return nil
//    }
//}

// https://jameshfisher.com/2017/04/27/custom-cifilter/
// kernel from http://flexmonkey.blogspot.com/2016/04/creating-procedural-normal-maps-for.html
let kernels = CIKernel.makeKernels(source:
    """
    float lumAtOffset(sampler source, vec2 origin, vec2 offset) {
      vec3 pixel = sample(source, samplerTransform(source, origin + offset)).rgb;
      float lum = pixel.r; //from grayscale image, all channels are equal to luminance
      return lum;
    }

    kernel vec4 normalMap(sampler image) {
      vec2 d = destCoord();
      float intensity = 10.0; //how much the features are amplified, more intensity = little details pop out more
      float northLum = lumAtOffset(image, d, vec2(0.0, -1.0));
      float southLum = lumAtOffset(image, d, vec2(0.0, 1.0));
      float westLum = lumAtOffset(image, d, vec2(-1.0, 0.0));
      float eastLum = lumAtOffset(image, d, vec2(1.0, 0.0));
      float horizontalSlope = (intensity * (westLum - eastLum) + 1.0) * 0.5;
      float verticalSlope = (intensity * (southLum - northLum) + 1.0) * 0.5;
      return vec4(horizontalSlope, verticalSlope, 1.0, 1.0) ;
    }
    """
)!

let myKernel = kernels[0]

class NormalMapFilter : CIFilter {
    var inputImage:CIImage?
    override var outputImage: CIImage? {
        let src = CISampler(image: self.inputImage!)
        return myKernel.apply(extent: inputImage!.extent, roiCallback: {(index, rect) in return rect}, arguments: [src])
    }
}
