//
//  Triangle.swift
//  MetalParticleSystem
//
//  Created by Astemir Eleev on 17/10/2017.
//  Copyright © 2017 Astemir Eleev. All rights reserved.
//

import Foundation
import Metal

class Triangle: Node {
    
    init?(device: MTLDevice) {
        
        let v0 = Vertex(x: 0.0, y: 1.0, z: 0.0,     r: 1.0, g: 0.0, b: 0.0, a: 1.0)
        let v1 = Vertex(x: -1.0, y: -1.0, z: 0.0,   r: 0.0, g: 1.0, b: 0.0, a: 1.0)
        let v2 = Vertex(x: 1.0, y: -1.0, z: 0.0,    r: 0.0, g: 0.0, b: 1.0, a: 1.0)
        
        let verticesArray = [ v0, v1, v2 ]
        super.init(name: "Triangle", vertices: verticesArray, device: device)
    }
    
}
