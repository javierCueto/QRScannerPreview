//
//  QRScannerViewController.swift
//  QRScannerPreview
//
//  Created by Javier Cueto on 04/01/23.
//

import UIKit

protocol QRScannerViewControllerCoordinator: AnyObject {
    func didTappedCancelButton()
    func didLectureWasCompleted(valueScanned: String?, errorMessage: String?)
}

final class QRScannerViewController: UIViewController {
    // MARK: - Public properties
    
    
    // MARK: - Private properties
    private let heightView =  UIScreen.main.bounds.height
    
    private let borderImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "placeCard")
        return imageView
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Cancelar", for: .normal)
        button.setTitleColor(.white, for: .normal)
      return button
    }()
    
    private let bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white.withAlphaComponent(0.7)
        return view
    }()
    
    private var scanner: QRScanner
    
    private weak var coordinator: QRScannerViewControllerCoordinator?
    
    // MARK: - Life Cycle
    
    init(scanner: QRScanner, coordinator: QRScannerViewControllerCoordinator) {
        self.scanner = scanner
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
        isModalInPresentation = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configScanner()
    }
    
    // MARK: - Helpers
    private func configUI() {
        
    }
    
    private func configScanner() {
        view.backgroundColor = .black
        scanner.config()
        scanner.setFrame(view: view)
        view.addSubview(borderImageView)
        borderImageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        borderImageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        borderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        borderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        let thirdPartHeighView =  heightView/3
        borderImageView.heightAnchor.constraint(equalToConstant: thirdPartHeighView).isActive = true
        
        view.addSubview(cancelButton)
        cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -((thirdPartHeighView/3)-9)).isActive = true
        
        cancelButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        
        view.addSubview(bottomView)
        bottomView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        bottomView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bottomView.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        scanner.viewDidDisappear()
        print("was clossed")
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scanner.setSpecificAreaToReadQR(frame: borderImageView.frame)
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    // MARK: - Actions
 
    @objc
    private func cancelButtonAction() {
        dismiss(animated: true)
        coordinator?.didTappedCancelButton()
    }
}

// MARK: - Extensions here

extension QRScannerViewController: QRScannerDelegate {
    func didScannerCompleted(valueScanned: String?, errorMessage: String?) {
        dismiss(animated: true)
        coordinator?.didLectureWasCompleted(valueScanned: valueScanned, errorMessage: errorMessage)
    }
    

}
