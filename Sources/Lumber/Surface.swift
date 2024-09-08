//
//  Surface.swift
//
//  Created by Zack Brown on 04/09/2024.
//

import Euclid

public struct Surface {
    
    public enum KnotType {
        
        case openUniform
        case uniform
    }
    
    public enum SplineType {
        
        case clamped
        case `default`
        case loop
    }
    
    internal let order, degreeU, degreeV: Int
    internal let knotsU, knotsV: [Double]
    internal let splineTypeU, splineTypeV: SplineType
    internal let controlPoints: [ControlPoint]
    
    public init(_ order: Int,
                _ degreeU: Int,
                _ degreeV: Int,
                _ knotsU: [Double],
                _ knotsV: [Double],
                _ splineTypeU: SplineType,
                _ splineTypeV: SplineType,
                _ controlPoints: [ControlPoint]) {
        
        self.order = order
        self.degreeU = degreeU
        self.degreeV = degreeV
        self.knotsU = knotsU
        self.knotsV = knotsV
        self.splineTypeU = splineTypeU
        self.splineTypeV = splineTypeV
        self.controlPoints = controlPoints
    }
    
    public func sample(_ u: Double,
                       _ v: Double) -> Vector {
        
        let tU = transpose(u: u)
        let tV = transpose(v: v)
        
        var sample = Vector.zero
        var d: Double = 1e-8
        
        for tV in 0..<degreeV {
            
            for tU in 0..<degreeU {
                
                let b = basis(tU, order, order, u, knotTypeU) * basis(tV, order, order, v, knotTypeV)
                let control = controlPoints[tU + tV * degreeU]
                
                sample += control.position * b * control.weight
                d += b * control.weight
            }
        }
        
        return sample / d
    }
}

internal extension Surface {
    
    var knotTypeU: KnotType { splineTypeU == .clamped ? .openUniform : .uniform }
    var knotTypeV: KnotType { splineTypeV == .clamped ? .openUniform : .uniform }
 
    var loopU: Bool { splineTypeU == .loop }
    var loopV: Bool { splineTypeV == .loop }
    
    var minimumU: Double { knotVector(order, order, degreeU, knotTypeU) }
    var minimumV: Double { knotVector(order, order, degreeV, knotTypeV) }
    var maximumU: Double { knotVector(degreeU, order, degreeU, knotTypeU) }
    var maximumV: Double { knotVector(degreeV, order, degreeV, knotTypeV) }
    
    func transpose(u value: Double) -> Double { minimumU + (maximumU - minimumU) * value }
    func transpose(v value: Double) -> Double { minimumV + (maximumV - minimumV) * value }
}

internal extension Surface {
    
    func knotVector(_ index: Int,
                    _ order: Int,
                    _ controlCount: Int,
                    _ knotType: KnotType) -> Double {
        
        let knot = controlCount + order + 1
        
        switch knotType {
            
        case .uniform: return 1.0 / Double(knot - 1) * Double(index)
        case .openUniform:
            
            guard index > order else { return 0.0 }
            guard index < (knot - 1 - order) else { return 1.0 }
            
            return Double(index) / Double(knot - order + 1)
        }
    }
    
    func basis(_ j: Int,
               _ k: Int,
               _ length: Int,
               _ t: Double,
               _ knotType: KnotType) -> Double {
        
        guard k != 0 else {
            
            let lhs = knotVector(j, order, length, knotType)
            let rhs = knotVector(j + 1, order, length, knotType)
            
            return t >= lhs && t < rhs ? 1.0 : 0.0
        }
        
        let k0 = knotVector(j + k, order, length, knotType)
        let k1 = knotVector(j, order, length, knotType)
        let k2 = knotVector(j + k + 1, order, length, knotType)
        let k3 = knotVector(j + 1, order, length, knotType)
        
        let v0 = k0 - k1
        let v1 = k2 - k3
        
        let c0 = v0 != 0.0 ? (t - k1) / v0 : 0.0
        let c1 = v1 != 0.0 ? (k2 - t) / v1 : 0.0
        
        return  c0 * basis(j, k - 1, length, t, knotType) +
                c1 * basis(j + 1, k - 1, length, t, knotType)
    }
}
