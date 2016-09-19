//
//  FaceDetectionViewController.swift
//  CIFilterDemo
//
//  Created by 权仔 on 16/9/19.
//  Copyright © 2016年 XZQ. All rights reserved.
//

import UIKit
import ImageIO

class FaceDetectionViewController: UIViewController {


    @IBOutlet weak var imageView: UIImageView!
    
    lazy var originalImage: UIImage = {
        return UIImage(named:"image4")!
    }()
    
    lazy var context: CIContext = {
        return CIContext()
    }()
    
    @IBAction func faceDetecting(_ sender: UIButton) {
        let inputImage = CIImage(image: originalImage)
        let detector = CIDetector(ofType: CIDetectorTypeFace,
                                  context: context,
                                  options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        var faceFeatures: [CIFaceFeature]!
        if let orientation: AnyObject = inputImage?.properties[kCGImagePropertyOrientation as String] as AnyObject? {
            faceFeatures = detector?.features(in: inputImage!, options: [CIDetectorImageOrientation: orientation]) as! [CIFaceFeature]
        } else {
            faceFeatures = detector?.features(in: inputImage!) as! [CIFaceFeature]
        }
        
        print(faceFeatures)
        
        // 1.
        let inputImageSize = inputImage?.extent.size
        var transform = CGAffineTransform()
        transform = transform.scaledBy(x: 1, y: -1)
        transform = transform.translatedBy(x: 0, y: -(inputImageSize?.height)!)
        
        for faceFeature in faceFeatures {
            var faceViewBounds = faceFeature.bounds.applying(transform)
            // 2.
            let scaleTransform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            faceViewBounds = faceViewBounds.applying(scaleTransform)
            
            let faceView = UIView(frame: faceViewBounds)
            faceView.layer.borderColor = UIColor.white.cgColor
            faceView.layer.borderWidth = 2
            
            imageView.addSubview(faceView)
        }
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        imageView.image = originalImage
    }
}
