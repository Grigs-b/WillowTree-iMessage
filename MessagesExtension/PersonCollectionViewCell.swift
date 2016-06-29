//
//  PersonCollectionViewCell.swift
//  iMessageApp
//
//  Created by Ryan Grigsby on 6/17/16.
//  Copyright © 2016 Grigs-b. All rights reserved.
//

import UIKit
import Messages

class PersonCollectionViewCell: UICollectionViewCell {

    @IBOutlet var personSticker: MSStickerView!
    let cache = FaceStickerCache.cache

    override func prepareForReuse() {
        personSticker.sticker = cache.placeholderSticker 
        super.prepareForReuse()
    }

    func configure(with person: Person) {

        // Note: when creating a sticker from a network request, you currently MUST use a placeholder,
        //  failing to use one will result in a cryptic crash when the sticker attempts to display
        personSticker.sticker = cache.placeholderSticker
        cache.sticker(for: person) { [weak self] (sticker) in
            DispatchQueue.main.async {

                self?.personSticker.sticker = sticker //stickler for stickers
                self?.personSticker.sizeToFit()
            }
        }
    }

}
