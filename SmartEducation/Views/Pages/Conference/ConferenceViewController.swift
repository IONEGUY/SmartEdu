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

    @IBOutlet weak var jitsiMeetView: JitsiMeetView!

    var viewModel: AnyObject?

    private var roomName = "SmartEDU"

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBackBarButtonItem()

        openConferenceView()
    }

    private func openConferenceView() {
        jitsiMeetView.delegate = self

        let options = JitsiMeetConferenceOptions.fromBuilder { [weak self] (builder) in
            builder.serverURL = URL(string: ApiConstants.conferenceUrl)
            builder.welcomePageEnabled = false
            builder.room = self?.roomName
        }

        JitsiMeet.sharedInstance().defaultConferenceOptions = options
        jitsiMeetView.join(options)
    }
}

extension ConferenceViewController: JitsiMeetViewDelegate {
    func conferenceTerminated(_ data: [AnyHashable: Any]!) {
        Router.pop()
    }
}
