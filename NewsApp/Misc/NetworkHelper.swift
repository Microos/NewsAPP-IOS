//
//  APIFetcher.swift
//  NewsApp
//
//  Created by Microos on 2020/4/28.
//  Copyright © 2020 Yiliang Xie. All rights reserved.
//

import UIKit
import Alamofire
import os.log
import SwiftyJSON



struct APIKey {
    static let OpenWeather = "b77a85d5b425f9fcccad7abee2e543fe"
    static let AutoSuggest = "079917df1d4642f3bf56e845141b2b61"

}
struct APIEndpoints {
    static let openWeather = "https://api.openweathermap.org/data/2.5/weather"
    static let autoSuggest = "https://api.cognitive.microsoft.com/bing/v7.0/suggestions"

    static func getAutoSuggestHeader() -> [String: String] {
        return ["Ocp-Apim-Subscription-Key": APIKey.AutoSuggest]
    }
}
struct BackendAPIEndpoint {
    static let Server = "https://cs571hw9-dep1.wl.r.appspot.com"
    static let HomeNews = "\(BackendAPIEndpoint.Server)/api/home"
    static let ArticleDetail = "\(BackendAPIEndpoint.Server)/api/article"
    static let Search = "\(BackendAPIEndpoint.Server)/api/search"
    static let Trends = "\(BackendAPIEndpoint.Server)/api/trends"
    static let Headlines = "\(BackendAPIEndpoint.Server)/api/headlines"

}

func getRequest(url: String, params: Parameters?, headers: HTTPHeaders?, completion: @escaping (Result<[String:Any]>) -> Void) {

    let request = Alamofire.request(url, parameters: params, headers: headers).responseJSON(completionHandler: {
        response in
        os_log("returned getRequest() fired to < %@ >", log: OSLog.default, type: .debug, "\(response.request!)")
        switch response.result {
        case .success(let value as [String: Any]):
            completion(.success(value))
        case .failure(let error):
            completion(.failure(error))
        default:
            fatalError("non dict JSON!")
        }
    })

    let fullURL = request.request == nil ? "Unknown URL" : "\(request.request!)"
    os_log("getRequest() fired to < %@ >", log: OSLog.default, type: .debug, fullURL)
}


class AutoSuggestAPI {

    static func requestSuggestion(text: String, completion: @escaping (Bool, [String]) -> Void) {
        getRequest(url: APIEndpoints.autoSuggest, params: ["q": text], headers: APIEndpoints.getAutoSuggestHeader(), completion: {
                resp in
                var ret = [String]()
                switch resp {
                case .success(let value):
                    let json = JSON(value)
                    let dictArr = json["suggestionGroups"][0]["searchSuggestions"]
                    for (_, d) in dictArr {
                        ret.append(d["displayText"].stringValue)
                    }
                    completion(true, ret)
                case .failure(let error):
                    ret.append("\(error)")
                    completion(false, [String]())
                }
            })
    }

}

class TrendingAPI {
    static func requestTrendingData(q: String, completion: @escaping (Result<[Double]>) -> Void) {
        getRequest(url: BackendAPIEndpoint.Trends, params: ["q": q], headers: nil) { (resp) in
            switch resp {
            case .success(let value):
                let json = JSON(value)
                if json["status"].stringValue != "ok" {
                    completion(.failure(NSError(domain: "TrendingAPI.requestTrendingData() not OK", code: -1, userInfo: value)))
                } else {
                    var ret = [Double]()
                    for (_, v) in json["content"] {
                        ret.append(v.doubleValue)
                    }
                    completion(.success(ret))

                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

class GuardianAPI {
    static func requestHomeData(completion: @escaping (Result<[DMNewsCard]>) -> Void) {
        getRequest(url: BackendAPIEndpoint.HomeNews, params: nil, headers: nil, completion: {
            data in
            switch data {
            case .success(let value):
                let json = JSON(value)
                if json["status"].stringValue != "ok" {
                    completion(.failure(NSError(domain: "GuardianAPI.requestHomeData() not OK", code: -1, userInfo: value)))
                } else {
                    var ret = [DMNewsCard]()
                    for (_, subJson) in json["content"] {
                        ret.append(DMNewsCard(json: subJson))

                    }
                    completion(Result.success(ret))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }

    static func requestArticleData(artID: String, completion: @escaping (Result<JSON>) -> Void) {
        getRequest(url: BackendAPIEndpoint.ArticleDetail, params: ["id": artID], headers: nil, completion: { resp in
                switch resp {
                case .success(let value):
                    let json = JSON(value)
                    if json["status"].stringValue != "ok" {
                        completion(.failure(NSError(domain: "GuardianAPI.requestArticleData() not OK", code: -1, userInfo: value)))
                    } else {
                        completion(.success(json["content"]))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            })
    }

    static func requestSearchData(q: String, completion: @escaping (Result<JSON>) -> Void) {
        getRequest(url: BackendAPIEndpoint.Search, params: ["q": q], headers: nil, completion: { resp in
                switch resp {
                case .success(let value):
                    let json = JSON(value)
                    if json["status"].stringValue != "ok" {
                        completion(.failure(NSError(domain: "GuardianAPI.requestSearchData() not OK", code: -1, userInfo: value)))
                    } else {
                        completion(.success(json["content"]))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            })
    }

    static func requestHeadlinesData(forSection: String, completion: @escaping (Result<[DMNewsCard]>) -> Void) {
        getRequest(url: BackendAPIEndpoint.Headlines, params: ["section": forSection], headers: nil) { (resp) in
            switch resp {
            case .success(let value):
                let json = JSON(value)

                if json["status"] != "ok" {
                    completion(.failure(NSError(domain: "GuardianAPI.requestHeadlinesData() not OK", code: -1, userInfo: value)))
                } else {
                    var ret = [DMNewsCard]()
                    for (_, subjson) in json["content"] {
                        ret.append(DMNewsCard(json: subjson))
                    }
                    completion(.success(ret))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }

    }
}

class WeatherAPI {
    static let url = APIEndpoints.openWeather
    static func requestWeather(city: String, state: String?, country: String, lon: Double, lat: Double, completion: @escaping ([String: String]?) -> Void) {
//        if dataAlreadySet{
//            return
//        }
        let params = [
            "lat": "\(lat)",
            "lon": "\(lon)",
            "units": "metric",
            "appid": APIKey.OpenWeather]
        getRequest(url: url, params: params, headers: nil, completion: { resp in
            switch resp {
            case .success(let data):
                var ret = [String: String]()

                let json = JSON(data)
                let temp = json["main"]["temp"].doubleValue.rounded()
                let summary = json["weather"][0]["main"].stringValue

                ret["city"] = city
                ret["temp"] = "\(Int(exactly: temp)!)°C"
                ret["summary"] = summary

                if let state = state {
                    ret["state"] = CLHelper.stateCodeToName(code: state)
                } else {
                    ret["state"] = country
                }

                completion(ret)
            case .failure(_):
                completion(nil)
            }


        })



    }
}
