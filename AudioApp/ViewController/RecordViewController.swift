//
//  RecordViewController.swift
//  Audio App
//
//  Created by Alexander Römer on 16.11.19.
//  Copyright © 2019 Alexander Römer. All rights reserved.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController {
    
    @IBOutlet weak var informationLabel: UILabel!
    
    private var accessGranted = false
    private var audioRecorder: AVAudioRecorder?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupAudioRecorder()
    }
    
    private func setupAudioRecorder() {
        if let audioRecorder = Utility.getAudioRecorder() {
            self.audioRecorder = audioRecorder
            self.audioRecorder!.delegate = self
            accessGranted = true
        } else {
            print("User denied access")
        }
    }
    
    private func updateInformationLabel(recording: Bool) {
        if recording {
            informationLabel.text = "Recording..."
            informationLabel.textColor = UIColor.red
        } else {
            informationLabel.text = "Hold Button To Record"
            informationLabel.textColor = UIColor.white
        }
    }
    
    private func startRecording() {
        print("Starting recording...")
        audioRecorder?.record()
    }
    
    private func stopRecording() {
        print("Stopped recording...")
        audioRecorder?.stop()
    }
    
    private func showAccessAlert() {
        let alertViewController = UIAlertController(title: "No Access To Microphone", message: "Please allow AudioApp access to the microphone in your settings", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertViewController.addAction(okAction)
        present(alertViewController, animated: true, completion: nil)
    }
    
    @IBAction private func recordButtonTouchDown(_ sender: UIButton) {
        if accessGranted {
            startRecording()
            updateInformationLabel(recording: true)
        } else {
            showAccessAlert()
        }
    }
    
    @IBAction private func recordButtonTouchUPInside(_ sender: UIButton) {
        if !accessGranted {return}
        stopRecording()
        updateInformationLabel(recording: false)
    }
    
    @IBAction private func recordButtonTouchUpOutside(_ sender: UIButton) {
        if !accessGranted {return}
        stopRecording()
        updateInformationLabel(recording: false)
    }
    
    
}

extension RecordViewController: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("Everything ok")
            if let saveViewController = storyboard?.instantiateViewController(withIdentifier: "SaveViewController") as? SaveViewController {
                present(saveViewController, animated: true, completion: nil)
            }
        } else {
            print("Error during recording")
        }
    }
}
