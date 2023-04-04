//
//  MainViewController.swift
//  Movey
//
//  Created by Jaime Jazareno III on 28/3/2023.
//

import Blueprints
import RxCocoa
import RxSwift
import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    private let viewModel: MainViewModelTypes = MainViewModel()
    private var tracksDataSource: UICollectionViewDiffableDataSource<Int, Track>?
    private var tracksSnapshot: NSDiffableDataSourceSnapshot<Int, Track> = NSDiffableDataSourceSnapshot<Int, Track>()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionViewDataSource()
        setupCollectionView()
        setupBindings()
    }

    private func setupCollectionViewDataSource() {
        tracksSnapshot = NSDiffableDataSourceSnapshot<Int, Track>()
        tracksSnapshot.appendSections([0])
        tracksSnapshot.appendItems([])
        tracksDataSource = UICollectionViewDiffableDataSource<Int, Track>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackCollectionViewCell", for: indexPath) as? TrackCollectionViewCell else {
                fatalError("Could not dequeue cell")
            }
            cell.set(track: item, indexPath: indexPath)
            cell.delegate = self
            return cell
        }
        tracksDataSource?.apply(tracksSnapshot, animatingDifferences: false)
    }

    private func setupCollectionView() {
        let blueprintLayout = VerticalBlueprintLayout(
          itemsPerRow: 3,
          height: 250,
          minimumInteritemSpacing: 10,
          minimumLineSpacing: 10,
          sectionInset: EdgeInsets(top: 10, left: 10, bottom: 10, right: 10),
          stickyHeaders: true,
          stickyFooters: false
        )
        collectionView.collectionViewLayout = blueprintLayout
        collectionView.register(UINib(nibName: "TrackCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TrackCollectionViewCell")
        collectionView.dataSource = tracksDataSource
    }

    private func setupBindings() {
        viewModel.outputs.tracksData.observe(on: MainScheduler.instance)
            .filter { $0 != nil }
            .map { $0! }
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] tracksData in
                guard let self, var newSnapshot = self.tracksDataSource?.snapshot() else { return }
                newSnapshot.deleteAllItems()
                newSnapshot.appendSections([0])
                newSnapshot.appendItems(tracksData.tracks, toSection: 0)
                newSnapshot.reloadItems(tracksData.tracks)
                self.tracksDataSource?.apply(newSnapshot, animatingDifferences: false)
            }).disposed(by: disposeBag)

        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self else { return }
                let item = self.viewModel.outputs.tracksData.value!.tracks[indexPath.row]
                let vm = TrackDetailViewModel()
                let storyboard = UIStoryboard(name: "TrackDetailViewController", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "TrackDetailViewController") as! TrackDetailViewController
                vc.viewModel = vm
                vm.inputs.set(track: item)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)

        viewModel.inputs.viewDidLoad()
    }

}

extension MainViewController: TrackCollectionViewCellDelegate {
    func didTapFavoriteButton(isFavorite: Bool, indexPath: IndexPath) {
        viewModel.inputs.favorite(track: viewModel.outputs.tracksData.value!.tracks[indexPath.row], isFavorite: isFavorite)
    }
}
