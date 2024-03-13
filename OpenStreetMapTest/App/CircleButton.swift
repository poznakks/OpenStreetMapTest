//
//  CircleButton.swift
//  OpenStreetMapTest
//
//  Created by Vlad Boguzh on 13.03.2024.
//

import UIKit

final class CircleButton: UIButton {

    private let image: UIImage

    init(image: UIImage) {
        self.image = image
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        setImage(image, for: .normal)
        layer.cornerRadius = Constants.cornerRadius
        translatesAutoresizingMaskIntoConstraints = false
    }
}

private enum Constants {
    static let cornerRadius: CGFloat = 60 / 2
}
