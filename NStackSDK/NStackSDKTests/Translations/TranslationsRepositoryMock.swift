//
//  TranslationsRepositoryMock.swift
//  NStackSDK
//
//  Created by Dominik Hádl on 05/12/2016.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Foundation
import Alamofire
import TranslationManager
@testable import NStackSDK

//class TranslationsRepositoryMock: TranslationRepository {
//   
//    var translationsResponse: TranslationsResponse?
//    var availableLanguages: [Language]?
//    var currentLanguage: Language?
//    var preferredLanguages = ["en"]
//    var customBundles: [Bundle]?
//
//    func fetchTranslations(acceptLanguage: String, completion: @escaping ((DataResponse<TranslationsResponse>) -> Void)) {
//        let error = NSError(domain: "", code: 0, userInfo: nil)
//        let result: Result = translationsResponse != nil ? .success(translationsResponse!) : .failure(error)
//        let response = DataResponse(request: nil, response: nil, data: nil, result: result)
//        completion(response)
//    }
//    
//    func fetchLocalizeTranslations(localize: Localize, acceptLanguage: String?, completion: @escaping Completion<TranslationsResponse>) {
//        let error = NSError(domain: "", code: 0, userInfo: nil)
//        let result: Result = translationsResponse != nil ? .success(translationsResponse!) : .failure(error)
//        let response = DataResponse(request: nil, response: nil, data: nil, result: result)
//        completion(response)
//    }
//
//    func fetchAvailableLanguages(completion: @escaping ((DataResponse<[Language]>) -> Void)) {
//        let error = NSError(domain: "", code: 0, userInfo: nil)
//        let result: Result = availableLanguages != nil ? .success(availableLanguages!) : .failure(error)
//        let response = DataResponse(request: nil, response: nil, data: nil, result: result)
//        completion(response)
//    }
//
//    func fetchCurrentLanguage(acceptLanguage: String, completion: @escaping ((DataResponse<Language>) -> Void)) {
//        let error = NSError(domain: "", code: 0, userInfo: nil)
//        let result: Result = currentLanguage != nil ? .success(currentLanguage!) : .failure(error)
//        let response = DataResponse(request: nil, response: nil, data: nil, result: result)
//        completion(response)
//    }
//    
//    func getLocalizationConfig(acceptLanguage: String, completion: @escaping (Result<[LocalizationModel], Error>) -> Void) {
//        
//    }
//    
//    func getTranslations(localization: LocalizationModel, acceptLanguage: String, completion: @escaping (Result<TranslationManager.TranslationResponse<TranslationManager.Language>, Error>) -> Void) {
//        
//    }
//    
//    func getAvailableLanguages<L>(completion: @escaping (Result<[L], Error>) -> Void) where L : LanguageModel {
//        
//    }
//
//    func fetchPreferredLanguages() -> [String] {
//        return preferredLanguages
//    }
//
//    func fetchBundles() -> [Bundle] {
//        return customBundles ?? Bundle.allBundles
//    }
//    
//    func fetchCurrentPhoneLanguage() -> String? {
//        return preferredLanguages.first
//    }
//}
