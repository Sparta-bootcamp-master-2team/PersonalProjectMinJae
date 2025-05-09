import UIKit
import RxCocoa
import RxSwift

final class CalculatorView: UIView {
    
    private let disposeBag = DisposeBag()
    // CalculatorVC에 이벤트 방출하기 위한 Subject
    private(set) var convertButtonTapEvents = PublishSubject<String?>()
    
    private let labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .center
        stackView.backgroundColor = .background
        return stackView
    }()
    
    private let currencyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .text
        return label
    }()
    
    private let countryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        return label
    }()
    
    private let amountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "금액을 입력하세요"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        textField.textAlignment = .center
        textField.backgroundColor = .cellBackground
        return textField
    }()
    
    private let convertButton: UIButton = {
        let button = UIButton()
        button.setTitle("환율 계산", for: .normal)
        button.backgroundColor = .systemBlue
        button.titleLabel?.textColor = .white
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .text
        label.text = "계산 결과가 여기에 표시됩니다."
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .background
        addViews()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(model: ExchangeItem) {
        currencyLabel.text = model.currencyTitle
        countryLabel.text = model.countryTitle
        
        // ConvertButton 클릭 시 TextField.text 이벤트 방출 관찰자
        convertButton.rx.tap
            .withLatestFrom(amountTextField.rx.text)
            .bind(to: convertButtonTapEvents)
            .disposed(by: disposeBag)
    }
    // 결과 레이블 텍스트 변경
    func fetchedRate(result: String) {
        self.resultLabel.text = result
    }
    
}

private extension CalculatorView {
    func addViews() {
        [currencyLabel, countryLabel].forEach {
            labelStackView.addArrangedSubview($0)
        }
        [labelStackView, convertButton, amountTextField, resultLabel].forEach {
            self.addSubview($0)
        }
    }
    
    func configureLayout() {
        labelStackView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).inset(32)
            $0.centerX.equalToSuperview()
        }
        amountTextField.snp.makeConstraints {
            $0.top.equalTo(labelStackView.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(44)
        }
        convertButton.snp.makeConstraints {
            $0.top.equalTo(amountTextField.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(44)
        }
        resultLabel.snp.makeConstraints {
            $0.top.equalTo(convertButton.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
    }
}
