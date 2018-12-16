//
//  ConnectionManager.swift
//  NStack
//
//  Created by Kasper Welner on 29/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation
import Alamofire
import Serpent
import Cashier

// FIXME: Figure out how to do accept language header properly

final class ConnectionManager {
    let baseURL = "https://nstack.io/api/v1/"
    let defaultUnwrapper: Parser.Unwrapper = { dict, _ in dict["data"] }
    let passthroughUnwrapper: Parser.Unwrapper = { dict, _ in return dict }

    let manager: Session
    let configuration: APIConfiguration

    var defaultHeaders: [String : String] {
        return [
            "X-Application-id"  : configuration.appId,
            "X-Rest-Api-Key"    : configuration.restAPIKey,
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
        var params: Parameters = [
            "version"           : currentVersion,
            "guid"              : Configuration.guid,
            "platform"          : "ios",
            "last_updated"      : ConnectionManager.lastUpdatedString,
            "old_version"       : oldVersion
        ]

        if let overriddenVersion = VersionUtilities.versionOverride {
            params["version"] = overriddenVersion
        }

        var headers: [String: String] = defaultHeaders
        if let acceptLanguage = acceptLanguage {
            headers["Accept-Language"] = acceptLanguage
        }

        let url = baseURL + "open" + (configuration.isFlat ? "?flat=true" : "")

        AF
            .request(url, method: .post, parameters: params, headers: HTTPHeaders(headers))
            .responseJSON(completionHandler: completion)
    }
}

extension ConnectionManager: TranslationsRepository {
    func fetchTranslations(acceptLanguage: String,
                           completion: @escaping Completion<TranslationsResponse>) {
        let params: Parameters = [
            "guid"              : Configuration.guid,
            "last_updated"      : ConnectionManager.lastUpdatedString
        ]

        let url = configuration.translationsUrlOverride ?? baseURL + "translate/mobile/keys?all=true" + (configuration.isFlat ? "&flat=true" : "")

        var headers = defaultHeaders
        headers["Accept-Language"] = acceptLanguage

        AF
            .request(url, method: .get, parameters:params, headers: HTTPHeaders(headers))
            .responseSerializable(completion, unwrapper: passthroughUnwrapper)
    }

    func fetchCurrentLanguage(acceptLanguage: String,
                              completion:  @escaping Completion<Language>) {
        let params: [String : Any] = [
            "guid"              : Configuration.guid,
            "last_updated"      : ConnectionManager.lastUpdatedString
        ]

        let url = baseURL + "translate/mobile/languages/best_fit?show_inactive_languages=true"

        var headers = defaultHeaders
        headers["Accept-Language"] = acceptLanguage

        AF
            .request(url, method: .get, parameters: params, headers: HTTPHeaders(headers))
            .responseSerializable(completion, unwrapper: defaultUnwrapper)
    }

    func fetchAvailableLanguages(completion:  @escaping Completion<[Language]>) {
        let params: [String : Any] = [
            "guid"              : Configuration.guid,
        ]

        let url = baseURL + "translate/mobile/languages"

        AF
            .request(url, method: .get, parameters:params, headers: HTTPHeaders(defaultHeaders))
            .responseSerializable(completion, unwrapper: defaultUnwrapper)
    }

    func fetchPreferredLanguages() -> [String] {
        return Locale.preferredLanguages
    }

    func fetchBundles() -> [Bundle] {
        return Bundle.allBundles
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
        AF
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
        AF.request(url, method: .post, parameters:params, headers: HTTPHeaders(defaultHeaders))
    }

    func markMessageAsRead(_ id: String) {
        let params: [String : Any] = [
            "guid"              : Configuration.guid,
            "message_id"        : id
        ]

        let url = baseURL + "notify/messages/views"
        AF.request(url, method: .post, parameters:params, headers: HTTPHeaders(defaultHeaders))
    }

    #if os(iOS) || os(tvOS)
    func markRateReminderAsSeen(_ answer: AlertManager.RateReminderResult) {
        let params: [String : Any] = [
            "guid"              : Configuration.guid,
            "platform"          : "ios",
            "answer"            : answer.rawValue
        ]

        let url = baseURL + "notify/rate_reminder/views"
        AF.request(url, method: .post, parameters:params, headers: HTTPHeaders(defaultHeaders))
    }
    #endif
}

// MARK: - Geography -

extension ConnectionManager: GeographyRepository {
    func fetchContinents(completion: @escaping Completion<[Continent]>) {
        AF
            .request(baseURL + "geographic/continents", headers: HTTPHeaders(defaultHeaders))
            .responseSerializable(completion, unwrapper: defaultUnwrapper)
    }
    
    func fetchLanguages(completion: @escaping Completion<[Language]>) {
        AF
            .request(baseURL + "geographic/languages", headers: HTTPHeaders(defaultHeaders))
            .responseSerializable(completion, unwrapper: defaultUnwrapper)
    }
    
    func fetchTimeZones(completion: @escaping Completion<[Timezone]>) {
        AF
            .request(baseURL + "geographic/time_zones", headers: HTTPHeaders(defaultHeaders))
            .responseSerializable(completion, unwrapper: defaultUnwrapper)
    }
    
    func fetchTimeZone(lat: Double, lng: Double, completion: @escaping Completion<Timezone>) {
        AF
            .request(baseURL + "geographic/time_zones/by_lat_lng?lat_lng=\(String(lat)),\(String(lng))", headers: HTTPHeaders(defaultHeaders))
            .responseSerializable(completion, unwrapper: defaultUnwrapper)
    }
    
    func fetchIPDetails(completion: @escaping Completion<IPAddress>) {
        AF
            .request(baseURL + "geographic/ip-address", headers: HTTPHeaders(defaultHeaders))
            .responseSerializable(completion, unwrapper: defaultUnwrapper)
    }
    
    func fetchCountries(completion:  @escaping Completion<[Country]>) {
        AF
            .request(baseURL + "geographic/countries", headers: HTTPHeaders(defaultHeaders))
            .responseSerializable(completion, unwrapper: defaultUnwrapper)
    }
}

// MARK: - Validation -

extension ConnectionManager: ValidationRepository {
    func validateEmail(_ email: String, completion:  @escaping Completion<Validation>) {
        AF
            .request(baseURL + "validator/email?email=\(email)", headers: HTTPHeaders(defaultHeaders))
            .responseSerializable(completion, unwrapper: defaultUnwrapper)
    }
}

// MARK: - Content -

extension ConnectionManager: ContentRepository {
    
    struct DataWrapper<T: Codable>: Swift.Codable {
        var data: T
    }
    
    func fetchStaticResponse<T:Swift.Codable>(atSlug slug: String, completion: @escaping ((Result<T>) -> Void)) {
      
        AF
            .request(baseURL + "content/responses/\(slug)", headers: HTTPHeaders(defaultHeaders))
            .validate()
            .responseData { (response) in
                switch response.result {
                case .success(let jsonData):
                    
                    do {
                       
                        let decoder = JSONDecoder()
                        let wrapper: DataWrapper<T> = try decoder.decode(DataWrapper<T>.self, from: jsonData)
                        
                        completion(.success(wrapper.data))
                    } catch let err {
                         completion(.failure(err))
                    }
                    
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }
    
    func fetchContent(_ id: Int, completion: @escaping Completion<Any>) {
        AF
            .request(baseURL + "content/responses/\(id)", headers: HTTPHeaders(defaultHeaders))
            .validate()
            .responseJSON(completionHandler: completion)
    }
    
    func fetchContent(_ slug: String, completion: @escaping Completion<Any>) {
        AF
            .request(baseURL + "content/responses/\(slug)", headers: HTTPHeaders(defaultHeaders))
            .validate()
            .responseJSON(completionHandler: completion)
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
