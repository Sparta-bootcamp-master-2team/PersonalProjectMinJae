import Foundation
import RxSwift

enum ConvertResult {
    case success
    case failure
}

class CalculatorViewModel: ViewModelProtocol {
    
    typealias State = PublishSubject<(ConvertResult, String?)>
    
    var state: RxSwift.PublishSubject<(ConvertResult, String?)>
    var item: ExchangeItem
    // 변환 결과와 문자열 이벤트 방출 (VC에서 수신)
    
    init(item: ExchangeItem) {
        self.item = item
        self.state = .init()
    }
    
    // 입력값 검증 후 이벤트 방출
    func calculateExchangeRate(input: String?) {
        if !isValidInput(input: input) {
            state.onNext((.failure, nil))
        } else {
            state.onNext((.success, calculate(input: input)))
        }
    }
    // 환율 계산 후 결과 문자열 리턴
    private func calculate(input: String?) -> String {
        guard let input = Double(input ?? ""),
              let rate = Double(item.rate) else { return "Error" }
        let digit: Double = pow(10, 2)
        let result = String(format: "%.2f", round(input * rate * digit) / digit)
        let inputString = String(format: "%.2f", input)
        let string = "$\(inputString) -> \(result) \(item.currencyTitle)"
        
        return string
    }
    
    // 입력값 검증
    private func isValidInput(input: String?) -> Bool {
        guard let text = input,
              text != "",
              Int(text) != nil else {
            return false
        }
        return true
    }
    // 마지막 환율 정보 삭제
    func removeLastCurrency() {
        var handler = CoreDataHandler()
        handler.removeLastCurrency()
    }
}
