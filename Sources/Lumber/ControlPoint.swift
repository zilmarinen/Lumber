//
//  ControlPoint.swift  
//
//  Created by Zack Brown on 07/09/2024.
//

import Euclid

public struct ControlPoint {
    
    public let position: Vector
    public let weight: Double
    
    public init(_ position: Vector,
                _ weight: Double) {
        
        self.position = position
        self.weight = weight
    }
}
