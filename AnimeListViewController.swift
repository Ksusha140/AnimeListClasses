//
//  AnimeListViewController.swift
//  AnimeList
//
//  Created by Ксения Афанасьева on 13.01.2019.
//  Copyright © 2019 Ксения Афанасьева. All rights reserved.
//

import UIKit

final class AnimeListViewController: UIViewController, Named {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var loadingView: LoadingView! {
        didSet {
            loadingModel.loadingView = loadingView
        }
    }
    
    let cellId = AnimeCollectionViewCell.className
    
    var animeListModel: AnimeListModelInterface! {
        didSet {
            animeListModel.animeListView = self
        }
    }
    var loadingModel: LoadingModelInterface!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)
        animeListModel.getAnimeList(query: "")
    }
}

extension AnimeListViewController: AnimeListViewInterface {
    func reloadData() {
        collectionView.reloadData()
    }
}

extension AnimeListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText.count > 3 else {
            animeListModel.getAnimeList(query: "")
            return
        }
        
        animeListModel.getAnimeList(query: searchText)
    }
}

extension AnimeListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return animeListModel.numberOfItemsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! AnimeCollectionViewCell
        animeListModel.setupCell(cell: cell, indexPath: indexPath)
        
        return cell
    }
}

extension AnimeListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        animeListModel.initiateActionOnCellSelection(at: indexPath)
    }
}

extension AnimeListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 16, height: 220)
    }
}
