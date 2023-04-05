//
//  TrackCollectionViewCell.swift
//  Movey
//
//  Created by Jaime Jazareno IV on 3/29/23.
//

import Foundation
import Kingfisher
import RxCocoa
import RxSwift
import UIKit

// MARK: Delegate hooks for this cell
protocol TrackCollectionViewCellDelegate: AnyObject {
    func didTapFavoriteButton(isFavorite: Bool, indexPath: IndexPath)
}

class TrackCollectionViewCell: UICollectionViewCell {

    // MARK: Variables
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    private let disposeBag: DisposeBag = DisposeBag()
    private var indexPath: IndexPath?
    weak var delegate: TrackCollectionViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupFavoriteButton()
        setupBindings()
    }

    private func setupFavoriteButton() {
        favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
    }

    // MARK: Bindings
    private func setupBindings() {
        favoriteButton.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] _ in
            guard let self, let indexPath = self.indexPath else { return }
            self.delegate?.didTapFavoriteButton(isFavorite: !self.favoriteButton.isSelected, indexPath: indexPath)
        }).disposed(by: disposeBag)
    }

    // MARK: Set function
    /// To be called out outisde of this class and triggers update of UI
    func set(track: Track, indexPath: IndexPath) {
        titleLabel.text = track.trackName
        genreLabel.text = track.primaryGenreName
        priceLabel.text = "$\(track.trackPrice ?? 0)"
        backgroundImageView.kf.indicatorType = .activity
        backgroundImageView.kf.setImage(with: URL(string: track.artworkUrl100))
        favoriteButton.isSelected = track.isFavorite ?? false

        self.indexPath = indexPath
    }
}
