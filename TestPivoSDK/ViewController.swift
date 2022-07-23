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

    var pivoHandler: PivoHandler?

    @IBOutlet var alertTitle: UILabel?
    @IBOutlet var alertMessage: UILabel?

    @IBOutlet var status: UILabel?

    override func viewDidLoad() {

        super.viewDidLoad()

        // Do any additional setup after loading the view.
        pivoHandler = PivoHandler(delegate: self)
    }
}

extension ViewController: PivoHandlerDelegate {

    func alert(title: String, message: String) {

        DispatchQueue.main.async {
            self.alertTitle?.text = title
            self.alertMessage?.text = message
        }
    }

    func updateStatus(status: String) {

        DispatchQueue.main.async {
            self.status?.text = status
        }
    }
}
