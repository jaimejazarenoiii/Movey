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
}

protocol MainViewModelOutputs {
    var status: BehaviorRelay<Bool?> { get }
    var error: BehaviorRelay<Error?> { get }
    var tracks: BehaviorRelay<[Track]?> { get }
}

protocol MainViewModelTypes {
    var inputs: MainViewModelInputs { get }
    var outputs: MainViewModelOutputs { get }
}

struct MainCollectionViewCellData {
    let section: Int
    let tracks: [Track]
}

class MainViewModel: MainViewModelTypes, MainViewModelOutputs, MainViewModelInputs {


    var inputs: MainViewModelInputs { return self }
    var outputs: MainViewModelOutputs { return self }

    var status: RxRelay.BehaviorRelay<Bool?>
    var error: RxRelay.BehaviorRelay<Error?>
    var tracks: BehaviorRelay<[Track]?>

    private var collectionView: BehaviorRelay<UICollectionView?>

    private let disposeBag: DisposeBag = DisposeBag()
    private let trackService: TrackServiceable

    init () {
        status = .init(value: nil)
        error = .init(value: nil)
        tracks = .init(value: nil)
        collectionView = .init(value: nil)
        trackService = TrackService()

        viewDidLoadProperty.flatMap { [weak self] _ -> Observable<[Track]?> in
            guard let self else { return Observable.empty() }
            return Observable.create { observer in
                Task {
                    observer.onNext(await self.fetchAllTracks())
                    observer.onCompleted()
                }
            }
        }
        .subscribe(onNext: { [weak self] tracks in
            guard let self else { return }
            self.tracks.accept(tracks)
        })
        .disposed(by: disposeBag)

        tracks.filter { $0 != nil }.flatMap { [weak self] ->

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

    private func fetchAllTracks() async throws -> [Track]? {
        do {
            return try await trackService.fetchAllTrack()
        } catch(let err) {
            print("There's an error: \(err.localizedDescription)")
        }
    }

}
