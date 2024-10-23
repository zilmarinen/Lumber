//
//  Surface.swift
//
//  Created by Zack Brown on 04/09/2024.
//

//import Bivouac
//import Euclid
//
//public struct Surface {
//    
//    public enum KnotType {
//        
//        case openUniform
//        case uniform
//    }
//    
//    public enum SplineType {
//        
//        case clamped
//        case `default`
//        case loop
//    }
//    
//    internal let order, degreeU, degreeV: Int
//    internal let splineTypeU, splineTypeV: SplineType
//    public let controlPoints: [ControlPoint]
//    
//    public init(_ order: Int,
//                _ degreeU: Int,
//                _ degreeV: Int,
//                _ splineTypeU: SplineType,
//                _ splineTypeV: SplineType,
//                _ controlPoints: [ControlPoint]) {
//        
//        self.order = order
//        self.splineTypeU = splineTypeU
//        self.splineTypeV = splineTypeV
//        
//        let loopU = splineTypeU == .loop
//        let loopV = splineTypeV == .loop
//        
//        switch (loopU, loopV) {
//            
//        case (false, false):
//            
//            self.degreeU = degreeU
//            self.degreeV = degreeV
//            self.controlPoints = controlPoints
//            
//        case (false, true):
//            
//            self.degreeU = degreeU
//            self.degreeV = degreeV + order
//            self.controlPoints = controlPoints
//            
//        case (true, false):
//            
//            self.degreeU = degreeU + order
//            self.degreeV = degreeV
//            self.controlPoints = controlPoints.wrapX(degreeU,
//                                                     degreeV,
//                                                     order)
//            
//        case (true, true):
//            
//            self.degreeU = degreeU + order
//            self.degreeV = degreeV + order
//            self.controlPoints = controlPoints
//        }
//        
//        print("U: [\(minimumU), \(maximumU)]")
//        print("V: [\(minimumV), \(maximumV)]")
//    }
//    
//    public func sample(_ u: Double,
//                       _ v: Double) -> Vector {
//        
//        let tU = transpose(u: u)
//        let tV = transpose(v: v)
//        
//        var sample = Vector.zero
//        var d: Double = 1e-8
//        
//        for iV in 0..<degreeV {
//            
//            for iU in 0..<degreeU {
//                
//                let b = basis(iU, order, degreeU, tU, knotTypeU) * basis(iV, order, degreeV, tV, knotTypeV)
//                let control = controlPoints[iU + iV * degreeU]
//                
//                sample += control.position * b * control.weight
//                d += b * control.weight
//            }
//        }
//        
//        return sample / d
//    }
//}
//
//internal extension Surface {
//    
//    var knotTypeU: KnotType { splineTypeU == .clamped ? .openUniform : .uniform }
//    var knotTypeV: KnotType { splineTypeV == .clamped ? .openUniform : .uniform }
//    
//    var minimumU: Double { knotVector(order, degreeU, knotTypeU) }
//    var minimumV: Double { knotVector(order, degreeV, knotTypeV) }
//    var maximumU: Double { knotVector(degreeU, degreeU, knotTypeU) }
//    var maximumV: Double { knotVector(degreeV, degreeV, knotTypeV) }
//    
//    func transpose(u value: Double) -> Double { minimumU + (maximumU - minimumU) * value }
//    func transpose(v value: Double) -> Double { minimumV + (maximumV - minimumV) * value }
//}
//
//internal extension Surface {
//    
//    func knotVector(_ index: Int,
//                    _ controlCount: Int,
//                    _ knotType: KnotType) -> Double {
//        
//        let knot = controlCount + order + 1
//        
//        switch knotType {
//            
//        case .uniform: return 1.0 / Double(knot - 1) * Double(index)
//        case .openUniform:
//            
//            guard index > order else { return 0.0 }
//            guard index < (knot - 1 - order) else { return 1.0 }
//            
//            return Double(index) / Double(knot - order + 1)
//        }
//    }
//    
//    func basis(_ j: Int,
//               _ k: Int,
//               _ length: Int,
//               _ t: Double,
//               _ knotType: KnotType) -> Double {
//        
//        guard k != 0 else {
//            
//            let lhs = knotVector(j, length, knotType)
//            let rhs = knotVector(j + 1, length, knotType)
//            
//            return t >= lhs && t < rhs ? 1.0 : 0.0
//        }
//        
//        let k0 = knotVector(j + k, length, knotType)
//        let k1 = knotVector(j, length, knotType)
//        let k2 = knotVector(j + k + 1, length, knotType)
//        let k3 = knotVector(j + 1, length, knotType)
//        
//        let v0 = k0 - k1
//        let v1 = k2 - k3
//        
//        let c0 = v0 != 0.0 ? (t - k1) / v0 : 0.0
//        let c1 = v1 != 0.0 ? (k2 - t) / v1 : 0.0
//        
//        return  c0 * basis(j, k - 1, length, t, knotType) +
//                c1 * basis(j + 1, k - 1, length, t, knotType)
//    }
//}
//
//extension Surface {
//    
//    public func mesh(_ uResolution: Int,
//                     _ vResolution: Int) throws -> Mesh {
//        
//        let uStep = 1.0 / Double(uResolution)
//        let vStep = 1.0 / Double(vResolution)
//        
//        var polygons: [Polygon] = []
//        
//        for u in 1...uResolution {
//            
//            for v in 1...vResolution {
//                
//                let s0 = sample(Double(u - 1) * uStep, Double(v - 1) * vStep)
//                let s1 = sample(Double(u - 1) * uStep, Double(v) * vStep)
//                let s2 = sample(Double(u) * uStep, Double(v - 1) * vStep)
//                let s3 = sample(Double(u) * uStep, Double(v) * vStep)
//                
//                try polygons.append(Polygon.face([s2, s1, s0],
//                                                 .blue))
//                
//                try polygons.append(Polygon.face([s3, s1, s2],
//                                                 .red))
//            }
//        }
//        
//        return Mesh(polygons)
//    }
//}
//
//extension Surface {
//    
//    public static func plane(_ u: Double = 1.0,
//                             _ v: Double = 1.0) -> Self {
//        
//        let controlPoints = [ControlPoint(.init(u, 0.0, -v), 1.0),
//                             ControlPoint(.init(-u, 0.0, -v), 1.0),
//                             ControlPoint(.init(u, 0.0, v), 1.0),
//                             ControlPoint(.init(-u, 0.0, v), 1.0)]
//        
//        return Surface(1,
//                       2,
//                       2,
//                       .default,
//                       .default,
//                       controlPoints)
//    }
//    
//    static func torus() -> Self {
//        
//        let controlPoints = [ControlPoint(.init(0.0, 0.0, 1.0), 1.0),
//                             ControlPoint(.init(2.0, 0.0, 1.0), 1.0 / 3.0),
//                             ControlPoint(.init(2.0, 0.0, -1.0), 1.0 / 3.0),
//                             ControlPoint(.init(0.0, 0.0, -1.0), 1.0),
//                             
//                             ControlPoint(.init(0.0, 0.0, 1.0), 1.0 / 3.0),
//                             ControlPoint(.init(2.0, 4.0, 1.0), 1.0 / 9.0),
//                             ControlPoint(.init(2.0, 4.0, -1.0), 1.0 / 9.0),
//                             ControlPoint(.init(0.0, 0.0, -1.0), 1.0 / 3.0),
//                             
//                             ControlPoint(.init(0.0, 0.0, 1.0), 1.0 / 3.0),
//                             ControlPoint(.init(-2.0, 4.0, 1.0), 1.0 / 9.0),
//                             ControlPoint(.init(-2.0, 4.0, -1.0), 1.0 / 9.0),
//                             ControlPoint(.init(0.0, 0.0, -1.0), 1.0 / 3.0),
//                             
//                             ControlPoint(.init(0.0, 0.0, 1.0), 1.0),
//                             ControlPoint(.init(-2.0, 0.0, 1.0), 1.0 / 3.0),
//                             ControlPoint(.init(-2.0, 0.0, -1.0), 1.0 / 3.0),
//                             ControlPoint(.init(0.0, 0.0, -1.0), 1.0)]
//        
//        return Surface(2,
//                       4,
//                       4,
//                       .default,
//                       .default,
//                       controlPoints)
//    }
//}
//
//extension Array where Element == ControlPoint {
//    
//    func wrapX(_ rows: Int,
//               _ columns: Int,
//               _ order: Int) -> Self {
//        
//        var result = Self()
//        
//        for column in 0..<columns {
//            
//            for row in 0..<(rows + order) {
//                
//                let i = row % rows + column * rows
//                
//                result.append(self[i])
//            }
//        }
//        
//        return result
//    }
//}
