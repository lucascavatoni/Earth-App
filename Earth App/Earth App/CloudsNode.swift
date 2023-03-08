//
//  CloudsNode.swift
//  Earth App
//
//  Created by Lucas Cavatoni on 20/11/2020.
//

import SceneKit
import SpriteKit
import ModelIO

let myContext = CIContext(options: [CIContextOption.workingColorSpace: kCFNull!])

class CloudsNode: SCNNode {
    
    //init(key: String, lon: Float){
    override init() {
        super.init()
        
        self.categoryBitMask = LightType.earth
        
        //Creating sphere
        //Sphere of radius +0.1% of earth radius (~6 km)
        let sphere = SCNSphere(radius: 1.001)
        //Number of segments
        sphere.segmentCount = segments
        //Geometry is this sphere
        self.geometry = sphere
        
        //Probably dead URL of GrayScale clouds
        //let url = URL(string: "https://raw.githubusercontent.com/apollo-ng/cloudmap/master/global.jpg")
        
        //Nasa clouds+radar
        //let url = URL(string: "ftp://ftp.sos.noaa.gov/sosrt/rt/noaa/clouds_precip/4096/combined_image_20210204_0100.jpg")
        
        //Nasa radar png
        //let url = URL(string:  "ftp://public.sos.noaa.gov/rt/precip/3600/imergert_composite.2021-02-04T04_30_00Z.png")
        
        //NOAA GMGSI GrayScale
        //let url = URL(string: "https://www.ospo.noaa.gov/data/imagery/gmgsi/gmgsi-"+key+".gif")
        
        //let url = URL(string: "https://raw.githubusercontent.com/apollo-ng/cloudmap/master/global.jpg")
        
        //let url = URL(string: "https://secure.xericdesign.com/mosaic/composite.jpg")
        
        self.geometry?.firstMaterial?.transparent.mipFilter = SCNFilterMode.linear
        self.geometry?.firstMaterial?.transparent.maxAnisotropy = anisotropy
                
        //self.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)

        self.geometry?.firstMaterial?.normal.intensity = 0.1
        self.geometry?.firstMaterial?.normal.mipFilter = SCNFilterMode.linear
        self.geometry?.firstMaterial?.normal.maxAnisotropy = anisotropy

        self.geometry?.firstMaterial?.shaderModifiers = [.fragment: terminatorFragmentShader]
        
        self.geometry?.firstMaterial?.transparencyMode = .rgbZero // 0.0 is opaque
        
        self.name = "clouds"
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }


}


//let cloudsMDL = MDLTexture(data: data, topLeftOrigin: true, name: "cloudsMDL", dimensions: vector_int2(2048, 2048), rowStride: 0, channelCount: 1, channelEncoding: .uInt8, isCube: false)
//let cloudsMDL = MDLTexture(

//let cloudsCGum = cloudsMDL.imageFromTexture()
//let cloudsCG = cloudsCGum?.takeUnretainedValue()

//let cloudsNormal = MDLNormalMapTexture(byGeneratingNormalMapWith: cloudsMDL, name: "cloudsNormal", smoothness: 0.0, contrast: 1.0)

//let cloudMDL = MDLTexture(named: "cloudnormal")!


//switch key {
//
//case "eumetsat":
//
////            let url = URL(string: "https://view.eumetsat.int/geoserver/ows?service=WMS&request=GetMap&version=1.3.0&layers=mumi:worldcloudmap_ir108&styles=&format=image/png&crs=EPSG:4326&bbox=-90,-180,90,180&width=4096&height=2048")! /// max allowed size 6688x3344
////
////            let task = URLSession.shared.dataTask(with: url) { data, response, error in
////                guard let data = data, error == nil else { return }
////                let cloudsRaw = UIImage(data: data)!.replaceColor(UIColor.white, with: UIColor.darkGray)
////                let cloudsFinal = cloudsRaw.increaseContrastAndInvert(value: 2, context: myContext) /// 1.13  2.2 see line.
////
////                let cloudsNormal = cloudsRaw.makeNormal(context: myContext)
////
////                DispatchQueue.main.async { /// execute on main thread
////                    self.geometry?.firstMaterial?.transparent.contents = cloudsFinal
////                    self.geometry?.firstMaterial?.normal.contents = cloudsNormal
////                }
////            }
////            task.resume()
//
//    //self.geometry?.firstMaterial?.transparent.textureComponents = .red
//
//
//    break
//
////NOAA GMGSI GrayScale LongWave Infrared
//case "noaalw":
//    let url = URL(string: "https://www.ospo.noaa.gov/data/imagery/gmgsi/gmgsi-lw.gif")
//    //let url = URL(string: "https://secure.xericdesign.com/mosaic/composite.jpg")
//    let task = URLSession.shared.dataTask(with: url!) { data, response, error in
//        guard let data = data, error == nil else { return }
//
//        DispatchQueue.main.async() { [self] in    // execute on main thread
//
//            //Correct contrast histogram to take into account see color and max cloud color
//            let diffuseTexture = UIImage(data: data)?.handleNOAA()
//            //let diffuseTexture = UIImage(data: data)
//
//            let diffuse = SCNMaterialProperty(contents: diffuseTexture!)
//
//            self.geometry?.firstMaterial?.setValue(diffuse, forKey: "diffuseTexture")
//
//        }
//    }
//
//    task.resume()
//    break
//
////NOAA GMGSI GrayScale Visible
//case "vis":
//    let url = URL(string: "https://www.ospo.noaa.gov/data/imagery/gmgsi/gmgsi-vis.gif")
//    let task = URLSession.shared.dataTask(with: url!) { data, response, error in
//        guard let data = data, error == nil else { return }
//
//        DispatchQueue.main.async() { [self] in    // execute on main thread
//
//            //Because original image has an underlay of blue marble old generation
//            //So in color, so we must turn the image in black and white
//            let cloudImage = UIImage(data: data)?.handleNOAA().contrastIncrease(minValue: 60, maxValue: 240)
//
//            //let cloudImageInverted = cloudImage?.invert()
//
//            //self.geometry?.firstMaterial?.transparent.contents = cloudImageInverted
//
//            self.geometry?.firstMaterial?.diffuse.contents = cloudImage
//
//            self.geometry?.firstMaterial?.transparencyMode = .rgbZero
//
//            self.geometry?.firstMaterial?.transparency = 1.0
//
//            let time = Time()
//
//            let delta = time.getDelta()*180/Float.pi
//            let lambda = time.getLongitude()
//
//            let multiply = cloudImage?.terminator(delta: delta,longitude: lambda)
//
//            self.geometry?.firstMaterial?.multiply.contents = multiply
//
//        }
//    }
//
//    task.resume()
//    break
//
////Nasa Clouds
//case "nasa":
//    //Nasa clouds text file URL
//    if let textUrl = URL(string: "ftp://ftp.sos.noaa.gov/sosrt/rt/noaa/sat/linear/rawlabel.txt") {
//        do{
//            //read all the lines of the text file
//            let contents = try String(contentsOf: textUrl)
//            //split the lines into a list, separated by newlines
//            let lines = contents.components(separatedBy: .newlines)
//            //Take last full line, which is one before the last line (because the very last line is blank)
//            let line = lines[lines.count-2]
//            //Split this line into date and time separated by space
//            let lineElements = line.components(separatedBy: .whitespaces)
//            //Date element
//            let DateString = lineElements[2]
//            //Time element
//            let TimeString = lineElements[3]
//            //Split the date into day, month and year
//            let date = DateString.components(separatedBy: "/")
//            //Split the time into hours and minutes
//            let time = TimeString.components(separatedBy: ":")
//
//            let url = URL(string: "ftp://ftp.sos.noaa.gov/sosrt/rt/noaa/sat/linear/raw/linear_rgb_cyl_"+date[2]+date[0]+date[1]+"_"+time[0]+time[1]+".jpg")
//
//            let task = URLSession.shared.dataTask(with: url!) { data, response, error in
//                guard let data = data, error == nil else { return }
//
//                DispatchQueue.main.async() { [self] in    // execute on main thread
//
//                    //Because original image has an underlay of blue marble old generation
//                    //So in color, so we must turn the image in black and white
//                    let cloudImage = UIImage(data: data)!
//
//                    //let cloudImageInverted = cloudImage.invert()
//                    //self.geometry?.firstMaterial?.transparent.contents = cloudImageInverted
//
//                    self.geometry?.firstMaterial?.diffuse.contents = cloudImage
//
//                    self.geometry?.firstMaterial?.transparencyMode = .rgbZero
//
//                    self.geometry?.firstMaterial?.transparency = 1.0
//
//                }
//            }
//
//            task.resume()
//
//    } catch{
//            //contents could not be loaded
//        }
//    }
//    break
//
////Nasa Precipitation+Clouds
//case "nasaprecip":
//    //Nasa clouds text file URL
//    if let textUrl = URL(string: "ftp://ftp.sos.noaa.gov/sosrt/rt/noaa/clouds_precip/labels/labels.txt") {
//        do{
//            //read all the lines of the text file
//            let contents = try String(contentsOf: textUrl)
//            //split the lines into a list, separated by newlines
//            let lines = contents.components(separatedBy: .newlines)
//            //Take last full line, which is one before the last line (because the very last line is blank)
//            let line = lines[lines.count-2]
//            //Split this line into date and time separated by space
//            let lineElements = line.components(separatedBy: .whitespaces)
//            //Date element
//            let DateString = lineElements[0]
//            //Time element
//            let TimeString = lineElements[1]
//            //Split the date into day, month and year
//            let date = DateString.components(separatedBy: "/")
//            //Split the time into hours and minutes
//            let time = TimeString.components(separatedBy: ":")
//
//            let url = URL(string: "ftp://ftp.sos.noaa.gov/sosrt/rt/noaa/clouds_precip/4096/combined_image_"+date[2]+date[0]+date[1]+"_"+time[0]+time[1]+".jpg")
//
//            let task = URLSession.shared.dataTask(with: url!) { data, response, error in
//                guard let data = data, error == nil else { return }
//
//                DispatchQueue.main.async() { [self] in    // execute on main thread
//
//                    //Because original image has an underlay of blue marble old generation
//                    //So in color, so we must turn the image in black and white
//                    let cloudImage = UIImage(data: data)!
//
//                    //let cloudImageInverted = cloudImage.invert()
//                    //self.geometry?.firstMaterial?.transparent.contents = cloudImageInverted
//
//                    self.geometry?.firstMaterial?.diffuse.contents = cloudImage
//
//                    self.geometry?.firstMaterial?.transparencyMode = .rgbZero
//
//                    self.geometry?.firstMaterial?.transparency = 1.0
//
//                }
//            }
//
//            task.resume()
//
//    } catch{
//            //contents could not be loaded
//        }
//    }
//break
//case "dead":
//    let url = URL(string: "https://raw.githubusercontent.com/apollo-ng/cloudmap/master/global.jpg")
//    let task = URLSession.shared.dataTask(with: url!) { data, response, error in
//        guard let data = data, error == nil else { return }
//
//        DispatchQueue.main.async() { [self] in    // execute on main thread
//
//            let cloudImage = UIImage(data: data)
//
//            //let cloudImageInverted = cloudImage?.invert()
//
//            //self.geometry?.firstMaterial?.transparent.contents = cloudImageInverted
//
//            self.geometry?.firstMaterial?.diffuse.contents = cloudImage
//
//            self.geometry?.firstMaterial?.transparencyMode = .rgbZero
//
//            self.geometry?.firstMaterial?.transparency = 1.0
//
//            let time = Time()
//
//            let delta = time.getDelta()*180/Float.pi
//            let lambda = time.getLongitude()
//
//            let multiply = cloudImage?.terminator(delta: delta,longitude: lambda)
//
//            self.geometry?.firstMaterial?.multiply.contents = multiply
//
//        }
//    }
//
//    task.resume()
//break
//default:
//break
//
//}
