import UIKit

class CalculatorViewController: UIViewController {

    private var item: ExchangeItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
}
