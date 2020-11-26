//
//  SpeechSynthesizerService.swift
//  SmartEducation
//
//  Created by MacBook on 11/16/20.
//

import OSSSpeechKit
import AVFoundation

class SpeechSynthesizerService: NSObject {
    func synthesize(_ text: String) {
        DispatchQueue.global().async {
            let speechKit = OSSSpeech.shared
            speechKit.voice = OSSVoice(quality: .enhanced, language: .Australian)
            speechKit.speakText(text)
        }
    }
}
