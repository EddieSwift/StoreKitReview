//
//  StoreReviewManager.swift
//  StoreKitReview
//
//  Created by Eduard Galchenko on 15.04.2020.
//  Copyright © 2020 Eduard Galchenko. All rights reserved.
//

import Foundation
import StoreKit

enum UserDefaultsKeys: String {
    case userPushNotificationAlreadySeenKey, storeReviewInitialDelayCountKey, lastDateReviewPromptedKey, lastVersionPromptedForReviewKey
}

class StoreReviewManager {
    private let minimumDaysSinceLastReview = 122
    private let minimumInitialDelayCount = 10

    func askForReview(navigationController: UINavigationController?) {
        guard let navigationController = navigationController else { return }

        if #available(iOS 10.3, *) {
            let oldTopViewController = navigationController.topViewController
            let currentVersion = version()
            let count = initialDelayCount
            incrementInitialDelayCount()

            // Has the task/process been completed several times and the user has not already been prompted for this version?
            if count >= minimumInitialDelayCount && currentVersion != lastVersionPromptedForReview && lastDatePromptedUser <= Date().daysAgo(minimumDaysSinceLastReview) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    if navigationController.topViewController == oldTopViewController {
                        SKStoreReviewController.requestReview()
                        UserDefaults.standard.set(currentVersion, forKey: UserDefaultsKeys.lastVersionPromptedForReviewKey.rawValue)
                        UserDefaults.standard.set(Date(), forKey:UserDefaultsKeys.lastDateReviewPromptedKey.rawValue)
                    }
                }
            }
        }
    }

    private var lastDatePromptedUser: Date {
        get {
            return UserDefaults.standard.object(forKey: UserDefaultsKeys.lastDateReviewPromptedKey.rawValue) as? Date ?? Date().daysAgo(minimumDaysSinceLastReview + 1)
        }
    }

    private var lastVersionPromptedForReview: String? {
        get {
            return UserDefaults.standard.string(forKey: UserDefaultsKeys.lastVersionPromptedForReviewKey.rawValue)
        }
    }

    private func version() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "\(version).\(build)"
    }

    private var initialDelayCount: Int {
        get {
            return UserDefaults.standard.integer(forKey: UserDefaultsKeys.storeReviewInitialDelayCountKey.rawValue)
        }
    }

    private func incrementInitialDelayCount() {
        var count = initialDelayCount
        if count < minimumInitialDelayCount {
            count += 1
            UserDefaults.standard.set(count, forKey: UserDefaultsKeys.storeReviewInitialDelayCountKey.rawValue)
        }
    }
}
