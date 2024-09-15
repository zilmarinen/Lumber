//
//  ControlPoint.swift  
//
//  Created by Zack Brown on 07/09/2024.
//

import Euclid
import simd

public struct ControlPoint {
    
    public let position: Vector
    public let weight: Double
    
    public var weighted: SIMD4<Double> { SIMD4(position.x * weight,
                                               position.y * weight,
                                               position.z * weight,
                                               weight) }
    
    public init(_ position: Vector,
                _ weight: Double) {
        
        self.position = position
        self.weight = weight
    }
    
    public init(_ weighted: SIMD4<Double>) {
        
        self.position = Vector(weighted.x / weighted.w,
                               weighted.y / weighted.w,
                               weighted.z / weighted.w)
        self.weight = weighted.w
    }
}

extension SIMD4<Double> {
    
    internal func mix(_ other: Self,
                      _ t: Double) -> Self { (1.0 - t) * self + t * other }
}

extension Array {
    
    func wrappedIndex(_ i: Int) -> Int { (i % count + count) % count }
}
