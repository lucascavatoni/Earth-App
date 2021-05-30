//
//  PrecipNode.swift
//  Earth App
//
//  Created by Lucas Cavatoni on 04/02/2021.
//


import SceneKit

class PrecipNode: SCNNode {
    
    override init(){
        super.init()
        
        
        //Creating sphere
        //Sphere of radius +0.1% of earth radius (~7km)
        let sphere = SCNSphere(radius: 1.001)
        //Number of segments
        sphere.segmentCount = 48
        //Geometry is this sphere
        self.geometry = sphere
        
        self.geometry?.firstMaterial?.transparency = 0.0
        
        
        //Probably dead URL of GrayScale clouds
        //let url = URL(string: "https://raw.githubusercontent.com/apollo-ng/cloudmap/master/global.jpg")
        
        //Nasa clouds+radar
        //let url = URL(string: "ftp://ftp.sos.noaa.gov/sosrt/rt/noaa/clouds_precip/4096/combined_image_20210204_0100.jpg")
        
        //Nasa radar png
        //let url = URL(string:  "ftp://public.sos.noaa.gov/rt/precip/3600/imergert_composite.2021-02-04T04_30_00Z.png")
        
        //NOAA GMGSI GrayScale
        //let url = URL(string: "https://www.ospo.noaa.gov/data/imagery/gmgsi/gmgsi-"+key+".gif")
        
        
        
        
        //Nasa Clouds
        
        //Nasa clouds text file URL
        if let textUrl = URL(string: "ftp://ftp.sos.noaa.gov/sosrt/rt/noaa/clouds_precip/labels/labels.txt") {
            do{
                //read all the lines of the text file
                let contents = try String(contentsOf: textUrl)
                //split the lines into a list, separated by newlines
                let lines = contents.components(separatedBy: .newlines)
                //Take last full line, which is one before the last line (because the very last line is blank)
                let line = lines[lines.count-2]
                //Split this line into date and time separated by space
                print(line)
                let lineElements = line.components(separatedBy: .whitespaces)
                //Date element
                let DateString = lineElements[0]
                //Time element
                let TimeString = lineElements[1]
                //Split the date into day, month and year
                let date = DateString.components(separatedBy: "/")
                //Split the time into hours and minutes
                let time = TimeString.components(separatedBy: ":")
                
                let url = URL(string: "ftp://ftp.sos.noaa.gov/sosrt/rt/noaa/clouds_precip/4096/combined_image_"+date[2]+date[0]+date[1]+"_"+time[0]+time[1]+".jpg")
                
                let task = URLSession.shared.dataTask(with: url!) { data, response, error in
                    guard let data = data, error == nil else { return }

                    DispatchQueue.main.async() {    // execute on main thread
                        let cloudImage = UIImage(data: data)!

                        //Original image has parallel lines, meridian lines, coastlines and other junk
                        //So the image must be cleaned by guessing the pixels behind the overlay
                        
                        //cloudImage = cloudImage.handleNOAA()
                        
                        //cloudImage = cloudImage.keepClouds()
                        
                        //let cloudImage = self.Blur(image: cloudImageTemp)

                        //Image for transparency, Black is opaque, White is transparent, so cloud image must be inverted
                        //let cloudImageInverted = cloudImage.invert()
                        //self.geometry?.firstMaterial?.transparent.contents = cloudImageInverted

                        self.geometry?.firstMaterial?.diffuse.contents = cloudImage
                        
                        self.geometry?.firstMaterial?.transparency = 1.0
                        //Telling scenekit to take the image RGB colors as transparency mask
                        //self.geometry?.firstMaterial?.transparencyMode = .rgbZero
                    }
                }
                
                task.resume()
                
                
                
                
                
                
                
                
            } catch{
                //contents could not be loaded
            }
        }
        
        


        
        

        
        self.castsShadow = false

    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

    
    func Blur(image: UIImage) -> UIImage{
        let CIimage = CIImage(image: image)!
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(CIimage, forKey: kCIInputImageKey)
        return convert(ciImage: (filter?.outputImage)!)!
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
    
    
    func convertToGrayScale(image: UIImage) -> UIImage {

        // Create image rectangle with current image width/height
        let imageRect:CGRect = CGRect(x:0, y:0, width:image.size.width, height: image.size.height)

        // Grayscale color space
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let width = image.size.width
        let height = image.size.height

        // Create bitmap content with current image size and grayscale colorspace
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)

        // Draw image into current context, with specified rectangle
        // using previously defined context (with grayscale colorspace)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        context?.draw(image.cgImage!, in: imageRect)
        let imageRef = context!.makeImage()

        // Create a new UIImage object
        let newImage = UIImage(cgImage: imageRef!)

        return newImage
    }
    
    func convertToRGB(image: UIImage) -> UIImage {

        // Create image rectangle with current image width/height
        let imageRect:CGRect = CGRect(x:0, y:0, width:image.size.width, height: image.size.height)

        // RGB color space
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let width = image.size.width
        let height = image.size.height

        // Create bitmap content with current image size and RGB colorspace
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)

        // Draw image into current context, with specified rectangle
        // using previously defined context (with RGB colorspace)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 24, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        context?.draw(image.cgImage!, in: imageRect)
        let imageRef = context!.makeImage()

        // Create a new UIImage object
        let newImage = UIImage(cgImage: imageRef!)

        return newImage
    }
    
    func cropImage(imageToCrop:UIImage, toRect rect:CGRect) -> UIImage{
        
        let imageRef:CGImage = imageToCrop.cgImage!.cropping(to: rect)!
        let cropped:UIImage = UIImage(cgImage:imageRef)
        return cropped
    }
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    
    
    
        
}

