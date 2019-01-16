//
//  AnimeListModel.swift
//  AnimeList
//
//  Created by Ксения Афанасьева on 15.01.2019.
//  Copyright © 2019 Ксения Афанасьева. All rights reserved.
//

import Foundation

protocol AnimeListViewInterface: class {
    var animeListModel: AnimeListModelInterface! { get set }
    func reloadData()
}

protocol AnimeListModelInterface: class {
    var animeListView: AnimeListViewInterface? { get set }
    func getAnimeList(query: String)
    func numberOfItemsInSection(_ section: Int) -> Int
    func setupCell(cell: AnimeCellViewInterface, indexPath: IndexPath)
    func initiateActionOnCellSelection(at indexPath: IndexPath)
}

final class AnimeListModel: NSObject, AnimeListModelInterface, LoadingModelInterface {
    
    weak var animeListView: AnimeListViewInterface?
    weak var loadingView: LoadingViewInterface?
    private let dataManager: AnimeListDataManagerInterface
    private let router: AnimeListRouterInterface
    
    private var animeCellsModels = [AnimeCellModelInterface]() {
        didSet {
            animeListView?.reloadData()
        }
    }
    
    private var animeList = [Anime]() {
        didSet {
            animeCellsModels = animeList.map { AnimeCellModel(anime: $0) }
        }
    }
    
    init(dataManager: AnimeListDataManagerInterface, router: AnimeListRouterInterface) {
        self.dataManager = dataManager
        self.router = router
    }
}

extension AnimeListModel {
    func getAnimeList(query: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        perform(#selector(getData(query:)), with: query, afterDelay: 0.3, inModes: [.common])
    }
    
    @objc private func getData(query: String) {
        let stateString = query.isEmpty ? String.ANL.downloadingContent : String.ANL.animeSearch
        loadingView?.startLoading(withState: stateString)
        dataManager.getAnimeList(query: query, onError: { [weak self] error in
            self?.animeList = []
            let errorMessage = query.isEmpty ? String.ANL.downloadError : String.ANL.noSearchResults
            self?.loadingView?.stopLoading(withMessage: errorMessage)
        }, onSuccess: { [weak self] animeList in
            self?.animeList = animeList
            self?.loadingView?.hide()
        })
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return animeCellsModels.count
    }
    
    func setupCell(cell: AnimeCellViewInterface, indexPath: IndexPath) {
        cell.animeCellModel = animeCellsModels[indexPath.item]
    }
    
    func initiateActionOnCellSelection(at indexPath: IndexPath) {
        router.routeToAnimeDetail(anime: animeList[indexPath.row])
    }
}
