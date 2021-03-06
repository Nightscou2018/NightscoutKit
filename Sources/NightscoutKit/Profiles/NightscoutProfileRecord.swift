//
//  NightscoutProfileRecord.swift
//  NightscoutKit
//
//  Created by Michael Pangburn on 2/23/18.
//  Copyright © 2018 Michael Pangburn. All rights reserved.
//

import Foundation


/// A Nightscout profile record.
/// This type stores data such as the user's profiles and the blood glucose units used in specifying details of these profiles.
public struct NightscoutProfileRecord: NightscoutIdentifiable, TimelineValue {
    /// The profile record's unique, internally assigned identifier.
    public let id: NightscoutIdentifier

    /// The name of the default profile.
    /// If the `profiles` dictionary does not contain this key, the profile record is malformed.
    public let defaultProfileName: String

    /// The date at which this profile record was last validated by the user.
    public let date: Date

    /// The blood glucose units used in creating the profiles' blood glucose target and insulin sensitivity schedules.
    public let bloodGlucoseUnits: BloodGlucoseUnit

    /// A dictionary containing the profiles, keyed by the profile names.
    public let profiles: [String: NightscoutProfile]

    /// The record's default profile. If the `profiles` dictionary does not contain the `defaultProfileName` key,
    /// this property will return the first entry in the `profiles` dictionary.
    /// An empty `profiles` dictionary can result only from a programmer error, so accessing this property
    /// in such a case will result in a crash.
    public var defaultProfile: NightscoutProfile {
        let defaultProfile = profiles[defaultProfileName]
        assert(defaultProfile != nil)
        return defaultProfile ?? profiles.first!.value
    }

    /// Creates a new profile record.
    /// - Parameter id: The record identifier. By default, a new identifier is generated.
    /// - Parameter defaultProfileName: The name of the default profile. This name must appear as a key in the profiles dictionary.
    /// - Parameter date: The date at which the profile record was last validated by the user.
    /// - Parameter bloodGlucoseUnits: The blood glucose units used in creating the profiles' blood glucose target and insulin sensitivity schedules.
    /// - Parameter profiles: A dictionary containing the profiles, keyed by the profile names.
    /// - Returns: A new profile record.
    public init(id: NightscoutIdentifier = .init(), defaultProfileName: String, date: Date, bloodGlucoseUnits: BloodGlucoseUnit, profiles: [String: NightscoutProfile]) {
        precondition(profiles[defaultProfileName] != nil, "The default profile name must appear in the profiles dictionary.")
        self.id = id
        self.defaultProfileName = defaultProfileName
        self.date = date
        self.bloodGlucoseUnits = bloodGlucoseUnits
        self.profiles = profiles
    }
}

// MARK: - JSON

extension NightscoutProfileRecord: JSONParseable {
    private enum Key {
        static let defaultProfileName: JSONKey<String> = "defaultProfile"
        static let dateString: JSONKey<String> = "startDate"
        static let units: JSONKey<BloodGlucoseUnit> = "units"
        static let profileDictionaries: JSONKey<[String: JSONDictionary]> = "store"
    }

    static func parse(fromJSON profileJSON: JSONDictionary) -> NightscoutProfileRecord? {
        guard
            let id = NightscoutIdentifier.parse(fromJSON: profileJSON),
            let defaultProfileName = profileJSON[Key.defaultProfileName],
            let recordDate = profileJSON[convertingDateFrom: Key.dateString],
            let units = profileJSON[convertingFrom: Key.units],
            let profileDictionaries = profileJSON[Key.profileDictionaries]
        else {
            return nil
        }

        let profiles = profileDictionaries.compactMapValues(NightscoutProfile.parse)
        guard !profiles.isEmpty else {
            return nil
        }

        return .init(
            id: id,
            defaultProfileName: defaultProfileName,
            date: recordDate,
            bloodGlucoseUnits: units,
            profiles: profiles
        )
    }
}

extension NightscoutProfileRecord: JSONConvertible {
    var jsonRepresentation: JSONDictionary {
        var json: JSONDictionary = [:]
        json[NightscoutIdentifier.Key.id] = id.value
        json[Key.defaultProfileName] = defaultProfileName
        json[convertingDateFrom: Key.dateString] = date
        json[convertingFrom: Key.units] = bloodGlucoseUnits
        json[Key.profileDictionaries] = profiles.mapValues { $0.jsonRepresentation }
        return json
    }
}
