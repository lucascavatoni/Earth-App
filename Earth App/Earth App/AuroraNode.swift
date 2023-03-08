//
//  AuroraNode.swift
//  Earth App
//
//  Created by Lucas Cavatoni on 23/11/2021.
//

import SceneKit
import Foundation

class AuroraNode: SCNNode {
    override init() {
        super.init()
        
        self.categoryBitMask = LightType.emission
        
        let geometry = SCNSphere(radius: 1.016) // 127 km
        self.geometry = geometry
        geometry.segmentCount = segments

        self.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
        
        self.geometry?.firstMaterial?.emission.mipFilter = SCNFilterMode.linear
        self.geometry?.firstMaterial?.emission.maxAnisotropy = anisotropy
        
        self.geometry?.firstMaterial?.transparent.mipFilter = SCNFilterMode.linear
        self.geometry?.firstMaterial?.transparent.maxAnisotropy = anisotropy
        
        self.geometry?.firstMaterial?.transparencyMode = .aOne
        
        self.name = "aurora"
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeAuroraLines(width: Int, height: Int) -> [PixelData]{
        var pixels: [PixelData] = .init(repeating: .init(a: 255, r: 0, g: 0, b: 0), count: width * height)
        var light: UInt8 = 128
        for _ in 0..<180 {
            var turned = 0
            var row = Int.random(in: 0...(height-1))
            for j in 0..<width {
                let dir = Int.random(in:1...21)
                if (dir > 2 ){
                    turned = 0
                } else if (dir == 1 && turned >= 0){
                    row = row + 1
                    turned = 1
                } else if (turned <= 0){
                    row = row - 1
                    turned = -1
                }
                if (row > 0 && row < height-1){
                    let minRand = max(Int(light) - 64,0)
                    let maxRand = min(Int(light) + 64,255)
                    light = UInt8(Int.random(in:minRand...maxRand))
                    
                    var index = row * width + j
                    pixels[index].r = light
                    
                    index = (row-1) * width + j
                    pixels[index].r = UInt8(Double(light)/4.0)
                    
                    index = (row+1) * width + j
                    pixels[index].r = UInt8(Double(light)/4.0)
                }
            }
        }
        
        return pixels
    }
    
//    func makeAuroraLines2() -> [PixelData]{
//        let height = 2048
//        let width = 4096
//        let k = 1.0/4096.0
//        let freq = 1.0
//        var pixels: [PixelData] = .init(repeating: .init(a: 0, r: 0, g: 0, b: 0), count: width * height)
//        var light: UInt8 = 128
//        for _ in 0..<60 {
//
//        }
//
//        return pixels
//    }
//
}

public struct PixelData {
    var a: UInt8
    var r: UInt8
    var g: UInt8
    var b: UInt8
}

func makePixelsFromData(stringArray: [String]) -> [PixelData]{
    let height = 181
    let width = 360
    var pixels: [PixelData] = .init(repeating: .init(a: 0, r: 0, g: 0, b: 0), count: width * height)
    for i in 0 ..< 65160 {
        
        let aurora = Double(stringArray[3*i+2])!/100.0
        
        if (aurora > 0){
            var lat = Int(stringArray[3*i+1])!
            if abs(lat) > 30 { // discarding the false positive at the equator
                var lon = Int(stringArray[3*i])!
                
                let auroraGreen = 0.3*aurora
                let auroraBlue = 0.2*aurora
                let auroraRed = 0.1*aurora
                
                let auroraAlpha = (0.2126 * auroraRed + 0.7152 * auroraGreen + 0.0722 * auroraBlue)
                
                lon = lon + 180;
                if (lon >= 360){
                    lon = lon - 360
                }
                
                lat = 90 - lat; ///so 0 is in the top-left
                let index = lat * width + lon
                pixels[index].a = UInt8(auroraAlpha*255.0)
                pixels[index].r = UInt8(auroraRed*255.0)
                pixels[index].g = UInt8(auroraGreen*255.0)
                pixels[index].b = UInt8(auroraBlue*255.0)
            }
        }
    }
    
    return pixels
}
