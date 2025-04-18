import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ExchangeView: UIView {
    
    private let emptyView = EmptyView()
    
    // 메인 TableView에 뿌려질 데이터 (ViewModel 구현 전 임시)
    private var items: [ExchangeItem] = []
    private var filteredItems: [ExchangeItem] = []
    // VC로 이벤트 전달하기 위한 Subject
    private(set) var cellTouchedEvents: PublishSubject<ExchangeItem> = .init()
    private let disposeBag = DisposeBag()
    
    // 메인 TableView
    private lazy var exchangeTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ExchangeTableViewCell.self, forCellReuseIdentifier: ExchangeTableViewCell.identifier)
        tableView.delegate = self
        tableView.backgroundView = emptyView
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private lazy var searchBar = UISearchBar()
    // MARK: UITableViewDiffableDataSource
    typealias DataSource = UITableViewDiffableDataSource<Section, ExchangeItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ExchangeItem>
    
    enum Section {
        case main
    }
    
    private var dataSource: DataSource?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
        configureLayout()
        configureTableView()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // SearchBar 바인딩
    private func bind() {
        // SearchBar의 텍스트 변경마다 이벤트 방출
        searchBar.rx.text
            .subscribe(onNext: { [weak self] text in
                self?.filterItems(searchText: text ?? "")
            })
            .disposed(by: disposeBag)
        
        // Cell 선택시 이벤트 방출
        exchangeTableView.rx.itemSelected
            .map{ [unowned self] in
                self.filteredItems[$0.row]
            }
            .bind(to: cellTouchedEvents)
            .disposed(by: disposeBag)
    }
    // 데이터 저장
    func fetchData(rates: [ExchangeItem]) {
        makeSnapshotApply(rates: rates)
    }
    
    // 데이터 필터링 후 적용
    private func filterItems(searchText: String) {
        let text = searchText.uppercased()
        filteredItems = items.filter { $0.currencyTitle.contains(text) || $0.countryTitle.uppercased().contains(text) }
        
        searchText == "" ? filteredItems = items : nil
    }
    
    // Snapshot 생성
    private func makeSnapshotApply(rates: [ExchangeItem]) {
        var snapShot = Snapshot()
        snapShot.appendSections([.main])
        snapShot.appendItems(rates)
        
        dataSource?.apply(snapShot, animatingDifferences: false)
        dataSource?.showEmptyView(tableView: exchangeTableView)
    }
    
    // TablewView 구성
    private func configureTableView() {
        dataSource = DataSource(tableView: self.exchangeTableView) { tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ExchangeTableViewCell.identifier, for: indexPath) as? ExchangeTableViewCell else { return UITableViewCell() }
            cell.configure(model: item)
            return cell
        }
    }
}

private extension ExchangeView {
    private func addViews() {
        [exchangeTableView, searchBar].forEach {
            self.addSubview($0)
        }
    }
    
    private func configureLayout() {
        searchBar.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }
        exchangeTableView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.leading.trailing.bottom.equalTo(self.safeAreaLayoutGuide)
        }
        emptyView.snp.makeConstraints {
            $0.edges.equalTo(exchangeTableView)
            $0.center.equalTo(exchangeTableView)
        }
    }
}

// MARK: UITableViewDelegate
extension ExchangeView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
