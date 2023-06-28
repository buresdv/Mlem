//
//  Generic Merge Sort.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-27.
//

import Foundation

/**
 Performs merge on two sorted arrays, returning the result.
 
 The arrays must be sorted such that compare(a[0], a[1]) returns true
 
 The result will be sorted using the provided compare such that, if compare(x, y) returns true, x will appear before y in the output.
 */
func merge<T>(arr1: [T], arr2: [T], compare: (T, T) -> Bool) -> [T] {
    var ret: [T] = .init()
    
    var aIdx = 0
    var bIdx = 0
    
    // merge
    while aIdx < arr1.count && bIdx < arr2.count {
        if compare(arr1[aIdx], arr2[bIdx]) {
            ret.append(arr1[aIdx])
            aIdx += 1
        } else {
            ret.append(arr2[bIdx])
            bIdx += 1
        }
    }
    
    // handle remaining values
    while aIdx < arr1.count {
        ret.append(arr1[aIdx])
        aIdx += 1
    }
    while bIdx < arr2.count {
        ret.append(arr2[bIdx])
        bIdx += 1
    }
    
    return ret
}
