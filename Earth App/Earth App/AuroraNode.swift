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

        //127 km
        let geometry = SCNSphere(radius: 1.020)
        self.geometry = geometry
        geometry.segmentCount = 48
        
        self.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
        
        //let url = URL(string: )!
        //let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            //guard let data = data, error == nil else { return }

            //DispatchQueue.main.async() { [self] in    // execute on main thread
                
                //Because original image has an underlay of blue marble old generation
                //So in color, so we must turn the image in black and white
        if let url = URL(string: "https://services.swpc.noaa.gov/json/ovation_aurora_latest.json") {
            do {
                var contents = try String(contentsOf: url)

                contents = contents.substring(fromIndex: 150)
                
                contents = contents.filter("-0123456789,".contains)
                
                let stringArray = contents.components(separatedBy: ",")
                
                let pixels = makePixelsFromData(stringArray: stringArray)
                
                let auroraTexture = UIImage(pixels: pixels, width: 360, height: 181)
                
                //aurora lines width
                //let width = 360
                //let height = width / 2
                
                //let auroraLinesPixels = makeAuroraLines(width: width, height: height)
                //let auroraLinesTexture = UIImage(pixels: auroraLinesPixels, width: width, height: height)
                
                //let auroraLinesTexture = UIImage(named: "auroraLines")
                
                //emission
                let aurora = SCNMaterialProperty(contents: auroraTexture!)
                //let auroraLines = SCNMaterialProperty(contents: auroraLinesTexture!)
                
                //setting the value
                self.geometry?.firstMaterial?.setValue(aurora, forKey: "auroraTexture")
                //self.geometry?.firstMaterial?.setValue(auroraLines, forKey: "auroraLinesTexture")
                
                
                //self.geometry?.firstMaterial?.transparencyMode = .dualLayer
                
                let shaderModifier =
                
                """
                #pragma transparent

                uniform sampler2D auroraTexture;
                //uniform sampler2D auroraLinesTexture;
                
                vec3 light = _lightingContribution.diffuse;
                float sunLum = light.r;
                float lum = max(0.0, 1.0 - 100.0 * sunLum);
                
                vec4 aurora = texture2D(auroraTexture, _surface.emissionTexcoord);
                //vec4 auroraLines = texture2D(auroraLinesTexture, _surface.emissionTexcoord);
                
                float alpha = 0.2126*aurora.r + 0.7152*aurora.g + 0.0722*aurora.b;
                
                aurora = aurora * lum * alpha * 0.2 ;
                
                _output.color = aurora ;

                """
                
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
                
                self.geometry?.firstMaterial?.shaderModifiers = [.fragment: shaderModifier]
                
                //self.isDoubleSided
                
                
            } catch {
                // contents could not be loaded
            }
        } else {
            // the URL was bad!
        }
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makePixelsFromData(stringArray: [String]) -> [PixelData]{
        let height = 181
        let width = 360
        var pixels: [PixelData] = .init(repeating: .init(a: 0, r: 0, g: 0, b: 0), count: width * height)
        for i in 0 ..< 65160 {
                
            var lat = Int(stringArray[3*i+1])!
            let aurora = Float(stringArray[3*i+2])!/100
            
            if (aurora > 0){
                if (abs(lat) > 45){
                    var lon = Int(stringArray[3*i])!
                    let auroraGreen = aurora
                    
                    //let auroraRed = aurora * aurora
                    //let auroraBlue = 0.33 * sqrt(aurora)
                    
                    let auroraBlue = 0.1*log(10*aurora+1)
                    let auroraRed = 0.01*log(100*aurora+1)
                    
                    //let auroraBlue = log(aurora+1)
                    //let auroraRed = 0.1*log(10*aurora+1)
                    
                    //let auroraRed = 0.0
                    //let auroraBlue = 0.0 * aurora

                    lon = lon + 180;
                    if (lon >= 360){
                        lon = lon - 360
                    }
                    
                    lat = 90 - lat;
                    let index = lat * width + lon
                    pixels[index].a = 255
                    pixels[index].r = UInt8(auroraRed*255.0)
                    pixels[index].g = UInt8(auroraGreen*255.0)
                    pixels[index].b = UInt8(auroraBlue*255.0)
                }
            }
        }
        
        return pixels
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
    
    func makeAuroraLines2() -> [PixelData]{
        let height = 2048
        let width = 4096
        let k = 1.0/4096.0
        let freq = 1.0
        var pixels: [PixelData] = .init(repeating: .init(a: 0, r: 0, g: 0, b: 0), count: width * height)
        var light: UInt8 = 128
        for _ in 0..<60 {
            
        }
        
        return pixels
    }

}

public struct PixelData {
    var a: UInt8
    var r: UInt8
    var g: UInt8
    var b: UInt8
}
