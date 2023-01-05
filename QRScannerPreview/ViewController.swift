//
//  ViewController.swift
//  QRScannerPreview
//
//  Created by Javier Cueto on 04/01/23.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    private var button: UIButton = {
       let button = UIButton()
        button.setTitle("scanner qr", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        return button
    }()
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        super.viewDidLoad()
        view.addSubview(button)
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        button.addTarget(self, action: #selector(callQR), for: .touchUpInside)
    }
    
    
    @objc func callQR() {
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied, .restricted:
            let alert = UIAlertController(title: "Alert", message: "favor de dar permiso", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        case .authorized, .notDetermined:
            let scanner = QRScanner()
            let controller = QRScannerViewController(scanner: scanner, coordinator: self)
            scanner.delegate = controller
            present(controller, animated: true)
        @unknown default:
            print("desconocido")
        }

    }

}

extension ViewController: QRScannerViewControllerCoordinator {
    func didTappedCancelButton() {
        print("was cancel")
    }
    
    func didLectureWasCompleted(valueScanned: String?, errorMessage: String?) {
        if let errorMessage = errorMessage {
            print("error here", errorMessage)
            let alert = UIAlertController(title: "Alert", message: "errorMessage", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        guard let valueScanned = valueScanned else { return }
        print(valueScanned)
    }
}

