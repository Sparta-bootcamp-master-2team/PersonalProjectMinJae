import Foundation
import UIKit

// 검색결과 없을 시 검색 결과 없음 View 보이도록 구현
extension UITableViewDiffableDataSource {
    func showEmptyView(tableView: UITableView) {
        if snapshot().itemIdentifiers.isEmpty {
            tableView.backgroundView?.isHidden = false
        } else {
            tableView.backgroundView?.isHidden = true
        }
    }
}
