//
//  Localize.swift
//  NStackSDK
//
//  Created by Andrew Lloyd on 17/06/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation
import Serpent
import TranslationManager

public struct Localization: LocalizationModel {
    public var localeIdentifier: String {
        return language.acceptLanguage
    }
    
    public var id: Int
    public var url: String
    
    public var lastUpdatedAt: String
    public var shouldUpdate: Bool
    public var language: Language
    
    enum CodingKeys: String, CodingKey {
        case id, url, language
        case lastUpdatedAt = "last_updated_at"
        case shouldUpdate = "should_update"
    }
}
