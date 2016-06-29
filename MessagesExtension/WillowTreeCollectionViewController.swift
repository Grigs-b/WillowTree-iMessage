//
//  WillowTreeCollectionViewController.swift
//  iMessageApp
//
//  Created by Ryan Grigsby on 6/17/16.
//  Copyright © 2016 Grigs-b. All rights reserved.
//

import UIKit
import Messages

protocol WillowTreeCollectionViewDelegate: class {
    func didSelectPerson(_ person: Person, withController controller: WillowTreeCollectionViewController)
}

class WillowTreeCollectionViewController: UICollectionViewController {

    weak var delegate: WillowTreeCollectionViewDelegate?
    private var nameService: NameService!
    private var people: People = [] {
        didSet {
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nameService.people() { [unowned self]
            result in
            switch result {
            case .success(let people):
                self.people = people
            case .error(let error):
                print("Error retrieving people \(error)")
            }
        }
    }
}

// MARK: - Instantiation
extension WillowTreeCollectionViewController {
    class func build(nameService: NameService, delegate: WillowTreeCollectionViewDelegate?) -> WillowTreeCollectionViewController {
        guard let controller = UIStoryboard(name: String(WillowTreeCollectionViewController), bundle: nil).instantiateViewController(withIdentifier: String(WillowTreeCollectionViewController)) as? WillowTreeCollectionViewController else {
            fatalError("Unable to instantiate WillowTreeCollectionViewController")
        }
        controller.nameService = nameService
        return controller
    }
}

// MARK: UICollectionViewDataSource
extension WillowTreeCollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(PersonCollectionViewCell), for: indexPath) as? PersonCollectionViewCell else { fatalError("Unable to dequeue a PersonCollectionViewCell") }

        cell.configure(with: people[indexPath.row])
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        delegate?.didSelectPerson(people[indexPath.row], withController: self)
    }
}
