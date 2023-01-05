//
//  QRScanner.swift
//  QRScannerPreview
//
//  Created by Javier Cueto on 04/01/23.
//

import UIKit
import AVFoundation

protocol QRScannerDelegate: AnyObject {
    func didScannerCompleted(valueScanned: String?, errorMessage: String?)
}

final class QRScanner: NSObject {
    private var captureSession: AVCaptureSession?
    private var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var metadataOutput: AVCaptureMetadataOutput?
     var messageError: String?
    weak var delegate: QRScannerDelegate?
    
    func config() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied, .restricted:
            messageError = "Se requiere permisos de la camara"
            
        case .authorized, .notDetermined:
        
            checkCameraPermission()
        @unknown default:
            messageError = "Error desconocido para el permiso de camara"
        }

        
        
    }
    
    private func checkCameraPermission() {
        configWithPermissions()

    }
    
    private func configWithPermissions() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            messageError = "Device not supported"
            return
        }
        
        let captureDeviceInput: AVCaptureDeviceInput
        do {
            captureDeviceInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            messageError = "Error capturing device"
            return
        }
        
        if (captureSession.canAddInput(captureDeviceInput)) {
            captureSession.addInput(captureDeviceInput)
        } else {
            messageError = "Imposible to capture in the device"
            return
        }
        
        metadataOutput = AVCaptureMetadataOutput()
        guard let metadataOutput = metadataOutput else { return }
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
            
        } else {
            messageError = "Imposible to capture in the device"
            return
        }
        captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    }
    
    func setFrame(view: UIView) {
        guard let captureSession = captureSession else { return }
        guard let captureVideoPreviewLayer = captureVideoPreviewLayer else { return }
        captureVideoPreviewLayer.frame = view.layer.bounds
        captureVideoPreviewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(captureVideoPreviewLayer)
        DispatchQueue.global().async {
            captureSession.startRunning()
        }
        
        
        
    }
    
    func setSpecificAreaToReadQR(frame: CGRect) {
        guard let metadataOutput = metadataOutput else { return }
        guard let captureVideoPreviewLayer = captureVideoPreviewLayer else { return }
        metadataOutput.rectOfInterest = captureVideoPreviewLayer.metadataOutputRectConverted(fromLayerRect: frame)
    }
    
    func viewDidDisappear() {
        guard let captureSession = captureSession else { return }
        if (captureSession.isRunning) {
            captureSession.stopRunning()
        }
    }
}

extension QRScanner : AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession?.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            delegate?.didScannerCompleted(valueScanned: stringValue, errorMessage: nil)
        }else {
            delegate?.didScannerCompleted(valueScanned: nil, errorMessage: "No qr detected")
        }
        
    }
}



