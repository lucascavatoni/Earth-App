//
//  EarthNode.swift
//  Earth App
//
//  Created by Lucas Cavatoni on 19/11/2020.
//

import SceneKit

class SurfaceNode: SCNNode {
    
    init(key: String) {
        super.init()
        
        //Creating sphere
        //Sphere of radius 1
        let sphere = SCNSphere(radius: 1)
        //Number of segments
        sphere.segmentCount = 48
        //Geometry is this sphere
        self.geometry = sphere

        
        switch key {
        //Nasa Blue Marble Next Generation Monthly
        case "bluemarble":
            //Calendar
            var calendar = Calendar.current
            calendar.timeZone = TimeZone(identifier: "UTC")!
            //month
            let m:Int = Int(calendar.component(.month, from: Date()))
            switch m {
            case 1:
                //January
                self.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "world.topo.200401.3x21600x10800")
                break
            case 2:
                //February
                self.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "world.topo.200402.3x21600x10800")
                break
            case 3:
                //March
                self.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "world.topo.200403.3x21600x10800")
                break
            case 4:
                //April
                self.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "world.topo.200404.3x21600x10800")
                break
            case 5:
                //May
                self.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "world.topo.200405.3x21600x10800")
                break
            case 6:
                //June
                self.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "world.topo.200406.3x21600x10800")
                break
            case 7:
                //July
                self.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "world.topo.200407.3x21600x10800")
                break
            case 8:
                //August
                self.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "world.topo.200408.3x21600x10800")
                break
            case 9:
                //September
                self.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "world.topo.200409.3x21600x10800")
                break
            case 10:
                //October
                self.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "world.topo.200410.3x21600x10800")
                break
            case 11:
                //November
                self.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "world.topo.200411.3x21600x10800")
                break
            case 12:
                //December
                self.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "world.topo.200412.3x21600x10800")
                break
            default:
                //Default case: June
                self.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "world.topo.200406.3x21600x10800")
                break
            }
            
        break
        //Earth Visible Image
        case "true-color":
            
            //First Offline images
            
            //Calendar
            var calendar = Calendar.current
            calendar.timeZone = TimeZone(identifier: "UTC")!
            //month
            let m:Int = Int(calendar.component(.month, from: Date()))
            switch m {
            case 1:
                //January
                self.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "world.topo.200401.3x21600x10800")
                break
            case 2:
                //February
                self.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "world.topo.200402.3x21600x10800")
                break
            case 3:
                //March
                self.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "world.topo.200403.3x21600x10800")
                break
            case 4:
                //April
                self.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "world.topo.200404.3x21600x10800")
                break
            case 5:
                //May
                self.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "world.topo.200405.3x21600x10800")
                break
            case 6:
                //June
                self.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "world.topo.200406.3x21600x10800")
                break
            case 7:
                //July
                self.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "world.topo.200407.3x21600x10800")
                break
            case 8:
                //August
                self.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "world.topo.200408.3x21600x10800")
                break
            case 9:
                //September
                self.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "world.topo.200409.3x21600x10800")
                break
            case 10:
                //October
                self.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "world.topo.200410.3x21600x10800")
                break
            case 11:
                //November
                self.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "world.topo.200411.3x21600x10800")
                break
            case 12:
                //December
                self.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "world.topo.200412.3x21600x10800")
                break
            default:
                //Default case: June
                self.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "world.topo.200406.3x21600x10800")
                break
            }
            
            
            //Nasa true color text file URL
            if let textUrl = URL(string: "ftp://ftp.sos.noaa.gov/sosrt/rt/noaa/true_color/labels/labels.txt") {
                do{
                    //read all the lines of the text file
                    let contents = try String(contentsOf: textUrl)
                    //split the lines into a list, separated by newlines
                    let lines = contents.components(separatedBy: .newlines)
                    //Take last full line, which is one before the last line (because the very last line is blank)
                    let line = lines[lines.count-2]
                    //Split this line into date and time separated by space
                    let lineElements = line.components(separatedBy: .whitespaces)
                    //Month element
                    var month = lineElements[0]
                    //Day element
                    var day = lineElements[1]
                    //Year element
                    let year = lineElements[2]
                    //Getting rid of the coma at the end of the day (Apr 12, 2021)
                    day = day[0 ..< 2]
                    //Converting month from text format to number format
                    month = monthConvertStrToNumber(Month: month)
                    

                
                    let url = URL(string: "ftp://ftp.sos.noaa.gov/sosrt/rt/noaa/true_color/4096/TRUE.daily."+year+month+day+".color.png")
                    
                    let task = URLSession.shared.dataTask(with: url!) { data, response, error in
                        guard let data = data, error == nil else { return }

                        DispatchQueue.main.async() { [self] in    // execute on main thread
                            
                            //Because original image has an underlay of blue marble old generation
                            //So in color, so we must turn the image in black and white
                            let Image = UIImage(data: data)!

                            self.geometry?.firstMaterial?.diffuse.contents = Image
                            
                            
                        }
                    }
                    
                    task.resume()
                    
            } catch{
                    //contents could not be loaded
                }
            }
        break
        default:
            //Default case: June
            self.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "world.topo.200406.3x21600x10800")
            break
        }
        
        
        //Water
        self.geometry?.firstMaterial?.specular.contents = UIImage(named: "specular")
        
        //Night
        let emissionTexture = UIImage(named: "lights2016")!
        
        //emission
        let emission = SCNMaterialProperty(contents: emissionTexture)
        
        //setting the value
        self.geometry?.firstMaterial?.setValue(emission, forKey: "emissionTexture")
        
        //Shader to hide night lights at day
        let shaderModifier =
        """
        uniform sampler2D emissionTexture;

        vec3 light = _lightingContribution.diffuse;
        float lum = max(0.0, 1 - (0.2126*light.r + 0.7152*light.g + 0.0722*light.b));
        vec4 emission = texture2D(emissionTexture, _surface.diffuseTexcoord) * lum;
                float t = 0.1; // no emission will show above this threshold
                _output.color = vec4(
                    light.r > t ? _output.color.r : (light.r/t * _output.color.r + (1-light.r/t) * (_output.color.r + emission.r)),
                    light.g > t ? _output.color.g : (light.g/t * _output.color.g + (1-light.g/t) * (_output.color.g + emission.g)),
                    light.b > t ? _output.color.b : (light.b/t * _output.color.b + (1-light.b/t) * (_output.color.b + emission.b)),1);
        """
        
        self.geometry?.firstMaterial?.shaderModifiers = [.fragment: shaderModifier]
        
        //Water shininess, higher value = smaller reflection point
        self.geometry?.firstMaterial?.shininess = 0.5
        
        //Water specular intensity, between 0 and 1
        self.geometry?.firstMaterial?.specular.intensity = 0.5
        
        self.castsShadow = false
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func monthConvertStrToNumber(Month: String) -> String {
        switch Month {
        case "Jan":
            return "01"
        case "Feb":
            return "02"
        case "Mar":
            return "03"
        case "Apr":
            return "04"
        case "May":
            return "05"
        case "Jun":
            return "06"
        case "Jul":
            return "07"
        case "Aug":
            return "08"
        case "Sep":
            return "09"
        case "Oct":
            return "10"
        case "Nov":
            return "11"
        case "Dec":
            return "12"
        default:
            return "01"
        }
    }
    
}
