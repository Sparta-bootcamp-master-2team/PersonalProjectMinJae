import UIKit

final class CalculatorViewController: UIViewController {

    private var item: ExchangeItem?
    private let calculatorView = CalculatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addViews()
        configureLayout()
        configureNavigtaioinBar()
        bind()
    }
    
    convenience init(itme: ExchangeItem) {
        self.init(nibName: nil, bundle: nil)
        self.item = itme
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        guard let item else { return }
        calculatorView.bind(model: item)
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
