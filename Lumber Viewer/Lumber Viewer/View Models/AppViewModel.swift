//
//  AppViewModel.swift
//
//  Created by Zack Brown on 08/09/2024.
//

import Bivouac
import Euclid
import Lumber
import SceneKit

class AppViewModel: ObservableObject {
    
    @Published var showControls: Bool = true {
        
        didSet {
            
            guard oldValue != showControls else { return }
            
            updateScene()
        }
    }
    
    @Published var profile: Mesh.Profile = .init(polygonCount: 0,
                                                 vertexCount: 0)
    
    internal let scene = ModelViewScene()
    
    init() {
        
        updateScene()
    }
}

extension AppViewModel {
    
    private func updateScene() {
        
        scene.clear()
        
        let surface = NURBS.plane()
        
        guard let mesh = try? surface.mesh(7, 7) else { return }
        
        self.scene.model.geometry = SCNGeometry(mesh)
        self.scene.model.geometry?.program = Program(function: .geometry)
        
        let node = SCNNode(mesh: Mesh.cube(center: Vector(0.0, -0.01, 0.0),
                                           size: Vector(2.0, 0.01, 2.0)))
        
        self.scene.rootNode.addChildNode(node)
        
        updateProfile(for: mesh)
        
        if showControls {
            
            surface.cage.forEach { drawControlPoints(controlPoints: $0) }
        }
    }
    
    private func drawControlPoints(controlPoints: [ControlPoint]) {
        
        for controlPoint in controlPoints {
            
            let node = SCNNode(mesh: Mesh.cube(size: Vector(size: 0.05),
                                               material: Color.black))
            
            node.position = SCNVector3(controlPoint.position)
            
            self.scene.rootNode.addChildNode(node)
        }
    }
    
    private func updateProfile(for mesh: Mesh) {
            
        DispatchQueue.main.async { [weak self] in
            
            guard let self else { return }
            
            self.profile = mesh.profile
        }
    }
}
