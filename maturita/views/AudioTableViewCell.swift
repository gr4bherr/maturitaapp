//
//  AudioTableViewCell.swift
//  maturita
//
//  Created by grabherr on 21.04.2021.
//

import UIKit
import SwiftySound

public var audioPlaying: Bool = false

class AudioTableViewCell: UITableViewCell { //play/pause button
    
    var mp3file: String = ""
    var isPlaying: Bool = false

    @IBOutlet weak var button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBAction func onPress(_ sender: UIButton) { //action that happens when button pressed
        playAudio(audioName: mp3file)
    }
    public func configure(file: String) { //configuring which audio file to play
        mp3file = file
    }
    func playAudio(audioName: String) { //play/pause function
        button.setTitle("Přehrát poslech", for: .normal)
        if audioPlaying {
            Sound.stopAll()
            audioPlaying = false
        } else {
            Sound.play(file: audioName, fileExtension: "mp3", numberOfLoops: 1)
            audioPlaying = true
        }
    }
}
