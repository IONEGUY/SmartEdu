//
//  StringResources.swift
//  SmartEducation
//
//  Created by MacBook on 11/17/20.
//

import Foundation

struct StringResources {
    static let greetingMessage = "Hi, I’m Hakima. How can I help you?"
    static let unknownQuestionMessage = "Hmm…I don’t have an answer for that. Is there something else I can help with"
    static let predefinedMessages: [String : String] = [
        "QUESTION": "OK. What is your question? Please ask.",
        "EARTH": "The Earth’s radius is 3,958.8 miles long, and its circumference is 24,873.6 miles",
        "MARS": """
            It seems like Mars is on everyone’s mind these days. NASA is planning to send first humans to the
            red planet by 2030. Elon Musk’s SpaceX wants to get there even sooner. It is aiming to have people
            on Mars by 2024!
        """,
        "MOON": """
            The Moon is made from many of the same things that we find here on Earth. Scientists studied about
            800 pounds of moon rocks brought back by the Apollo astronauts. Their tests showed that the
            rocks from the Moon are similar to three kinds of igneous rocks that are found here on Earth:
            basalt, anorthosite and breccias
        """,
        "THE HOTTEST PLANET": """
            Venus has the hottest surface temperature (+864° F). It's very thick carbon dioxide atmosphere
            and sulfuric acid clouds act as a heat trap. This is called the greenhouse effect
        """
    ]
}
