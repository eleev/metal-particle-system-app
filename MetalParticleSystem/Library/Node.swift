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
    
    // MARK: - Properties
    
    let device: MTLDevice
    let name: String
    var vertexCount: Int
    var vertexBuffer: MTLBuffer
    var time: CFTimeInterval = 0.0

    var bufferProvider: BufferProvider
    
    // MARK: - Transform properties
    
    var positionX: Float = 0.0
    var positionY: Float = 0.0
    var positionZ: Float = 0.0
    
    var rotationX: Float = 0.0
    var rotationY: Float = 0.0
    var rotationZ: Float = 0.0
    var scale: Float     = 1.0
    
    // MARK: - Initializers
    
    init?(name: String, vertices: Array<Vertex>, device: MTLDevice) {
        
        self.bufferProvider = BufferProvider(device: device, inflightBuffersCount: 3, sizeOfUniformsBuffer: MemoryLayout<Float>.size * Matrix4.numberOfElements * 2)
        
        var vertexData = Array<Float>()
        vertices.forEach { vertex in
            vertexData += vertex.floatBuffer()
        }
        
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        guard let vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: []) else { return nil }
        
        self.vertexBuffer = vertexBuffer
        self.name = name
        self.device = device
        vertexCount = vertices.count
    }
    
    // MARK: - Methods
    
    /// Renders node using triangle primitive into the provided command queue and pipeline state
    ///
    /// - Parameters:
    ///   - commandQueue: is a target CommandQueue instance
    ///   - pipelineState: is an instance of MTLRenderPipelineState class
    ///   - drawable: is an instance of CAMetalDrawable class
    ///   - clearColor: is an optional instance of MTLClearColor 
    func render(in commandQueue: MTLCommandQueue, pipelineState: MTLRenderPipelineState, drawable: CAMetalDrawable, parentModelViewMatrix: Matrix4, projectionMatrix: Matrix4, clearColor: MTLClearColor?) {

        // This will make the CPU wait in case bufferProvider.avaliableResourcesSemaphore has no free resources.
        _ = bufferProvider.avaliableResourcesSemaphore.wait(timeout: DispatchTime.distantFuture)
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        // When the GPU finishes rendering, it executes a completion handler to signal the semaphore and bumps its count back up again.
        commandBuffer?.addCompletedHandler { (_) in
            self.bufferProvider.avaliableResourcesSemaphore.signal()
        }
        
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderEncoder?.setCullMode(MTLCullMode.front)
        renderEncoder?.setRenderPipelineState(pipelineState)
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        let nodeModelMatrix = self.modelMatrix()
        nodeModelMatrix.multiply(left: parentModelViewMatrix)
        
        let uniformBuffer = bufferProvider.nextUniformsBuffer(projectionMatrix: projectionMatrix, modelViewMatrix: nodeModelMatrix)
        
        renderEncoder?.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: vertexCount/3)
        renderEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
    func updateWithDelta(delta: CFTimeInterval){
        time += delta
    }
    
    func modelMatrix() -> Matrix4 {
        
        let matrix = Matrix4()
        matrix.translate(x: positionX, y: positionY, z: positionZ)
        matrix.rotateAround(x: rotationX, y: rotationY, z: rotationZ)
        matrix.scale(x: scale, y: scale, z: scale)
        return matrix
    }
    
}
