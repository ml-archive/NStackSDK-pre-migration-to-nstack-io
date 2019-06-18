//
//  Localize.swift
//  NStackSDK
//
//  Created by Andrew Lloyd on 17/06/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation
import Serpent

public struct Localize {
    var id = 0
    var url = ""
    var lastUpdatedAt = Date()
    var shouldUpdate: Bool = false
    var language: Language?
}

extension Localize: Serializable {
    public init(dictionary: NSDictionary?) {
        id            <== (self, dictionary, "id")
        url           <== (self, dictionary, "url")
        lastUpdatedAt <== (self, dictionary, "last_updated_at")
        shouldUpdate  <== (self, dictionary, "should_update")
        language      <== (self, dictionary, "language")
    }
    
    public func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "id")              <== id
        (dict, "url")             <== url
        (dict, "last_updated_at") <== lastUpdatedAt
        (dict, "should_update")   <== shouldUpdate
        (dict, "language")        <== language
        return dict
    }
}
