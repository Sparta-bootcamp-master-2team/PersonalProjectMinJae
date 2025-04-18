import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class CalculatorViewController: UIViewController {

    private var item: ExchangeItem?
    private let calculatorView = CalculatorView()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addViews()
        configureLayout()
        configureNavigtaioinBar()
        bind()
    }
    // 생성 시 ExchangeItem 인자로 받도록 구현
    convenience init(item: ExchangeItem) {
        self.init(nibName: nil, bundle: nil)
        self.item = item
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 데이터 및 RxCocoa 바인딩
    private func bind() {
        guard let item else { return }
        calculatorView.bind(model: item)
        
        calculatorView
            .convertButtonTapEvents
            .subscribe{[weak self] input in
                self?.calculateExchangeRate(input: input)
            }
            .disposed(by: disposeBag)
    }
    
    // 입력값 검증
    private func isValidInput(input: String?) -> Bool {
        guard let text = input,
              text != "",
              Int(text) != nil else {
            return false
        }
        return true
    }
    
    // 환율 계산
    private func calculateExchangeRate(input: String?) {
        if !isValidInput(input: input) {
            let alert: UIAlertController = .initErrorAlert(title: "오류", message: "금액을 입력해주세요")
            self.present(alert, animated: false)
        } else {
            guard let input = Double(input ?? ""),
                  let rate = Double(item?.rate ?? "") else { return }
            let digit: Double = pow(10, 2)
            let result = String(format: "%.2f", round(input * rate * digit) / digit)
            let inputString = String(format: "%.2f", input)
            let string = "$\(inputString) -> \(result) \(item?.currencyTitle ?? "")"
            
            calculatorView.fetchedRate(result: string)
        }
    }
    
}
// MARK: Add SubView, Configure UI,Layout
private extension CalculatorViewController {
    func addViews() {
        view.addSubview(calculatorView)
    }
    func configureLayout() {
        calculatorView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configureNavigtaioinBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "환율 계산기"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
}
