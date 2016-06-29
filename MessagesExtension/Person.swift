//
//  Person.swift
//  iMessageApp
//
//  Created by Ryan Grigsby on 6/16/16.
//  Copyright © 2016 Grigs-b. All rights reserved.
//

import UIKit

struct Person {
    var name: String
    var imageURL: URL
}

typealias People = [Person]

extension Person {
    var queryItems: [URLQueryItem] {
        let items = [URLQueryItem(name: "name", value: name),
                     URLQueryItem(name: "imageURL", value: imageURL.absoluteString)]
        return items
    }
}

extension Person: CustomStringConvertible {
    var description: String {
        return "\(name),\(imageURL)"
    }

    init?(description: String?) {
        guard let parts = description?.components(separatedBy: ",") where parts.count == 2,
            let name = parts.first,
            let imageURLString = parts.last,
            let imageURL = URL(string: imageURLString) else {
                return nil
        }
        self.init(name: name, imageURL: imageURL)
    }
}

extension Person: Equatable {}

func ==(lhs: Person, rhs: Person) -> Bool {
    return lhs.name == rhs.name
}
