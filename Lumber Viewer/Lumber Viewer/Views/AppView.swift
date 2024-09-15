//
//  AppView.swift
//
//  Created by Zack Brown on 05/09/2024.
//

import Bivouac
import Dependencies
import SceneKit
import SwiftUI

struct AppView: View {
    
    @Dependency(\.deviceManager) var deviceManager
    
    @ObservedObject private var viewModel = AppViewModel()
        
    var body: some View {
        
        #if os(iOS)
            NavigationStack {
        
                viewer
            }
        #else
            viewer
        #endif
    }
    
    var viewer: some View {
        
        ZStack(alignment: .bottomTrailing) {
            
            sceneView
            
            Text("Polygons: [\(viewModel.profile.polygonCount)] Vertices: [\(viewModel.profile.vertexCount)]")
                .foregroundColor(.black)
                .padding()
        }
    }
    
    var sceneView: some View {
        
        SceneView(scene: viewModel.scene,
                  pointOfView: viewModel.scene.camera.pov,
                  options: [.allowsCameraControl,
                            .rendersContinuously],
                  delegate: viewModel.scene,
                  technique: deviceManager.technique)
        .toolbar {
            
            ToolbarItemGroup {
                
                toolbar
            }
        }
    }
    
    @ViewBuilder
    var toolbar: some View {
        
        Menu {
                                
            Toggle("Show Controls", isOn: $viewModel.showControls)
            
        } label: {
            
            Label("Change viewer settings", systemImage: "slider.horizontal.3")
        }
    }
}
