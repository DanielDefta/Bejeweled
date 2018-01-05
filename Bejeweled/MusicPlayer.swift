//
//  MusicPlayer.swift
//  Bejeweled
//
//  Created by Daniel Defta on 26/12/2017.
//  Copyright © 2017 Daniel Defta. All rights reserved.
//

import Foundation
import AVFoundation
struct MusicPlayer{
    
    static var sharedInstance = MusicPlayer()
    
    var backgroundMusic : AVAudioPlayer!
    
    
    mutating func play(name: String){
        if backgroundMusic == nil {
            guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
                fatalError()
            }
            do {
                backgroundMusic = try AVAudioPlayer(contentsOf: url)
                backgroundMusic.numberOfLoops = -1
                
                backgroundMusic.volume = UserDefaults.standard.float(forKey: "musicVolume")
                backgroundMusic.play()
            } catch {
                fatalError()
            }
        }
    }
    
    mutating func stop(){
        if(backgroundMusic.isPlaying){
            backgroundMusic.stop()
        }
    }
    
    mutating func setVolume(volume: Float, tijd: TimeInterval){
        if( backgroundMusic.isPlaying){
            backgroundMusic.setVolume(volume, fadeDuration: tijd)
            UserDefaults.standard.setValue(volume, forKey: "musicVolume")
        }
    }
}
