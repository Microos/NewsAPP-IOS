//
//  helper.swift
//  NewsApp
//
//  Created by Microos on 2020/4/28.
//  Copyright © 2020 Yiliang Xie. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import Toast_Swift

class Helper {
    static let storyboard = UIStoryboard(name: "Main", bundle: nil)
    static func instantiateViewController(_ id: String) -> UIViewController {
        return storyboard.instantiateViewController(identifier: id)
    }


    static let alphabets = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 !?.,"
    static func genRandomString(_ min: Int, _ max: Int) -> String {
        let len = Int.random(in: min...max)
        return String((0..<len).map { _ in alphabets.randomElement()! })
    }



    static func simpleAlert(title: String, message: String, presenter: UIViewController) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            presenter.present(alert, animated: true)
        }
    }

    static let dateFormater = ISO8601DateFormatter()
    static let relativeFormater = RelativeDateTimeFormatter()
    static func computeAgeFromISO8601String(string: String) -> String {

        relativeFormater.unitsStyle = .full


        let pubDate = dateFormater.date(from: string) ?? Date()
        let curDate = Date()

        let interval = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: pubDate, to: curDate)

        if let d = interval.day, d > 0 {
            return "\(d)d ago"
        } else if let h = interval.hour, h > 0 {
            return "\(h)h ago"
        } else if let m = interval.minute, m > 0 {
            return "\(m)m ago"
        } else if let s = interval.second, s > 0 {
            return "\(s)s ago"
        } else {
            return "now"
        }

    }

    static func openTwitterShareInSafari(link: String) {
        let text = "Checkout this Article!\n\(link)\n"
        let url = "https://twitter.com/intent/tweet?text=\(text.urlEncoded()!)&hashtags=CSCI_571_NewsApp"
        UIApplication.shared.open(URL(string: url)!)
    }

    static func errorToast(view: UIView?, message: String, duration: Double = ToastManager.shared.duration, position: ToastPosition = ToastPosition.center) {
        if let view = view {
            view.makeToast(message, duration: duration, position: position, style: Helper.getErrorWarningToastStyle(.Error))
        } else {
            print("Error: Trying to maketoast from nil view")

        }
    }

    static func warningToast(view: UIView?, message: String, duration: Double = ToastManager.shared.duration, position: ToastPosition = ToastPosition.center) {
        if let view = view {
            view.makeToast(message, duration: duration, position: position, style: Helper.getErrorWarningToastStyle(.Warning))
        } else {
            print("Error: Trying to maketoast from nil view")

        }


    }


    enum StyleErrorWarning {
        case Error, Warning
    }
    static func getErrorWarningToastStyle(_ errorOrWarning: StyleErrorWarning) -> ToastStyle {
        var style = ToastStyle()


        style.titleColor = UIColor.white
        style.messageAlignment = .center
        style.titleAlignment = .center
        switch errorOrWarning {
        case .Error:
            style.backgroundColor = #colorLiteral(red: 0.887075305, green: 0.07681948692, blue: 0.07692144066, alpha: 1)
        case .Warning:
            style.backgroundColor = #colorLiteral(red: 0.9999635816, green: 0.771012187, blue: 0.0001958988723, alpha: 1)
        }
        return style
    }

    static func asyncLoadImage(imageview: UIImageView, urlstr: String?) {
        //place holder image is set to guardian by default
        if let url = urlstr {
            imageview.sd_setImage(with: URL(string: url), placeholderImage: UIConfig.guardianFallbackImage, options: [.scaleDownLargeImages])
        } else {
            imageview.image = UIConfig.guardianFallbackImage
        }
    }
}


//MARK: Location
class CLHelper {
    //USC location
    // 34.02188
    // -118.28587
    static func configCLManager(manager: CLLocationManager, delegate: CLLocationManagerDelegate) {
        // setup manager

        manager.requestWhenInUseAuthorization()
        manager.delegate = delegate
        manager.desiredAccuracy = kCLLocationAccuracyBest

    }

    static func locationToCityName(lat: Double, lon: Double, complete: @escaping (String?, String?, String?) -> Void)
    {
        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(CLLocation(latitude: lat, longitude: lon), completionHandler:
                    {
                    placeMarks, error in
                    complete(placeMarks?.first?.locality, placeMarks?.first?.administrativeArea, placeMarks?.first?.country)
            })
    }

    private static let stateCodes = ["AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "DC", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"]
    private static let fullStateNames = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "District of Columbia", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"]

    static var stateCodeDict: [String: String] = [:]

    static func stateCodeToName(code: String) -> String {
        if stateCodeDict.count == 0 {
            //init dict
            for (k, v) in zip(stateCodes, fullStateNames) {
                stateCodeDict[k] = v
            }
        }

        return stateCodeDict[code] ?? code // return the
    }


}


//code from: https://stackoverflow.com/a/45871217/5318060
public extension CharacterSet {

    static let urlQueryParameterAllowed = CharacterSet.urlQueryAllowed.subtracting(CharacterSet(charactersIn: "&?"))

    static let urlQueryDenied = CharacterSet.urlQueryAllowed.inverted()
    static let urlQueryKeyValueDenied = CharacterSet.urlQueryParameterAllowed.inverted()
    static let urlPathDenied = CharacterSet.urlPathAllowed.inverted()
    static let urlFragmentDenied = CharacterSet.urlFragmentAllowed.inverted()
    static let urlHostDenied = CharacterSet.urlHostAllowed.inverted()

    static let urlDenied = CharacterSet.urlQueryDenied
        .union(.urlQueryKeyValueDenied)
        .union(.urlPathDenied)
        .union(.urlFragmentDenied)
        .union(.urlHostDenied)


    func inverted() -> CharacterSet {
        var copy = self
        copy.invert()
        return copy
    }
}



public extension String {
    func urlEncoded(denying deniedCharacters: CharacterSet = .urlDenied) -> String? {
        return addingPercentEncoding(withAllowedCharacters: deniedCharacters.inverted())
    }


}


protocol ToastDelegate {
    func toast(_ message: String)
}


extension UIViewController {
    func alertError(title: String?, message: String) {
        Helper.simpleAlert(title: title ?? "Error", message: message, presenter: self)
    }
    func errorToast(_ message: String) {
        Helper.errorToast(view: self.view.superview, message: message, duration: 5.0)
    }
    func warningToast(_ message: String) {
        Helper.warningToast(view: self.view.superview, message: message)
    }

    func regularToast(_ message: String) {
        self.view.superview?.makeToast(message, duration: 2.0, position: .bottom)
    }
}
