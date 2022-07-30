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

    var connectedPivo: ConnectedPivo? { set get }

    func alert(title: String, message: String)
    func updateStatus(status: String)
}

class PivoHandler {

    static var shared: PivoHandler = PivoHandler()

    private lazy var pivoSDK = PivoSDK.shared

    var delegate: PivoHandlerDelegate?

    private var isScanning: Bool { nil != self.pivoScanner }
    private var isConnecting: Bool { self.connectedPivo?.isConnecting ?? false }

    private var pivoScanner: PivoScanner?
    private var connectedPivo: ConnectedPivo?

    private var foundRotators: Rotators = [:]

    private var rotators: Rotators = [:]

    private init() {

        guard let licenseFileURL = Bundle.main.url(forResource: "licenseKey", withExtension: "json")
        else {
            presentAlert(title: "Failed", message: "Missing licence key file.")
            return
        }

        delegate?.updateStatus(status: "Licence Key File Found")

        do {
            try pivoSDK.unlockWithLicenseKey(licenseKeyFileURL: licenseFileURL)
        }
        catch {
            presentAlert(title: "Failed", message: "Error unlocking Pivo license key: \(error.localizedDescription)")
            return
        }

        pivoSDK.addDelegate(self)

        delegate?.updateStatus(status: "SDK Unlocked!")

        self.pivoScanner = PivoScanner(scanTime: 5.0) { [weak self] rotators in

            guard let self = self else { return }

            guard let rotators = rotators else {

                self.delegate?.updateStatus(status: "Error scanning for rotators.")
                return
            }

            self.handleAfterScanning(rotators: rotators)

            self.pivoScanner = nil
        }
    }

    deinit {

        self.pivoScanner = nil
        self.connectedPivo = nil

        pivoSDK.removeDelegate(self)
    }
}

extension PivoHandler {

    private func handleAfterScanning(rotators: Rotators) {

        //MARK: + If 1 device is availabel => connect
        //      + Multiple devices ask user for selecting
        if rotators.count == 0 {
            delegate?.updateStatus(status: "Could not find any rotators")
        } else if rotators.count == 1 {

            let rotatorId = rotators.first!.key
            let rotatorName = rotators[rotatorId] ?? "*UNKNOWN ROTATOR*"
            self.connectedPivo = ConnectedPivo(id: rotatorId, name: rotatorName) { [weak self] success in

                guard let self = self else { return }

                guard success else {

                    self.delegate?.updateStatus(status: "Error connecting to Pivo!")
                    self.connectedPivo = nil
                    return
                }

                self.delegate?.connectedPivo = self.connectedPivo
            }

        } else {
            delegate?.updateStatus(status: "Multiple rotators detected")
        }

        self.foundRotators = rotators
    }

    func updateView() {

    }
}

/// Required PivoConnectionDelegate function
extension PivoHandler: PivoConnectionDelegate {

    /// User denied the bluetooth permission
    func pivoConnectionBluetoothPermissionDenied() {

        delegate?.alert(title: "PivoSDK\nPivoConnectionDelegate", message: "Bluetooth Permission Denied!")
    }
}

extension PivoHandler {

    func presentAlert(title: String, message: String) {

        delegate?.alert(title: title, message: message)
    }
}

/// Optional PivoConnectionDelegate functions
extension PivoHandler {

    /// A Pivo is discovered during scaning process
    /// - Parameters:
    ///   - id: id of the Pivo, can be used to differentiate between Pivo and to connect to it later
    ///   - deviceName: Pivo's name
    func pivoConnection(didDiscover id: String, deviceName: String) {

        delegate?.alert(title: "PivoSDK\nPivoConnectionDelegate", message: "Pivo id: \(id) name: \(deviceName) discovered")
        rotators[id] = deviceName
    }

    /// Pivo is connected to the app
    /// - Parameter id: Pivo's id
    func pivoConnection(didConnect id: String) {

        delegate?.alert(title: "PivoSDK\nPivoConnectionDelegate", message: "Pivo id: \(id) name: \(rotators[id] ?? "*UNKNOWN*") connected.")
    }

    /// Pivo is disconnected
    /// - Parameter id: Pivo's id
    func pivoConnection(didDisconnect id: String) {

        delegate?.alert(title: "PivoSDK\nPivoConnectionDelegate", message: "Pivo id: \(id) name: \(rotators[id] ?? "*UNKNOWN*") disconnected.")
    }

    /// Fail to connect to the Pivo
    /// - Parameter id: Pivo's id
    func pivoConnection(didFailToConnect id: String) {

        delegate?.alert(title: "PivoSDK\nPivoConnectionDelegate", message: "Pivo id: \(id) name: \(rotators[id] ?? "*UNKNOWN*") failed to connect.")
    }

    /// Finish establish the connection with Pivo, you can control the Pivo from now on
    /// - Parameter id: Pivo's id
    func pivoConnection(didEstablishSuccessfully id: String) {

        delegate?.alert(title: "PivoSDK\nPivoConnectionDelegate", message: "Pivo id: \(id) name: \(rotators[id] ?? "*UNKNOWN*") connection fully established.")
    }

    /// Pivo stop rotating after execute a command from the app or user press Stop button
    func pivoConnectionDidRotate() {

        delegate?.alert(title: "PivoSDK\nPivoConnectionDelegate", message: "Pivo stop rotating after execute a command from the app or user press Stop button")
    }

    func pivoConnectionDidRotate1DegreeLeft() {

        delegate?.alert(title: "PivoSDK\nPivoConnectionDelegate", message: "Connected Pivo did rotate 1 Degree Left")
    }

    func pivoConnectionDidRotate1DegreeRight() {

        delegate?.alert(title: "PivoSDK\nPivoConnectionDelegate", message: "Connected Pivo did rotate 1 Degree Right")
    }

    /// Pivo battery level changed
    /// - Parameter batteryLevel: New battery level
    func pivoConnection(batteryLevel: Int) {

        delegate?.alert(title: "PivoSDK\nPivoConnectionDelegate", message: "Pivo battery level: \(batteryLevel)")
    }

    /// When user press remote control buttons, Pivo forwards button that presses back to the app
    /// - Parameter command: command from remote control
    func pivoConnection(remoteControlerCommandReceived command: PivoBasicSDK.PivoEvent) {

        delegate?.alert(title: "PivoSDK\nPivoConnectionDelegate", message: "Pivo remote controller command: \(command.description)")
    }

    /// Call whenever bluetooth status changed
    /// - Parameter bluetoothIsOn: on or off
    func pivoConnection(bluetoothIsOn: Bool) {

        delegate?.alert(title: "PivoSDK\nPivoConnectionDelegate", message: "Pivo SDK Bluetooth status: \(bluetoothIsOn ? "On" : "Off")")
    }

    /// Notify when by pass remote controller on
    func pivoConnectionByPassRemoteControllerOn() {

        delegate?.alert(title: "PivoSDK\nPivoConnectionDelegate", message: "Pivo SDK Bypass Remote Controller On")
    }

    /// Notify when by pass remote controller off
    func pivoConnectionByPassRemoteControllerOff() {

        delegate?.alert(title: "PivoSDK\nPivoConnectionDelegate", message: "Pivo SDK Bypass Remote Controller Off")
    }
}

