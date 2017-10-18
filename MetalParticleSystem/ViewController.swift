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

    var device: MTLDevice!
    var metalLayer: CAMetalLayer!
    var vertexBuffer: MTLBuffer! = nil
    var pipelineState: MTLRenderPipelineState!
    var timer: CADisplayLink!
    var commandQueue: MTLCommandQueue!
    
    var objectToDraw: Cube!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // MLTDevice setup
        device = MTLCreateSystemDefaultDevice()
        
        // CAMetalLayer setup
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
        
        // Vertext Buffer setup
        objectToDraw = Cube(device: device)
        
        // Render pipeline setup
        let defaultLibrary = device.makeDefaultLibrary()
        let fragmentProgram = defaultLibrary?.makeFunction(name: "basic_fragment")
        let vertexProgram = defaultLibrary?.makeFunction(name: "basic_vertex")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
        // Dispaly Link setup
        
        timer = CADisplayLink(target: self, selector: #selector(ViewController.gameloop))
        timer.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        
        commandQueue = device.makeCommandQueue()
    }

    // MARK: - Runloop
    
    func render() {
        
        guard let drawable = metalLayer.nextDrawable() else { return }
        objectToDraw.render(in: commandQueue, pipelineState: pipelineState, drawable: drawable, clearColor: nil)
    }
    
    @objc func gameloop() {
        autoreleasepool {
            self.render()
        }
    }
    
}

