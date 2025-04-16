import UIKit
import SnapKit
import Alamofire
import RxSwift
import RxCocoa

// Cell Model
struct ExchangeItem: Hashable {
    let currencyTitle: String
    let countryTitle: String
    let rate: String
}

final class ViewController: UIViewController {

    // 메인 TableView
    private lazy var exchangeTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ExchangeTableViewCell.self, forCellReuseIdentifier: ExchangeTableViewCell.identifier)
        tableView.delegate = self
        tableView.backgroundView = emptyView
        return tableView
    }()
    
    private let disposeBag = DisposeBag()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        return searchBar
    }()
    
    private lazy var emptyView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        let label = UILabel()
        label.text = "검색 결과 없음"
        label.textAlignment = .center
        label.textColor = .gray
        view.addSubview(label)
        label.snp.makeConstraints {
            $0.edges.equalTo(view)
            $0.center.equalTo(view)
        }
        return view
    }()
    
    func bind() {
        searchBar
            .rx
            .text
            .subscribe(onNext: { [weak self] text in
                self?.filterItems(searchText: text ?? "")
            })
            .disposed(by: disposeBag)
    }
    
    private func filterItems(searchText: String) {
        filteredItems = items.filter { $0.currencyTitle.contains(searchText) || $0.countryTitle.contains(searchText) }
        
        searchText == "" ? filteredItems = items : nil
        
        let snapShot = makeSnapshot()
        dataSource?.apply(snapShot, animatingDifferences: false)
        dataSource?.showEmptyView(tableView: exchangeTableView)
    }
    // 메인 TableView에 뿌려질 데이터 (ViewModel 구현 전 임시)
    private var items: [ExchangeItem] = []
    private var filteredItems: [ExchangeItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureTableView()
        addViews()
        configureLayout()
        bind()
        // 네트워크 작업
        let networkManager = NetworkManager()
        Task {
            do {
                let result = try await networkManager.fetch(type: Response.self, for: ServerURL.string)
                await MainActor.run {
                    fetchData(rates: result.rates)
                }
            } catch(let error) {
                let alert: UIAlertController = .initErrorAlert(title: "오류", message: "데이터를 불러올 수 없습니다.")
                await MainActor.run {
                    self.present(alert, animated: true)
                }
            }
        }
        
    }
    
// MARK: UItableViewDiffableDataSource
    typealias DataSource = UITableViewDiffableDataSource<Section, ExchangeItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ExchangeItem>
    
    enum Section: CaseIterable {
        case main
    }
    
    private var dataSource: DataSource?
    
    // 네트워크 작업을 통해 받아온 데이터를 저장
    private func fetchData(rates: [String: Double]) {
        for (key, value) in rates {
            let country = CountryDictionary.dictionary[key] ?? "Unknown Country"
            items.append(ExchangeItem(currencyTitle: key,
                                      countryTitle: country,
                                      rate: String(format: "%.4f", value)))
        }
        filteredItems = items
        let snapShot = makeSnapshot()
        dataSource?.apply(snapShot, animatingDifferences: false)
    }
    
    private func makeSnapshot() -> Snapshot {
        var snapShot = Snapshot()
        snapShot.appendSections([.main])
        snapShot.appendItems(filteredItems)
        return snapShot
    }
    
    private func configureTableView() {
        dataSource = DataSource(tableView: self.exchangeTableView) { tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ExchangeTableViewCell.identifier, for: indexPath) as? ExchangeTableViewCell else { return UITableViewCell() }
            cell.configure(model: item)
            return cell
        }
        
        let snapShot = makeSnapshot()
        
        dataSource?.apply(snapShot, animatingDifferences: false)
    }
    
}

extension UITableViewDiffableDataSource {
    func showEmptyView(tableView: UITableView) {
        if snapshot().itemIdentifiers.isEmpty {
            tableView.backgroundView?.isHidden = false
        } else {
            tableView.backgroundView?.isHidden = true
        }
    }
}

private extension ViewController {
    private func addViews() {
        [exchangeTableView, searchBar].forEach {
            view.addSubview($0)
        }
    }
    
    private func configureLayout() {
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }
        exchangeTableView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        emptyView.snp.makeConstraints {
            $0.edges.equalTo(exchangeTableView)
            $0.center.equalTo(exchangeTableView)
        }
    }
}

// MARK: UIAlertController Extension
extension UIAlertController {
    static func initErrorAlert(title: String, message: String) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default)
        alertController.addAction(okAction)
        return alertController
    }
}

// MARK: UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}


// MARK: NetworkManager
struct Response: Codable {
    let result: String
    let base: String
    let rates: [String: Double]
    
    enum CodingKeys: String, CodingKey {
        case result
        case base = "base_code"
        case rates
    }
}


enum NetworkError: Error {
    case invalidURL
    case decodingError
    case serverError(code: Int)
    case transportError
}

enum ServerURL {
    static let string = "https://open.er-api.com/v6/latest/USD"
}

final class NetworkManager {
    func fetch<T: Codable>(type: T.Type, for url: String) async throws ->  T {
        guard let url = URL(string: url) else {
            throw(NetworkError.invalidURL)
        }
        let request = Session.default.request(url)
        
        let response = await request.serializingDecodable(T.self).response
        
        guard response.response?.statusCode == 200 else {
            throw NetworkError.serverError(code: response.response?.statusCode ?? 0)
        }
        
        guard let data = response.value else {
            throw(NetworkError.decodingError)
        }
        return data
    }
}

