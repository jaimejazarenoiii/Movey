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

    private let disposeBag: DisposeBag = DisposeBag()
    private let trackService: TrackServiceable

    init () {
        status = .init(value: nil)
        error = .init(value: nil)
        tracks = .init(value: nil)
        trackService = TrackService()

        viewDidLoadProperty.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            Task {
                await self.fetchAllTracks()
            }
        }).disposed(by: disposeBag)
    }

    private let viewDidLoadProperty: PublishSubject<Void> = .init()
    func viewDidLoad() {
        viewDidLoadProperty.onNext(())
    }

    private func fetchAllTracks() async {
        do {
            try await trackService.fetchAllTrack()

        } catch(let err) {
            print("There's an error: \(err.localizedDescription)")
        }
    }

}
