import UIKit
import SnapKit
import RxSwift

final class ViewController: UIViewController {

    private let exchangeView = ExchangeView()
    private let disposeBag = DisposeBag()
    private let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addViews()
        configureLayout()
        configureNavigtaioinBar()
        bind()
        viewModel.fetchData()
    }
    
    private func bind() {
        // exchangeView의 subject 이벤트 수신
        exchangeView
            .cellTouchedEvents
            .subscribe(onNext: { [weak self] item in
                self?.navigationController?.pushViewController(CalculatorViewController(itme: item), animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.dataLoadState
            .observe(on: MainScheduler.instance)
            .subscribe {[weak self] state in
                guard let self else { return }
                let items = self.viewModel.exchageItemDTO.items
                switch state {
                case .success:
                    self.exchangeView.fetchData(rates: items)
                case .failure:
                    let alert: UIAlertController = .initErrorAlert(title: "오류", message: "데이터를 불러올 수 없습니다.")
                    self.present(alert, animated: false)
                }
            }
            .disposed(by: disposeBag)
    }
    
}
// MARK: Add SubView, Configure UI,Layout
private extension ViewController {
    func addViews() {
        view.addSubview(exchangeView)
    }
    
    func configureLayout() {
        exchangeView.snp.makeConstraints {
            $0.top.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }
    }
    // Configure NavigationBar
    func configureNavigtaioinBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "환율 정보"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
}
