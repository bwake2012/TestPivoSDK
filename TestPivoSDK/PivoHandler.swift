// PivoHandler.swift
//
// Created by Bob Wakefield on 7/23/22.
// for TestPivoSDK
//
// Using Swift 5.0
// Running on macOS 12.4
//
// 
//

import UIKit
import PivoBasicSDK

protocol PivoHandlerDelegate {

    func alert(title: String, message: String)
    func updateStatus(status: String)
}

class PivoHandler {

    private lazy var pivoSDK = PivoSDK.shared

    private var delegate: PivoHandlerDelegate?

    private var isScanning = false
    private var isConnecting = false
    private var rotators = [String: String]()

    init(delegate: PivoHandlerDelegate) {

        self.delegate = delegate

        guard let licenseFileURL = Bundle.main.url(forResource: "licenseKey", withExtension: "json")
        else {
            presentAlert(title: "Failed", message: "Missing licence key file.")
            return
        }

        delegate.updateStatus(status: "Licence Key File Found")

        do {
            try pivoSDK.unlockWithLicenseKey(licenseKeyFileURL: licenseFileURL)
        }
        catch {
            presentAlert(title: "Failed", message: "Error unlocking Pivo license key: \(error.localizedDescription)")
            return
        }

        delegate.updateStatus(status: "SDK Unlocked!")

        startScanning()
    }

    deinit {

        pivoSDK.stopScan()
        pivoSDK.removeDelegate(self)
    }

    private func startScanning() {
        
        let scanningPeriod : DispatchTime = .now() + 5
        
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: scanningPeriod) {
            
            DispatchQueue.main.async {
                self.scanBluetoothDevice()
            }
        }
    }

    private func stopScanning() {

        stopScan()
    }
}

extension PivoHandler {

    func scanBluetoothDevice() {

        guard !isScanning else {
            stopScan()
            return
        }

        isConnecting = false
        self.rotators.removeAll()

        updateView()
        do {
            try pivoSDK.scan()
        }
        catch (let error as PivoError) {
            switch error {
            case .licenseNotProvided:
                delegate?.updateStatus(status: "licenseNotProvided")
                presentAlert(title: "Failed", message: "License not provided")
            case .invalidLicenseKey:
                delegate?.updateStatus(status: "invalidLicenseKey")
                presentAlert(title: "Failed", message: "Invalid license key")
            case .expiredLicenseKey:
                delegate?.updateStatus(status: "expiredLicenseKey")
                presentAlert(title: "Failed", message: "License is expired")
            case .bluetoothOff:
                delegate?.updateStatus(status: "bluetoothOff")
                presentAlert(title: "Failed", message: "Bluetooth is off, please turn it on")
            case .cannotReadLicenseKeyFile:
                presentAlert(title: "Failed", message: "Can't read license key")
            case .bluetoothPermissionNotAllowed:
                presentAlert(title: "Failed", message: "Bluetooth permission is not allowed")
            case .trackingModeNotSupported:
                presentAlert(title: "Failed", message: "Tracking mode is not supported")
            case .feedbackNotSupported:
                presentAlert(title: "Failed", message: "Feedback not supported")
            case .pivoNotConnected:
                presentAlert(title: "Failed", message: "Pivo not connected")
            @unknown default:
                break
            }
            return
        }
        catch {
            return
        }

        isScanning = true

        delegate?.updateStatus(status: "Scanning...")

        let scanningPeriod : DispatchTime = .now() + 5

        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: scanningPeriod) {
            DispatchQueue.main.async { () in
                if self.isScanning {
                    self.stopScan()
                }
            }
        }
    }

    private func stopScan() {
        pivoSDK.stopScan()
        isScanning = false

        handleAfterScanning()
    }

    private func handleAfterScanning() {
        //MARK: + If 1 device is availabel => connect
        //      + Multiple devices ask user for selecting
        if self.rotators.count == 0 {
            delegate?.updateStatus(status: "Could not find any rotators")
        } else if self.rotators.count == 1 {

            let rotatorId = self.rotators.first!.key
            delegate?.updateStatus(status: "Please connect to rotator")
            self.isConnecting = true
            self.pivoSDK.connect(id: rotatorId)
        } else {
            delegate?.updateStatus(status: "Several rotators detected")
        }
    }

    func updateView() {

    }
}

extension PivoHandler: PivoConnectionDelegate {

    func pivoConnectionBluetoothPermissionDenied() {

        delegate?.updateStatus(status: "Bluetooth permission denied!")
    }
}

extension PivoHandler {

    func presentAlert(title: String, message: String) {

        delegate?.alert(title: title, message: message)
    }
}
