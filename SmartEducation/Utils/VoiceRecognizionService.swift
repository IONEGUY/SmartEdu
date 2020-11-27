//
//  VoiceRecognizionService.swift
//  SmartEducation
//
//  Created by MacBook on 10/26/20.
//

import OSSSpeechKit

class VoiceRecognizionService: NSObject, OSSSpeechDelegate {
    private let speechKit = OSSSpeech.shared

    private var recognitionCompletion: (String?) -> Void = { _ in }

    func startRecording(_ recognitionCompletion: @escaping (String?) -> Void) {
        self.recognitionCompletion = recognitionCompletion
        speechKit.delegate = self
        speechKit.recordVoice()
    }

    func stopRecording() {
        speechKit.endVoiceRecording()
    }

    func didCompleteTranslation(withText text: String) {
        recognitionCompletion(text)
    }

    func didFailToProcessRequest(withError error: Error?) {
        guard let err = error else {
            print("Error with the request but the error returned is nil")
            return
        }
        print("Error with the request: \(err)")
    }

    func authorizationToMicrophone(withAuthentication type: OSSSpeechKitAuthorizationStatus) {
        print("Authorization status has returned: \(type.message).")
    }

    func didFailToCommenceSpeechRecording() {
        print("Failed to record speech.")
    }

    func didFinishListening(withText text: String) {}
}
