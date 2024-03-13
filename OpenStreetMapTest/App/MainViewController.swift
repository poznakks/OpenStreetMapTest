//
//  MainViewController.swift
//  OpenStreetMapTest
//
//  Created by Vlad Boguzh on 13.03.2024.
//

import UIKit
import MapboxMaps

final class MainViewController: UIViewController {

    private var cancellables: Set<AnyCancelable> = []

    private lazy var pointAnnotationManager = mapView.annotations.makePointAnnotationManager()

    private lazy var mapView = MapView(frame: view.bounds)

    private lazy var plusZoomButton: CircleButton = {
        let button = CircleButton(image: Asset.plusZoom.image)
        button.addTarget(self, action: #selector(didTapPlusZoom), for: .touchUpInside)
        view.addSubview(button)
        return button
    }()

    private lazy var minusZoomButton: CircleButton = {
        let button = CircleButton(image: Asset.minusZoom.image)
        button.addTarget(self, action: #selector(didTapMinusZoom), for: .touchUpInside)
        view.addSubview(button)
        return button
    }()

    private lazy var moveToCurrentLocationButton: CircleButton = {
        let button = CircleButton(image: Asset.moveToCurrentLocation.image)
        button.addTarget(self, action: #selector(didTapMoveToCurrentLocation), for: .touchUpInside)
        view.addSubview(button)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupConstraints()
    }

    private func setupMapView() {
        mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
            if let latestLocation = self?.mapView.location.latestLocation?.coordinate {
                let cameraOptions = CameraOptions(center: latestLocation, zoom: 12, bearing: 0, pitch: 0)
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

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            moveToCurrentLocationButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            moveToCurrentLocationButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20
            ),
            moveToCurrentLocationButton.heightAnchor.constraint(equalToConstant: 60),
            moveToCurrentLocationButton.widthAnchor.constraint(equalToConstant: 60),

            minusZoomButton.bottomAnchor.constraint(equalTo: moveToCurrentLocationButton.topAnchor, constant: -15),
            minusZoomButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20
            ),
            minusZoomButton.heightAnchor.constraint(equalToConstant: 60),
            minusZoomButton.widthAnchor.constraint(equalToConstant: 60),

            plusZoomButton.bottomAnchor.constraint(equalTo: minusZoomButton.topAnchor, constant: -15),
            plusZoomButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20
            ),
            plusZoomButton.heightAnchor.constraint(equalToConstant: 60),
            plusZoomButton.widthAnchor.constraint(equalToConstant: 60)
        ])
    }

    @objc
    private func didTapMoveToCurrentLocation() {
        guard let latestLocation = mapView.location.latestLocation?.coordinate else {
            return
        }
        let cameraOptions = CameraOptions(center: latestLocation)
        mapView.camera.ease(to: cameraOptions, duration: 1)
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
        mapView.camera.ease(to: cameraOptions, duration: 0.3)
    }

    private func openPopup(for pointAnnotation: PointAnnotation) {
        let popupViewController = InfoPopupViewController(for: pointAnnotation)
        popupViewController.onRemove = { [weak self] _ in
            self?.pointAnnotationManager.annotations.removeAll(where: { $0.isSelected })
        }

        if let sheet = popupViewController.sheetPresentationController {
            sheet.detents = [.custom { _ in 120 }]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }

        present(popupViewController, animated: true)
    }
}

// MARK: Point Annotations
private extension MainViewController {
    func addMarker(at coordinate: CLLocationCoordinate2D) {
        let fillDataVC = FillDataPopupViewController()

        fillDataVC.onDataFilled = { [weak self] info in
            self?.createMarker(at: coordinate, with: info)
        }

        if let sheet = fillDataVC.sheetPresentationController {
            sheet.detents = [.custom { _ in 120 }]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
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
            ViewAnnotationAnchorConfig(anchor: .topLeft, offsetX: 7, offsetY: -5)
        ]
        mapView.viewAnnotations.add(annotation)
    }
}

private enum ZoomDirection {
    case plus
    case minus
}
