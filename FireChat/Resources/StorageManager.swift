//
//  StorageManager.swift
//  FireChat
//
//  Created by Дмитро Вакулінський on 15.06.2021.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion ) {
    
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: {metadata, error in
            guard error == nil else {
                print("Failed to upload")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL(completion: {url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToDownloadUrl))
                    return
                }
                let urlString = url.absoluteString
                print("download url returnet: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToDownloadUrl
    }
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)
        
        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToDownloadUrl))
                return
            }
            
            completion(.success(url))
        })
    }
}

