//
//  AnimeListConfigurator.swift
//  AnimeList
//
//  Created by Ксения Афанасьева on 16.01.2019.
//  Copyright © 2019 Ксения Афанасьева. All rights reserved.
//

import UIKit

protocol AnimeListConfiguratorInterface {
    func configureAnimeListModule() -> UIViewController
    func configureAnimeDetailModule(anime: Anime) -> UIViewController
}

class AnimeListConfigurator: AnimeListConfiguratorInterface {
    func configureAnimeListModule() -> UIViewController {
        guard let animeListViewController = UIStoryboard(name: AnimeListViewController.className, bundle: nil).instantiateInitialViewController() as? AnimeListViewController else {
            fatalError("Couldn't instantiate " + AnimeListViewController.className)
        }
        
        let animeListDataManager = AnimeListDataManager()
        let animeListRouter = AnimeListRouter(configurator: self)
        let animeListModel = AnimeListModel(dataManager: animeListDataManager, router: animeListRouter)
        animeListViewController.animeListModel = animeListModel
        animeListViewController.loadingModel = animeListModel
        
        return animeListViewController
    }
    
    func configureAnimeDetailModule(anime: Anime) -> UIViewController {
        guard let animeDetailViewController = UIStoryboard(name: AnimeDetailViewController.className, bundle: nil).instantiateInitialViewController() as? AnimeDetailViewController else {
            fatalError("Couldn't instantiate " + AnimeDetailViewController.className)
        }
        
        let animeDetailDataManager = AnimeDetailDataManager()
        let animeDetailRouter = AnimeListRouter(configurator: AnimeDetailConfigurator())
        let animeDetailModel = animeDetailModel(dataManager: animeDetailDataManager, router: animeDetailRouter)
        animeDetailViewController.animeDetailModel = animeDetailModel
        
        return animeDetailViewController
    }
}
