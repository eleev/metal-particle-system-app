//
//  BufferProvider.swift
//  MetalParticleSystem
//
//  Created by Astemir Eleev on 19/10/2017.
//  Copyright © 2017 Astemir Eleev. All rights reserved.
//

import Foundation
import Metal

class BufferProvider: NSObject {

    var avaliableResourcesSemaphore: DispatchSemaphore

    let inflightBuffersCount: Int
    private var uniformsBuffers: [MTLBuffer]
    private var avaliableBufferIndex: Int = 0

    init(device:MTLDevice, inflightBuffersCount: Int, sizeOfUniformsBuffer: Int) {
        
        avaliableResourcesSemaphore = DispatchSemaphore(value: inflightBuffersCount)
        
        self.inflightBuffersCount = inflightBuffersCount
        uniformsBuffers = [MTLBuffer]()
        
        for _ in 0...inflightBuffersCount-1 {
            if let uniformsBuffer = device.makeBuffer(length: sizeOfUniformsBuffer, options: []) {
                uniformsBuffers.append(uniformsBuffer)
            }
        }
    }
    
    deinit{
        
        for _ in 0...self.inflightBuffersCount {
            self.avaliableResourcesSemaphore.signal()
        }
    }
    
    func nextUniformsBuffer(projectionMatrix: Matrix4, modelViewMatrix: Matrix4) -> MTLBuffer {
        
        let buffer = uniformsBuffers[avaliableBufferIndex]
        let bufferPointer = buffer.contents()
        let numberOfElements = Matrix4.numberOfElements
        
        memcpy(bufferPointer, modelViewMatrix.raw, MemoryLayout<Float>.size * numberOfElements)
        memcpy(bufferPointer + MemoryLayout<Float>.size * numberOfElements, projectionMatrix.raw, MemoryLayout<Float>.size * numberOfElements)
        
        avaliableBufferIndex += 1
        if avaliableBufferIndex == inflightBuffersCount{
         
            avaliableBufferIndex = 0
        }
        return buffer
    }
}
