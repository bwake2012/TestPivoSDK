// ViewController.swift
//
// Created by Bob Wakefield on 7/22/22.
// for TestPivoSDK
//
// Using Swift 5.0
// Running on macOS 12.4
//
// 
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var controlStack: UIStackView?
    @IBOutlet var infoStack: UIStackView?

    var connectedPivo: ConnectedPivo? {

        didSet {

            self.controlStack?.isHidden = nil == self.connectedPivo
            self.infoStack?.isHidden = nil == self.connectedPivo

            self.pivoName?.text = connectedPivo?.name
            self.pivoID?.text = connectedPivo?.id

            self.pivoVersion?.text = connectedPivo?.pivoVersion
            self.pivoBatteryLevel?.text = "\(connectedPivo?.batteryLevel ?? 0)"
        }
    }

    lazy var pivoHandler: PivoHandler? = PivoHandler.shared

    var speed: Int = 10

    @IBOutlet var alertTitle: UILabel?
    @IBOutlet var alertMessage: UILabel?

    @IBOutlet var pivoName: UILabel?
    @IBOutlet var pivoID: UILabel?
    @IBOutlet var pivoVersion: UILabel?
    @IBOutlet var pivoBatteryLevel: UILabel?

    @IBOutlet var status: UILabel?

    @IBAction func touchUpTurnLeft45(_ sender: Any) {

        connectedPivo?.turnLeft(angle: 45, speed: self.speed)
    }

    @IBAction func touchUpTurnRight45(_ sender: Any) {

        connectedPivo?.turnRight(angle: 45, speed: self.speed)
    }

    @IBAction func touchUpSnapLeft45(_ sender: Any) {

        connectedPivo?.snapLeft(angle: 45)
    }

    @IBAction func touchUpSnapRight45(_ sender: Any) {

        connectedPivo?.snapRight(angle: 45)
    }

    @IBAction func touchDownTurnLeft(_ sender: Any) {

        connectedPivo?.turnLeft(speed: self.speed)
    }

    @IBAction func touchUpTurnLeft(_ sender: Any) {

        connectedPivo?.stop()
    }

    @IBAction func touchDownTurnRight(_ sender: Any) {

        connectedPivo?.turnRight(speed: self.speed)
    }

    @IBAction func touchUpTurnRight(_ sender: Any) {

        connectedPivo?.stop()
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        // Do any additional setup after loading the view.
        controlStack?.isHidden = true
        infoStack?.isHidden = true

        pivoHandler?.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)
    }
}

extension ViewController: PivoHandlerDelegate {

    func alert(title: String, message: String) {

        DispatchQueue.main.async {
            self.alertTitle?.text = title
            self.alertMessage?.text = message

            debugLog("\(title) \(message)")
        }
    }

    func updateStatus(status: String) {

        DispatchQueue.main.async {
            self.status?.text = status
        }
    }
}
