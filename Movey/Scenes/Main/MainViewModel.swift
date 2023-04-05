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
    func search(keyword: String?)
    func viewWillAppear()
}

protocol MainViewModelOutputs {
    var status: BehaviorRelay<Status?> { get }
    var error: BehaviorRelay<Error?> { get }
    var tracks: BehaviorRelay<[Track]?> { get }
    var filteredTracks: BehaviorRelay<[Track]?> { get }
}

protocol MainViewModelTypes {
    var inputs: MainViewModelInputs { get }
    var outputs: MainViewModelOutputs { get }
}

class MainViewModel: MainViewModelTypes, MainViewModelOutputs, MainViewModelInputs {


    var inputs: MainViewModelInputs { return self }
    var outputs: MainViewModelOutputs { return self }

    var status: RxRelay.BehaviorRelay<Status?>
    var error: RxRelay.BehaviorRelay<Error?>
    var tracks: BehaviorRelay<[Track]?>
    var filteredTracks: BehaviorRelay<[Track]?>

    private var collectionView: BehaviorRelay<UICollectionView?>

    private let disposeBag: DisposeBag = DisposeBag()
    private let trackService: TrackServiceable

    init () {
        status = .init(value: nil)
        error = .init(value: nil)
        tracks = .init(value: nil)
        collectionView = .init(value: nil)
        filteredTracks = .init(value: nil)
        trackService = TrackService()

        tracks.bind(to: filteredTracks).disposed(by: disposeBag)

        searchProperty
            .throttle(.milliseconds(400), scheduler: MainScheduler.instance)
            .map { [weak self] keyword -> [Track]? in
                guard let self else { return nil }
                guard let keyword, !keyword.isEmpty else { return self.tracks.value }
                return self.tracks.value?.filter { $0.trackName.lowercased().contains(keyword.lowercased()) }
            }
            .bind(to: filteredTracks)
            .disposed(by: disposeBag)

        Observable.merge(viewDidLoadProperty, viewWillAppearProperty, favoriteTrackProperty.map { _ in () })
            .map { Status.requesting }
            .bind(to: status)
            .disposed(by: disposeBag)

        viewDidLoadProperty.subscribe(on: MainScheduler.instance).subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            Task {
                let _ = try await self.fetchAllTracks()
                DispatchQueue.main.async {
                    let tracks = self.fetchLocalTracks()
                    self.tracks.accept(tracks!)
                    self.status.accept(.success)
                }
            }
        })
        .disposed(by: disposeBag)

        Observable.combineLatest(viewDidLoadProperty, viewWillAppearProperty)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                DispatchQueue.main.async {
                    let tracks = self.fetchLocalTracks()
                    self.tracks.accept(tracks!)
                    self.status.accept(.success)
                }
            }).disposed(by: disposeBag)

        favoriteTrackProperty.subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] track, isFavorite in
                guard let self else { return }
                DBManager.shared.update(track: track, isFavorite: isFavorite)
                let tracks = self.fetchLocalTracks()
                self.tracks.accept(tracks!)
                self.status.accept(.success)
            }).disposed(by: disposeBag)

        setCollectionViewProperty.bind(to: collectionView).disposed(by: disposeBag)
    }

    private let viewWillAppearProperty: PublishSubject<Void> = .init()
    func viewWillAppear() {
        viewWillAppearProperty.onNext(())
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

    private let searchProperty: PublishSubject<String?> = .init()
    func search(keyword: String?) {
        searchProperty.onNext(keyword)
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
