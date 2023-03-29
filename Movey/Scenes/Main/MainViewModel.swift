//
//  MainViewModel.swift
//  Movey
//
//  Created by Jaime Jazareno III on 29/3/2023.
//

import RxCocoa
import RxSwift

protocol MainViewModelInputs {
    func viewDidLoad()
}

protocol MainViewModelOutputs {
    var status: BehaviorRelay<Bool?> { get }
    var error: BehaviorRelay<Error?> { get }
}

protocol MainViewModelTypes {
    var inputs: MainViewModelInputs { get }
    var outputs: MainViewModelOutputs { get }
}

struct MainViewModel: MainViewModelTypes, MainViewModelOutputs, MainViewModelInputs {
    var inputs: MainViewModelInputs { return self }
    var outputs: MainViewModelOutputs { return self }

    var status: RxRelay.BehaviorRelay<Bool?>
    var error: RxRelay.BehaviorRelay<Error?>

    init () {
        status = .init(value: nil)
        error = .init(value: nil)
    }

    private let viewDidLoadProperty: PublishSubject<Void> = .init()
    func viewDidLoad() {
        viewDidLoadProperty.onNext(())
    }


}
