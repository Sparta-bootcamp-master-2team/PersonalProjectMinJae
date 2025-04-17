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
        addViews()
        configureLayout()
        configureNavigtaioinBar()
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
