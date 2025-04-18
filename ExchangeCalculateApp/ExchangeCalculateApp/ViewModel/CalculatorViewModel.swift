import Foundation
import RxSwift

enum ConvertResult {
    case success
    case failure
}

class CalculatorViewModel: ViewModelProtocol {
    
    var item: ExchangeItem
    // 변환 결과와 문자열 이벤트 방출 (VC에서 수신)
    var convertResult: PublishSubject<(ConvertResult, String?)> = .init()
    
    init(item: ExchangeItem) {
        self.item = item
    }
    
    // 입력값 검증 후 이벤트 방출
    func calculateExchangeRate(input: String?) {
        if !isValidInput(input: input) {
            convertResult.onNext((.failure, nil))
        } else {
            convertResult.onNext((.success, calculate(input: input)))
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
}
