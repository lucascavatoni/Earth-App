//
//  UIImage+replaceColor.swift
//  Earth App
//
//  Created by Lucas Cavatoni on 28/12/2020.
//

import Foundation
import UIKit

extension UIImage {

    //might be total shit
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
                
                let Light = ((4-i)*CGFloat((pixelBuffer?[leftOffset].redComponent)!) + i*CGFloat((pixelBuffer?[rightOffset].redComponent)!)) / 4.0

                
                let Color = RGBA32(color: UIColor(red: Light / 255.0, green: Light / 255.0, blue: Light / 255.0, alpha: 1))
 
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

    //found on https://levelup.gitconnected.com/changing-and-replacing-colors-in-images-using-swift-d338ba79bd04
    /**
     Replaces a color in the image with a different color.
     - Parameter color: color to be replaced.
     - Parameter with: the new color to be used.
     - Parameter tolerance: tolerance, between 0 and 1. 0 won't change any colors,
                            1 will change all of them. 0.5 is default.
     - Returns: image with the replaced color.
     */
    func replaceColor(_ color: UIColor, with: UIColor) -> UIImage {
            guard let imageRef = self.cgImage else {
                return self
            }
            // Get color components from replacement color
            let withColorComponents = with.cgColor.components
            let newRed = UInt8(withColorComponents![0] * 255)
            //let newGreen = UInt8(withColorComponents![1] * 255)
            //let newBlue = UInt8(withColorComponents![2] * 255)
            //let newAlpha = UInt8(withColorComponents![3] * 255)

            let width = imageRef.width
            let height = imageRef.height
            
            let bytesPerPixel = 4
            let bytesPerRow = bytesPerPixel * width
            let bitmapByteCount = bytesPerRow * height
            
            let rawData = UnsafeMutablePointer<UInt8>.allocate(capacity: bitmapByteCount)
            defer {
                rawData.deallocate()
            }
            
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
                return self
            }
            
            guard let context = CGContext(
                data: rawData,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: bytesPerRow,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
                    | CGBitmapInfo.byteOrder32Big.rawValue
            ) else {
                return self
            }
            
            let rc = CGRect(x: 0, y: 0, width: width, height: height)
            // Draw source image on created context.
            context.draw(imageRef, in: rc)
            var byteIndex = 0
            // Iterate through pixels
            while byteIndex < bitmapByteCount {
                // Get color of current pixel
                let red = CGFloat(rawData[byteIndex + 0]) / 255
                //let green = CGFloat(rawData[byteIndex + 1]) / 255
                //let blue = CGFloat(rawData[byteIndex + 2]) / 255
                //let alpha = CGFloat(rawData[byteIndex + 3]) / 255
                let currentColor = UIColor(red: red, green: 0.0, blue: 0.0, alpha: 1.0)
                // Replace pixel if the color is close enough to the color being replaced.
                if compareColor(firstColor: color, secondColor: currentColor) {
                    rawData[byteIndex + 0] = newRed
                    rawData[byteIndex + 1] = newRed
                    rawData[byteIndex + 2] = newRed
                    //rawData[byteIndex + 3] = newAlpha
                }
                byteIndex += 4
            }
            
            // Retrieve image from memory context.
            guard let image = context.makeImage() else {
                return self
            }
            let result = UIImage(cgImage: image)
            return result
        }
    
    /**
         Check if two colors are the same (or close enough given the tolerance).
         - Parameter firstColor: first color used in the comparisson.
         - Parameter secondColor: second color used in the comparisson.
         - Parameter tolerance: how much variation can there be for the function to return true.
                                0 is less sensitive (will always return false),
                                1 is more sensitive (will always return true).
         */
    private func compareColor(
        firstColor: UIColor,
        secondColor: UIColor
    ) -> Bool {
        var r1: CGFloat = 0.0, g1: CGFloat = 0.0, b1: CGFloat = 0.0, a1: CGFloat = 0.0;
        var r2: CGFloat = 0.0, g2: CGFloat = 0.0, b2: CGFloat = 0.0, a2: CGFloat = 0.0;

        firstColor.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        secondColor.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return r1 == r2
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
    
    func modifyContrastAndInvert(value: NSNumber, context: CIContext) -> UIImage{
        let CIimage = CIImage(image: self)!
        let parameters = ["inputContrast": value]
        let outputImage1 = CIimage.applyingFilter("CIColorControls", parameters: parameters)
        let outputImage2 = outputImage1.applyingFilter("CIColorInvert")
        let CGimage = context.createCGImage(outputImage2, from: outputImage2.extent)!
        return UIImage(cgImage: CGimage)
    }
    
    func invert(context: CIContext) -> UIImage{
        let CIimage = CIImage(image: self)!
        let outputImage = CIimage.applyingFilter("CIColorInvert")
        let CGimage = context.createCGImage(outputImage, from: outputImage.extent)!
        return UIImage(cgImage: CGimage)
    }
    
    func makeNormal(context: CIContext) -> UIImage{
        let CIimage = CIImage(image: self)!
        let filter = NormalMapFilter()
        filter.inputImage = CIimage
        let outputImage = filter.outputImage!
        let CGimage = context.createCGImage(outputImage, from: outputImage.extent)!
        return UIImage(cgImage: CGimage)
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
    
    @discardableResult func colorCorrection() -> UIImage {
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

        //Damping parameter, between 0 and 1
        //0 -> No damping
        //1 -> Full damping (binary image)
        let parameter: CGFloat = 0.5
        
        //Maximum brightness output image (0 - 255)
        let maxValue: CGFloat = 255
        
        for row in 0 ..< Int(height!) {
            for column in 0 ..< Int(width!) {
                let offset = row * width! + column
                var Light = CGFloat((pixelBuffer?[offset].redComponent)!)
                let absRow = CGFloat(abs(CGFloat(row)-250.0))
                //Threshold curve, higher latitudes have lower surface temperature so appear
                //brighter in the IR image so we must increase the threshold in high absolute
                //latitudes
                let threshold = CGFloat(0.4*absRow+80)
                if Light > threshold {
                    Light = Light + parameter * (maxValue - Light)
                } else {
                    Light = Light - parameter * Light
                }
                if Light == 255 {
                    Light = 0
                }
                
                let Color = RGBA32(color: UIColor(red: Light / 255.0, green: Light / 255.0, blue: Light / 255.0, alpha: 1))
 
                
                pixelBuffer?[offset] = Color
                
            }
        }
        

        let outputCGImage = (context?.makeImage()!)!

        return UIImage(cgImage: outputCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
    
    @discardableResult func contrastIncrease(minValue: CGFloat,maxValue: CGFloat) -> UIImage {
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
        
        //Difference between the maximum threshold and the minimum threshold
        let deltaValue: CGFloat = maxValue - minValue
        
        for row in 0 ..< Int(height!) {
            for column in 0 ..< Int(width!) {
                let offset = row * width! + column
                var Light = CGFloat((pixelBuffer?[offset].redComponent)!)
                
                Light = 255.0 * ( (Light - minValue)/deltaValue )
                
                if Light > 255.0 {
                    Light = 255.0
                }
                    
                if Light < 0.0 {
                    Light = 0.0
                }
                    
                
                let Color = RGBA32(color: UIColor(red: Light / 255.0, green: Light / 255.0, blue: Light / 255.0, alpha: 1))

                pixelBuffer?[offset] = Color
                
            }
        }
        

        let outputCGImage = (context?.makeImage()!)!

        return UIImage(cgImage: outputCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
    
    @discardableResult func contrastIncreaseEumetsat(minValue: CGFloat,maxValue: CGFloat) -> UIImage {
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
        
        //Difference between the maximum threshold and the minimum threshold
        let deltaValue: CGFloat = maxValue - minValue
        
        for row in 0 ..< Int(height!) {
            for column in 0 ..< Int(width!) {
                let offset = row * width! + column
                var Light = CGFloat((pixelBuffer?[offset].redComponent)!)
                
                if Light == 255.0 {
                    Light = 100
                }
                
                Light = 255.0 * ( (Light - minValue)/deltaValue )
                
                if Light > 255.0 {
                    Light = 255.0
                }
                    
                if Light < 0.0 {
                    Light = 0.0
                }
                    
                
                let Color = RGBA32(color: UIColor(red: Light / 255.0, green: Light / 255.0, blue: Light / 255.0, alpha: 1))

                pixelBuffer?[offset] = Color
                
            }
        }
        

        let outputCGImage = (context?.makeImage()!)!

        return UIImage(cgImage: outputCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
    
    @discardableResult func gaussianBlur() -> UIImage {
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
        
        for row in 1 ..< Int(height!-1) {
            for column in 1 ..< Int(width!-1) {
                
                let offset00 = (row-1) * width! + column-1
                let offset01 = (row-1) * width! + column
                let offset02 = (row-1) * width! + column+1
                
                let offset10 = row * width! + column-1
                let offset11 = row * width! + column
                let offset12 = row * width! + column+1
                
                let offset20 = (row+1) * width! + column-1
                let offset21 = (row+1) * width! + column
                let offset22 = (row+1) * width! + column+1
                
                
                let light00 = CGFloat((pixelBuffer?[offset00].redComponent)!)
                let light01 = CGFloat((pixelBuffer?[offset01].redComponent)!)
                let light02 = CGFloat((pixelBuffer?[offset02].redComponent)!)
                
                let light10 = CGFloat((pixelBuffer?[offset10].redComponent)!)
                let light11 = CGFloat((pixelBuffer?[offset11].redComponent)!)
                let light12 = CGFloat((pixelBuffer?[offset12].redComponent)!)
                
                let light20 = CGFloat((pixelBuffer?[offset20].redComponent)!)
                let light21 = CGFloat((pixelBuffer?[offset21].redComponent)!)
                let light22 = CGFloat((pixelBuffer?[offset22].redComponent)!)

                let light = (1*(light00 + light02 + light20 + light22) + 2*(light01 + light10 + light12 + light21) + 4*light11)/16
                
                let Color = RGBA32(color: UIColor(red: light / 255.0, green: light / 255.0, blue: light / 255.0, alpha: 1))

                pixelBuffer?[offset11] = Color
                
            }
        }
        

        let outputCGImage = (context?.makeImage()!)!

        return UIImage(cgImage: outputCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
    
    @discardableResult func terminator(delta: Float,longitude: Float) -> UIImage {
        
        let height = 512
        let width = 1024
        
        //To redo with an empty image...
        let inputCGImage = self.cgImage
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width
        let bitmapInfo       = RGBA32.bitmapInfo

        let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)

        context!.draw(inputCGImage!, in: CGRect(x: 0, y: 0, width: width, height: height))

        let buffer = context?.data

        let pixelBuffer = buffer?.bindMemory(to: RGBA32.self, capacity: width * height)
 
        
        
        
        let toRadians = Double.pi/180.0
        let toDegrees = 180.0/Double.pi
        
        //Max angle from center lat,lon = 0
        let thresholdMax = 90.0
        //Min angle from center lat,lon = 0
        let thresholdMin = 72.0

        //intensity of the color mask
        let value = 0.5
        
        //Ax+B
        let A = (1.0 - value) / (thresholdMax - thresholdMin)
        
        //B terminator
        let B = (thresholdMax - thresholdMin*value) / (thresholdMax - thresholdMin)
        
        let cosThresMax = cos(thresholdMax*toRadians)
        let cosThresMin = cos(thresholdMin*toRadians)
        
        for row in 0 ..< Int(height) {
            for column in 0 ..< Int(width) {
                let offset = row * width + column
                
                let lat = (Double(height)/2.0-Double(row))/Double(height)*180.0
                let lon = abs(Double(column) - Double(width)/2+Double(longitude)/360.0*Double(width))/Double(width)*360.0
                var cosAngle = cos(lat*toRadians)*cos(lon*toRadians)
                //to do why 0.7
                let angle = acos(cosAngle)*toDegrees - Double(delta-0.7)*sin(lat*toRadians)
                cosAngle = cos(angle*toRadians)
                
                var light = 1.0
                var light_r = 1.0
                var light_g = 1.0
                var light_b = 1.0
                        
                if cosAngle > cosThresMin || cosAngle < cosThresMax {
                    light = 1.0 * 255.0
                } else {
                    light = (-A*angle+B)*255.0
                }
                   
                if light < 255.0 {
                    light_r = 1.0
                    light_g = light/255.0
                    light_b = light*light/255.0/255.0
                }
                
            
                let Color = RGBA32(color: UIColor(red: light_r, green: light_g, blue: light_b, alpha: 1))

                pixelBuffer?[offset] = Color
                
            }
        }
        

        let outputCGImage = (context?.makeImage()!)!

        return UIImage(cgImage: outputCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
    
    @discardableResult func resizeImage(targetWidth: CGFloat, targetHeight: CGFloat) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetWidth  / size.width
        let heightRatio = targetHeight / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    convenience init?(pixels: [PixelData], width: Int, height: Int) {
            guard width > 0 && height > 0, pixels.count == width * height else { return nil }
            var data = pixels
            guard let providerRef = CGDataProvider(data: Data(bytes: &data, count: data.count * MemoryLayout<PixelData>.size) as CFData)
                else { return nil }
            guard let cgim = CGImage(
                width: width,
                height: height,
                bitsPerComponent: 8,
                bitsPerPixel: 32,
                bytesPerRow: width * MemoryLayout<PixelData>.size,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue),
                provider: providerRef,
                decode: nil,
                shouldInterpolate: true,
                intent: .defaultIntent)
            else { return nil }
            self.init(cgImage: cgim)
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

