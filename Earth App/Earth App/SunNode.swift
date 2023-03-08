//
//  SunNode.swift
//  Earth App
//
//  Created by Lucas Cavatoni on 03/12/2020.
//

import SceneKit

let sunRadius: Float = 100

class SunNode: SCNNode {
    override init(){
        super.init()
        
        self.categoryBitMask = LightType.emission
        
        //Geometry is a plane (sprite)
        self.geometry = SCNPlane(width: 2*CGFloat(sunRadius), height: 2*CGFloat(sunRadius))
        
        //let sunTexture = UIImage(named: "sun")
        
        //Setting the sun's texture
        //self.geometry?.firstMaterial?.emission.contents = sunTexture
        
        //Setting the sun's diffuse content
        self.geometry?.firstMaterial?.diffuse.contents = UIColor.black.withAlphaComponent(1)
        
        //Setting the inverted sun texture as transparency mask
        //self.geometry?.firstMaterial?.transparent.contents = sunTexture?.invert()
        
        //Telling scenekit to take the image RGB colors as transparency mask
        //var sun: UIImage?
        
        self.geometry?.firstMaterial?.lightingModel = SCNMaterial.LightingModel.constant
        
        let url = URL(string: "https://sdo.gsfc.nasa.gov/assets/img/latest/latest_1024_HMIIC.jpg")
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard let data = data, error == nil else { return }
                let sun = UIImage(data: data)
            DispatchQueue.main.async() {    /// execute on main thread

                self.geometry?.firstMaterial?.emission.contents = sun
            }
        }

        task.resume()

        self.geometry?.firstMaterial?.emission.textureComponents = .green
        self.geometry?.firstMaterial?.emission.mipFilter = SCNFilterMode.linear
        self.geometry?.firstMaterial?.emission.maxAnisotropy = anisotropy
        self.geometry?.firstMaterial?.emission.intensity = 100.0 ///maximum capacity of HDR, 1000 is burned
        
        self.geometry?.firstMaterial?.transparent.contents = UIImage(named: "sunMask")
        self.geometry?.firstMaterial?.transparent.mipFilter = SCNFilterMode.linear
        self.geometry?.firstMaterial?.transparent.maxAnisotropy = anisotropy
        self.geometry?.firstMaterial?.transparencyMode = .rgbZero
        
        //self.filters = addBloom()
        
        //let program = SCNProgram()
        //program.fragmentShader = shader
        //self.geometry?.firstMaterial?.program = program
        

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

func addBloom() -> [CIFilter]? {
    let bloomFilter = CIFilter(name:"CIBloom")!
    bloomFilter.setValue(100.0, forKey: "inputRadius") //default 10.0
    bloomFilter.setValue(0.1, forKey: "inputIntensity") //default 0.5
    return [bloomFilter]
}
