//
//  NameService.swift
//  iMessageApp
//
//  Created by Ryan Grigsby on 6/16/16.
//  Copyright © 2016 Grigs-b. All rights reserved.
//

import Foundation

enum Result<S,E> {
    case success(S)
    case error(E)
}

enum ErrorType {
    case parsing
    case unknown(String)

}

extension ErrorType: CustomStringConvertible {
    var description:String {
        switch self {
        case .parsing:
            return "Parsing Error"
        case .unknown(let message):
            return message
        }
    }
}

protocol NameService {
    func people(completion: ((Result<People, ErrorType>) -> Void))
}

class APINameService: NameService {

    func people(completion: ((Result<People, ErrorType>) -> Void)) {
        do {
            try nameData() {
                result in
                switch result {
                case .success(let persons):

                    var people = People()
                    for person in persons {
                        if let url = person["url"],
                            let name = person["name"],
                            let imageURL = URL(string: url) {

                            let person = Person(name: name, imageURL: imageURL)
                            people.append(person)
                        }
                    }
                    DispatchQueue.main.async { completion(.success(people)) }

                case .error(let error):
                    DispatchQueue.main.async { completion(.error(error)) }
                }
            }
        } catch {
            DispatchQueue.main.async { completion(.error(.parsing)) }
        }
    }

    private func nameData(completion: ((Result<Array<Dictionary<String,String>>, ErrorType>) -> Void)?) throws {
        if let url = URL(string: "http://api.namegame.willowtreemobile.com/") {
            let task = URLSession.shared().dataTask(with: url) {
                (result:Data?, response:URLResponse?, error:NSError?) in

                if let result = result,
                    let json = try! JSONSerialization.jsonObject(with: result, options: .allowFragments) as? Array<Dictionary<String, String>> {
                    completion?(.success(json))
                } else {
                    completion?(.error(.unknown(error?.description ?? "Unknown Error")))
                }
                
            }
            task.resume()
        }
    }
}

// MARK: Mock for testing
class MockNameService: NameService {
    func people(completion: ((Result<People, ErrorType>) -> Void)) {
        var people = People()
        let url = URL(string: "https://willowtreeapps.com/wp-content/uploads/2013/10/headshot_matt_jones1.jpg")
        people.append(Person(name: "Matt Jones", imageURL: url!))
        completion(.success(people))
    }
}
