//
//  BookmarkManager.swift
//  NewsApp
//
//  Created by Microos on 2020/5/2.
//  Copyright © 2020 Yiliang Xie. All rights reserved.
//

import Foundation
//MARK: Bookmark man


typealias BookmarkDict = [String: DMNewsCard]
typealias BookmarkOrderIndex = [String]

protocol BookmarkManagerDataChangeNotificationReceiver {
    func bookmarkManagerDataChangezNotified()
}
class BookmarkManager {
    //
    //    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    //    static let RootURL = DocumentsDirectory.appendingPathComponent(DataStoreID)
    static let database = UserDefaults.standard
   
    static let dictKey = "BookmarkDictionary"
    static var dict: BookmarkDict = initDict()
    static let ordIdxKey = "BookmarkDictionaryOrderIndex"
    static var orderIndex: BookmarkOrderIndex = initOrderIndex()


    private static func initDict() -> BookmarkDict {
        //check DB dictKey
        if database.value(forKey: dictKey) == nil {
            print("BookmarkManager: No dict record found in DB, init")
            let retDict = BookmarkDict()
            //put into DB
            saveToUserDB(key: dictKey, data: retDict)
            return retDict
        } else {
            //read dict from DB
            return loadFromUserDB(key: dictKey) as! BookmarkDict
        }
    }
    private static func initOrderIndex() -> BookmarkOrderIndex {
        //check DB ordIdxKey
        if database.value(forKey: ordIdxKey) == nil {
            print("BookmarkManager: No orderIndex record found in DB, init")
            let index = BookmarkOrderIndex()
            //put into DB
            saveToUserDB(key: ordIdxKey, data: index)
            return index
        } else {
            //read dict from DB
            return loadFromUserDB(key: ordIdxKey) as! BookmarkOrderIndex
        }
    }


    @discardableResult static func addBookmark(item: DMNewsCard?, notifyExcepts: [String]? = nil) -> Bool {

        guard let item = item else {
            print("BookmarkManager.saveBookmark got nil, no action")
            return false
        }
        
        if dict[item.artId] != nil{
            print("Item [\(item.artId)] already in bookmark DB, ignored addition")
            return false
        }else{
            //add/ local itemss
            dict[item.artId] = item
            orderIndex.append(item.artId)
            
            //encode dict, update to db
            dumpBookmarkDataToUserDB()

            //notify
            notify(excepts: notifyExcepts)
            return true

        }
        
    }


    @discardableResult static func removeBookmark(artId: String?, notifyExcepts: [String]? = nil) -> Bool {
        guard let artId = artId else {
            print("BookmarkManager.removebookmark got nil, no action")
            return false
        }
        // remove local item
        if let _ = dict.removeValue(forKey: artId), let idx = orderIndex.firstIndex(of: artId) {
            // continue to remove index
            orderIndex.remove(at: idx)
            // remove DB item
            dumpBookmarkDataToUserDB()

            //notify
            notify(excepts: notifyExcepts)
            return true
        } else {
            // not even exists in local dict
            print("BookmarkManager.removebookmark, item is not marked, no action")
            return false
        }

    }

    static func loadBookmarks() -> [DMNewsCard] {
        var ret = [DMNewsCard]()

        for i in orderIndex.reversed() {
            ret.append(dict[i]!)
        }

        return ret

    }

    static func isMarked(artId: String) -> Bool {
        let val = dict[artId]
        return val != nil
    }

    static func removeAll(notifyExcepts: [String]? = nil) {
        let emptyDict = BookmarkDict()
        let emptyIndex = BookmarkOrderIndex()
        dict = emptyDict
        orderIndex = emptyIndex
        dumpBookmarkDataToUserDB()
        //notify
        notify(excepts: notifyExcepts)
        print("Bookmark Manager: all data are removed!")
    }

    
    private static func dumpBookmarkDataToUserDB(){
        saveToUserDB(key: ordIdxKey, data: orderIndex)
        saveToUserDB(key: dictKey, data: dict)
    }
    
    private static func saveToUserDB(key: String, data: Any) {
        let archivedData = try? NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)
        database.setValue(archivedData!, forKey: key)
    }

    private static func loadFromUserDB(key: String) -> Any {
        let data = database.value(forKey: key) as! Data
        let decodedDict = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
        return decodedDict!
    }
}

//MARK: Bookmark man notification protocol
extension BookmarkManager {
    static var notificationReceivers = [String: BookmarkManagerDataChangeNotificationReceiver]()
    static func unregisterAsNotificationReceiver(id:String){
        if notificationReceivers[id] == nil{
            print("BookmarkManager.unregisterAsNotificationReceiver: \(id) is not registered, ignore")
            return
        }
        notificationReceivers.removeValue(forKey: id)
    }
    static func registerAsNotificationReceiver(id: String, receiver: BookmarkManagerDataChangeNotificationReceiver) {
        if notificationReceivers[id] != nil {
            print("BookmarkManager.registerAsNotificationReceiver: \(id) has registered, will override")
        }
        notificationReceivers[id] = receiver
    }
    static func notify(excepts: [String]? = nil) {
        for (id, receiver) in notificationReceivers {
            if let b = excepts?.contains(id), b { continue }
            receiver.bookmarkManagerDataChangezNotified()
        }
    }
}
