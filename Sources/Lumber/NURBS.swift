//
//  NURBS.swift
//
//  Created by Zack Brown on 14/09/2024.
//

import Bivouac
import Euclid

extension Array where Element == [ControlPoint] {
    
    public func mesh(_ uResolution: Int,
                     _ vResolution: Int,
                     _ wrapU: Bool,
                     _ wrapV: Bool) throws -> Mesh {
        
        var controlPoints = self
        
        if wrapU {
            
            for i in 0..<controlPoints.count {
                
                if let control = controlPoints[i].first {
                    
                    controlPoints[i].append(control)
                }
            }
        }
        
        if wrapV,
           let controls = controlPoints.first {
            
            controlPoints.append(controls)
        }
        
        let uStep = 1.0 / Double(uResolution)
        let vStep = 1.0 / Double(vResolution)
        
        var polygons: [Polygon] = []
        
        for u in 1...uResolution {
            
            for v in 1...vResolution {
                
                let s0 = controlPoints.sample(Double(u - 1) * uStep,
                                              Double(v - 1) * vStep)
                let s1 = controlPoints.sample(Double(u - 1) * uStep,
                                              Double(v) * vStep)
                let s2 = controlPoints.sample(Double(u) * uStep,
                                              Double(v - 1) * vStep)
                let s3 = controlPoints.sample(Double(u) * uStep,
                                              Double(v) * vStep)
                
                try polygons.append(Polygon.face([s2.position, s1.position, s0.position],
                                                 .blue))
                
                try polygons.append(Polygon.face([s3.position, s1.position, s2.position],
                                                 .red))
            }
        }
        
        return Mesh(polygons)
    }
    
    internal func sample(_ u: Double,
                         _ v: Double) -> ControlPoint {
        
        let degreeU = (first?.count ?? 1) - 1
        let degreeV = count - 1
        
        let controlPoints = map { $0.sample(degreeU,
                                            u) }
        
        return controlPoints.sample(degreeV,
                                    v)
    }
}

extension Array where Element == ControlPoint {
    
    internal func sample(_ degree: Int,
                         _ t: Double) -> ControlPoint {
        
        guard degree > 0 else {
        
            guard let controlPoint = first else { fatalError("Invalid control points") }
            
            return controlPoint
        }
        
        var controls: [ControlPoint] = []
        
        for i in 0..<degree {
            
            let lhs = self[i]
            let rhs = self[i + 1]
            
            let interpolated = lhs.weighted.mix(rhs.weighted,
                                                t)
            
            controls.append(.init(interpolated))
        }
        
        return controls.sample(degree - 1,
                               t)
    }
}

public enum Spline {
    
    case plane(x: Double,
               z: Double)
    
    case unknown
    
    case urn(sides: Int,
             innerRadius: Double,
             outerRadius: Double)
    
    public func mesh(_ uResolution: Int,
                     _ vResolution: Int,
                     _ wrapU: Bool,
                     _ wrapV: Bool) throws -> Mesh { try controlPoints.mesh(uResolution,
                                                                            vResolution,
                                                                            wrapU,
                                                                            wrapV) }
    
    public var controlPoints: [[ControlPoint]] {
        
        switch self {
            
        case .plane(let x, let z): return plane(x, z)
            
        case .unknown: return unknown()
            
        case .urn(let sides,
                  let innerRadius,
                  let outerRadius): return urn(sides,
                                               innerRadius,
                                               outerRadius)
        }
    }
}

extension Spline {
    
    internal func plane(_ x: Double,
                        _ z: Double) -> [[ControlPoint]] {
    
        [[ControlPoint(.init(x, 0.0, -z), 1.0),
          ControlPoint(.init(-x, 0.0, -z), 1.0)],
         [ControlPoint(.init(x, 0.0, z), 1.0),
          ControlPoint(.init(-x, 0.0, z), 1.0)]]
    }
    
    internal func urn(_ sides: Int,
                      _ innerRadius: Double,
                      _ outerRadius: Double) -> [[ControlPoint]] {
        
        var top: [ControlPoint] = []
        var middle: [ControlPoint] = []
        var bottom: [ControlPoint] = []

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
        
        return [top,
                middle,
                bottom]
    }
    
    internal func unknown() -> [[ControlPoint]] {
        
        [[ControlPoint(.init(0.0, 0.0, 0.0), 1.0),
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
    }
}
