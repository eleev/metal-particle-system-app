//
//  Node.swift
//  MetalParticleSystem
//
//  Created by Astemir Eleev on 17/10/2017.
//  Copyright © 2017 Astemir Eleev. All rights reserved.
//

import Foundation
import Metal
import QuartzCore

/// Node represents an object to draw. Requires verticies, name and a device to create buffers and render later on.
class Node {
    let devide: MTLDevice
    let name: String
    var vertexCount: Int
    var vertexBuffer: MTLBuffer
    
    init?(name: String, vertices: Array<Vertex>, device: MTLDevice) {
        
        var vertexData = Array<Float>()
        vertices.forEach { vertex in
            vertexData += vertex.floatBuffer()
        }
        
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        guard let vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: []) else { return nil }
        
        self.vertexBuffer = vertexBuffer
        self.name = name
        self.devide = device
        vertexCount = vertices.count
    }
    
    /// Renders node using triangle primitive into the provided command queue and pipeline state
    ///
    /// - Parameters:
    ///   - commandQueue: is a target CommandQueue instance
    ///   - pipelineState: is an instance of MTLRenderPipelineState class
    ///   - drawable: is an instance of CAMetalDrawable class
    ///   - clearColor: is an optional instance of MTLClearColor 
    func render(in commandQueue: MTLCommandQueue, pipelineState: MTLRenderPipelineState, drawable: CAMetalDrawable, clearColor: MTLClearColor?) {
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = clearColor ?? MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderEncoder?.setRenderPipelineState(pipelineState)
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount)
        renderEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
}
