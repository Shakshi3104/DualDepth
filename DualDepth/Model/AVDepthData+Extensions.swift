//
//  AVDepthData+Extensions.swift
//  DualDepth
//
//  Created by MacBook Pro M1 on 2021/10/27.
//

import Foundation
import AVFoundation
import UIKit

extension AVDepthData {
    // convert to AVDepthData (kCVPixelFormatType_DisparityFloat32)
    var asDisparityFloat32: AVDepthData {
        var convertedDepthData: AVDepthData
                
        // Convert 16 bit floats up to 32 bit
        // https://stackoverflow.com/questions/55009162/filtering-depth-data-on-ios-12-appears-to-be-rotated
        if self.depthDataType != kCVPixelFormatType_DisparityFloat32 {
            convertedDepthData = self.converting(toDepthDataType: kCVPixelFormatType_DisparityFloat32)
        } else {
            convertedDepthData = self
        }
        
        return convertedDepthData
    }
    
    // convert AVDepthData to UIImage
    var asDepthMapImage: UIImage? {
        let convertedDepthData = self.asDisparityFloat32
        let normalizedDepthMap = convertedDepthData.depthDataMap.normalize()
        return normalizedDepthMap.uiImage
    }
}
