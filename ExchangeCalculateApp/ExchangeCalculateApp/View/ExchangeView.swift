import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ExchangeView: UIView {
    
    private let emptyView = EmptyView()
    
    // VC로 이벤트 전달하기 위한 Subjects
    // cellTouchedEvents: Cell 클릭 시 이벤트 방출, VC에서 수신
    // filteredTextEvents: SearchBar의 text값이 변경될 때 이벤트 방출, VC에서 수신
    private(set) var cellTouchedEvents: PublishSubject<IndexPath> = .init()
    private(set) var filteredTextEvents: PublishSubject<String?> = .init()
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
            .bind(to: filteredTextEvents)
            .disposed(by: disposeBag)
        
        // Cell 선택시 이벤트 방출
        exchangeTableView.rx.itemSelected
            .bind(to: cellTouchedEvents)
            .disposed(by: disposeBag)
    }
    // UI에 필요한 데이터 불러오기 (DTO -> ViewModel -> VC -> ExchangeView)
    func fetchData(rates: [ExchangeItem]) {
        makeSnapshotApply(rates: rates)
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
