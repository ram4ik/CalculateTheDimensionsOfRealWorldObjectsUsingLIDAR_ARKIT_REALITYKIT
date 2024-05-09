//
//  ContentView.swift
//  CalculateTheDimensionsOfRealWorldObjectsUsingLIDAR_ARKIT_REALITYKIT
//
//  Created by Ramill Ibragimov on 5/9/24.
//

import SwiftUI
import ARKit
import RealityKit

struct ContentView: View {
    @State var distance: Float = 0
    @State var positions: [SIMD3<Float>] = []
    
    var body: some View {
        VStack {
            ARViewContainer(distance: $distance, positions: $positions)
            Text("Distance: \(String(format: "%.2f", distance)) meters")
                .foregroundStyle(.primary)
                .font(.headline)
                .padding(.bottom, 100)
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var distance: Float
    @Binding var positions: [SIMD3<Float>]
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        arView.session.run(config)
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        return arView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(distance: $distance, positions: $positions)
    }
}

class Coordinator: NSObject {
    @Binding var distance: Float
    @Binding var positions: [SIMD3<Float>]
    
    init(distance: Binding<Float>, positions: Binding<[SIMD3<Float>]>) {
        _distance = distance
        _positions = positions
    }
    
    func distanceBetweenPoints(_ point1: SIMD3<Float>, _ point2: SIMD3<Float>) -> Float {
        let deltaX = point2.x - point1.x
        let deltaY = point2.y - point1.y
        let deltaZ = point2.z - point1.z
        
        let distance = sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ)
        return distance
    }
    
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let arView = gestureRecognizer.view as? ARView else { return }
        let touchLocation = gestureRecognizer.location(in: arView)
        
        if let hitTestResult = arView.raycast(from: touchLocation, allowing: .estimatedPlane, alignment: .any).first {
            let worldTransform = hitTestResult.worldTransform
            let position = SIMD3<Float>(worldTransform.columns.3.x,
                                        worldTransform.columns.3.y,
                                        worldTransform.columns.3.z)
            positions.append(position)
            if (positions.count >= 2) {
                distance = distanceBetweenPoints(positions[positions.count - 2], positions[positions.count - 1])
            }
            
            let pointAnchor = AnchorEntity(world: position)
            let pointEntity = ModelEntity(mesh: .generateSphere(radius: 0.005), materials: [SimpleMaterial(color: .green, isMetallic: true)])
            pointAnchor.addChild(pointEntity)
            arView.scene.addAnchor(pointAnchor)
        }
    }
}

#Preview {
    ContentView()
}
