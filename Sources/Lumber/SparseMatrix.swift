//
//  SparseMatrix.swift
//
//  Created by Zack Brown on 04/09/2024.
//

import Accelerate

internal struct SparseMatrix {
    
    internal let size: Int32
    internal let columnStarts: [Int]
    internal let rowIndices: [Int32]
    internal let isSymmetrical: Bool
    internal let data: [Double]
    
    internal init(_ size: Int32,
                  _ columnStarts: [Int],
                  _ rowIndices: [Int32],
                  _ isSymmetrical: Bool,
                  _ data: [Double]) {
        
        self.size = size
        self.columnStarts = columnStarts
        self.rowIndices = rowIndices
        self.isSymmetrical = isSymmetrical
        self.data = data
    }
}

internal extension SparseMatrix {
    
    var attributes: SparseAttributes_t {
        
        guard isSymmetrical else { return SparseAttributes_t() }
        
        return SparseAttributes_t(transpose: false,
                                  triangle: SparseLowerTriangle,
                                  kind: SparseSymmetric,
                                  _reserved: 0,
                                  _allocatedBySparse: false)
    }
    
    var structure: SparseMatrixStructure {
        
        var columnStarts = self.columnStarts
        var rowIndices = self.rowIndices
        
        return columnStarts.withUnsafeMutableBufferPointer { columnPointer in
            
            rowIndices.withUnsafeMutableBufferPointer { rowIndexPointer in
                
                guard let columnStarts = columnPointer.baseAddress,
                      let rowIndices = rowIndexPointer.baseAddress else { fatalError("Invalid pointer to matrix row / column indices") }
                
                return SparseMatrixStructure(rowCount: size,
                                             columnCount: size,
                                             columnStarts: columnStarts,
                                             rowIndices: rowIndices,
                                             attributes: attributes,
                                             blockSize: 1)
            }
        }
    }
    
    var matrix: SparseMatrix_Double {
        
        var data = self.data
        
        return data.withUnsafeMutableBufferPointer { dataPointer in
            
            guard let data = dataPointer.baseAddress else { fatalError("Invalid pointer to matrix data") }
            
            return SparseMatrix_Double(structure: structure,
                                       data: data)
        }
    }
}
