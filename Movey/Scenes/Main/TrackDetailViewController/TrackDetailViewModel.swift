//
//  TrackDetailViewModel.swift
//  Movey
//
//  Created by Jaime Jazareno IV on 4/4/23.
//

import RxCocoa
import RxSwift

// MARK: Input methods
protocol TrackDetailViewModelInputs {
    func viewDidLoad()
    func favorite(track: Track, isFavorite: Bool)
    func set(track: Track)
}

// MARK: Output variables
protocol TrackDetailViewModelOutputs {
    var status: BehaviorRelay<Bool?> { get }
    var error: BehaviorRelay<Error?> { get }
    var track: BehaviorRelay<Track?> { get }
}

// MARK: Type wrapper
protocol TrackDetailViewModelTypes {
    var inputs: TrackDetailViewModelInputs { get }
    var outputs: TrackDetailViewModelOutputs { get }
}

// MARK: Class implementation
class TrackDetailViewModel: TrackDetailViewModelTypes, TrackDetailViewModelOutputs, TrackDetailViewModelInputs {
    var inputs: TrackDetailViewModelInputs { return self }
    var outputs: TrackDetailViewModelOutputs { return self }

    var status: RxRelay.BehaviorRelay<Bool?>
    var error: RxRelay.BehaviorRelay<Error?>
    var track: RxRelay.BehaviorRelay<Track?>

    private let disposeBag: DisposeBag = DisposeBag()

    /// Variable init plus bindings
    init() {
        status = .init(value: nil)
        error = .init(value: nil)
        track = .init(value: nil)

        /// Trigger the setting of track when view did load occurs
        Observable.combineLatest(setTrackProperty.asObservable(), viewDidLoadProperty.asObservable())
            .subscribe(on: MainScheduler.instance)
            .map { $0.0 }
            .bind(to: track)
            .disposed(by: disposeBag)

        favoriteTrackProperty.subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] track, isFavorite in
                guard let self else { return }
                DBManager.shared.update(track: track, isFavorite: isFavorite)
                let newTrack = DBManager.shared.getTrack(id: track.trackId)
                self.track.accept(newTrack)
            }).disposed(by: disposeBag)
    }

    private let setTrackProperty: PublishSubject<Track> = .init()
    func set(track: Track) {
        setTrackProperty.onNext(track)
    }

    private let viewDidLoadProperty: PublishSubject<Void> = .init()
    func viewDidLoad() {
        viewDidLoadProperty.onNext(())
    }

    private let favoriteTrackProperty: PublishSubject<(Track, Bool)> = .init()
    func favorite(track: Track, isFavorite: Bool) {
        favoriteTrackProperty.onNext((track, isFavorite))
    }
}
