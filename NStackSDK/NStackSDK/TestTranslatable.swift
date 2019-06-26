//
//  TestTranslatable.swift
//  NStackSDK
//
//  Created by Andrew Lloyd on 24/06/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation
import TranslationManager

public struct TestTranslatable: Translatable {
    public subscript(key: String) -> TranslatableSection? {
        return nil
    }
}
