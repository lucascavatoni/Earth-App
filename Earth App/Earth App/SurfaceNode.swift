//
//  EarthNode.swift
//  Earth App
//
//  Created by Lucas Cavatoni on 19/11/2020.
//

import SceneKit

let earthRadius: Float = 1.0

class SurfaceNode: SCNNode {
    
    //init(lon: Float) {
    override init() {
        super.init()
                
        self.categoryBitMask = LightType.earth
        
        //Creating sphere
        //Sphere of radius 1
        let sphere = SCNSphere(radius: CGFloat(earthRadius))
        //Number of segments
        sphere.segmentCount = segments
        //Geometry is this sphere
        self.geometry = sphere
        
        //let highDetailLOD = SCNLevelOfDetail(geometry: sphere, screenSpaceRadius: 1)
        
        let diffuseTexture: UIImage;
        
        //Calendar
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!
        //month
        let m:Int = Int(calendar.component(.month, from: Date()))
        switch m {
        case 1:
            //January
            diffuseTexture = UIImage(named: "world.200401.3x5400x2700")!
            break
        case 2:
            //February
            diffuseTexture = UIImage(named: "world.200402.3x5400x2700")!
            break
        case 3:
            //March
            diffuseTexture = UIImage(named: "world.200403.3x5400x2700")!
            break
        case 4:
            //April
            diffuseTexture = UIImage(named: "world.200404.3x5400x2700")!
            break
        case 5:
            //May
            diffuseTexture = UIImage(named: "world.200405.3x5400x2700")!
            break
        case 6:
            //June
            diffuseTexture = UIImage(named: "world.200406.3x5400x2700")!
            break
        case 7:
            //July
            diffuseTexture = UIImage(named: "world.200407.3x5400x2700")!
            break
        case 8:
            //August
            diffuseTexture = UIImage(named: "world.200408.3x5400x2700")!
            break
        case 9:
            //September
            diffuseTexture = UIImage(named: "world.200409.3x5400x2700")!
            break
        case 10:
            //October
            diffuseTexture = UIImage(named: "world.200410.3x5400x2700")!
            break
        case 11:
            //November
            diffuseTexture = UIImage(named: "world.200411.3x5400x2700")!
            break
        case 12:
            //December
            diffuseTexture = UIImage(named: "world.200412.3x21600x10800")!
            break
        default:
            //Default case: June
            diffuseTexture = UIImage(named: "world.200409.3x21600x10800")!
            break
        }
        
        
        // DAY
        self.geometry?.firstMaterial?.diffuse.contents = diffuseTexture
        self.geometry?.firstMaterial?.diffuse.mipFilter = SCNFilterMode.linear
        self.geometry?.firstMaterial?.diffuse.maxAnisotropy = anisotropy
        
        // NIGHT
        self.geometry?.firstMaterial?.emission.contents = UIImage(named: "lights")
        self.geometry?.firstMaterial?.emission.mipFilter = SCNFilterMode.linear
        self.geometry?.firstMaterial?.emission.maxAnisotropy = anisotropy
        
        // WATER
        self.geometry?.firstMaterial?.specular.contents = UIImage(named: "specular")
        self.geometry?.firstMaterial?.specular.mipFilter = SCNFilterMode.linear
        self.geometry?.firstMaterial?.specular.maxAnisotropy = anisotropy
        
        // NORMAL
        self.geometry?.firstMaterial?.normal.contents = UIImage(named: "normal")
        self.geometry?.firstMaterial?.normal.intensity = 0.1
        self.geometry?.firstMaterial?.normal.mipFilter = SCNFilterMode.linear
        self.geometry?.firstMaterial?.normal.maxAnisotropy = anisotropy
        
        self.geometry?.firstMaterial?.shaderModifiers = [.surface: earthSurfaceShader, .fragment: terminatorFragmentShader]

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
