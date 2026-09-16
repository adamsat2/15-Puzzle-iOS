//
//  SoundManager.swift
//  15-Puzzle
//

import AVFoundation

class SoundManager: NSObject, AVAudioPlayerDelegate {
    static let shared = SoundManager()
    
    var audioPlayer: AVAudioPlayer?
    
    private override init() {
        super.init()
        
        DispatchQueue.global(qos: .background).async {
            do {
                // .ambient allows the sound effects to play without stopping background music from another app
                try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Failed to set audio session category: \(error.localizedDescription)")
            }
        }
    }
    
    func playSound(soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            print("Could not find the sound file: \(soundName)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            DispatchQueue.global(qos: .background).async { [weak self] in
                self?.audioPlayer?.play()
            }
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioPlayer = nil
    }
}
