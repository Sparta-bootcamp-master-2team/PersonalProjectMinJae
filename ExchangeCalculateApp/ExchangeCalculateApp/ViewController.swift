import UIKit
import SnapKit

struct ExchangeItem: Hashable{
    let title: String
    let rate: String
}

class ViewController: UIViewController {

    private lazy var exchangeTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ExchangeTableViewCell.self, forCellReuseIdentifier: ExchangeTableViewCell.identifier)
        tableView.delegate = self
        return tableView
    }()
    
    private var items: [ExchangeItem] = [ExchangeItem(title: "hi", rate: "10"), ExchangeItem(title: "nice", rate: "10"), ExchangeItem(title: "bye", rate: "10")]
    
    enum Section: CaseIterable {
        case main
    }
    
    typealias DataSource = UITableViewDiffableDataSource<Section, ExchangeItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ExchangeItem>
    
    private var dataSource: DataSource?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureTableView()
        addViews()
        configureLayout()
        
    }
    
    private func addViews() {
        view.addSubview(exchangeTableView)
    }
    
    private func configureLayout() {
        exchangeTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func configureTableView() {
        dataSource = DataSource(tableView: self.exchangeTableView) { tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ExchangeTableViewCell.identifier, for: indexPath) as? ExchangeTableViewCell else { return UITableViewCell() }
            cell.configure(model: item)
            return cell
        }
        var snapShot = Snapshot()
        snapShot.appendSections([.main])
        snapShot.appendItems(items)
        dataSource?.apply(snapShot, animatingDifferences: false)
    }
    
}

// MARK: UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.estimatedRowHeight
    }
}
