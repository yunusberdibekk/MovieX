//
//  MAUserDefaultsManager.swift
//  MovieApp
//
//  Created by Yunus Emre Berdibek on 1.03.2024.
//

import Foundation

protocol MAUserDefaultsManager {
    func fetch(_ key: UserDefaultsKey,
               completion: @escaping (Result<[Movie], UserDefaultsError>) -> Void)

    func save(_ key: UserDefaultsKey,
              movies: [Movie]) -> UserDefaultsError?

    func update(_ status: UpdateStatus,
                movie: Movie,
                completion: @escaping (UserDefaultsError?) -> Void)

    func check(_ movie: Movie, completion: @escaping (Bool) -> Void)

    func remove(_ key: UserDefaultsKey)
}

extension MAUserDefaultsManager {
    func fetch(_ key: UserDefaultsKey,
               completion: @escaping (Result<[Movie], UserDefaultsError>) -> Void)
    {
        guard let data = UserDefaults.standard.object(forKey: key.rawValue) as? Data else {
            completion(.success([]))
            return
        }

        do {
            let decoder = JSONDecoder()
            let decodedModel = try decoder.decode([Movie].self, from: data)

            completion(.success(decodedModel))
        } catch {
            completion(.failure(.unableToDefaults))
        }
    }

    func save(_ key: UserDefaultsKey,
              movies: [Movie]) -> UserDefaultsError?
    {
        do {
            let encoder = JSONEncoder()
            let encodedModel = try encoder.encode(movies)

            UserDefaults.standard.setValue(encodedModel, forKey: key.rawValue)
        } catch {
            return .unableToDefaults
        }

        return nil
    }

    func update(_ status: UpdateStatus, movie: Movie, completion: @escaping (UserDefaultsError?) -> Void) {
        fetch(.downloads) { result in
            switch result {
            case .success(var movies):
                switch status {
                case .add:
                    guard !movies.contains(where: { $0.id == movie.id }) else {
                        return completion(.alreadyInDownloads)
                    }
                    movies.append(movie)
                case .remove:
                    movies.removeAll(where: { $0.id == movie.id })
                }
                completion(save(.downloads, movies: movies))
            case .failure(let error):
                completion(error)
            }
        }
    }

    func check(_ movie: Movie, completion: @escaping (Bool) -> Void) {
        fetch(.downloads) { result in
            switch result {
            case .success(let movies):
                guard !movies.contains(where: { $0.id == movie.id }) else {
                    return completion(true)
                }
                completion(false)
            case .failure:
                completion(false)
            }
        }
    }

    func remove(_ key: UserDefaultsKey) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
}

enum UpdateStatus {
    case add
    case remove
}

enum UserDefaultsKey: String {
    case downloads
}

enum UserDefaultsError: Error {
    case unableToDefaults
    case alreadyInDownloads
    case invalidData

    var description: String {
        switch self {
        case .unableToDefaults:
            return "@UserDefaultsError: Unable to downloads list."
        case .alreadyInDownloads:
            return "@UserDefaultsError: This movie already in downloads list."
        case .invalidData:
            return "@UserDefaultsError: Invalid data."
        }
    }
}
