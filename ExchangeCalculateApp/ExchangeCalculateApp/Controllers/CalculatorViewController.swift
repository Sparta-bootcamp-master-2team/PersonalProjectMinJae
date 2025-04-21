import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class CalculatorViewController: UIViewController {

//    private var item: ExchangeItem?
    private let calculatorView = CalculatorView()
    private let disposeBag = DisposeBag()
    private var viewModel: CalculatorViewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addViews()
        configureLayout()
        configureNavigtaioinBar()
        bind()
    }
    // 생성 시 ExchangeItem 인자로 받도록 구현
    init(item: ExchangeItem) {
        self.viewModel = CalculatorViewModel(item: item)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 데이터 및 RxCocoa 바인딩
    private func bind() {
        calculatorView.bind(model: viewModel.item)
        
        // Convert버튼 터치시 viewModel에서 환율 계산
        calculatorView
            .convertButtonTapEvents
            .subscribe{[weak self] input in
                self?.viewModel.calculateExchangeRate(input: input)
            }
            .disposed(by: disposeBag)
        
        // 환율 계산 결과 바인딩
        viewModel.state
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] result in
                guard let self else { return }
                switch result.0 {
                case .success:
                    guard let resultString = result.1 else { return }
                    calculatorView.fetchedRate(result: resultString)
                case .failure:
                    let alert: UIAlertController = .initErrorAlert(title: "오류", message: "금액을 입력해주세요")
                    self.present(alert, animated: false)
                }
            }
            .disposed(by: disposeBag)
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
