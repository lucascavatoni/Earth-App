//
//  SCNVector3_Extension.swift
//  Earth App
//
//  Created by Lucas Cavatoni on 21/02/2023.
//

import SceneKit

extension SCNVector3 {
    func normalized() -> SCNVector3 {
        let length = sqrt(x*x + y*y + z*z)
        if length != 0 {
            return SCNVector3(x/length, y/length, z/length)
        }
        return SCNVector3Zero
    }
    
    func dot(_ other: SCNVector3) -> Float {
        return x * other.x + y * other.y + z * other.z
    }
    
    static func -(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3(x: left.x - right.x, y: left.y - right.y, z: left.z - right.z)
    }
}
