//
//  Constants.swift
//  NStack
//
//  Created by Kasper Welner on 02/10/15.
//  Copyright © 2015 Nodes. All rights reserved.
//
import Cashier

enum Constants {
    static let persistentStore: NOPersistentStore = .cache(withId: "NStack")

    enum CacheKeys {
        static let previousVersion      = "PreviousVersionKey"
        static let lastUpdatedDate      = "LastUpdated"
        static let prevAcceptedLanguage = "PrevAcceptedLanguageKey"
        static let countries            = "CountriesKey"
        static let continents           = "ContinentsKey"
        static let languanges           = "LanguangesKey"
        static let timezones            = "TimezonesKey"
        static let languageOverride     = "LanguageOverride"
        static let localizations        = "LocalizationsKey"
    }
}
