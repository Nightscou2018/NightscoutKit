//
//  ProfileStoreSnapshot.swift
//  NightscoutKit
//
//  Created by Michael Pangburn on 2/23/18.
//  Copyright © 2018 Michael Pangburn. All rights reserved.
//

import Foundation


struct ProfileStoreSnapshot: UniquelyIdentifiable {
    let id: String
    let defaultProfileName: String
    let recordDate: Date
    let units: BloodGlucoseUnit
    let profiles: [String: Profile]
}

extension ProfileStoreSnapshot: JSONParseable {
    private struct Key {
        static let id = "_id"
        static let defaultProfileName = "defaultProfile"
        static let recordDateString = "startDate"
        static let unitString = "units"
        static let profileDictionaries = "store"
    }

    static func parse(from profileJSON: JSONDictionary) -> ProfileStoreSnapshot? {
        guard
            let id = profileJSON[Key.id] as? String,
            let defaultProfileName = profileJSON[Key.defaultProfileName] as? String,
            let recordDateString = profileJSON[Key.recordDateString] as? String,
            let recordDate = TimeFormatter.date(from: recordDateString),
            let unitString = profileJSON[Key.unitString] as? String,
            let units = BloodGlucoseUnit(rawValue: unitString),
            let profileDictionaries = profileJSON[Key.profileDictionaries] as? [String: JSONDictionary]
        else {
            return nil
        }

        return ProfileStoreSnapshot(
            id: id,
            defaultProfileName: defaultProfileName,
            recordDate: recordDate,
            units: units,
            profiles: profileDictionaries.compactMapValues(Profile.parse)
        )
    }
}
