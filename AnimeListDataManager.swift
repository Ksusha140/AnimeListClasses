//
//  AnimeListDataManager.swift
//  AnimeList
//
//  Created by Ксения Афанасьева on 15.01.2019.
//  Copyright © 2019 Ксения Афанасьева. All rights reserved.
//

import RealmSwift
import Moya

protocol AnimeListDataManagerInterface {
    func getAnimeList(query: String, onError: @escaping (Error?) -> Void,
                      onSuccess: @escaping ([Anime]) -> Void)
}

final class AnimeListDataManager {
    
    private let networkManager = NetworkManager()
    private var currentRequest: Cancellable?
    
    private func createAnimeFromObject(_ animeObject: AnimeObject) -> Anime {
        return Anime(id: animeObject.id, title: animeObject.title, imagePath: animeObject.imagePath,
                     score: animeObject.score, type: animeObject.type, rank: animeObject.rank.value,
                     startDate: animeObject.startDate, endDate: animeObject.endDate, episodesCount: animeObject.episodesCount.value)
    }
    
    private func getTopAnime(onError: @escaping (Error?) -> Void,
                             onSuccess: @escaping ([Anime]) -> Void) {
        let realm = try! Realm()
        let animeObjectsList = realm.objects(AnimeObject.self)
        if animeObjectsList.isEmpty {
            currentRequest = networkManager.getTopAnime(onError: { error in
                onError(error)
            }, onSuccess: { [weak self] animeList in
                self?.currentRequest = nil
                onSuccess(animeList)
            })
        } else {
            let animeList: [Anime] = animeObjectsList.map { createAnimeFromObject($0) }
            let sortedAnimeList = animeList.filter { $0.rank != nil }.sorted(by: { $0.rank! < $1.rank! })
            let sliceUpperBound = sortedAnimeList.count < 50 ? sortedAnimeList.count : 50
            onSuccess(Array(sortedAnimeList[0..<sliceUpperBound]))
        }
    }
    
    private func search(query: String, onError: @escaping (Error?) -> Void,
                        onSuccess: @escaping ([Anime]) -> Void) {
        currentRequest = networkManager.searchAnime(query: query, onError: { error in
            onError(error)
        }, onSuccess: { [weak self] animeList in
            self?.currentRequest = nil
            onSuccess(animeList)
        })
    }
}

extension AnimeListDataManager: AnimeListDataManagerInterface {
    func getAnimeList(query: String, onError: @escaping (Error?) -> Void,
                      onSuccess: @escaping ([Anime]) -> Void) {
        currentRequest?.cancel()
        if query.isEmpty {
            getTopAnime(onError: onError, onSuccess: onSuccess)
        } else {
            search(query: query, onError: onError, onSuccess: onSuccess)
        }
    }
}
