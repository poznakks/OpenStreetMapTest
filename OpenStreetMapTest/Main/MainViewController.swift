//
//  MainViewController.swift
//  OpenStreetMapTest
//
//  Created by Vlad Boguzh on 13.03.2024.
//

import UIKit
import MapboxMaps

final class MainViewController: UIViewController {
    
    // MARK: Properties
    private var cancellables: Set<AnyCancelable> = []

    private lazy var pointAnnotationManager = mapView.annotations.makePointAnnotationManager()

    // MARK: UI Elements
    private lazy var mapView = MapView(frame: view.bounds)

    private lazy var plusZoomButton: CircleButton = {
        let button = CircleButton(image: Asset.plusZoom.image)
        button.addTarget(self, action: #selector(didTapPlusZoom), for: .touchUpInside)
        return button
    }()

    private lazy var minusZoomButton: CircleButton = {
        let button = CircleButton(image: Asset.minusZoom.image)
        button.addTarget(self, action: #selector(didTapMinusZoom), for: .touchUpInside)
        return button
    }()

    private lazy var moveToCurrentLocationButton: CircleButton = {
        let button = CircleButton(image: Asset.moveToCurrentLocation.image)
        button.addTarget(self, action: #selector(didTapMoveToCurrentLocation), for: .touchUpInside)
        return button
    }()

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupConstraints()
    }

    // MARK: MapView setup
    private func setupMapView() {
        mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
            if let latestLocation = self?.mapView.location.latestLocation?.coordinate {
                let cameraOptions = CameraOptions(
                    center: latestLocation,
                    zoom: Constants.initialCameraZoom,
                    bearing: 0,
                    pitch: 0
                )
                self?.mapView.mapboxMap.setCamera(to: cameraOptions)
            }
        }.store(in: &cancellables)

        mapView.location.onLocationChange.observe { [weak self] locations in
            guard let latestLocation = locations.last?.coordinate else { return }
            self?.mapView.mapboxMap.setCamera(to: .init(center: latestLocation))
        }.store(in: &cancellables)

        mapView.gestures.onMapLongPress.observe { [weak self] context in
            self?.addMarker(at: context.coordinate)
        }.store(in: &cancellables)

        let config = Puck2DConfiguration(topImage: Asset.currentLocation.image, scale: .constant(0.2))
        mapView.location.options.puckType = .puck2D(config)
        mapView.location.options.puckBearingEnabled = true

        view.addSubview(mapView)
    }

    // MARK: Constraints
    private func setupConstraints() {
        let stack: UIStackView = {
            let stack = UIStackView(
                arrangedSubviews: [plusZoomButton, minusZoomButton, moveToCurrentLocationButton]
            )
            stack.axis = .vertical
            stack.spacing = Constants.buttonsSpacing
            stack.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(stack)
            return stack
        }()

        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: Constants.buttonsTrailingAnchor
            )
        ])
        constrainButtonsWidthHeight([plusZoomButton, minusZoomButton, moveToCurrentLocationButton])
    }

    // MARK: Actions
    @objc
    private func didTapMoveToCurrentLocation() {
        guard let latestLocation = mapView.location.latestLocation?.coordinate else {
            return
        }
        let cameraOptions = CameraOptions(center: latestLocation)
        mapView.camera.ease(
            to: cameraOptions,
            duration: Constants.moveToCurrentLocationAnimationDuration
        )
    }

    @objc
    private func didTapPlusZoom() {
        zoom(to: .plus)
    }

    @objc
    private func didTapMinusZoom() {
        zoom(to: .minus)
    }

    private func zoom(to direction: ZoomDirection) {
        let cameraState = mapView.mapboxMap.cameraState
        let zoomValue = direction == .plus ? cameraState.zoom + 1 : cameraState.zoom - 1
        let cameraOptions = CameraOptions(zoom: zoomValue)
        mapView.camera.ease(
            to: cameraOptions,
            duration: Constants.zoomAnimationDuration
        )
    }

    private func openPopup(for pointAnnotation: PointAnnotation) {
        let popupViewController = InfoPopupViewController(for: pointAnnotation)
        popupViewController.onRemove = { [weak self] _ in
            self?.pointAnnotationManager.annotations.removeAll(where: { $0.isSelected })
        }

        if let sheet = popupViewController.sheetPresentationController {
            sheet.detents = [.custom { _ in Constants.popupHeight }]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = Constants.popupCornerRadius
        }

        present(popupViewController, animated: true)
    }
}

// MARK: - Point Annotations
private extension MainViewController {
    func addMarker(at coordinate: CLLocationCoordinate2D) {
        let fillDataVC = FillDataPopupViewController()

        fillDataVC.onDataFilled = { [weak self] info in
            self?.createMarker(at: coordinate, with: info)
        }

        if let sheet = fillDataVC.sheetPresentationController {
            sheet.detents = [.custom { _ in Constants.popupHeight }]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = Constants.popupCornerRadius
        }

        present(fillDataVC, animated: true)
    }

    func createMarker(at coordinate: CLLocationCoordinate2D, with info: PointAnnotationInfo) {
        var pointAnnotation = PointAnnotation(coordinate: coordinate)
        pointAnnotation.setup(info: info) { [weak self] _ in
            self?.openPopup(for: pointAnnotation)
            return true
        }
        pointAnnotationManager.annotations.append(pointAnnotation)
        addViewAnnotation(to: pointAnnotation, at: coordinate)
    }

    func addViewAnnotation(
        to pointAnnotation: PointAnnotation,
        at coordinate: CLLocationCoordinate2D
    ) {
        let view = AnnotationView(pointAnnotation: pointAnnotation)
        let annotation = ViewAnnotation(
            annotatedFeature: .layerFeature(
                layerId: pointAnnotationManager.layerId,
                featureId: pointAnnotation.id
            ),
            view: view
        )
        annotation.variableAnchors = [
            ViewAnnotationAnchorConfig(
                anchor: .topLeft,
                offsetX: Constants.viewAnnotationOffset.0,
                offsetY: Constants.viewAnnotationOffset.1
            )
        ]
        mapView.viewAnnotations.add(annotation)
    }
}

// MARK: - Constrain Buttons Width Height
private extension MainViewController {
    func constrainButtonsWidthHeight(_ buttons: [UIView]) {
        buttons.forEach { button in
            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalToConstant: Constants.buttonsWidthHeight),
                button.widthAnchor.constraint(equalToConstant: Constants.buttonsWidthHeight)
            ])
        }
    }
}

// MARK: - ZoomDirection
private enum ZoomDirection {
    case plus
    case minus
}

// MARK: - Constants
private enum Constants {
    static let buttonsTrailingAnchor: CGFloat = -15
    static let buttonsSpacing: CGFloat = 15
    static let buttonsWidthHeight: CGFloat = 60

    static let moveToCurrentLocationAnimationDuration: TimeInterval = 1
    static let zoomAnimationDuration: TimeInterval = 0.3

    static let popupHeight: CGFloat = 120
    static let popupCornerRadius: CGFloat = 20

    static let initialCameraZoom: CGFloat = 12
    static let viewAnnotationOffset: (CGFloat, CGFloat) = (7, -5)
}
