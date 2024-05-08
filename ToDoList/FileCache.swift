//
//  FileCache.swift
//  ToDoList
//
//  Created by Yanina Kovrakh on 01.05.2024.
//

import Foundation

final class FileCache {

    static let shared = FileCache()
    private let manager = FileManager.default
    private let folderName = "ToDoItems"

    private var toDoItemsFileMap = [String: [ToDoItem]]()

    private init() {
        createFileDirectoryIfNeeded()
        print(manager.urls(for: .documentDirectory, in: .userDomainMask))
    }

    func addToDoItem(_ item: ToDoItem, list listName: String) {
        toDoItemsFileMap[listName, default: []].append(item)
    }

    func removeToDoItem(by id: String, from listName: String) {
        guard var itemsList = toDoItemsFileMap[listName] else {
            print("There is no such list: \(listName)")
            return
        }

        itemsList.removeAll { $0.id == id }
        toDoItemsFileMap[listName] = itemsList
    }

    func retrieveFromFile(_ listName: String) -> [ToDoItem]? {
        guard let fileUrl = FileCache.fileUrl(in: self.folderName, for: listName) else {
            print("There is no such a file.")
            return nil
        }

        do {
            let jsonData = try Data(contentsOf: fileUrl)
            let jsonArray = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] ?? []
            return jsonArray.compactMap { jsonDict in
                ToDoItem.parse(json: jsonDict)
            }
        } catch {
            print("Failed to read or parse JSON from file:", error)
            return nil
        }
    }

    func saveFile(_ listName: String) {
        guard let items = toDoItemsFileMap[listName] else { return }
        
        guard let fileUrl = FileCache.fileUrl(in: self.folderName, for: listName) else {
            print("There is no such a file.")
            return
        }

        let jsonArray = items.compactMap { $0.json }
        
        do {
            let fileData = try JSONSerialization.data(withJSONObject: jsonArray, options: [.prettyPrinted, .sortedKeys])
            try fileData.write(to: fileUrl, options: [.atomic, .completeFileProtection])
        } catch {
            print("Failed to write JSON data to file: \(error)")
        }
    }

    private func createFileDirectoryIfNeeded() {
        guard let documentsDirectory = FileCache.documentsDirectory else { return }

        let folderUrl = documentsDirectory.appending(path: self.folderName)

        do {
            try manager.createDirectory(at: folderUrl, withIntermediateDirectories: true)
            print("Directory created")
        } catch {
            print("Failed to create directory: \(error)")
        }
    }
}

extension FileCache {
    static var documentsDirectory: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    static func fileUrl(in folderName: String, for listName: String) -> URL? {
           return documentsDirectory?.appendingPathComponent("\(folderName)/\(listName)")
       }
}
