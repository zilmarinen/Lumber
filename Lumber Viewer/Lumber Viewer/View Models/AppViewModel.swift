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
        
        /*
         
         {  glm::vec3(0, 0, 1), glm::vec3(0, 0, 1), glm::vec3(0, 0, 1), glm::vec3(0, 0, 1),
            glm::vec3(2, 0, 1), glm::vec3(2, 4, 1),  glm::vec3(-2, 4, 1),  glm::vec3(-2, 0, 1),
            glm::vec3(2, 0, -1), glm::vec3(2, 4, -1), glm::vec3(-2, 4, -1), glm::vec3(-2, 0, -1),
            glm::vec3(0, 0, -1), glm::vec3(0, 0, -1), glm::vec3(0, 0, -1), glm::vec3(0, 0, -1)
         }
         
         {  1,       1.f/3.f, 1.f/3.f, 1,
            1.f/3.f, 1.f/9.f, 1.f/9.f, 1.f/3.f,
            1.f/3.f, 1.f/9.f, 1.f/9.f, 1.f/3.f,
            1,       1.f/3.f, 1.f/3.f, 1
         }
         
         */
        
//        let controlPoints = [ControlPoint(.init(0.0, 0.0, 1.0), 1.0),
//                             ControlPoint(.init(0.0, 0.0, 1.0), 1.0 / 3.0),
//                             ControlPoint(.init(0.0, 0.0, 1.0), 1.0 / 3.0),
//                             ControlPoint(.init(0.0, 0.0, 1.0), 1.0),
//        
//                             ControlPoint(.init(2.0, 0.0, 1.0), 1.0 / 3.0),
//                             ControlPoint(.init(2.0, 4.0, 1.0), 1.0 / 9.0),
//                             ControlPoint(.init(-2.0, 4.0, 1.0), 1.0 / 9.0),
//                             ControlPoint(.init(-2.0, 0.0, 1.0), 1.0 / 3.0),
//        
//                             ControlPoint(.init(2.0, 0.0, -1.0), 1.0 / 3.0),
//                             ControlPoint(.init(2.0, 4.0, -1.0), 1.0 / 9.0),
//                             ControlPoint(.init(-2.0, 4.0, -1.0), 1.0 / 9.0),
//                             ControlPoint(.init(-2.0, 0.0, -1.0), 1.0 / 3.0),
//        
//                             ControlPoint(.init(0.0, 0.0, -1.0), 1.0),
//                             ControlPoint(.init(0.0, 0.0, -1.0), 1.0 / 3.0),
//                             ControlPoint(.init(0.0, 0.0, -1.0), 1.0 / 3.0),
//                             ControlPoint(.init(0.0, 0.0, -1.0), 1.0)]
        
        let controlPoints = [ControlPoint(.init(1.0, 0.0, -1.0), 1.0),
                             ControlPoint(.init(-1.0, 0.0, -1.0), 1.0),
                             ControlPoint(.init(1.0, 0.0, 1.0), 1.0),
                             ControlPoint(.init(-1.0, 0.0, 1.0), 1.0)]
        
        let surface = Surface(4,
                              2,
                              2,
                              .default,
                              .default,
                              controlPoints)
        
        guard let mesh = try? surface.mesh(5, 5) else { return }
        
        self.scene.model.geometry = SCNGeometry(mesh)
        self.scene.model.geometry?.program = Program(function: .geometry)
        
        let node = SCNNode(mesh: Mesh.cube(center: Vector(0.0, -0.01, 0.0),
                                           size: Vector(2.0, 0.01, 2.0)))
        
        self.scene.rootNode.addChildNode(node)
        
        updateProfile(for: mesh)
    }
    
    private func updateProfile(for mesh: Mesh) {
            
        DispatchQueue.main.async { [weak self] in
            
            guard let self else { return }
            
            self.profile = mesh.profile
        }
    }
}
