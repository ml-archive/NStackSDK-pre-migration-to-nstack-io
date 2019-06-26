//
//  ConnectionManager.swift
//  NStack
//
//  Created by Kasper Welner on 29/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation
import Serpent
import Cashier
import TranslationManager
import Alamofire

#if canImport(UIKit)
import UIKit

#warning("N-Meta not currently working with Mac & Watch, just going to use `ios` for all")
#if os(watchOS)
let platformString = "watchos"
#else
let platformString = "ios"
#endif
#elseif canImport(AppKit)
import AppKit
let platformString = "macos"
#else
let platformString = ""
#endif
let deviceString = "\(platformString);staging;\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "");\(UIDevice.current.systemVersion);\(UIDevice.current.model)"

// FIXME: Figure out how to do accept language header properly
final class ConnectionManager {
    
    let baseURL = "https://nstack.io/api/v1/"
    let baseURLv2 = "https://nstack.io/api/v2/"
    let defaultUnwrapper: Parser.Unwrapper = { dict, _ in dict["data"] }
    let passthroughUnwrapper: Parser.Unwrapper = { dict, _ in return dict }

    let manager: Session
    let configuration: APIConfiguration

    var defaultHeaders: [String : String] {
        return [
            "X-Application-id"  : configuration.appId,
            "X-Rest-Api-Key"    : configuration.restAPIKey,
            "N-Meta"            : deviceString
        ]
    }

    init(configuration: APIConfiguration) {
        let sessionConfiguration = Session.default.session.configuration
        sessionConfiguration.timeoutIntervalForRequest = 20.0

        self.manager = Session(configuration: sessionConfiguration)
        self.configuration = configuration
    }
}

extension ConnectionManager: AppOpenRepository {
    func postAppOpen(oldVersion: String = VersionUtilities.previousAppVersion,
                     currentVersion: String = VersionUtilities.currentAppVersion,
                     acceptLanguage: String? = nil, completion: @escaping Completion<Any>) {
        var params: [String : Any] = [
            "version"           : currentVersion,
            "guid"              : Configuration.guid,
            "platform"          : "ios",
            "last_updated"      : ConnectionManager.lastUpdatedString,
            "old_version"       : oldVersion
        ]

        if let overriddenVersion = VersionUtilities.versionOverride {
            params["version"] = overriddenVersion
        }

        var headers = defaultHeaders
        if let acceptLanguage = acceptLanguage {
            headers["Accept-Language"] = acceptLanguage
        }

        let url = baseURLv2 + "open" + (configuration.isFlat ? "?flat=true" : "")

        manager
            .request(url, method: .post, parameters: params, headers: HTTPHeaders(defaultHeaders))
            .responseJSON(completionHandler: completion)
    }
    
    func newPostAppOpen(oldVersion: String = VersionUtilities.previousAppVersion,
                        currentVersion: String = VersionUtilities.currentAppVersion,
                        acceptLanguage: String? = nil, completion: @escaping Completion<AppOpenResponse>) {
        var params: [String: String] = [
            "version": currentVersion,
            "guid": Configuration.guid,
            "platform": "ios",
            "last_updated": ConnectionManager.lastUpdatedString,
            "old_version": oldVersion
        ]
        
        if let overriddenVersion = VersionUtilities.versionOverride {
            params["version"] = overriddenVersion
        }
        
        var headers = defaultHeaders
        if let acceptLanguage = acceptLanguage {
            headers["Accept-Language"] = acceptLanguage
        }
        
        let url = baseURLv2 + "open" + (configuration.isFlat ? "?flat=true" : "")
        manager.request(url, method: .post, parameters: params, encoder: JSONParameterEncoder.default, headers: HTTPHeaders(defaultHeaders))
            .responseSerializable(completion, unwrapper: passthroughUnwrapper)
    }
}

extension ConnectionManager: TranslationRepository {

    func getTranslations(localization: LocalizationModel, acceptLanguage: String, completion: @escaping (Result<TranslationResponse<Language>, Error>) -> Void) {
        //TODO
        
    }
    
    func getLocalizationConfig(acceptLanguage: String, completion: @escaping (Result<[LocalizationModel], Error>) -> Void) {
        //TODO
    }
    
    func getAvailableLanguages<L>(completion: @escaping (Result<[L], Error>) -> Void) where L : LanguageModel {
        //TODO
    }


    func fetchTranslations(acceptLanguage: String,
                           completion: @escaping Completion<TranslationsResponse>) {
        let params: [String : Any] = [
            "guid"              : Configuration.guid,
            "last_updated"      : ConnectionManager.lastUpdatedString
        ]

        let url = configuration.translationsUrlOverride ?? baseURL + "translate/mobile/keys?all=true" + (configuration.isFlat ? "&flat=true" : "")

        var headers = defaultHeaders
        headers["Accept-Language"] = acceptLanguage

        manager
            .request(url, method: .get, parameters:params, headers: HTTPHeaders(defaultHeaders))
            .responseSerializable(completion, unwrapper: passthroughUnwrapper)
    }

    func fetchCurrentLanguage(acceptLanguage: String,
                              completion:  @escaping Completion<Language>) {
        let params: [String : String] = [
            "guid"              : Configuration.guid,
            "last_updated"      : ConnectionManager.lastUpdatedString
        ]

        let url = baseURL + "translate/mobile/languages/best_fit?show_inactive_languages=true"

        var headers = defaultHeaders
        headers["Accept-Language"] = acceptLanguage

        manager
            .request(url, method: .get, parameters: params, encoder: JSONParameterEncoder.default, headers: HTTPHeaders(defaultHeaders))
            .responseDecodable(completionHandler: completion)
            //.responseSerializable(completion, unwrapper: defaultUnwrapper)
    }

    func fetchAvailableLanguages(completion:  @escaping Completion<[Language]>) {
        let params: [String : Any] = [
            "guid"              : Configuration.guid,
        ]

        let url = baseURL + "translate/mobile/languages"

        manager
            .request(url, method: .get, parameters:params, headers: HTTPHeaders(defaultHeaders))
            .responseDecodable(completionHandler: completion)
    }

    func fetchPreferredLanguages() -> [String] {
        return Locale.preferredLanguages
    }

    func fetchBundles() -> [Bundle] {
        return Bundle.allBundles
    }
    
    func fetchCurrentPhoneLanguage() -> String? {
        return Locale.current.languageCode
    }
}

extension ConnectionManager: UpdatesRepository {
    func fetchUpdates(oldVersion: String = VersionUtilities.previousAppVersion,
                      currentVersion: String = VersionUtilities.currentAppVersion,
                      completion: @escaping Completion<Update>) {
        let params: [String : Any] = [
            "current_version"   : currentVersion,
            "guid"              : Configuration.guid,
            "platform"          : "ios",
            "old_version"       : oldVersion,
            ]

        let url = baseURL + "notify/updates"
        manager
            .request(url, method: .get, parameters:params, headers: HTTPHeaders(defaultHeaders))
            .responseSerializable(completion, unwrapper: defaultUnwrapper)
    }
}

extension ConnectionManager: VersionsRepository {
    func markWhatsNewAsSeen(_ id: Int) {
        let params: [String : Any] = [
            "guid"              : Configuration.guid,
            "update_id"         : id,
            "type"              : "new_in_version",
            "answer"            : "no",
        ]

        let url = baseURL + "notify/updates/views"
        manager.request(url, method: .post, parameters:params, headers: HTTPHeaders(defaultHeaders))
    }

    func markMessageAsRead(_ id: String) {
        let params: [String : Any] = [
            "guid"              : Configuration.guid,
            "message_id"        : id
        ]

        let url = baseURL + "notify/messages/views"
        manager.request(url, method: .post, parameters:params, headers: HTTPHeaders(defaultHeaders))
    }

    #if os(iOS) || os(tvOS)
    func markRateReminderAsSeen(_ answer: AlertManager.RateReminderResult) {
        let params: [String : Any] = [
            "guid"              : Configuration.guid,
            "platform"          : "ios",
            "answer"            : answer.rawValue
        ]

        let url = baseURL + "notify/rate_reminder/views"
        manager.request(url, method: .post, parameters:params, headers: HTTPHeaders(defaultHeaders))
    }
    #endif
}

// MARK: - Geography -

extension ConnectionManager: GeographyRepository {
    func fetchContinents(completion: @escaping Completion<[Continent]>) {
        manager
            .request(baseURL + "geographic/continents", headers: HTTPHeaders(defaultHeaders))
            .responseSerializable(completion, unwrapper: defaultUnwrapper)
    }
    
    func fetchLanguages(completion: @escaping Completion<[Language]>) {
        manager
            .request(baseURL + "geographic/languages", headers: HTTPHeaders(defaultHeaders))
            .responseDecodable(completionHandler: completion)
    }
    
    func fetchTimeZones(completion: @escaping Completion<[Timezone]>) {
        manager
            .request(baseURL + "geographic/time_zones", headers: HTTPHeaders(defaultHeaders))
            .responseSerializable(completion, unwrapper: defaultUnwrapper)
    }
    
    func fetchTimeZone(lat: Double, lng: Double, completion: @escaping Completion<Timezone>) {
        manager
            .request(baseURL + "geographic/time_zones/by_lat_lng?lat_lng=\(String(lat)),\(String(lng))", headers: HTTPHeaders(defaultHeaders))
            .responseSerializable(completion, unwrapper: defaultUnwrapper)
    }
    
    func fetchIPDetails(completion: @escaping Completion<IPAddress>) {
        manager
            .request(baseURL + "geographic/ip-address", headers: HTTPHeaders(defaultHeaders))
            .responseSerializable(completion, unwrapper: defaultUnwrapper)
    }
    
    func fetchCountries(completion:  @escaping Completion<[Country]>) {
        manager
            .request(baseURL + "geographic/countries", headers: HTTPHeaders(defaultHeaders))
            .responseSerializable(completion, unwrapper: defaultUnwrapper)
    }
}

// MARK: - Validation -

extension ConnectionManager: ValidationRepository {
    func validateEmail(_ email: String, completion:  @escaping Completion<Validation>) {
        manager
            .request(baseURL + "validator/email?email=\(email)", headers: HTTPHeaders(defaultHeaders))
            .responseSerializable(completion, unwrapper: defaultUnwrapper)
    }
}

// MARK: - Content -

extension ConnectionManager: ContentRepository {
    
    struct DataWrapper<T: Codable>: Swift.Codable {
        var data: T
    }
    
    func fetchStaticResponse<T:Swift.Codable>(atSlug slug: String, completion: @escaping ((NStack.NStackResult<T>) -> Void)) {
      
        manager
            .request(baseURL + "content/responses/\(slug)", headers: HTTPHeaders(defaultHeaders))
            .validate()
            .responseData { (response) in
                switch response.result {
                case .success(let jsonData):
                    
                    do {
                       
                        let decoder = JSONDecoder()
                        let wrapper: DataWrapper<T> = try decoder.decode(DataWrapper<T>.self, from: jsonData)
                        completion(NStack.NStackResult.success(data: wrapper.data))
                    } catch let err {
                         completion(.failure(err))
                    }
                    
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }
    
    func fetchContent(_ id: Int, completion: @escaping Completion<Any>) {
        manager
            .request(baseURL + "content/responses/\(id)", headers: HTTPHeaders(defaultHeaders))
            .validate()
            .responseJSON(completionHandler: completion)
    }
    
    func fetchContent(_ slug: String, completion: @escaping Completion<Any>) {
        manager.request(baseURL + "content/responses/\(slug)", headers: HTTPHeaders(defaultHeaders))
            .validate()
            .responseJSON(completionHandler: completion)
    }
}

// MARK: - Collections -
extension ConnectionManager: ColletionRepository {
    func fetchCollection<T: Swift.Codable>(_ id: Int, maxNumberOfEntries: Int, completion: @escaping ((NStack.NStackResult<T>) -> Void)) {
       
        manager
            .request(baseURL + "content/collections/\(id)?limit=\(maxNumberOfEntries)", headers:  HTTPHeaders(defaultHeaders))
            .validate()
            .responseData { (response) in
                switch response.result {
                case .success(let jsonData):
                    do {
                        
                        let decoder = JSONDecoder()
                        let wrapper: DataWrapper<T> = try decoder.decode(DataWrapper<T>.self, from: jsonData)
                        
                        completion(NStack.NStackResult.success(data: wrapper.data))
                    } catch let err {
                        completion(.failure(err))
                    }
                    
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }
}

// MARK: - Utility Functions -

// FIXME: Refactor

extension ConnectionManager {

    static var lastUpdatedString: String {
        let cache = Constants.persistentStore

        // FIXME: Handle language change
//        let previousAcceptLanguage = cache.string(forKey: Constants.CacheKeys.prevAcceptedLanguage)
//        let currentAcceptLanguage  = TranslationManager.acceptLanguage()
//
//        if let previous = previousAcceptLanguage, previous != currentAcceptLanguage {
//            cache.setObject(currentAcceptLanguage, forKey: Constants.CacheKeys.prevAcceptedLanguage)
//            setLastUpdated(Date.distantPast)
//        }

        let key = Constants.CacheKeys.lastUpdatedDate
        let date = cache.object(forKey: key) as? Date ?? Date.distantPast
        return date.stringRepresentation()
    }

    func setLastUpdated(toDate date: Date = Date()) {
        Constants.persistentStore.setObject(date, forKey: Constants.CacheKeys.lastUpdatedDate)
    }
}
