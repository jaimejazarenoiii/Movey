//
//  MainViewModel.swift
//  Movey
//
//  Created by Jaime Jazareno III on 29/3/2023.
//

import RxCocoa
import RxSwift
import UIKit

protocol MainViewModelInputs {
    func viewDidLoad()
    func set(collectionView: UICollectionView)
    func favorite(track: Track, isFavorite: Bool)
}

protocol MainViewModelOutputs {
    var status: BehaviorRelay<Bool?> { get }
    var error: BehaviorRelay<Error?> { get }
    var tracksData: BehaviorRelay<TracksCollectionViewCellData?> { get }
}

protocol MainViewModelTypes {
    var inputs: MainViewModelInputs { get }
    var outputs: MainViewModelOutputs { get }
}

class MainViewModel: MainViewModelTypes, MainViewModelOutputs, MainViewModelInputs {


    var inputs: MainViewModelInputs { return self }
    var outputs: MainViewModelOutputs { return self }

    var status: RxRelay.BehaviorRelay<Bool?>
    var error: RxRelay.BehaviorRelay<Error?>
    var tracksData: BehaviorRelay<TracksCollectionViewCellData?>

    private var collectionView: BehaviorRelay<UICollectionView?>

    private let disposeBag: DisposeBag = DisposeBag()
    private let trackService: TrackServiceable

    init () {
        status = .init(value: nil)
        error = .init(value: nil)
        tracksData = .init(value: nil)
        collectionView = .init(value: nil)
        trackService = TrackService()

        viewDidLoadProperty.subscribe(on: MainScheduler.instance).subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            Task {
                let _ = try await self.fetchAllTracks()
                DispatchQueue.main.async {
                    let tracks = DBManager.shared.getTracks()
                    self.tracksData.accept(TracksCollectionViewCellData(section: 0, tracks: tracks))
                }
            }
        })
        .disposed(by: disposeBag)

        favoriteTrackProperty.subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] track, isFavorite in
                guard let self else { return }
                DBManager.shared.update(track: track, isFavorite: isFavorite)
                let tracks = self.fetchLocalTracks()
                self.tracksData.accept(TracksCollectionViewCellData(section: 0, tracks: tracks!))
            }).disposed(by: disposeBag)

        setCollectionViewProperty.bind(to: collectionView).disposed(by: disposeBag)
    }

    private let viewDidLoadProperty: PublishSubject<Void> = .init()
    func viewDidLoad() {
        viewDidLoadProperty.onNext(())
    }

    private let setCollectionViewProperty: PublishSubject<UICollectionView> = .init()
    func set(collectionView: UICollectionView) {
        setCollectionViewProperty.onNext(collectionView)
    }

    private let favoriteTrackProperty: PublishSubject<(Track, Bool)> = .init()
    func favorite(track: Track, isFavorite: Bool) {
        favoriteTrackProperty.onNext((track, isFavorite))
    }

    private func fetchAllTracks() async throws -> [Track]? {
        do {
            return try await trackService.fetchAllTrack()
        } catch(let err) {
            print("There's an error: \(err.localizedDescription)")
            return nil
        }
    }

    private func fetchLocalTracks() -> [Track]? {
        DBManager.shared.getTracks().map { $0 }
    }
}
