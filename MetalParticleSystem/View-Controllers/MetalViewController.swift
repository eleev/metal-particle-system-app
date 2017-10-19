//
//  ViewController.swift
//  MetalParticleSystem
//
//  Created by Astemir Eleev on 16/10/2017.
//  Copyright © 2017 Astemir Eleev. All rights reserved.
//

import UIKit
import Metal

protocol MetalViewControllerDelegate : class{
    func updateLogic(timeSinceLastUpdate: CFTimeInterval)
    func renderObjects(drawable: CAMetalDrawable)
}

class MetalViewController: UIViewController {

    // MARK: - Properties
    
    var device: MTLDevice!
    var metalLayer: CAMetalLayer!
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
    var timer: CADisplayLink!
    var projectionMatrix: Matrix4!
    var lastFrameTimestamp: CFTimeInterval = 0.0
    
    // MARK: - Delegate property
    
    weak var metalViewControllerDelegate: MetalViewControllerDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        device = MTLCreateSystemDefaultDevice()
        
        let fov = Float(85).radians
        let aspectRation = Float(self.view.bounds.size.width / self.view.bounds.size.height)
        let nearZ = Float(0.01)
        let farZ = Float(100.0)
        
        projectionMatrix = Matrix4.makePerspectiveView(angle: fov, aspectRatio: aspectRation, nearZ: nearZ, farZ: farZ)
        
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
        
        let defaultLibrary = device.makeDefaultLibrary()
        let fragmentProgram = defaultLibrary?.makeFunction(name: "basic_fragment")
        let vertexProgram = defaultLibrary?.makeFunction(name: "basic_vertex")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
        commandQueue = device.makeCommandQueue()
        
        timer = CADisplayLink(target: self, selector: #selector(MetalViewController.newFrame(displayLink:)))
        timer.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
    }

    // MARK: - Runloop
    
    func render() {
        guard let drawable = metalLayer?.nextDrawable() else { return }
        self.metalViewControllerDelegate?.renderObjects(drawable: drawable)
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
    
        self.metalViewControllerDelegate?.updateLogic(timeSinceLastUpdate: timeSinceLastUpdate)
        autoreleasepool {
            self.render()
        }
    }
    
}

