//
//  MainViewController.swift
//  Movey
//
//  Created by Jaime Jazareno III on 28/3/2023.
//

import RxCocoa
import RxSwift
import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    private let viewModel: MainViewModelTypes = MainViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupBindings()
    }

    private func setupBindings() {
        
        viewModel.inputs.viewDidLoad()
    }

}

