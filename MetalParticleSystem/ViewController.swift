//
//  ViewController.swift
//  MetalParticleSystem
//
//  Created by Astemir Eleev on 16/10/2017.
//  Copyright © 2017 Astemir Eleev. All rights reserved.
//

import UIKit
import Metal

class ViewController: UIViewController {

    var objectToDraw: Cube!
    
    var device: MTLDevice!
    var metalLayer: CAMetalLayer!
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
    var timer: CADisplayLink!
    var projectionMatrix: Matrix4!
    var lastFrameTimestamp: CFTimeInterval = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        device = MTLCreateSystemDefaultDevice()
        
        let angle = Float(85.0).radians
        let aspectRatio = Float(self.view.bounds.size.width / self.view.bounds.size.height)
        let nearZ: Float = 0.01
        let farZ: Float = 100.0
        
        projectionMatrix = Matrix4.makePerspectiveView(angle: angle, aspectRatio: aspectRatio, nearZ: nearZ, farZ: farZ)
        
        metalLayer = CAMetalLayer()
        metalLayer.device = device           
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
        
        // Geometry setup
        objectToDraw = Cube(device: device)
        
        // Shader loading
        let defaultLibrary = device.makeDefaultLibrary()!
        let fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment")
        let vertexProgram = defaultLibrary.makeFunction(name: "basic_vertex")
        
        // Pipeline descriptor setup
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        // Pipeline setup
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
        commandQueue = device.makeCommandQueue()
        
        timer = CADisplayLink(target: self, selector: #selector(ViewController.newFrame(displayLink:)))
        timer.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
    }

    // MARK: - Runloop
    
    func render() {
        
        guard let drawable = metalLayer?.nextDrawable() else { return }
        let worldModelMatrix = Matrix4()
        worldModelMatrix.translate(x: 0.0, y: 0.0, z: -7.0)
        worldModelMatrix.rotateAround(x: Float(25).radians, y: 0.0, z: 0.0)
        
        objectToDraw.render(in: commandQueue, pipelineState: pipelineState, drawable: drawable, parentModelViewMatrix: worldModelMatrix, projectionMatrix: projectionMatrix ,clearColor: nil)
    }
    
    @objc func newFrame(displayLink: CADisplayLink){
        
        if lastFrameTimestamp == 0.0 {
            lastFrameTimestamp = displayLink.timestamp
        }
        
        let elapsed: CFTimeInterval = displayLink.timestamp - lastFrameTimestamp
        lastFrameTimestamp = displayLink.timestamp
        
        gameloop(timeSinceLastUpdate: elapsed)
    }
    
    func gameloop(timeSinceLastUpdate: CFTimeInterval) {
        
        objectToDraw.updateWithDelta(delta: timeSinceLastUpdate)
        
        autoreleasepool {
            self.render()
        }
    }
    
}

