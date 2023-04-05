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
    // MARK: Variables
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchTextField: UITextField!

    @IBOutlet weak var dateLabel: UILabel!
    private let viewModel: MainViewModelTypes = MainViewModel()
    private var tracksDataSource: UICollectionViewDiffableDataSource<Int, Track>?
    private var tracksSnapshot: NSDiffableDataSourceSnapshot<Int, Track> = NSDiffableDataSourceSnapshot<Int, Track>()
    private let disposeBag = DisposeBag()

    // MARK: Override functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.viewWillAppear()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDateLabel()
        setupCollectionViewDataSource()
        setupCollectionView()
        setupBindings()
        // Create Date
        let date = Date()

        // Create Date Formatter
        let dateFormatter = DateFormatter()

        // Set Date/Time Style
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
        UserDefaults.standard.set(dateFormatter.string(from: date), forKey: "lastSession")
        guard UserDefaults.standard.integer(forKey: "trackId") == 0 else {
            return DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                guard let track = DBManager.shared.getTrack(id: UserDefaults.standard.integer(forKey: "trackId")) else { return }
                return self.navigateToTrackDetail(track: track)
            }
        }
    }

    // MARK: Private functions
    private func setupDateLabel() {
        let isoDate = UserDefaults.standard.string(forKey: "lastSession") ?? ""

        dateLabel.text = "Last session: \(isoDate)"
    }

    private func setupCollectionViewDataSource() {
        tracksSnapshot = NSDiffableDataSourceSnapshot<Int, Track>()
        tracksSnapshot.appendSections([0])
        tracksSnapshot.appendItems([])
        tracksDataSource = UICollectionViewDiffableDataSource<Int,
                                                              Track>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackCollectionViewCell",
                                                                for: indexPath) as? TrackCollectionViewCell else {
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
        searchTextField.rx.text.orEmpty
            .subscribe(onNext: viewModel.inputs.search(keyword:))
            .disposed(by: disposeBag)

        viewModel.outputs.filteredTracks.observe(on: MainScheduler.instance)
            .filter { $0 != nil }
            .map { $0! }
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] tracks in
                guard let self, var newSnapshot = self.tracksDataSource?.snapshot() else { return }
                newSnapshot.deleteAllItems()
                newSnapshot.appendSections([0])
                newSnapshot.appendItems(tracks, toSection: 0)
                newSnapshot.reloadItems(tracks)
                self.tracksDataSource?.apply(newSnapshot, animatingDifferences: false)
            }).disposed(by: disposeBag)

        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self else { return }
                let item = self.viewModel.outputs.filteredTracks.value![indexPath.row]
                self.navigateToTrackDetail(track: item)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.status.observe(on: MainScheduler.instance)
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .filter { $0 == .success }
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)

        viewModel.outputs.status.observe(on: MainScheduler.instance)
            .filter { $0 == .requesting}
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

                let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
                loadingIndicator.hidesWhenStopped = true
                loadingIndicator.style = UIActivityIndicatorView.Style.medium
                loadingIndicator.startAnimating()

                alert.view.addSubview(loadingIndicator)
                self.present(alert, animated: true, completion: nil)
            }).disposed(by: disposeBag)

        viewModel.inputs.viewDidLoad()
    }

    private func navigateToTrackDetail(track: Track) {
        let vm = TrackDetailViewModel()
        let storyboard = UIStoryboard(name: "TrackDetailViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TrackDetailViewController") as! TrackDetailViewController
        vc.viewModel = vm
        vm.inputs.set(track: track)
        UserDefaults.standard.set(track.trackId, forKey: "trackId")
        dismiss(animated: true)
        navigationController?.pushViewController(vc, animated: true)
    }

}

// MARK: Hook from TrackCollectionViewCell
extension MainViewController: TrackCollectionViewCellDelegate {
    func didTapFavoriteButton(isFavorite: Bool, indexPath: IndexPath) {
        viewModel.inputs.favorite(track: viewModel.outputs.filteredTracks.value![indexPath.row], isFavorite: isFavorite)
    }
}
