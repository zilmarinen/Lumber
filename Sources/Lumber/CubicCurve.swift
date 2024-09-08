//
//  CubicCurve.swift
//
//  Created by Zack Brown on 04/09/2024.
//

import Euclid

internal struct CubicCurve<S: SIMD> where S.Scalar == Double {
    
    let a, b, c, d: S
    
    internal var start: S { a }
    internal var end: S { a + b + c + d }
    internal var control0: S { a + b / 3.0 }
    internal var control1: S { a + 2.0 * b / 3.0 + c / 3.0 }
    
    internal init(a: S,
                  b: S,
                  c: S,
                  d: S) {
        
        self.a = a
        self.b = b
        self.c = c
        self.d = d
    }
    
    internal init(start: S,
                  end: S,
                  derivativeStart: S,
                  derivativeEnd: S) {
        
        self.a = start
        self.b = derivativeStart
        self.c = 3.0 * (end - start) - 2.0 * derivativeStart - derivativeEnd
        self.d = 2.0 * (start - end) + derivativeStart + derivativeEnd
    }
}

internal extension CubicCurve {
    
    func f(_ t: Double) -> S {
        
        let t2 = t * t
        let linear = a + (t * b)
        let quadratic = t2 * c
        
        return linear + quadratic + (t2 * t * d)
    }
    
    func df(_ t: Double) -> S {
        
        let t2 = t * t
        
        return b + (2.0 * c * t) + (3 * d * t2)
    }
    
    func ddf(_ t: Double) -> S { 2.0 * c + 6.0 * d * t }
}
