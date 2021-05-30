//
//  UIImage+replaceColor.swift
//  Earth App
//
//  Created by Lucas Cavatoni on 28/12/2020.
//

import Foundation
import UIKit

extension UIImage {

    @discardableResult func replace(color: UIColor, withColor replacingColor: UIColor) -> UIImage {
        let inputCGImage = self.cgImage
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let width            = inputCGImage?.width
        let height           = inputCGImage?.height
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width!
        let bitmapInfo       = RGBA32.bitmapInfo

        let context = CGContext(data: nil, width: width!, height: height!, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        
        context!.draw(inputCGImage!, in: CGRect(x: 0, y: 0, width: width!, height: height!))

        let buffer = context?.data

        let pixelBuffer = buffer?.bindMemory(to: RGBA32.self, capacity: width! * height!)

        let inColor = RGBA32(color: color)
        let outColor = RGBA32(color: replacingColor)
        for row in 0 ..< Int(height!) {
            for column in 0 ..< Int(width!) {
                let offset = row * width! + column
                if pixelBuffer?[offset] == inColor {
                    pixelBuffer?[offset] = outColor
                }
            }
        }
   
        let outputCGImage = (context?.makeImage()!)!

        return UIImage(cgImage: outputCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
    
    @discardableResult func handleNOAA() -> UIImage {
        let inputCGImage = self.cgImage
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let width            = inputCGImage?.width
        let height           = inputCGImage?.height
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width!
        let bitmapInfo       = RGBA32.bitmapInfo

        let context = CGContext(data: nil, width: width!, height: height!, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)

        context!.draw(inputCGImage!, in: CGRect(x: 0, y: 0, width: width!, height: height!))

        let buffer = context?.data

        let pixelBuffer = buffer?.bindMemory(to: RGBA32.self, capacity: width! * height!)

        let Cyan = RGBA32(color: UIColor(red: 0, green: 1, blue: 1, alpha: 1))
        let Red = RGBA32(color: UIColor(red: 1, green: 0, blue: 0, alpha: 1))
        let Green = RGBA32(color: UIColor(red: 0, green: 1, blue: 0, alpha: 1))
        let Magenta = RGBA32(color: UIColor(red: 1, green: 0, blue: 1, alpha: 1))

        
        //Remove meridians
        for row in 0 ..< Int(height! - 12) {
            for column in 0 ..< Int(width! - 3) {
                let offset = row * width! + column
                if pixelBuffer?[offset] == Cyan {
                    let replacingColumn = column + 1
                    let replacingOffset = row * width! + replacingColumn
                    pixelBuffer?[offset] = (pixelBuffer?[replacingOffset])!
                }
            }
        }
        
        //Remove latitude lines : parallels
        for row in 0 ..< Int(height! - 12) {
            for column in 0 ..< Int(width! - 3) {
                let offset = row * width! + column
                if pixelBuffer?[offset] == Cyan {
                    let replacingRow = row + 1
                    let replacingOffset = replacingRow * width! + column
                    pixelBuffer?[offset] = (pixelBuffer?[replacingOffset])!
                }
            }
        }
        

        
        //Remove Coastal lines
        for row in 0 ..< Int(height! - 12) {
            for column in 0 ..< Int(width! - 3) {
                let offset = row * width! + column
                if pixelBuffer?[offset] == Magenta {
                    let replacingColumn = column + 1
                    let replacingOffset = row * width! + replacingColumn
                    pixelBuffer?[offset] = (pixelBuffer?[replacingOffset])!
                }
            }
        }
        
        for row in 1 ..< Int(height! - 12) {
            for column in 0 ..< Int(width! - 3) {
                let offset = row * width! + column
                if pixelBuffer?[offset] == Magenta {
                    let replacingRow = row - 1
                    let replacingOffset = replacingRow * width! + column
                    pixelBuffer?[offset] = (pixelBuffer?[replacingOffset])!
                }
            }
        }
        
        for row in 0 ..< Int(height! - 12) {
            for column in 1 ..< Int(width! - 3) {
                let offset = row * width! + column
                if pixelBuffer?[offset] == Magenta {
                    let replacingColumn = column - 1
                    let replacingOffset = row * width! + replacingColumn
                    pixelBuffer?[offset] = (pixelBuffer?[replacingOffset])!
                }
            }
        }
        
        for row in 0 ..< Int(height! - 12) {
            for column in 0 ..< Int(width! - 3) {
                let offset = row * width! + column
                if pixelBuffer?[offset] == Magenta {
                    let replacingRow = row + 1
                    let replacingOffset = replacingRow * width! + column
                    pixelBuffer?[offset] = (pixelBuffer?[replacingOffset])!
                }
            }
        }
        
        //Remove Meridian numbers
        for row in 450 ..< 458 {
            for column in 59 ..< 777 {
                let offset = row * width! + column
                if pixelBuffer?[offset] == Green {
                    let replacingColumn = column + 1
                    let replacingOffset = row * width! + replacingColumn
                    pixelBuffer?[offset] = (pixelBuffer?[replacingOffset])!
                }
            }
        }
        
        for row in 450 ..< 458 {
            for column in 59 ..< 777 {
                let offset = row * width! + column
                if pixelBuffer?[offset] == Green {
                    let replacingRow = row + 1
                    let replacingOffset = replacingRow * width! + column
                    pixelBuffer?[offset] = (pixelBuffer?[replacingOffset])!
                }
            }
        }
        
        //Remove Parallel numbers
        for row in 70 ..< 427 {
            for column in 751 ..< 775 {
                let offset = row * width! + column
                if pixelBuffer?[offset] == Red {
                    let replacingColumn = column + 1
                    let replacingOffset = row * width! + replacingColumn
                    pixelBuffer?[offset] = (pixelBuffer?[replacingOffset])!
                }
            }
        }
        
        for row in 70 ..< 427 {
            for column in 751 ..< 775 {
                let offset = row * width! + column
                if pixelBuffer?[offset] == Red {
                    let replacingRow = row + 1
                    let replacingOffset = replacingRow * width! + column
                    pixelBuffer?[offset] = (pixelBuffer?[replacingOffset])!
                }
            }
        }
        
        //Remove Bottom Horizontal Black stripe
        for row in 488 ..< Int(height!) {
            for column in 0 ..< Int(width!) {
                let offset = row * width! + column
                let replacingRow = row - 1
                let replacingOffset = replacingRow * width! + column
                pixelBuffer?[offset] = (pixelBuffer?[replacingOffset])!
                
            }
        }
        
        //Remove Right Vertical Black stripe
        for row in 0 ..< Int(height!) {
            for column in 833 ..< Int(width!) {
                let i = CGFloat(column - 832)
                let leftOffset = row * width! + 832
                let rightOffset = row * width! + 0
                
                let Red = ((4-i)*CGFloat((pixelBuffer?[leftOffset].redComponent)!) + i*CGFloat((pixelBuffer?[rightOffset].redComponent)!)) / 4.0
                let Green = ((4-i)*CGFloat((pixelBuffer?[leftOffset].greenComponent)!) + i*CGFloat((pixelBuffer?[rightOffset].greenComponent)!)) / 4.0
                let Blue = ((4-i)*CGFloat((pixelBuffer?[leftOffset].blueComponent)!) + i*CGFloat((pixelBuffer?[rightOffset].blueComponent)!)) / 4.0
                
                let Color = RGBA32(color: UIColor(red: Red / 255.0, green: Green / 255.0, blue: Blue / 255.0, alpha: 1))
 
                let offset = row * width! + column
                pixelBuffer?[offset] = Color
                
            }
        }
        

        let outputCGImage = (context?.makeImage()!)!

        return UIImage(cgImage: outputCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
    
    
    @discardableResult func keepIce() -> UIImage {
        let inputCGImage = self.cgImage
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let width            = inputCGImage?.width
        let height           = inputCGImage?.height
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width!
        let bitmapInfo       = RGBA32.bitmapInfo

        let context = CGContext(data: nil, width: width!, height: height!, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)

        context!.draw(inputCGImage!, in: CGRect(x: 0, y: 0, width: width!, height: height!))

        let buffer = context?.data

        let pixelBuffer = buffer?.bindMemory(to: RGBA32.self, capacity: width! * height!)

        let Ice = RGBA32(color: UIColor(red: 240.0/255.0, green: 245.0/255.0, blue: 250.0/255.0, alpha: 1))
        let Snow = RGBA32(color: UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1))
        let Clear = RGBA32(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0))
        
        for row in 0 ..< Int(height!) {
            for column in 0 ..< Int(width!) {
                let offset = row * width! + column
                if pixelBuffer?[offset] == Ice || pixelBuffer?[offset] == Snow {
                } else {
                    pixelBuffer?[offset] = Clear
                }
            }
        }
  

        let outputCGImage = (context?.makeImage()!)!

        return UIImage(cgImage: outputCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
    
    
    @discardableResult func keepClouds() -> UIImage {
        let inputCGImage = self.cgImage
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let width            = inputCGImage?.width
        let height           = inputCGImage?.height
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width!
        let bitmapInfo       = RGBA32.bitmapInfo

        let context = CGContext(data: nil, width: width!, height: height!, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)

        context!.draw(inputCGImage!, in: CGRect(x: 0, y: 0, width: width!, height: height!))

        let buffer = context?.data

        let pixelBuffer = buffer?.bindMemory(to: RGBA32.self, capacity: width! * height!)

        let Clear = RGBA32(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0))
        
        let threshold: Float = 0.8
        
        for row in 0 ..< Int(height!) {
            for column in 0 ..< Int(width!) {
                let offset = row * width! + column
                let red: Float = Float((pixelBuffer?[offset].redComponent)!)/255.0
                let green: Float = Float((pixelBuffer?[offset].greenComponent)!)/255.0
                let blue: Float = Float((pixelBuffer?[offset].blueComponent)!)/255.0
                let luminance = 0.2126*red + 0.7152*green + 0.0722*blue
                //let luminance = (red + green + blue)/3
                if luminance < threshold {
                    pixelBuffer?[offset] = Clear
                } 
            }
        }
  

        let outputCGImage = (context?.makeImage()!)!

        return UIImage(cgImage: outputCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
    
    
    
    func convert(ciImage:CIImage) -> UIImage?
      {
        let context = CIContext(options: [CIContextOption.workingColorSpace: kCFNull!])
        if let cgImage:CGImage = context.createCGImage(ciImage, from: ciImage.extent, format: .RGBA8, colorSpace: CGColorSpace.init(name: CGColorSpace.sRGB)!) {
          let image:UIImage = UIImage.init(cgImage: cgImage)
          return image
        }
        return nil
      }
    
    func invert() -> UIImage{
        let CIimage = CIImage(image: self)!
        let filter = CIFilter(name: "CIColorInvert")
        filter?.setValue(CIimage, forKey: kCIInputImageKey)
        
        return convert(ciImage: (filter?.outputImage)!)!
    }
    
    func withSaturationAdjustment(byVal: CGFloat) -> UIImage {
            guard let cgImage = self.cgImage else { return self }
            guard let filter = CIFilter(name: "CIColorControls") else { return self }
            filter.setValue(CIImage(cgImage: cgImage), forKey: kCIInputImageKey)
            filter.setValue(byVal, forKey: kCIInputSaturationKey)
            guard let result = filter.value(forKey: kCIOutputImageKey) as? CIImage else { return self }
            guard let newCgImage = CIContext(options: nil).createCGImage(result, from: result.extent) else { return self }
            return UIImage(cgImage: newCgImage, scale: UIScreen.main.scale, orientation: imageOrientation)
        }
    
    var noiseReducted: UIImage? {
        guard let cgImage = self.cgImage else { return self }
        guard let noiseReduction = CIFilter(name: "CINoiseReduction") else { return self }
        noiseReduction.setValue(CIImage(cgImage: cgImage), forKey: kCIInputImageKey)
        noiseReduction.setValue(100, forKey: "inputNoiseLevel")
        noiseReduction.setValue(100, forKey: "inputSharpness")
        guard let result = noiseReduction.value(forKey: kCIOutputImageKey) as? CIImage else { return self }
        guard let newCgImage = CIContext(options: nil).createCGImage(result, from: result.extent)
            else { return self }
        return UIImage(cgImage: newCgImage, scale: UIScreen.main.scale, orientation: imageOrientation)
    }

}

struct RGBA32: Equatable {
    private var color: UInt32

    var redComponent: UInt8 {
        return UInt8((self.color >> 24) & 255)
    }

    var greenComponent: UInt8 {
        return UInt8((self.color >> 16) & 255)
    }

    var blueComponent: UInt8 {
        return UInt8((self.color >> 8) & 255)
    }

    var alphaComponent: UInt8 {
        return UInt8((self.color >> 0) & 255)
    }

    init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        self.color = (UInt32(red) << 24) | (UInt32(green) << 16) | (UInt32(blue) << 8) | (UInt32(alpha) << 0)
    }

    init(color: UIColor) {
        let components = color.cgColor.components ?? [0.0, 0.0, 0.0, 1.0]
        let colors = components.map { UInt8($0 * 255) }
        self.init(red: colors[0], green: colors[1], blue: colors[2], alpha: colors[3])
    }

    static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue

    static func ==(lhs: RGBA32, rhs: RGBA32) -> Bool {
        return lhs.color == rhs.color
    }
    

}
