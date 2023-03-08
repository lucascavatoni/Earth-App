//
//  FloatingPointType_Extension.swift
//  Earth App
//
//  Created by Lucas Cavatoni on 26/01/2023.
//

extension Float {
    func sign() -> Float {
        return (self < Self(0) ? -1 : 1)
    }
    
    func toRadians() -> Float {
        return self/180*Float.pi
    }

    func toDegrees() -> Float {
        return self/Float.pi*180
    }
}





