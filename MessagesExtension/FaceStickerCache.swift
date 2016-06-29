//
//  FaceStickerCache.swift
//  iMessageApp
//
//  Created by Ryan Grigsby on 6/20/16.
//  Copyright © 2016 Grigs-b. All rights reserved.
//

import Foundation
import Messages


class FaceStickerCache {

    static let cache = FaceStickerCache()

    private let cacheURL: URL

    private let queue = OperationQueue()

    /**
     An `MSSticker` that can be used as a placeholder while a real
     sticker is being fetched from the cache.
     NOTE: Be sure to have a placeholder. Attempting to render a sticker with
        a nil image will result in a crash. As of Beta 1 the error was very cryptic and misleading.
        Hopefully this will be refined
     */
    let placeholderSticker: MSSticker = {
        let bundle = Bundle.main()
        guard let placeholderURL = bundle.urlForResource("sticker_placeholder", withExtension: "png") else { fatalError("Unable to find placeholder sticker image") }

        do {
            let description = NSLocalizedString("An ice cream sticker", comment: "")
            return try MSSticker(contentsOfFileURL: placeholderURL, localizedDescription: description)
        }
        catch {
            fatalError("Failed to create placeholder sticker: \(error)")
        }
    }()

    // MARK: Initialization
    private init() {
        let fileManager = FileManager.default()
        let tempPath = NSTemporaryDirectory()
        let directoryName = UUID().uuidString

        do {
            try cacheURL = URL(fileURLWithPath: tempPath).appendingPathComponent(directoryName)
            try fileManager.createDirectory(at: cacheURL, withIntermediateDirectories: true, attributes: nil)
        }
        catch {
            fatalError("Unable to create cache URL: \(error)")
        }
    }

    deinit {
        let fileManager = FileManager.default()
        do {
            try fileManager.removeItem(at: cacheURL)
        }
        catch {
            print("Unable to remove cache directory: \(error)")
        }
    }

    // MARK
    func sticker(for person: Person, completion: (sticker: MSSticker) -> Void) {
        // Determine the URL for the sticker.
        let fileName = person.name.replacingOccurrences(of: " ", with: "_") + ".png"
        guard let url = try? cacheURL.appendingPathComponent(fileName) else { fatalError("Unable to create sticker URL") }

        // Create an operation to process the request.
        let operation = BlockOperation {
            let fileManager = FileManager.default()

            // return early if we have the file already
            guard let path = url.path where !fileManager.fileExists(atPath: path) else { return }

            // Create the sticker image and write it to disk.
            let data: Data
            do {
                data = try Data(contentsOf: person.imageURL)
            } catch {
                fatalError("Can't obtain contents of url")
            }
            guard
                let image = UIImage(data: data),
                let imageData = UIImagePNGRepresentation(image) else { fatalError("Unable to create image") }

            do {
                try imageData.write(to: url, options: [.atomicWrite])

            } catch {
                fatalError("Failed to write sticker image to cache: \(error)")
            }
        }


        // Set the operation's completion block to call the request's completion handler.
        operation.completionBlock = {
            do {

                let sticker = try MSSticker(contentsOfFileURL: url, localizedDescription: person.name)
                completion(sticker: sticker)
            } catch {
                print("Failed to write image to cache, error: \(error)")
            }
        }

        // Add the operation to the queue to start the work.
        self.queue.addOperation(operation)
    }
}
