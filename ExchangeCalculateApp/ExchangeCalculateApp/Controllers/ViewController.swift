import UIKit
import SnapKit

final class ViewController: UIViewController {

    private let exchangeView = ExchangeView()
    override func loadView() {
        super.loadView()
        self.view = exchangeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // 네트워크 작업
        let networkManager = NetworkManager()
        Task {
            do {
                let result = try await networkManager.fetch(type: Response.self, for: ServerURL.string)
                await MainActor.run {
                    exchangeView.fetchData(rates: result.rates)
                }
            } catch {
                let alert: UIAlertController = .initErrorAlert(title: "오류", message: "데이터를 불러올 수 없습니다.")
                await MainActor.run {
                    self.present(alert, animated: true)
                }
            }
        }
    }
}
