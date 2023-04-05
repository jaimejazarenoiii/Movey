//
//  TrackDetailViewController.swift
//  Movey
//
//  Created by Jaime Jazareno IV on 4/4/23.
//

import RxCocoa
import RxSwift
import UIKit

class TrackDetailViewController: UIViewController {
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    var viewModel: TrackDetailViewModelTypes!
    private let disposeBag: DisposeBag = DisposeBag()

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UserDefaults.standard.set(0, forKey: "trackId")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupFavoriteButton()
        setupBindings()
    }

    private func setupFavoriteButton() {
        favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
    }


    private func setupBindings() {
        viewModel.outputs.track.observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] track in
                guard let self, let track else { return }
                self.favoriteButton.isSelected = track.isFavorite ?? false
                self.titleLabel.text = track.trackName
                self.genreLabel.text = track.primaryGenreName
                self.priceLabel.text = "$\(track.trackPrice ?? 0.0)"
                self.imageView.kf.indicatorType = .activity
                self.imageView.kf.setImage(with: URL(string: track.artworkUrl100))
                self.descriptionLabel.text = track.longDescription
            }).disposed(by: disposeBag)

        favoriteButton.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            self.viewModel.inputs.favorite(track: self.viewModel.outputs.track.value!,
                                           isFavorite: !self.favoriteButton.isSelected)
        }).disposed(by: disposeBag)
        viewModel.inputs.viewDidLoad()
    }

}
