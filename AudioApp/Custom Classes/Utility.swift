//
//  Utility.swift
//  Audio App
//
//  Created by Alexander Römer on 16.11.19.
//  Copyright © 2019 Alexander Römer. All rights reserved.
//

import Foundation
import AVFoundation


class Utility {
    
    private static func getDocumentDirectory() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    static func deleteAudioApp(at url: URL) -> Bool {
        do {
            try FileManager.default.removeItem(at: url)
            return true
        } catch {
            return false
        }
    }
    
    static func getFilenamesAndURLs(for folder: String) -> (success: Bool, names: [String], urls: [URL]) {
        var urls = [URL]()
        var names = [String]()
        
        guard let documentDirectory = getDocumentDirectory() else {
            return (false, names, urls)
        }
        let folderDirectory = documentDirectory.appendingPathComponent(folder)
        
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: folderDirectory, includingPropertiesForKeys: nil, options: [])
            for url in directoryContents {
                urls.append(url)
                let fileName = url.lastPathComponent
                let cleanName = fileName.replacingOccurrences(of: "caf", with: "")
                names.append(cleanName)
            }
            
            return (true, names, urls)
        } catch {
            print("Could not search for urls of files in document directory: \(error)")
            return (false, names, urls)
        }
        
    }
    
    static func moveAudioFile(to category: String, with name: String) -> Bool {
        do {
            guard let documentDirectory = getDocumentDirectory() else { return false }
            let categoryPath = documentDirectory.appendingPathComponent(category)
            let originPath = documentDirectory.appendingPathComponent("mysound.caf")
            let destinationPath = categoryPath.appendingPathComponent(name)
            try FileManager.default.moveItem(at: originPath, to: destinationPath)
            return true
        } catch {
            return false
        }
    }
    
    static func getAudioRecorder() -> AVAudioRecorder? {
        var audioRecorder: AVAudioRecorder?
        let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
        if audioSession.responds(to: #selector(AVAudioSession.requestRecordPermission(_:))) {
            AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
                if granted {
                    try! audioSession.setCategory(.playAndRecord, mode: AVAudioSession.Mode.default, options: .mixWithOthers)
                    try! audioSession.setActive(true)
                    
                    guard let documentsDirectory = getDocumentDirectory()
                        else { return }
                    let url = documentsDirectory.appendingPathComponent("mysound.caf")
                    
                    let settings: [String:Any] =  [
                        AVFormatIDKey: Int(kAudioFormatAppleIMA4),
                        AVSampleRateKey: 44100.0,
                        AVNumberOfChannelsKey: 2,
                        AVEncoderBitRateKey: 12800,
                        AVLinearPCMBitDepthKey: 16,
                        AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
                    ]
                    
                    do {
                        audioRecorder = try AVAudioRecorder(url: url, settings: settings)
                    } catch {
                        print("Could not initialsie Recorder")
                    }
                    
                } else {
                    print("User denied access")
                }
            }
        }
        return  audioRecorder
    }
}
