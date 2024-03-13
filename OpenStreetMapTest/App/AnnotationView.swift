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
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        return label
    }()

    private lazy var lastSeenLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        return label
    }()

    init(pointAnnotation: PointAnnotation) {
        self.pointAnnotation = pointAnnotation
        self.info = PointAnnotationInfo.fromJSONObject(pointAnnotation.customData)
        let frame = CGRect(x: 0, y: 0, width: 120, height: 60)
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
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
        nameLabel.text = info?.name ?? "No name"
        lastSeenLabel.text = info?.lastSeen
    }

    private func setupConstraints() {
        let stack = UIStackView(arrangedSubviews: [nameLabel, lastSeenLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6)
        ])
    }
}
