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
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Name"
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 12
        textField.layer.masksToBounds = true
        textField.autocorrectionType = .no
        textField.textColor = .black
        textField.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 1
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
        let stack = UIStackView(arrangedSubviews: [fillDataLabel, nameTextField])
        stack.axis = .vertical
        stack.spacing = 15
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            nameTextField.heightAnchor.constraint(equalToConstant: 40)
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
