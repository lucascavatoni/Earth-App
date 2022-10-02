//
//  EarthNode.swift
//  Earth App
//
//  Created by Lucas Cavatoni on 19/11/2020.
//

import SceneKit

class SurfaceNode: SCNNode {
    
    override init() {
        super.init()
        
        //Creating sphere
        //Sphere of radius 1
        let sphere = SCNSphere(radius: 1)
        //Number of segments
        sphere.segmentCount = 48
        //Geometry is this sphere
        self.geometry = sphere

        let diffuseTexture: UIImage;
        
        let monthly = true
        if monthly {
            //Calendar
            var calendar = Calendar.current
            calendar.timeZone = TimeZone(identifier: "UTC")!
            //month
            let m:Int = Int(calendar.component(.month, from: Date()))
            switch m {
            case 1:
                //January
                diffuseTexture = UIImage(named: "world.topo.200401.3x21600x10800")!
                break
            case 2:
                //February
                diffuseTexture = UIImage(named: "world.topo.200402.3x21600x10800")!
                break
            case 3:
                //March
                diffuseTexture = UIImage(named: "world.topo.200403.3x21600x10800")!
                break
            case 4:
                //April
                diffuseTexture = UIImage(named: "world.topo.200404.3x21600x10800")!
                break
            case 5:
                //May
                diffuseTexture = UIImage(named: "world.topo.200405.3x21600x10800")!
                break
            case 6:
                //June
                diffuseTexture = UIImage(named: "world.topo.200406.3x21600x10800")!
                break
            case 7:
                //July
                diffuseTexture = UIImage(named: "world.topo.200407.3x21600x10800")!
                break
            case 8:
                //August
                diffuseTexture = UIImage(named: "world.topo.200408.3x21600x10800")!
                break
            case 9:
                //September
                diffuseTexture = UIImage(named: "world.topo.200409.3x21600x10800")!
                break
            case 10:
                //October
                diffuseTexture = UIImage(named: "world.topo.200410.3x21600x10800")!
                break
            case 11:
                //November
                diffuseTexture = UIImage(named: "world.topo.200411.3x21600x10800")!
                break
            case 12:
                //December
                diffuseTexture = UIImage(named: "world.topo.200412.3x21600x10800")!
                break
            default:
                //Default case: June
                diffuseTexture = UIImage(named: "world.topo.200409.3x21600x10800")!
                break
            }
        } else {
            diffuseTexture = UIImage(named: "earth_truecolor_texture_map_12k_by_fargetanik_ddjmpsj")!
        }
                
        //Night
        let emissionTexture = UIImage(named: "lights")!
        
        //specular
        let specularTexture = UIImage(named: "specular")!
        
        //emission
        let emission = SCNMaterialProperty(contents: emissionTexture)
        
        //diffuse
        let diffuse = SCNMaterialProperty(contents: diffuseTexture)
        
        //specular
        let specular = SCNMaterialProperty(contents: specularTexture)
        
        //setting the value
        self.geometry?.firstMaterial?.setValue(emission, forKey: "emissionTexture")
        
        self.geometry?.firstMaterial?.setValue(diffuse, forKey: "diffuseTexture")
        
        self.geometry?.firstMaterial?.setValue(specular, forKey: "specularTexture")
        
        let ShaderModifier =
        
        """
        uniform sampler2D diffuseTexture;
                
        uniform vec3 direction = _light.direction;
        
        uniform float scalar = dot(direction,_surface.normal)*_light.intensity.rgb;
        
        vec3 light = _lightingContribution.diffuse;
        //float lum = 0.2126*light.r + 0.7152*light.g + 0.0722*light.b;
        float sunLum = light.r;
        float moonLum = light.g;
        vec4 ground = texture2D(diffuseTexture, _surface.diffuseTexcoord);

        //ground.r = powr(ground.r,0.7);
        //ground.g = powr(ground.g,1.0);
        //ground.b = powr(ground.b,1.4);
        
        float ambient = 0.002;
        
        //epsilon = 0.01;
        
        if ((ground.r - ground.g > 0.03) || (ground.g - ground.b > 0.03)){
            ground.g = 0.7*ground.g;
            ground.b = 0.2*ground.b;
        } else {
            ground.b = 0.8 * ground.b;
        }
        
        vec4 diffuse = ground * max(max(sunLum,moonLum),ambient);
        
        _output.color = diffuse;
        
        uniform sampler2D specularTexture;
        
        float factor = ( _surface.normal.x * _surface.normal.x + _surface.normal.y * _surface.normal.y );
        
        vec3 specular = _lightingContribution.specular;
        float lumSpecular = 0.2126*specular.r + 0.7152*specular.g + 0.0722*specular.b;
        vec4 specularColor = texture2D(specularTexture, _surface.specularTexcoord) * lumSpecular * (1.0 + 100 * powr(factor,4));
        specularColor = vec4(specularColor.r,specularColor.g*(1.0-0.6*factor),specularColor.b*0.7*(1.0-1.0*factor),1.0);
        _output.color += specularColor;
        
        uniform sampler2D emissionTexture;

        float lum = max(0.0, 1.0 - 100.0 * sunLum);
        vec4 emission = texture2D(emissionTexture, _surface.emissionTexcoord) * lum;
        
        //vec4 lights = vec4(emission.r*emission.r,emission.r*0.2*(1.0-0.5*factor),0.1*emission.r*(1.0-emission.r)*(1.0-factor),1.0);
        //vec4 lights = vec4(emission.r,0.1*log(10*emission.r+1),0.01*log(100*emission.r+1),1.0);
        
        factor = factor*factor;
        
        //HP sodium sRGB : 255, 183, 76
        //in Linear sRGB : 1, 0.47353149614801, 0.0722718506823175 -> 1, 0.47, 0.072
        
        //HPS is 2200K -> https://andi-siess.de/rgb-to-color-temperature/ -> 255, 147, 44 -> 1, 0.291770649817536, 0.0251868596273616
        // 1, 0.29, 0.026 -> 255, 147, 44
        // other source https://academo.org/demos/colour-temperature-relationship/ : 255, 146, 39 -> 1, 0.287440837726917, 0.0202885630566524
        
        
        
        vec4 lights = vec4(emission.r,((0.474-0.292)*emission.g+0.292)*emission.g*(1-0.5*factor),((0.072-0.025)*emission.b+0.025)*emission.b*(1-factor),1.0)*0.5;
        
        _output.color += lights;

        """
        
        self.geometry?.firstMaterial?.shaderModifiers = [.fragment: ShaderModifier]
        
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
