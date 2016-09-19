//
//  ComplexFilterViewController.swift
//  CIFilterDemo
//
//  Created by 权仔 on 16/9/18.
//  Copyright © 2016年 XZQ. All rights reserved.
//
/*
 稍复杂的内置滤镜，除了需要提供inputImage原始图片这个参数外，还需要提供一些其他参数
 */

import UIKit

class ComplexFilterViewController: UIViewController {

    /*
     滤镜的分类
     按效果分类：
     kCICategoryDistortionEffect		扭曲效果，比如bump、旋转、hole
     kCICategoryGeometryAdjustment	几何开着调整，比如仿射变换、平切、透视转换
     kCICategoryCompositeOperation	合并，比如源覆盖（source over）、最小化、源在顶（source atop）、色彩混合模式
     kCICategoryHalftoneEffect		Halftone效果，比如screen、line screen、hatched
     kCICategoryColorAdjustment		色彩调整，比如伽马调整、白点调整、曝光
     kCICategoryColorEffect			色彩效果，比如色调调整、posterize
     kCICategoryTransition			图像间转换，比如dissolve、disintegrate with mask、swipe
     kCICategoryTileEffect			瓦片效果，比如parallelogram、triangle
     kCICategoryGenerator			图像生成器，比如stripes、constant color、checkerboard
     kCICategoryGradient			渐变，比如轴向渐变、仿射渐变、高斯渐变
     kCICategoryStylize				风格化，比如像素化、水晶化
     kCICategorySharpen			锐化、发光
     kCICategoryBlur				模糊，比如高斯模糊、焦点模糊、运动模糊
     按使用场景分类：
     kCICategoryStillImage			能用于静态图像
     kCICategoryVideo				能用于视频
     kCICategoryInterlaced			能用于交错图像
     kCICategoryNonSquarePixels		能用于非矩形像素
     kCICategoryHighDynamicRange	能用于HDR
     */
    
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var imageView: UIImageView!
    
    lazy var originalImage: UIImage = {
        return UIImage(named:"image2")!
    }()
    
    lazy var context: CIContext = {
        return CIContext()
    }()
    
    var filter: CIFilter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.shadowOpacity = 0.0
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = CGSize(width: 1, height: 1)
        
        slider.maximumValue = Float(M_PI)
        slider.minimumValue = Float(-M_PI)
        slider.value = 0
        slider.addTarget(self, action: #selector(valueChanged(_:)), for: UIControlEvents.valueChanged)
        
        let inputImage = CIImage(image: originalImage)
        filter = CIFilter(name: "CIHueAdjust")
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        slider.sendActions(for: UIControlEvents.valueChanged)
        
        // 查看217种内置的滤镜，可以通过这些信息简单了解各种类型滤镜的使用
    
        showFiltersInconsole()
    }
    
    func valueChanged(_ slider: UISlider) {
        filter.setValue(slider.value, forKey: kCIInputAngleKey)
        let outputImage = filter.outputImage
        let cgImage = context.createCGImage(outputImage!, from: (outputImage?.extent)!)
        imageView.image = UIImage(cgImage: cgImage!)
    }
    
    @IBAction func colorInvert(_ sender: UIButton) {
        let colorInvertFilter = CIColorInvert()
        colorInvertFilter.inputImage = CIImage(image: imageView.image!)
        let outputImage = colorInvertFilter.outputImage
        let cgImage = context.createCGImage(outputImage!, from: (outputImage?.extent)!)
        imageView.image = UIImage(cgImage: cgImage!)
    }
    
    @IBAction func showOriginalImage(_ sender: UIButton) {
        imageView.image = originalImage
    }
    
    @IBAction func replaceBackground(_ sender: UIButton) {
        let cubeMap = createCubeMap(60,90)
        let data = NSData(bytesNoCopy: cubeMap.data, length: Int(cubeMap.length), freeWhenDone: true)
        let colorCubeFilter = CIFilter(name: "CIColorCube")
        
        colorCubeFilter?.setValue(cubeMap.dimension, forKey: "inputCubeDimension")
        colorCubeFilter?.setValue(data, forKey: "inputCubeData")
        colorCubeFilter?.setValue(CIImage(image: imageView.image!), forKey: kCIInputImageKey)
        var outputImage = colorCubeFilter?.outputImage
        
        let sourceOverCompositingFilter = CIFilter(name: "CISourceOverCompositing")
        sourceOverCompositingFilter?.setValue(outputImage, forKey: kCIInputImageKey)
        sourceOverCompositingFilter?.setValue(CIImage(image: UIImage(named: "image3")!), forKey: kCIInputBackgroundImageKey)
        
        outputImage = sourceOverCompositingFilter?.outputImage
        let cgImage = context.createCGImage(outputImage!, from: outputImage!.extent)
        imageView.image = UIImage(cgImage: cgImage!)
    }
    
    @IBAction func oldFilmEffect(_ sender: UIButton) {
        /*
         需要使用CISepiaTone滤镜，CISepiaTone能使整体颜色偏棕褐色，又有点像复古
         需要创建随机噪点图，很像以前电视机没信号时显示的图像，再通过它生成一张白斑图滤镜
         需要创建另一个随机噪点图，然后通过它生成一张黑色磨砂图滤镜，就像是一张使用过的黑色砂纸一样
         把它们组合起来
         */
        
        // 应用CISepiaTone滤镜到原图上
        let inputImage = CIImage(image: originalImage)
        let sepiaToneFilter = CIFilter(name: "CISepiaTone")
        sepiaToneFilter?.setValue(inputImage, forKey: kCIInputImageKey)
        sepiaToneFilter?.setValue(1.0, forKey: kCIInputIntensityKey)
        
        // 创建白斑图滤镜
        let whiteSpecksFilter = CIFilter(name: "CIColorMatrix")
        whiteSpecksFilter?.setValue(CIFilter(name:"CIRandomGenerator")?.outputImage?.cropping(to: (inputImage?.extent)!), forKey: kCIInputImageKey)
        whiteSpecksFilter?.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputRVector")
        whiteSpecksFilter?.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputGVector")
        whiteSpecksFilter?.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputBVector")
        whiteSpecksFilter?.setValue(CIVector(x: 0, y: 0 , z: 0, w: 0), forKey: "inputBiasVector")
        
        // 把CISepiaTone滤镜和白斑图滤镜以原覆盖（source over）的方式先组合起来
        let sourceOverCompositingFilter = CIFilter(name: "CISourceOverCompositing")
        sourceOverCompositingFilter?.setValue(whiteSpecksFilter?.outputImage, forKey: kCIInputBackgroundImageKey)
        sourceOverCompositingFilter?.setValue(sepiaToneFilter?.outputImage, forKey: kCIInputImageKey)
        
        // 使用CIAffineTransform滤镜先对随机降噪图进行处理
        let affineTransformFilter = CIFilter(name: "CIAffineTransform")
        affineTransformFilter?.setValue(CIFilter(name: "CIRandomGenerator")?.outputImage?.cropping(to: (inputImage?.extent)!), forKey: kCIInputImageKey)
        affineTransformFilter?.setValue(NSValue(cgAffineTransform:CGAffineTransform(scaleX: 1.5, y: 25)), forKey: kCIInputTransformKey)
        
        // 创建蓝绿色磨砂图滤镜
        let darkScratchesFilter = CIFilter(name: "CIColorMatrix")
        darkScratchesFilter?.setValue(affineTransformFilter?.outputImage, forKey: kCIInputImageKey)
        
        darkScratchesFilter?.setValue(CIVector(x: 4, y: 0, z: 0, w: 0), forKey: "inputRVector")
        darkScratchesFilter?.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputGVector")
        darkScratchesFilter?.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputBVector")
        darkScratchesFilter?.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputAVector")
        darkScratchesFilter?.setValue(CIVector(x: 0, y: 1, z: 1, w: 1), forKey: "inputBiasVector")
        
        // 用CIMinimumComponet 滤镜把蓝绿色磨砂图滤镜处理成黑色磨砂图滤镜
        let minumComponentFilter = CIFilter(name: "CIMinimumComponent")
        minumComponentFilter?.setValue(darkScratchesFilter?.outputImage, forKey: kCIInputImageKey)
        
        // 最终组合在一起
        let multiplyCompositingFilter = CIFilter(name: "CIMultiplyCompositing")
        multiplyCompositingFilter?.setValue(minumComponentFilter?.outputImage, forKey: kCIInputBackgroundImageKey)
        
        multiplyCompositingFilter?.setValue(sourceOverCompositingFilter?.outputImage, forKey: kCIInputImageKey)
        
        // 最后输出
        let outputImage = multiplyCompositingFilter?.outputImage
        let cgImage = context.createCGImage(outputImage!, from: (outputImage?.extent)!)
        imageView.image = UIImage(cgImage: cgImage!)
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
