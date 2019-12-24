//
//  AudioTableViewCell.swift
//  Audio App
//
//  Created by Alexander Römer on 16.11.19.
//  Copyright © 2019 Alexander Römer. All rights reserved.
//

import UIKit

protocol AudioCellDelegate {
    func shouldPlaySound(at url: URL)
}

class AudioTableViewCell: UITableViewCell {

    @IBOutlet weak var audioFileLabel: UILabel!
    
    var delegate: AudioCellDelegate?
    var url: URL?
    
    
    @IBAction func playButtonHandler(_ sender: UIButton) {
        if let url = url {
        delegate?.shouldPlaySound(at: url)
        }
    }
}


