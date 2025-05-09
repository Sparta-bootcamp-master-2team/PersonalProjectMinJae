import UIKit
import SnapKit
import RxSwift

final class ExchangeViewController: UIViewController {

    private let exchangeView = ExchangeView()
    private let disposeBag = DisposeBag()
    private let viewModel = ExchangeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        addViews()
        configureLayout()
        configureNavigtaioinBar()
        bind()
        viewModel.fetchData()
    }
    
    private func bind() {
        // exchangeView의 셀 선택 이벤트 수신 (ViewModel에게 데이터 요청 후 적용)
        exchangeView.cellTouchedEvents
            .subscribe(onNext: { [weak self] indexPath in
                guard let self else { return }
                self.navigationController?.pushViewController(CalculatorViewController(item: viewModel.exchageItemDTO.items[indexPath.row]), animated: true)
                // 셀 진입 시 해당 셀의 통화 문자열을 CoreData에 저장
                let currency = viewModel.exchageItemDTO.items[indexPath.row].currencyTitle
                self.viewModel.fetchLastSelectedCurrency(currency: currency)
            })
            .disposed(by: disposeBag)
        
        // exchangeView의 텍스트변경 이벤트 수신 (ViewModel에게 데이터 요청 후 적용)
        exchangeView.filteredTextEvents
            .subscribe { [weak self] text in
                guard let self,
                      let text = text
                else { return }
                
                let filteredItems = viewModel.exchageItemDTO.filterItems(searchText: text)
                self.exchangeView.fetchData(rates: filteredItems)
            }
            .disposed(by: disposeBag)
        
        // Cell Favorite Button Event -> ExchangeView -> VC 수신받기
        exchangeView.cellFavoriteButtonEvents
            .subscribe(onNext: { [weak self] currency in
                self?.viewModel.fetchFavorite(currency: currency)
            })
            .disposed(by: disposeBag)
        
        // 네트워크 작업 결과 이벤트 수신
        viewModel.state
            .observe(on: MainScheduler.instance)
            .subscribe {[weak self] state in
                guard let self else { return }
                let items = self.viewModel.exchageItemDTO.items
                switch state {
                case .dataFetchSuccess:
                    self.exchangeView.fetchData(rates: items)
                case .dataFetchFailure:
                    let alert: UIAlertController = .initErrorAlert(title: "오류", message: "데이터를 불러올 수 없습니다.")
                    self.present(alert, animated: false)
                case .dataUpdated:
                    self.exchangeView.fetchData(rates: items)
                case .coreDataFetchFailure:
                    let alert: UIAlertController = .initErrorAlert(title: "오류", message: "즐겨찾기 수정에 실패하였습니다.")
                    self.present(alert, animated: false)
                }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: Add SubView, Configure UI,Layout
private extension ExchangeViewController {
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
