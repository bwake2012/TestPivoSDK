// ConnectedPivo.swift
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

class ConnectedPivo {

    typealias ConnectionCompletion = (Bool) -> Void

    private lazy var pivoSDK = PivoSDK.shared

    private(set) var id: String
    private(set) var name: String

    private var connection: ConnectionCompletion?

    private(set) var isConnecting = false
    private(set) var fullyConnected = false

    private(set) var batteryLevel: Int = 0
    private(set) var pivoVersion: String = ""

    init(id: String, name: String, connection: ConnectionCompletion?) {

        self.id = id
        self.name = name

        self.connection = connection

        pivoSDK.addDelegate(self)

        pivoSDK.connect(id: self.id)
    }

    deinit {

        pivoSDK.disconnect()
        pivoSDK.removeDelegate(self)
    }
}

extension ConnectedPivo: PivoConnectionDelegate {

    /// User denied the bluetooth permission
    func pivoConnectionBluetoothPermissionDenied() {

        debugLog("ConnectedPivo: Bluetooth Permission Denied!")
    }

    /// Pivo is connected to the app
    /// - Parameter id: Pivo's id
    func pivoConnection(didConnect id: String) {

        self.isConnecting = true
        self.fullyConnected = false
    }

    /// Pivo is disconnected
    /// - Parameter id: Pivo's id
    func pivoConnection(didDisconnect id: String) {

        self.fullyConnected = false
        self.isConnecting = false

        connection?(false)
    }

    /// Fail to connect to the Pivo
    /// - Parameter id: Pivo's id
    func pivoConnection(didFailToConnect id: String) {

        self.fullyConnected = false
        self.isConnecting = false

        connection?(false)
    }

    /// Finish establish the connection with Pivo, you can control the Pivo from now on
    /// - Parameter id: Pivo's id
    func pivoConnection(didEstablishSuccessfully id: String) {

        self.fullyConnected = true
        self.isConnecting = false

        pivoSDK.requestBatteryLevel()
        self.pivoVersion = pivoSDK.getPivoVersion()

        connection?(true)
    }

    /// Pivo battery level changed
    /// - Parameter batteryLevel: New battery level
    func pivoConnection(batteryLevel: Int) {

        self.batteryLevel = batteryLevel
    }
}

/// Commands
extension ConnectedPivo {

    func turnLeft(angle: Int, speed: Int) {

        pivoSDK.turnLeft(angle: angle, speed: speed)
    }

    func turnRight(angle: Int, speed: Int) {

        pivoSDK.turnRight(angle: angle, speed: speed)
    }

    func snapLeft(angle: Int) {

        pivoSDK.setFastestSpeed()

        pivoSDK.turnLeft(angle: angle)
    }

    func snapRight(angle: Int) {

        pivoSDK.setFastestSpeed()

        pivoSDK.turnRight(angle: angle)
    }

    func turnLeft(speed: Int) {

        pivoSDK.turnLeftContinuously(speed: speed)
    }

    func turnRight(speed: Int) {

        pivoSDK.turnRightContinuously(speed: speed)
    }

    func stop() {

        pivoSDK.stop()
    }
}
