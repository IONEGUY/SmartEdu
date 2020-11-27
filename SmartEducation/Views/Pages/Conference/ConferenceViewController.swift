//
//  ConferenceViewController.swift
//  SmartEducation
//
//  Created by MacBook on 11/6/20.
//

import UIKit
import JitsiMeet

class ConferenceViewController: UIViewController, MVVMViewController {
    typealias ViewModelType = AnyObject

    var viewModel: AnyObject?

    @IBOutlet weak var jitsiMeetView: JitsiMeetView!

    override func viewDidLoad() {
        super.viewDidLoad()

        openConferenceView()
    }

    private func openConferenceView() {
        jitsiMeetView.delegate = self

        let options = JitsiMeetConferenceOptions.fromBuilder { [weak self] (builder) in
            builder.serverURL = URL(string: ApiConstants.conferenceUrl)
            builder.welcomePageEnabled = false
            builder.room = StringResources.conferenceRoomName
        }

        if JitsiMeet.sharedInstance().defaultConferenceOptions == nil {
            JitsiMeet.sharedInstance().defaultConferenceOptions = options
        }
        jitsiMeetView.join(options)
    }
}

extension ConferenceViewController: JitsiMeetViewDelegate {
    func conferenceTerminated(_ data: [AnyHashable: Any]!) {
        if jitsiMeetView != nil {
            Router.pop()
            jitsiMeetView = nil
        }
    }
}
