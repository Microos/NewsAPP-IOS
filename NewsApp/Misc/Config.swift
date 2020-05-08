//
//  Config.swift
//  NewsApp
//
//  Created by Microos on 2020/4/29.
//  Copyright © 2020 Yiliang Xie. All rights reserved.
//

import UIKit

/*
 FIX:
    - bookmarks dict by adding order
    - weather repeatedly fire requests (3~5 times)
    - no bookmark data
    - exit from detail view
    - dataModel load image as props
    - move weather info into TableVC
    - button in side cell view
 TODO:
 
    /2h/
    - headlines search bar
    - headline newscard to detailview
    
    /9h/
    - headlines tab basic // 3h
    - trending tab // 1h
    
    - search result page // 4h
    - migrate news card cell from storyboard to xib // 1h
    
    /14h/
    - bookmark Tab // 5h
    - contex menu //1h
    - newsdetailview // 6h
    - search bar // 2h
 
    /3h/
    - spinner
    - bookmark manager
    - add/remove bookmark, with button
    - toast
    
    /14h/
    - ...
    - ...
    
 */




struct HeadlinesConfig{
    static let sectionNames = ["world", "business", "politics", "sports", "technology",  "science"]
}

struct UIConfig {
    static let collectionViewItemVHSpacing = CGFloat(12.0)
    static let cornerRadius: CGFloat = 9
    static let borderColor: CGColor = UIColor.lightGray.cgColor //UIColor(red: (225 / 255.0), green: (226 / 255.0), blue: (227 / 255.0), alpha: 1.0).cgColor
    static let boarderWidth: CGFloat = 0.75
    static let showSpinner = true //TODO: set to true for production
    static let guardianFallbackImage = #imageLiteral(resourceName: "guardian_fallback")
}

struct BookmarkButtonUIConfig {
    static let imageMarked = UIImage(systemName: "bookmark.fill")
    static let imageUnmarked = UIImage(systemName: "bookmark")

}

struct WeatherCellConfig {
    static let clouds = #imageLiteral(resourceName: "cloudy_weather")
    static let clear = #imageLiteral(resourceName: "clear_weather")
    static let snow = #imageLiteral(resourceName: "snowy_weather")
    static let rain = #imageLiteral(resourceName: "rainy_weather")
    static let thunderstorm = #imageLiteral(resourceName: "thunder_weather")
    static let sunny = #imageLiteral(resourceName: "sunny_weather")

    static func getImage(summary: String) -> UIImage {
        switch summary {
        case "Clouds":
            return WeatherCellConfig.clouds
        case "Clear":
            return WeatherCellConfig.clear
        case "Snow":
            return WeatherCellConfig.snow
        case "Rain":
            return WeatherCellConfig.rain
        case "Thunderstorm":
            return WeatherCellConfig.thunderstorm
        default:
            return WeatherCellConfig.sunny
        }
    }
}
