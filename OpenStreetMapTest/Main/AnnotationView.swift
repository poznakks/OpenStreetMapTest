//
//  AnnotationView.swift
//  OpenStreetMapTest
//
//  Created by Vlad Boguzh on 13.03.2024.
//

import UIKit
import MapboxMaps

final class AnnotationView: UIView {

    private let pointAnnotation: PointAnnotation
    private let info: PointAnnotationInfo?

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: Constants.nameAndLastSeenLabelsFontSize, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        return label
    }()

    private lazy var lastSeenLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: Constants.nameAndLastSeenLabelsFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        return label
    }()

    init(pointAnnotation: PointAnnotation) {
        self.pointAnnotation = pointAnnotation
        self.info = PointAnnotationInfo.fromJSONObject(pointAnnotation.customData)
        let frame = CGRect(x: 0, y: 0, width: Constants.viewWidth, height: Constants.viewHeight)
        super.init(frame: frame)
        setup()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .systemBackground
        layer.cornerRadius = Constants.viewCornerRadius
        layer.borderWidth = Constants.viewBorderWidth
        layer.borderColor = UIColor.black.cgColor
        nameLabel.text = info?.name ?? "No name"
        lastSeenLabel.text = info?.lastSeen
    }

    private func setupConstraints() {
        let stack = UIStackView(arrangedSubviews: [nameLabel, lastSeenLabel])
        stack.axis = .vertical
        stack.spacing = Constants.stackSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.stackInset),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.stackInset),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: Constants.stackInset),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.stackInset)
        ])
    }
}

private enum Constants {
    static let stackSpacing: CGFloat = 2
    static let stackInset: CGFloat = 6

    static let viewHeight: CGFloat = 60
    static let viewWidth: CGFloat = 120
    static let viewCornerRadius: CGFloat = 12
    static let viewBorderWidth: CGFloat = 1

    static let nameAndLastSeenLabelsFontSize: CGFloat = 12
}
