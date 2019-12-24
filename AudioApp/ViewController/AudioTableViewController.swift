//
//  AudioTableViewController.swift
//  Audio App
//
//  Created by Alexander Römer on 16.11.19.
//  Copyright © 2019 Alexander Römer. All rights reserved.
//

import UIKit
import AVFoundation

class AudioTableViewController: UIViewController {
    
    @IBOutlet weak var zeroHeightConstraint : NSLayoutConstraint!
    @IBOutlet weak var fullHeightConstraint : NSLayoutConstraint!
    @IBOutlet weak var tableView            : UITableView!
    @IBOutlet weak var playbarButton        : UIButton!
    @IBOutlet weak var playbar              : UISlider!
    
    private var audioFiles  = [String]()
    private var audioURLs   = [URL]()
    private var playerShown = false
    private var audioPlayer = AVAudioPlayer()
    private var timer       : Timer?
    
    override func viewWillDisappear(_ animated: Bool) {
        if playerShown {
            audioPlayer.stop()
            stopAudio()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let documentQuery = Utility.getFilenamesAndURLs(for: tabBarItem.title!)
        if documentQuery.success {
            audioURLs = documentQuery.urls
            audioFiles = documentQuery.names
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
    }
    
    private func animatePlayer(show: Bool, completion: @escaping () -> ()) {
        if show {
            zeroHeightConstraint.isActive = false
            fullHeightConstraint.isActive = true
        } else {
            fullHeightConstraint.isActive = false
            zeroHeightConstraint.isActive = true
        }
        
        UIView.animate(withDuration: 0.25, animations:  {
            self.view.layoutIfNeeded()
        }) { bool in
            completion()
        }
    }
    
    private func startAudio() {
        timer = Timer.scheduledTimer(timeInterval: 1/60, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        audioPlayer.play()
    }
    
    @objc private func updateSlider() {
        playbar.setValue(Float(audioPlayer.currentTime), animated: true)
    }
    
    private func stopAudio() {
        timer?.invalidate()
        playerShown = !playerShown
        animatePlayer(show: playerShown) {
            
        }
    }
    
    @IBAction private func playbarHandler(_ sender: UISlider) {
        audioPlayer.currentTime = TimeInterval(playbar.value)
    }
    
    @IBAction private func playbarButtonHandler(_ sender: UIButton) {
        if audioPlayer.isPlaying {
            sender.setImage(UIImage(named: "PlayButton"), for: .normal)
            audioPlayer.pause()
        } else {
            sender.setImage(UIImage(named: "PauseButton"), for: .normal)
            audioPlayer.play()
        }
    }
    
}

extension AudioTableViewController: AVAudioPlayerDelegate {
    
    internal func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopAudio()
    }
}

extension AudioTableViewController: AudioCellDelegate {
    
    internal func shouldPlaySound(at url: URL) {
        playbarButton.setImage(UIImage(named: "PauseButton"), for: .normal)
        playbar.setValue(0.0, animated: false)
        if !playerShown {
            //            Animated Player
            playerShown = !playerShown
            animatePlayer(show: playerShown, completion: {
                do {
                    self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                    self.audioPlayer.delegate = self
                    self.playbar.maximumValue = Float(self.audioPlayer.duration)
                    self.startAudio()
                } catch {
                    print(error)
                }
            })
        } else {
            //            Play Audio
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer.delegate = self
                playbar.maximumValue = Float(audioPlayer.duration)
                startAudio()
            } catch {
                print(error)
            }
        }
        
    }
}

extension AudioTableViewController: UITableViewDataSource {
    
    internal func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioFiles.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioCell", for: indexPath) as! AudioTableViewCell
        cell.audioFileLabel.text = audioFiles[indexPath.row]
        cell.url = audioURLs[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    internal func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let cell = tableView.cellForRow(at: indexPath) as?
                AudioTableViewCell {
                if Utility.deleteAudioApp(at: cell.url!) {
                    audioURLs.remove(at: indexPath.row)
                    audioFiles.remove(at: indexPath.row)
                    tableView.reloadData()
                }
            }
        }
    }
}
