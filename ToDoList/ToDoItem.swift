//
//  ToDoItem.swift
//  ToDoList
//
//  Created by Yanina Kovrakh on 29.04.2024.
//

import Foundation

struct ToDoItem {
    let id: String
    let text: String
    let importance: Importance
    let deadline: Date?
   
    init(id: String = UUID().uuidString, text: String, importance: Importance, deadline: Date?) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
    }
}

enum Importance {
    case low
    case medium
    case high
    
    init?(rawValue: String) {
            switch rawValue {
            case "low":
                self = .low
            case "medium":
                self = .medium
            case "high":
                self = .high
            default:
                return nil
            }
        }
}

extension ToDoItem {
    
    // form JSON
    var json: Any? {

        let dict = ToDoItem.createDictionary(from: self)
        
//        guard let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted]) else {
//            print("Failed to convert dictionary to JSON data.")
//            return nil
//        }
//                
//        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
//            print("Failed to convert dictionary to JSON string.")
//            return nil
//        }
//        
//        return jsonString

        return dict

    }
    
    // get data from json in case of success parse
    static func parse(json: Any) -> ToDoItem? {
        
        guard let json = parseJSONObject(json) else {
            print("Failed to parse JSON object")
            return nil
        }
        guard let id = getString(from: json, for: "id"),
              let text = getString(from: json, for: "text") else {
            print("ID or Test is not in the expected format")
            return nil
        }
        
        let importance = getImportance(from: json)
        
        let deadline = getDeadline(from: json)
        
        return ToDoItem(id: id, text: text, importance: importance, deadline: deadline)
    }
    
    private static func parseJSONObject(_ json: Any) -> [String: Any]? {
        do {
            let jsonDictData = try JSONSerialization.data(withJSONObject: json)
            return try JSONSerialization.jsonObject(with: jsonDictData) as? [String: Any]
        } catch {
            print("Failed to parse JSON object")
            return nil
        }
    }
    
    private static func getString(from jsonObject: [String: Any], for key: String) -> String? {
        return jsonObject[key] as? String
    }
    
    private static func getImportance(from jsonObject: [String: Any]) -> Importance {
        if let importanceValue = getString(from: jsonObject, for: "importance"),
           let importance = Importance(rawValue: importanceValue) {
            return importance
        } else {
            return .medium
        }
    }
    
    private static func getDeadline(from jsonObject: [String: Any]) -> Date? {
        if let deadlineUnix = jsonObject["deadline"] as? TimeInterval {
            return Date(timeIntervalSince1970: deadlineUnix)
        } else {
            return nil
        }
    }
    
    private static func createDictionary(from json: Any) -> [String: Any] {
        var dict = [String: Any]()
        
        let mirror = Mirror(reflecting: json)
        
        for case let (label?, value) in mirror.children {
            switch label {
            case "deadline":
                if let dateValue = value as? Date {
                    dict[label] = dateValue.timeIntervalSince1970
                }
            case "importance":
                if let importanceValue = value as? Importance, importanceValue != .medium {
                    dict[label] = String(describing: importanceValue)
                }
            default:
                dict[label] = value
            }
        }
        
        return dict
    }
}
