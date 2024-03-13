//
//  InfoPopupViewController.swift
//  OpenStreetMapTest
//
//  Created by Vlad Boguzh on 13.03.2024.
//

import UIKit
import MapboxMaps

final class InfoPopupViewController: UIViewController {

    var onRemove: ((PointAnnotation) -> Void)?

    private let pointAnnotation: PointAnnotation
    private let info: PointAnnotationInfo?

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        return label
    }()

    private lazy var lastSeenLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        return label
    }()

    private lazy var removeButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = Constants.removeButtonLabel
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .systemBlue
        config.cornerStyle = .capsule
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(didTapRemove), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        return button
    }()

    init(for pointAnnotation: PointAnnotation) {
        self.pointAnnotation = pointAnnotation
        self.info = PointAnnotationInfo.fromJSONObject(pointAnnotation.customData)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        nameLabel.text = "Name: \(info?.name ?? "")"
        lastSeenLabel.text = "Last seen: \(info?.lastSeen ?? "")"

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.topAnchor.constraint(
                equalTo: view.topAnchor,
                constant: Constants.nameLabelToTopOffset
            ),

            lastSeenLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lastSeenLabel.topAnchor.constraint(
                equalTo: nameLabel.bottomAnchor,
                constant: Constants.lastSeenLabelToNameLabelOffset
            ),

            removeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            removeButton.topAnchor.constraint(
                equalTo: lastSeenLabel.bottomAnchor,
                constant: Constants.removeButtonToLastSeenLabelOffset
            ),
            removeButton.heightAnchor.constraint(
                equalToConstant: Constants.removeButtonHeight
            ),
            removeButton.widthAnchor.constraint(
                equalToConstant: Constants.removeButtonWidth
            )
        ])
    }

    @objc
    private func didTapRemove() {
        onRemove?(pointAnnotation)
        dismiss(animated: true, completion: nil)
    }
}

private enum Constants {
    static let nameLabelToTopOffset: CGFloat = 20
    static let lastSeenLabelToNameLabelOffset: CGFloat = 10
    static let removeButtonToLastSeenLabelOffset: CGFloat = 20
    static let removeButtonHeight: CGFloat = 40
    static let removeButtonWidth: CGFloat = 300

    static let removeButtonLabel: String = "Remove"
}
