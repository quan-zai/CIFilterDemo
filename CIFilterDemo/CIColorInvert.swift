//
//  CIColorInvert.swift
//  CIFilterDemo
//
//  Created by 权仔 on 16/9/19.
//  Copyright © 2016年 XZQ. All rights reserved.
//

import UIKit

class CIColorInvert: CIFilter {

    var inputImage: CIImage!
    
    override var outputImage: CIImage? {
        get {
            return CIFilter(name: "CIColorMatrix", withInputParameters: [
                kCIInputImageKey : inputImage,
                "inputRVector"   : CIVector(x: -1, y: 0, z: 0),
                "inputGVector"   : CIVector(x: 0, y: -1, z: 0),
                "inputBVector"   : CIVector(x: 0, y: 0, z: -1),
                "inputBiasVector": CIVector(x: 1, y: 1, z: 1),
                ])?.outputImage
        }
    }
    
    
    
    
}
