//
//  Vertex.swift
//  MetalParticleSystem
//
//  Created by Astemir Eleev on 17/10/2017.
//  Copyright © 2017 Astemir Eleev. All rights reserved.
//

import Foundation


struct  Vertex {
    var x, y, z: Float      // position data
    var r, g, b, a: Float   // color data
    
    func floatBuffer() -> [Float] {
        return [ x, y, z, r, g, b, a ]
    }
}
