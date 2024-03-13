//
//  PointAnnotationInfo.swift
//  OpenStreetMapTest
//
//  Created by Vlad Boguzh on 13.03.2024.
//

import MapboxMaps

struct PointAnnotationInfo: Codable {
    let name: String
    let lastSeen: String

    func toJSONObject() -> JSONObject {
        var json: JSONObject = [:]
        json["name"] = .string(name)
        json["lastSeen"] = .string(lastSeen)
        return json
    }

    static func fromJSONObject(_ object: JSONObject) -> Self? {
        guard let name = object["name"]??.rawValue as? String,
              let lastSeen = object["lastSeen"]??.rawValue as? String else {
            return nil
        }
        let info = PointAnnotationInfo(name: name, lastSeen: lastSeen)
        return info
    }

    static func timestampToString(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
}
