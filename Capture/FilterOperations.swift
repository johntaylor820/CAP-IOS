//
//  FilterOperations.swift
//  Filterlapse
//
//  Created by Mathias on 2015-02-17.
//  Copyright (c) 2015 Mathias Palm. All rights reserved.
//

import Foundation
import GPUImage
import QuartzCore
import OpenGLES

public let RGBTAG = 33
public let OTHERTAG = 32

let filterOperations: Array<FilterOperationInterface> = [
    FilterOperation <GPUImageContrastFilter>(
        listName:"adjust",
        titleName:"Contrast",
        tag:0,
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:100.0, initialValue:50.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            var contrastVal = sliderValue
            if (sliderValue > 50.0) {
                contrastVal = sliderValue/50.0
            } else {
                contrastVal = sliderValue/100.0+0.5
            }
            filter.contrast = contrastVal
        },
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageBrightnessFilter>(
        listName:"adjust",
        titleName:"Brightness",
        tag:1,
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:100.0, initialValue:50.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.brightness = sliderValue/167-0.3
        },
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageWhiteBalanceFilter>(
        listName:"adjust",
        titleName:"Temperature",
        tag:2,
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:100.0, initialValue:50.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.temperature = (sliderValue/50.0)*1000.0 + 4000.0
            //5000.0 orginal val
        },
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageSaturationFilter>(
        listName:"adjust",
        titleName:"Saturation",
        tag:3,
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:100.0, initialValue:50.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.saturation = sliderValue/50.0
        },
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageSharpenFilter>(
        listName:"adjust",
        titleName:"Sharp",
        tag:4,
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:100.0, initialValue:50.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.sharpness = sliderValue/12.5 - 4.0
        },
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageGaussianSelectiveBlurFilter>(
        listName:"Selective Gaussian blur",
        titleName:"Tilt Shift",
        tag:5,
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:1.0, initialValue:0.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.excludeCircleRadius = 1 - sliderValue
            filter.blurRadiusInPixels = 15.0
        },
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageVignetteFilter>(
        listName:"adjust",
        titleName:"Vignette",
        tag:6,
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:100.0, initialValue:0.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.vignetteEnd = sliderValue / -98.95 + 1.5
        },
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    // Filter can only use one!
    FilterOperation <GPUImageFilter>(
        listName:"filter",
        titleName:"Normal",
        tag:7,
        image: UIImage(named:"filterimage.png"),
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <IFHudsonFilter>(
        listName:"filter",
        titleName:"California",
        tag:8,
        image: UIImage(named:"1.png"),
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <IFLomofiFilter>(
        listName:"filter",
        titleName:"Venice",
        tag:9,
        image: UIImage(named:"2.png"),
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <IFInkwellFilter>(
        listName:"filter",
        titleName:"Ansel",
        tag:10,
        image: UIImage(named:"3.png"),
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <IFSutroFilter>(
        listName:"filter",
        titleName:"Gotham",
        tag:11,
        image: UIImage(named:"4.png"),
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <IF1977Filter>(
        listName:"filter",
        titleName:"Park Ave.",
        tag:12,
        image: UIImage(named:"5.png"),
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <IFValenciaFilter>(
        listName:"filter",
        titleName:"Hollywood",
        tag:13,
        image: UIImage(named:"6.png"),
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <IFEarlybirdFilter>(
        listName:"filter",
        titleName:"1970's",
        tag:14,
        image: UIImage(named:"7.png"),
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <IFBrannanFilter>(
        listName:"filter",
        titleName:"Highrise",
        tag:15,
        image: UIImage(named:"8.png"),
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <IFToasterFilter>(
        listName:"filter",
        titleName:"Dreamstate",
        tag:16,
        image: UIImage(named:"9.png"),
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <IFXproIIFilter>(
        listName:"filter",
        titleName:"London",
        tag:17,
        image: UIImage(named:"10.png"),
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <IFNashvilleFilter>(
        listName:"filter",
        titleName:"Hipster",
        tag:18,
        image: UIImage(named:"11.png"),
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <IFRiseFilter>(
        listName:"filter",
        titleName:"High-Def",
        tag:19,
        image: UIImage(named:"12.png"),
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <IFWaldenFilter>(
        listName:"filter",
        titleName:"Pacific",
        tag:20,
        image: UIImage(named:"13.png"),
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <IFHefeFilter>(
        listName:"filter",
        titleName:"San Juan",
        tag:21,
        image: UIImage(named:"14.png"),
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    /*FilterOperation <GPUImageLookupFilter>(
        listName:"filter",
        titleName:"San Juan",
        tag:9,
        image: UIImage(named:"filterImage_san_juan"),
        lookUpImage: GPUImagePicture(image: UIImage(named:"san_juan_lookup.png")),
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageLookupFilter>(
        listName:"filter",
        titleName:"Gotham",
        tag:10,
        image: UIImage(named:"filterImage_gotham"),
        lookUpImage: GPUImagePicture(image: UIImage(named:"gotham_lookup.png")),
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageLookupFilter>(
        listName:"filter",
        titleName:"Hollywood",
        tag:11,
        image: UIImage(named:"filterImage_hollywood"),
        lookUpImage: GPUImagePicture(image: UIImage(named:"hollywood_lookup.png")),
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageLookupFilter>(
        listName:"filter",
        titleName:"Park Ave",
        tag:12,
        image: UIImage(named:"filterImage_park_ave"),
        lookUpImage: GPUImagePicture(image: UIImage(named:"park_Ave_lookup.png")),
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageLookupFilter>(
        listName:"filter",
        titleName:"Steampunk",
        tag:13,
        image: UIImage(named:"filterImage_steampunk"),
        lookUpImage: GPUImagePicture(image: UIImage(named:"steampunk_lookup.png")),
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageLookupFilter>(
        listName:"filter",
        titleName:"California",
        tag:14,
        image: UIImage(named:"filterImage_california"),
        lookUpImage: GPUImagePicture(image: UIImage(named:"california_lookup.png")),
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageLookupFilter>(
        listName:"filter",
        titleName:"Dreamstate",
        tag:15,
        image: UIImage(named:"filterImage_dreamstate"),
        lookUpImage: GPUImagePicture(image: UIImage(named:"dreamstate_lookup.png")),
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageLookupFilter>(
        listName:"filter",
        titleName:"High-Def",
        tag:16,
        image: UIImage(named:"filterImage_high_def"),
        lookUpImage: GPUImagePicture(image: UIImage(named:"high_def_lookup.png")),
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageLookupFilter>(
        listName:"filter",
        titleName:"Noir",
        tag:17,
        image: UIImage(named:"filterImage_noir"),
        lookUpImage: GPUImagePicture(image: UIImage(named:"noir_lookup.png")),
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageLookupFilter>(
        listName:"filter",
        titleName:"Nostalgia",
        tag:18,
        image: UIImage(named:"filterImage_nostalgia"),
        lookUpImage: GPUImagePicture(image: UIImage(named:"nostalgia_lookup.png")),
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageLookupFilter>(
        listName:"filter",
        titleName:"Pinhole",
        tag:19,
        image: UIImage(named:"filterImage_pinhole"),
        lookUpImage: GPUImagePicture(image: UIImage(named:"pinhole_lookup.png")),
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageFilter>(
        listName:"filter",
        titleName:"Reverse",
        tag:20,
        image: UIImage(named:"filterImage"),
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageFilter>(
        listName:"filter",
        titleName:"Slow-Mo",
        tag:21,
        image: UIImage(named:"filterImage"),
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageAmatorkaFilter>(
        listName:"filter",
        titleName:"Amatorka",
        tag:10,
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageMissEtikateFilter>(
        listName:"filter",
        titleName:"Etikate",
        tag:11,
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageSoftEleganceFilter>(
        listName:"filter",
        titleName:"Elegance",
        tag:12,
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageGrayscaleFilter>(
        listName:"filter",
        titleName:"Grayscale",
        tag:13,
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImagePrewittEdgeDetectionFilter>(
        listName:"filter",
        titleName:"Edge",
        tag:14,
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:1.0, initialValue:1.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.edgeStrength = sliderValue
        },
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImagePinchDistortionFilter>(
        listName:"filter",
        titleName:"Pinch",
        tag:15,
        sliderConfiguration:.enabled(minimumValue:-2.0, maximumValue:2.0, initialValue:2.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.scale = sliderValue
        },
        sliderLevelsCallback:nil,
        filterOperationType:.singleInput
    ),*/
    FilterOperation <GPUImageLevelsFilter>(
        listName:"levels",
        titleName:"Levels",
        tag:OTHERTAG,
        sliderConfiguration:.levels(min:0, gamma:0.5, max:1.0, minOut:0.0, maxOut:1.0),
        sliderUpdateCallback: nil,
        sliderLevelsCallback: {(filter, color, min, gamma, max, minOut, maxOut) in
            var newGamma = 1.0 - gamma + 0.5
            switch color {
            case 1:
                filter.setRedMin(min, gamma:newGamma, max:max, minOut:minOut, maxOut:maxOut)
            case 2:
                filter.setGreenMin(min, gamma:newGamma, max:max, minOut:minOut, maxOut:maxOut)
            case 3:
                filter.setBlueMin(min, gamma:newGamma, max:max, minOut:minOut, maxOut:maxOut)
            default:
                break
            }
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageLevelsFilter>(
        listName:"levels",
        titleName:"Levels",
        tag:RGBTAG,
        sliderConfiguration:.levels(min:0, gamma:0.5, max:1.0, minOut:0.0, maxOut:1.0),
        sliderUpdateCallback: nil,
        sliderLevelsCallback: {(filter, color, min, gamma, max, minOut, maxOut) in
            var newGamma = 1.0 - gamma + 0.5
            switch color {
            case 0:
                filter.setMin(min, gamma:newGamma, max:max, minOut:minOut, maxOut:maxOut)
            default:
                break
            }
        },
        filterOperationType:.singleInput
    )
]
