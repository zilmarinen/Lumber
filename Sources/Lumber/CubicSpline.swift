//
//  CubicSpline.swift
//
//  Created by Zack Brown on 04/09/2024.
//

import Euclid

internal protocol SIMDRepresentable: SIMD {
    
    
}

internal struct CubicSpline<S: SIMDRepresentable> where S.Scalar == Double {
    
    internal let curves: [CubicCurve<S>]
}
