// PivoScanner.swift
//
// Created by Bob Wakefield on 7/30/22.
// for TestPivoSDK
//
// Using Swift 5.0
// Running on macOS 12.5
//
// 
//

import Foundation
import PivoBasicSDK

typealias Rotators = [String: String]
typealias ScanCompletion = (Rotators?) -> Void

class PivoScanner {

    private lazy var pivoSDK = PivoSDK.shared

    private var completion: ScanCompletion?

    private var rotators: Rotators = [:]

    init(scanTime seconds: TimeInterval, completion: ScanCompletion?) {

        self.completion = completion

        pivoSDK.addDelegate(self)

        let scanningDelay: DispatchTime = .now() + 2

        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: scanningDelay) {

            DispatchQueue.main.async {
                self.beginScanning(scanDuration: seconds)
            }
        }
    }

    deinit {

        pivoSDK.stopScan()
        pivoSDK.removeDelegate(self)

        completion?(nil)
    }

    func beginScanning(scanDuration: TimeInterval) {

        self.rotators.removeAll()

        do {
            try pivoSDK.scan()
        }
        catch (let error as PivoError) {
            print(error.localizedDescription)

            switch error {
            case .licenseNotProvided:
                 debugLog("Failed: " + "License not provided")
            case .invalidLicenseKey:
                debugLog("Failed: " + "Invalid license key")
            case .expiredLicenseKey:
                debugLog("Failed: " + "License is expired")
            case .bluetoothOff:
                debugLog("Failed: " + "Bluetooth is off, please turn it on")
            case .cannotReadLicenseKeyFile:
                debugLog("Failed: " + "Can't read license key")
            case .bluetoothPermissionNotAllowed:
                debugLog("Failed: " + "Bluetooth permission is not allowed")
            case .trackingModeNotSupported:
                debugLog("Failed: " + "Tracking mode is not supported")
            case .feedbackNotSupported:
                debugLog("Failed: " + "Feedback not supported")
            case .pivoNotConnected:
                debugLog("Failed: " + "Pivo not connected")
            @unknown default:
                break
            }

            completion?(nil)

            return
        }
        catch {
            return
        }

        let scanningPeriod : DispatchTime = .now() + scanDuration

        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: scanningPeriod) {
            DispatchQueue.main.async { () in
                self.endScanning()
            }
        }
    }

    private func endScanning() {

        pivoSDK.stopScan()

        completion?(self.rotators)
    }
}

extension PivoScanner: PivoConnectionDelegate {

    func pivoConnectionBluetoothPermissionDenied() {

        completion?(nil)
    }

    /// A Pivo is discovered during scaning process
    /// - Parameters:
    ///   - id: id of the Pivo, can be used to differentiate between Pivo and to connect to it later
    ///   - deviceName: Pivo's name
    func pivoConnection(didDiscover id: String, deviceName: String) {

        rotators[id] = deviceName

        endScanning()
    }
}
