//
//  FillDataPopupViewController.swift
//  OpenStreetMapTest
//
//  Created by Vlad Boguzh on 13.03.2024.
//

import UIKit
import MapboxMaps

final class FillDataPopupViewController: UIViewController {

    var onDataFilled: ((PointAnnotationInfo) -> Void)?

    private lazy var fillDataLabel: UILabel = {
        let label = UILabel()
        label.text = "Fill data"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: Constants.fillDataLabelFontSize, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Name"
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = Constants.nameTextFieldCornerRadius
        textField.layer.masksToBounds = true
        textField.autocorrectionType = .no
        textField.textColor = .black
        textField.font = UIFont.systemFont(ofSize: Constants.nameTextFieldFontSize, weight: .medium)
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = Constants.nameTextFieldBorderWidth
        textField.backgroundColor = .systemBackground
        textField.addTarget(self, action: #selector(returnKeyAction), for: .editingDidEndOnExit)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupConstraints()
    }

    private func setupConstraints() {
        let stack: UIStackView = {
            let stack = UIStackView(arrangedSubviews: [fillDataLabel, nameTextField])
            stack.axis = .vertical
            stack.spacing = Constants.stackSpacing
            stack.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(stack)
            return stack
        }()

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Constants.stackLeadingTrailingInset
            ),
            stack.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Constants.stackLeadingTrailingInset
            ),
            stack.topAnchor.constraint(
                equalTo: view.topAnchor,
                constant: Constants.stackTopOffset
            ),
            nameTextField.heightAnchor.constraint(equalToConstant: Constants.nameTextFieldHeight)
        ])
    }

    @objc
    private func returnKeyAction() {
        let info = PointAnnotationInfo(
            name: nameTextField.text ?? "",
            lastSeen: PointAnnotationInfo.timestampToString(Date().timeIntervalSince1970)
        )
        onDataFilled?(info)
        dismiss(animated: true, completion: nil)
    }
}

private enum Constants {
    static let stackSpacing: CGFloat = 15
    static let stackLeadingTrailingInset: CGFloat = 30
    static let stackTopOffset: CGFloat = 20

    static let nameTextFieldHeight: CGFloat = 40
    static let nameTextFieldCornerRadius: CGFloat = 12
    static let nameTextFieldBorderWidth: CGFloat = 1
    static let nameTextFieldFontSize: CGFloat = 17

    static let fillDataLabelFontSize: CGFloat = 20
}
