//
//  GeometrySceneViewController.swift
//  MetalParticleSystem
//
//  Created by Astemir Eleev on 19/10/2017.
//  Copyright © 2017 Astemir Eleev. All rights reserved.
//

import UIKit

class GeometrySceneViewController: MetalViewController, MetalViewControllerDelegate {
    
    var worldModelMatrix:Matrix4!
    var objectToDraw: Cube!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        worldModelMatrix = Matrix4()
        worldModelMatrix.translate(x: 0.0, y: 0.0, z: -4.0)
        worldModelMatrix.rotateAround(x: Float(25).radians, y: 0.0, z: 0.0)
        
        objectToDraw = Cube(device: device)
        self.metalViewControllerDelegate = self
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - MetalViewControllerDelegate
    
    func renderObjects(drawable:CAMetalDrawable) {
        
        objectToDraw.render(in: commandQueue, pipelineState: pipelineState, drawable: drawable, parentModelViewMatrix: worldModelMatrix, projectionMatrix: projectionMatrix, clearColor: nil)
    }
    
    func updateLogic(timeSinceLastUpdate: CFTimeInterval) {
        objectToDraw.updateWithDelta(delta: timeSinceLastUpdate)
    }

}
