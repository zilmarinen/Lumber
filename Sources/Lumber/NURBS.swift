//
//  NURBS.swift
//
//  Created by Zack Brown on 14/09/2024.
//

import Euclid

public struct NURBS {
    
    public let cage: [[ControlPoint]]
    internal let degreeU: Int
    internal let degreeV: Int
    
    public init(_ cage: [[ControlPoint]]) {
        
        self.cage = cage
        self.degreeU = (cage.first?.count ?? 1) - 1
        self.degreeV = cage.count - 1
    }
    
    public init(_ cage: [[ControlPoint]],
                _ degreeU: Int,
                _ degreeV: Int) {
      
        self.cage = cage
        self.degreeU = degreeU
        self.degreeV = degreeV
    }
}

extension NURBS {
    
    public func sample(_ u: Double,
                       _ v: Double,
                       _ wrapU: Bool,
                       _ wrapV: Bool) -> ControlPoint {
        
        let controlPoints = cage.map { sample($0,
                                              degreeU,
                                              u,
                                              wrapU) }
        
        return sample(controlPoints,
                      degreeV,
                      v,
                      wrapV)
    }
    
    internal func sample(_ controlPoints: [ControlPoint],
                         _ degree: Int,
                         _ t: Double,
                         _ wrap: Bool) -> ControlPoint {
        
        guard degree >= 1 else {
        
            guard let controlPoint = controlPoints.first else { fatalError("Invalid control points") }
            
            return controlPoint
        }
        
        var controls: [ControlPoint] = []
        
        for i in 0..<degree {
            
            let j = wrap ? controlPoints.wrappedIndex(i) : i
            let k = wrap ? controlPoints.wrappedIndex(i + 1) : i + 1
            
            let lhs = controlPoints[j]
            let rhs = controlPoints[k]
            
            let interpolated = lhs.weighted.mix(rhs.weighted,
                                                t)
            
            controls.append(.init(interpolated))
        }
        
        return sample(controls,
                      degree - 1,
                      t,
                      wrap)
    }
}

extension NURBS {
    
    public func mesh(_ uResolution: Int,
                     _ vResolution: Int,
                     _ wrapU: Bool = true,
                     _ wrapV: Bool = true) throws -> Mesh {
        
        let uStep = 1.0 / Double(uResolution)
        let vStep = 1.0 / Double(vResolution)
        
        var polygons: [Polygon] = []
        
        for u in 1...uResolution {
            
            for v in 1...vResolution {
                
                let s0 = sample(Double(u - 1) * uStep, Double(v - 1) * vStep, wrapU, wrapV)
                let s1 = sample(Double(u - 1) * uStep, Double(v) * vStep, wrapU, wrapV)
                let s2 = sample(Double(u) * uStep, Double(v - 1) * vStep, wrapU, wrapV)
                let s3 = sample(Double(u) * uStep, Double(v) * vStep, wrapU, wrapV)
                
                try polygons.append(Polygon.face([s2.position, s1.position, s0.position],
                                                 .blue))
                
                try polygons.append(Polygon.face([s3.position, s1.position, s2.position],
                                                 .red))
            }
        }
        
        return Mesh(polygons)
    }
}

extension NURBS {
    
    public static func plane(_ x: Double = 1.0,
                             _ z: Double = 1.0) -> Self {
        
        let controlPoints = [[ControlPoint(.init(x, 0.0, -z), 1.0),
                              ControlPoint(.init(-x, 0.0, -z), 1.0)],
                             [ControlPoint(.init(x, 0.0, z), 1.0),
                              ControlPoint(.init(-x, 0.0, z), 1.0)]]
        
        return Self(controlPoints)
    }
    
    public static func urn() -> Self {
        
        var top: [ControlPoint] = []
        var middle: [ControlPoint] = []
        var bottom: [ControlPoint] = []

        let innerRadius = 0.5
        let outerRadius = 0.75
        let sides = 8
        let step = Double.tau / Double(sides)

        for i in 0..<sides {

            let angle = Angle(radians: Double(i) * step)

            top.append(.init(.init(cos(angle) * innerRadius,
                                   2.0,
                                   sin(angle) * innerRadius), 1.0))

            middle.append(.init(.init(cos(angle) * outerRadius,
                                      1.5,
                                      sin(angle) * outerRadius), 1.0))

            bottom.append(.init(.init(cos(angle) * innerRadius,
                                      0.0,
                                      sin(angle) * innerRadius), 1.0))
        }
        
        let controlPoints = [top,
                             middle,
                             bottom]
        
        return Self(controlPoints)
    }
    
    public static func unknown() -> Self {
        
        let controlPoints = [[ControlPoint(.init(0.0, 0.0, 0.0), 1.0),
                              ControlPoint(.init(1.0, 0.0, 1.0), 1.0),
                              ControlPoint(.init(2.0, 0.0, 0.0), 1.0),
                              ControlPoint(.init(3.0, 0.0, 1.0), 1.0)],
                             [ControlPoint(.init(0.0, 1.0, 1.0), 1.0),
                              ControlPoint(.init(1.0, 1.0, 2.0), 1.0),
                              ControlPoint(.init(2.0, 1.0, 1.0), 1.0),
                              ControlPoint(.init(3.0, 1.0, 2.0), 1.0)],
                             [ControlPoint(.init(0.0, 2.0, 0.0), 1.0),
                              ControlPoint(.init(1.0, 2.0, 1.0), 1.0),
                              ControlPoint(.init(2.0, 2.0, 0.0), 1.0),
                              ControlPoint(.init(3.0, 2.0, 1.0), 1.0)],
                             [ControlPoint(.init(0.0, 3.0, 1.0), 1.0),
                              ControlPoint(.init(1.0, 3.0, 2.0), 1.0),
                              ControlPoint(.init(2.0, 3.0, 1.0), 1.0),
                              ControlPoint(.init(3.0, 3.0, 2.0), 1.0)]]
        
        return Self(controlPoints)
    }
}
