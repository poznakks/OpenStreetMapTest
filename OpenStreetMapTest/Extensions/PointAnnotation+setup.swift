//
//  PointAnnotation+setup.swift
//  OpenStreetMapTest
//
//  Created by Vlad Boguzh on 13.03.2024.
//

import MapboxMaps

extension PointAnnotation {
    mutating func setup(
        info: PointAnnotationInfo,
        tapHandler: ((MapContentGestureContext) -> Bool)? = nil
    ) {
        self.image = .init(image: Asset.pointAnnotation.image, name: "pointAnnotation")
        self.iconSize = 0.15
        self.iconOffset = [0, -50]
        self.customData = info.toJSONObject()
        self.tapHandler = tapHandler
    }
}
