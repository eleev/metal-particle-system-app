//
//  Cube.swift
//  MetalParticleSystem
//
//  Created by Astemir Eleev on 18/10/2017.
//  Copyright © 2017 Astemir Eleev. All rights reserved.
//

import Foundation
import Metal

class Cube: Node {
    
    init?(device: MTLDevice) {
        
        let a = Vertex(x: -1.0, y:   1.0, z:   1.0, r:  1.0, g:  0.0, b:  0.0, a:  1.0)
        let b = Vertex(x: -1.0, y:  -1.0, z:   1.0, r:  0.0, g:  1.0, b:  0.0, a:  1.0)
        let c = Vertex(x:  1.0, y:  -1.0, z:   1.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0)
        let d = Vertex(x:  1.0, y:   1.0, z:   1.0, r:  0.1, g:  0.6, b:  0.4, a:  1.0)
        
        let q = Vertex(x: -1.0, y:   1.0, z:  -1.0, r:  1.0, g:  0.0, b:  0.0, a:  1.0)
        let r = Vertex(x:  1.0, y:   1.0, z:  -1.0, r:  0.0, g:  1.0, b:  0.0, a:  1.0)
        let s = Vertex(x: -1.0, y:  -1.0, z:  -1.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0)
        let t = Vertex(x:  1.0, y:  -1.0, z:  -1.0, r:  0.1, g:  0.6, b:  0.4, a:  1.0)
        
        let vertices: Array<Vertex> = [
            a,b,c ,a,c,d,   //Front
            r,t,s ,q,r,s,   //Back
            
            q,s,b ,q,b,a,   //Left
            d,c,t ,d,t,r,   //Right
            
            q,a,d ,q,d,r,   //Top
            b,s,t ,b,t,c    //Bot
        ]
        
        super.init(name: "Cube", vertices: vertices, device: device)
    }
}
