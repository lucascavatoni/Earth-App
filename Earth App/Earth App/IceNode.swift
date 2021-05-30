//
//  IceNode.swift
//  Earth App
//
//  Created by Lucas Cavatoni on 06/01/2021.
//

import SceneKit

class IceNode: SCNNode {
    override init(){
        super.init()
        
        
        //Creating sphere
        let sphere = SCNSphere(radius: 1.0005)
        //Number of segments
        sphere.segmentCount = 48
        //Geometry is this sphere
        self.geometry = sphere
        
        let url = URL(string: "https://www.nnvl.noaa.gov/images/globaldata/SnowIceCover_Daily.png")
        
        self.geometry?.firstMaterial?.transparency = 0.0
        
        //Do box if you want to download
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard let data = data, error == nil else { return }

            DispatchQueue.main.async() { // execute on main thread
                var iceTexture = UIImage(data: data)!
                
                iceTexture = iceTexture.keepIce()
                
                self.geometry?.firstMaterial?.diffuse.contents = iceTexture
                
                self.geometry?.firstMaterial?.transparency = 0.5
                
            }
        }
        
        task.resume()

        self.castsShadow = false
        

                
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
