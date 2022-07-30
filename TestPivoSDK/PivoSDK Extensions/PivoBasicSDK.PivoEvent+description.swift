// PivoBasicSDK.PivoEvent+description.swift
//
// Created by Bob Wakefield on 7/30/22.
//
// Using Swift 5.0

import PivoBasicSDK

extension PivoBasicSDK.PivoEvent {

    var description: String {

        switch self {

        case .MODE:
            return "MODE"
        case .CAMERA:
            return "CAMERA"
        case .STOP:
            return "STOP"
        case .OFF:
            return "OFF"
        case .CONNECTION_COMPLETED:
            return "CONNECTION_COMPLETED"
        case .NAME_CHANGED:
            return "NAME_CHANGED"
        case .VERSION:
            return "VERSION"
        case .BATTERY_CHANGED(batteryLevel: let batteryLevel):
            return "BATTERY_CHANGED batteryLevel: \(batteryLevel)"
        case .LEFT_PRESSED:
            return "LEFT_PRESSED"
        case .LEFT_RELEASED:
            return "LEFT_RELEASED"
        case .RIGHT_PRESSED:
            return "RIGHT_PRESSED"
        case .RIGHT_RELEASED:
            return "RIGHT_RELEASED"
        case .LEFT_CONTINOUS_PRESSED:
            return "LEFT_CONTINOUS_PRESSED"
        case .RIGHT_CONTINOUS_PRESSED:
            return "RIGHT_CONTINOUS_PRESSED"
        case .SPEEDUP_PRESSED(secondsPerRound: let secondsPerRound):
            return "SPEEDUP_PRESSED secondsPerRound: \(secondsPerRound)"
        case .SPEEDUP_RELEASED(secondsPerRound: let secondsPerRound):
            return "SPEEDUP_RELEASED secondsPerRound: \(secondsPerRound)"
        case .SPEEDDOWN_PRESSED(secondsPerRound: let secondsPerRound):
            return "SPEEDDOWN_PRESSED secondsPerRound: \(secondsPerRound)"
        case .SPEEDDOWN_RELEASED(secondsPerRound: let secondsPerRound):
            return "SPEEDDOWN_RELEASED secondsPerRound: \(secondsPerRound)"
        case .SPEED(secondsPerRound: let secondsPerRound):
            return "SPEED secondsPerRound: \(secondsPerRound)"
        case .ROTATED(direction: let direction, angle: let angle):
            return "ROTATED direction: \(direction), angle: \(angle)"
        case .ROTATED_1DEGREE_LEFT:
            return "ROTATED_1DEGREE_LEFT"
        case .ROTATED_1DEGREE_RIGHT:
            return "ROTATED_1DEGREE_RIGHT"
        case .BYPASS_RC_ON:
            return "BYPASS_RC_ON"
        case .BYPASS_RC_OFF:
            return "BYPASS_RC_OFF"
        @unknown default:
            return "@unknown default"
        }
    }
}
