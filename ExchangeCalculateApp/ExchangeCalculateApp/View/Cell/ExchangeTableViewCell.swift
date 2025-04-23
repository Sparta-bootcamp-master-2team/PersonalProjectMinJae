import UIKit
import SnapKit
import RxCocoa
import RxSwift

class ExchangeTableViewCell: UITableViewCell {

    static var identifier: String {
        return String(describing: ExchangeTableViewCell.self)
    }
    // ExchangeView로 전달하기 위한 객체
    private(set) var favoriteButtonEvents: PublishSubject<String?> = .init()
    var disposeBag = DisposeBag()
    
    private lazy var labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.addArrangedSubview(currencyLabel)
        stackView.addArrangedSubview(countryLabel)
        stackView.backgroundColor = .background
        return stackView
    }()
    
    private lazy var currencyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .text
        return label
    }()
    
    private lazy var countryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    private let rateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .text
        label.textAlignment = .right
        return label
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton()
        button.tintColor = .favorite
        return button
    }()
    
    private let rateChangedImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.up.square.fill"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .background
        addViews()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(model: ExchangeItem) {
        self.currencyLabel.text = model.currencyTitle
        self.countryLabel.text = model.countryTitle
        self.rateLabel.text = model.rate
        
        let imageName = model.isFavorited ? "star.fill" : "star"
        self.favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
        
        let changedRate = Double(model.changedRate)
        if abs(changedRate) > 0.01 {
            if changedRate > 0 {
                self.rateChangedImageView.image = UIImage(systemName: "chevron.up.square.fill")
                self.rateChangedImageView.tintColor = .systemRed
            } else {
                self.rateChangedImageView.image = UIImage(systemName: "chevron.down.square.fill")
                self.rateChangedImageView.tintColor = .systemBlue
            }
        } else {
            self.rateChangedImageView.image = nil
        }
        
    }
    // 바인딩
    func bind() {
        favoriteButton.rx.tap
            .withUnretained(self)
            .map { $0.0.currencyLabel.text }
            .bind(to: favoriteButtonEvents)
            .disposed(by: disposeBag)
        
    }
    // 셀 재사용시 DisposeBag 비우기
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

}

private extension ExchangeTableViewCell {
    func addViews() {
        [labelStackView, rateLabel, favoriteButton, rateChangedImageView].forEach {
            contentView.addSubview($0)
        }
    }
    
    func configureLayout() {
        labelStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(16)
        }
        
        rateLabel.snp.makeConstraints {
            $0.trailing.equalTo(rateChangedImageView.snp.leading).offset(-8)
            $0.centerY.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(labelStackView.snp.trailing).offset(16)
            $0.width.equalTo(120)
        }
        
        favoriteButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(10)
            $0.width.equalTo(32)
        }
        
        rateChangedImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
            $0.trailing.equalTo(favoriteButton.snp.leading).offset(-8)
        }
    }
}
