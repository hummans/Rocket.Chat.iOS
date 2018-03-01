//
//  UserUpdateRequest.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 27/02/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import SwiftyJSON
import Foundation

typealias UserUpdateResult = APIResult<UserUpdateRequest>

class UserUpdateRequest: APIRequest {
    let method: HTTPMethod = .post
    let path = "/api/v1/users.update"

    let userId: String
    let user: User
    let password: String?

    init(userId: String, user: User, password: String? = nil) {
        self.userId = userId
        self.user = user
        self.password = password
    }

    func body() -> Data? {
        guard let name = user.name,
                let username = user.username,
                let email = user.emails.first,
                !name.isEmpty,
                !username.isEmpty,
                !email.email.isEmpty else {
            return nil
        }

        var body = JSON([
            "userId": userId,
            "data": [
                "name": name,
                "username": username,
                "email": email.email
            ]
        ])

        if let password = password, !password.isEmpty {
            body["data"]["password"].string = password
        }

        let string = body.rawString()
        let data = string?.data(using: .utf8)

        return data
    }

    var contentType: String? {
        return "application/json"
    }
}

extension APIResult where T == UserUpdateRequest {
    var user: User? {
        guard let rawMessage = raw?["user"] else { return nil }

        let user = User()
        user.map(rawMessage, realm: nil)
        return user
    }

    var success: Bool {
        return raw?["success"].boolValue ?? false
    }

    var errorMessage: String? {
        return raw?["error"].stringValue
    }
}
