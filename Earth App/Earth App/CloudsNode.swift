//
//  CloudsNode.swift
//  Earth App
//
//  Created by Lucas Cavatoni on 20/11/2020.
//

import SceneKit

class CloudsNode: SCNNode {
    
    init(key: String){
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
        
        
        switch key {
        
        //NOAA GMGSI GrayScale LongWave Infrared
        case "lw":
            let url = URL(string: "https://www.ospo.noaa.gov/data/imagery/gmgsi/gmgsi-lw.gif")
            let task = URLSession.shared.dataTask(with: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async() { [self] in    // execute on main thread
                    
                    //Because original image has an underlay of blue marble old generation
                    //So in color, so we must turn the image in black and white
                    let cloudImage = UIImage(data: data)?.handleNOAA()

                    let cloudImageInverted = cloudImage?.invert()
                    self.geometry?.firstMaterial?.transparent.contents = cloudImageInverted

                    self.geometry?.firstMaterial?.diffuse.contents = cloudImage
   
                    self.geometry?.firstMaterial?.transparencyMode = .rgbZero
                    
                    self.geometry?.firstMaterial?.transparency = 1.0
                    
                }
            }
            
            task.resume()
            break
            
        //NOAA GMGSI GrayScale Visible
        case "vis":
            let url = URL(string: "https://www.ospo.noaa.gov/data/imagery/gmgsi/gmgsi-vis.gif")
            let task = URLSession.shared.dataTask(with: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async() { [self] in    // execute on main thread
                    
                    //Because original image has an underlay of blue marble old generation
                    //So in color, so we must turn the image in black and white
                    let cloudImage = UIImage(data: data)?.handleNOAA()

                    let cloudImageInverted = cloudImage?.invert()
                    
                    self.geometry?.firstMaterial?.transparent.contents = cloudImageInverted

                    self.geometry?.firstMaterial?.diffuse.contents = cloudImage
   
                    self.geometry?.firstMaterial?.transparencyMode = .rgbZero
                    
                    self.geometry?.firstMaterial?.transparency = 1.0

                }
            }
            
            task.resume()
            break
        
        //Nasa Clouds
        case "nasa":
            //Nasa clouds text file URL
            if let textUrl = URL(string: "ftp://ftp.sos.noaa.gov/sosrt/rt/noaa/sat/linear/rawlabel.txt") {
                do{
                    //read all the lines of the text file
                    let contents = try String(contentsOf: textUrl)
                    //split the lines into a list, separated by newlines
                    let lines = contents.components(separatedBy: .newlines)
                    //Take last full line, which is one before the last line (because the very last line is blank)
                    let line = lines[lines.count-2]
                    //Split this line into date and time separated by space
                    let lineElements = line.components(separatedBy: .whitespaces)
                    //Date element
                    let DateString = lineElements[2]
                    //Time element
                    let TimeString = lineElements[3]
                    //Split the date into day, month and year
                    let date = DateString.components(separatedBy: "/")
                    //Split the time into hours and minutes
                    let time = TimeString.components(separatedBy: ":")
                    
                    let url = URL(string: "ftp://ftp.sos.noaa.gov/sosrt/rt/noaa/sat/linear/raw/linear_rgb_cyl_"+date[2]+date[0]+date[1]+"_"+time[0]+time[1]+".jpg")
                    
                    let task = URLSession.shared.dataTask(with: url!) { data, response, error in
                        guard let data = data, error == nil else { return }

                        DispatchQueue.main.async() { [self] in    // execute on main thread
                            
                            //Because original image has an underlay of blue marble old generation
                            //So in color, so we must turn the image in black and white
                            let cloudImage = UIImage(data: data)!

                            let cloudImageInverted = cloudImage.invert()
                            self.geometry?.firstMaterial?.transparent.contents = cloudImageInverted

                            self.geometry?.firstMaterial?.diffuse.contents = cloudImage
           
                            self.geometry?.firstMaterial?.transparencyMode = .rgbZero
                            
                            self.geometry?.firstMaterial?.transparency = 1.0
                            
                        }
                    }
                    
                    task.resume()
                    
            } catch{
                    //contents could not be loaded
                }
            }
            break
            
        //Nasa Precipitation+Clouds
        case "nasaprecip":
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

                        DispatchQueue.main.async() { [self] in    // execute on main thread
                            
                            //Because original image has an underlay of blue marble old generation
                            //So in color, so we must turn the image in black and white
                            let cloudImage = UIImage(data: data)!

                            let cloudImageInverted = cloudImage.invert()
                            self.geometry?.firstMaterial?.transparent.contents = cloudImageInverted

                            self.geometry?.firstMaterial?.diffuse.contents = cloudImage
           
                            self.geometry?.firstMaterial?.transparencyMode = .rgbZero
                            
                            self.geometry?.firstMaterial?.transparency = 1.0
                            
                        }
                    }
                    
                    task.resume()
                    
            } catch{
                    //contents could not be loaded
                }
            }
        break
        default:
        break
        
        }
        
        self.castsShadow = false

    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }



}
