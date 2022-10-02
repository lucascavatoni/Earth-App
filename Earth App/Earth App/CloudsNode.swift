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
        //Sphere of radius +0.1% of earth radius (~6 km)
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
        case "noaalw":
            let url = URL(string: "https://www.ospo.noaa.gov/data/imagery/gmgsi/gmgsi-lw.gif")
            //let url = URL(string: "https://secure.xericdesign.com/mosaic/composite.jpg")
            let task = URLSession.shared.dataTask(with: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async() { [self] in    // execute on main thread
                    
                    //Correct contrast histogram to take into account see color and max cloud color
                    let diffuseTexture = UIImage(data: data)?.handleNOAA()
                    //let diffuseTexture = UIImage(data: data)
                    
                    let diffuse = SCNMaterialProperty(contents: diffuseTexture!)
                    
                    self.geometry?.firstMaterial?.setValue(diffuse, forKey: "diffuseTexture")
                    
                    let ShaderModifier =
                    
                    """

                    #pragma transparent
                    
                    uniform sampler2D diffuseTexture;

                    vec3 light = _lightingContribution.diffuse;
                    //float lum = 0.2126*light.r + 0.7152*light.g + 0.0722*light.b;
                    
                    float sunLum = light.r;
                    float moonLum = light.g;
                    
                    vec4 diffuse = texture2D(diffuseTexture, _surface.diffuseTexcoord);
                    
                    float color = 0.2126*diffuse.r + 0.7152*diffuse.g + 0.0722*diffuse.b;
                    
                    float minValue = 20.0/255.0;
                    float maxValue = 230/255.0;
                    
                    color = (color - minValue)/(maxValue-minValue);
                    
                    if (color > 1.0){
                        color = 1.0;
                    }
                    if (color < 0.0){
                        color = 0.0;
                    }
                    
                    float alpha = min(color,1.0);
                    
                    color = color * min(max(sunLum,moonLum),1.0) * 2.0;
                    
                    float factor = ( _surface.normal.x * _surface.normal.x + _surface.normal.y * _surface.normal.y );
                    
                    float red = color;
                    float green = color*(1.0-0.5*powr(factor,4));
                    float blue = color*(1.0-1.0*powr(factor,4));
                    
                    vec4 cloudColor = vec4(red,green*min(sunLum,1.0),blue*min(sunLum*sunLum,1.0),alpha) ;
                    if (sunLum < 0.001){
                        cloudColor = vec4(red,green,blue,1.0) * alpha;
                    }
                    
                    _output.color = cloudColor;
                    
                    """
                    
                    self.geometry?.firstMaterial?.shaderModifiers = [.fragment: ShaderModifier]
                    
                    
                }
            }
            
            task.resume()
            break
            
        case "eumetsat":
            let url = URL(string: "https://view.eumetsat.int/geoserver/ows?service=WMS&request=GetMap&version=1.3.0&layers=mumi:worldcloudmap_ir108&styles=&format=image/png&crs=EPSG:4326&bbox=-90,-180,90,180&width=6688&height=3344")
            //max allowed size
            //let url = URL(string: "https://secure.xericdesign.com/mosaic/composite.jpg")
            let task = URLSession.shared.dataTask(with: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async() { [self] in    // execute on main thread
                    
                    //Correct contrast histogram to take into account see color and max cloud color
                    let diffuseTexture = UIImage(data: data)
                    //let diffuseTexture = UIImage(named: "clouds")
                    
                    let diffuse = SCNMaterialProperty(contents: diffuseTexture ?? UIColor.black)
                    
                    self.geometry?.firstMaterial?.setValue(diffuse, forKey: "diffuseTexture")
                    
                    let ShaderModifier =
                    
                    """
                    //Function to convert sRGB values to Linear Color Space values, function found on stackOverflow, see link below
                    //https://stackoverflow.com/questions/44033605/why-is-metal-shader-gradient-lighter-as-a-scnprogram-applied-to-a-scenekit-node/44045637#44045637
                    //Formula available here :
                    //https://en.wikipedia.org/wiki/SRGB#Theory_of_the_transformation
                    
                    float srgbToLinear(float c) {
                        if (c <= 0.04045)
                            return c / 12.92;
                        else
                            return powr((c + 0.055) / 1.055, 2.4);
                    }
                    
                    float linearToSrgb(float c) {
                        if (c <= 0.0031308)
                            return c * 12.92;
                        else
                            return 1.055 * powr(c, 1.0/2.4) - 0.055;
                    }

                    #pragma body
                    #pragma transparent
                    
                    uniform sampler2D diffuseTexture;

                    vec3 light = _lightingContribution.diffuse;
                    //float lum = 0.2126*light.r + 0.7152*light.g + 0.0722*light.b;
                    
                    float sunLum = sqrt(light.r);
                    float moonLum = light.g;
                    
                    vec4 diffuse = texture2D(diffuseTexture, _surface.diffuseTexcoord);
                    
                    float color = diffuse.r;
                    
                    if (color > 0.9){
                        color = 0.1;
                    }
                    // 70 and 220
                    //
                    float minValue = 0.061;
                    float maxValue = 0.716;
                    
                    color = (color - minValue)/(maxValue-minValue);
                    
                    if (color > 1.0){
                        color = 1.0;
                    }
                    
                    if (color < 0.0){
                        color = 0.0;
                    }
                    
                    float factor = ( _surface.normal.x * _surface.normal.x + _surface.normal.y * _surface.normal.y );
                    
                    factor = factor*factor;
                    
                    color = powr(color,0.5);
                    
                    float alpha = powr(color,0.1);
                    
                    float red = color ;
                    float green = color * (1 - 0.5 * factor);
                    float blue = 0.8 * color * (1 - factor);
                    
                    float ambient = 0.002;
                    
                    if (sunLum > 0.001){
                        red = red * sunLum * sunLum;
                        green = green * sunLum * powr(sunLum,1.4);
                        blue = blue * sunLum * powr(sunLum,2.0);
                    } else {
                        red = red * max(moonLum,ambient);
                        green = green * max(moonLum,ambient);
                        blue = blue * max(moonLum,ambient);
                    }
                    
                    _output.color = vec4(red,green,blue,1.0) * alpha;
                    
                    """
                    
//                    let geoShader =
//
//                    """
//
//                    uniform sampler2D diffuseTexture;
//                    
//                    #pragma body
//
//                    vec4 color = texture2D(diffuseTexture, _geometry.texcoords[0]);
//
//                    float intensity = color.r;
//
//                    _geometry.position.xyz *= (1.0 + 0.009*intensity);
//
//                    """

                    
                    self.geometry?.firstMaterial?.shaderModifiers = [.fragment: ShaderModifier]
                    
                    
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
                    let cloudImage = UIImage(data: data)?.handleNOAA().contrastIncrease(minValue: 60, maxValue: 240)

                    let cloudImageInverted = cloudImage?.invert()
                    
                    self.geometry?.firstMaterial?.transparent.contents = cloudImageInverted

                    self.geometry?.firstMaterial?.diffuse.contents = cloudImage
   
                    self.geometry?.firstMaterial?.transparencyMode = .rgbZero
                    
                    self.geometry?.firstMaterial?.transparency = 1.0
                    
                    let time = Time()
                    
                    let delta = time.getDelta()*180/Float.pi
                    let lambda = time.getLongitude()
                    
                    let multiply = cloudImage?.terminator(delta: delta,longitude: lambda)
                    
                    self.geometry?.firstMaterial?.multiply.contents = multiply
   

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
        case "dead":
            let url = URL(string: "https://raw.githubusercontent.com/apollo-ng/cloudmap/master/global.jpg")
            let task = URLSession.shared.dataTask(with: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async() { [self] in    // execute on main thread

                    let cloudImage = UIImage(data: data)
                    
                    let cloudImageInverted = cloudImage?.invert()
                    
                    self.geometry?.firstMaterial?.transparent.contents = cloudImageInverted

                    self.geometry?.firstMaterial?.diffuse.contents = cloudImage
   
                    self.geometry?.firstMaterial?.transparencyMode = .rgbZero
                    
                    self.geometry?.firstMaterial?.transparency = 1.0
                    
                    let time = Time()
                    
                    let delta = time.getDelta()*180/Float.pi
                    let lambda = time.getLongitude()
                    
                    let multiply = cloudImage?.terminator(delta: delta,longitude: lambda)
                    
                    self.geometry?.firstMaterial?.multiply.contents = multiply

                }
            }
            
            task.resume()
        break
        default:
        break
        
        }


    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }


}
