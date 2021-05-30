//
//  SKSpriteNode+Extensions.swift
//  Earth App
//
//  Created by Lucas Cavatoni on 06/03/2021.
//

import Foundation
import SpriteKit

extension SKNode
{
    func addGlow(radius:CGFloat=30)
    {
        let view = SKView()
        let effectNode = SKEffectNode()
        let texture = view.texture(from: self)
        effectNode.shouldRasterize = true
        effectNode.filter = CIFilter(name: "CIGaussianBlur",parameters: ["inputRadius":radius])
        addChild(effectNode)
        effectNode.addChild(SKSpriteNode(texture: texture))
    }
}
