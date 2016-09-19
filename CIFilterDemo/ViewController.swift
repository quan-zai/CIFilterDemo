//
//  ViewController.swift
//  CIFilterDemo
//
//  Created by 权仔 on 16/9/18.
//  Copyright © 2016年 XZQ. All rights reserved.
//
/*
 自动改善图像以及内置滤镜
 */

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    lazy var originalImage: UIImage = {
        return UIImage(named: "image")!
    }()
    
    // 懒加载CIContext对象 CIContext对象是Core Image处理图像的关键
    lazy var context: CIContext = {
        return CIContext(options: nil)
    }()
    
    var filter: CIFilter!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.layer.shadowOpacity = 0.8
        self.imageView.layer.shadowColor = UIColor.black.cgColor;
        self.imageView.layer.shadowOffset = CGSize(width: 1, height: 1)
        
        self.imageView.image = originalImage
        
        self.showFiltersInconsole()
    }
    
    // 原图按钮
    @IBAction func showOriginalImage(_ sender: UIButton) {
        self.imageView.image = originalImage
    }
    
    // 自动改善
    @IBAction func autoAdjust(_ sender: AnyObject) {
        
        // 自动改善
        //        var inputImage = CIImage(image: originalImage)
        //        let filters = (inputImage?.autoAdjustmentFilters())! as [CIFilter]
        //        for filter: CIFilter in filters {
        //            filter.setValue(inputImage, forKey: kCIInputImageKey)
        //            inputImage = filter.outputImage
        //        }
        //        // 此时才对iamge做真正的渲染
        //        let cgImage = context.createCGImage(inputImage!, from: inputImage!.extent)
        //
        //        self.imageView.image = UIImage(cgImage: cgImage!)
        
        filter = CIFilter(name: "CIPhotoEffectInstant")
        
        var inputImage = CIImage(image: originalImage)

        filter.setValue(inputImage, forKey: kCIInputImageKey)
        inputImage = filter.outputImage
        // 此时才对iamge做真正的渲染
        let cgImage = context.createCGImage(inputImage!, from: inputImage!.extent)
        
        self.imageView.image = UIImage(cgImage: cgImage!)
    }
    
    func showFiltersInconsole() {
        let filterNames = CIFilter.filterNames(inCategory: kCICategoryBuiltIn)
        print(filterNames.count)
        print(filterNames)
        for filterName in filterNames {
            let filter = CIFilter(name: filterName as String)
            let attributes = filter?.attributes
            print(attributes)
        }
    }
}




