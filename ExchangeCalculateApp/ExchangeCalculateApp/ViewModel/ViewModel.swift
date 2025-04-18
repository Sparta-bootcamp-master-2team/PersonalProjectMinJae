import Foundation
import RxSwift

enum DataLoadState {
    case success
    case failure
}

class ViewModel: ViewModelProtocol {
    
    typealias State = PublishSubject<DataLoadState>

    var state: RxSwift.PublishSubject<DataLoadState>
    
    private let disposeBag = DisposeBag()
    private let networkManager = NetworkManager()
    // 데이터 담은 객체
    var exchageItemDTO = ExchangeItemDTO()
    // 네트워크 작업 결과 이벤트
    
    init() {
        self.state = .init()
    }
    
    // 데이터 불러오고 이벤트 방출
    func fetchData() {
        Task {
            do {
                let result = try await networkManager.fetch(type: Response.self, for: ServerURL.string)
                exchageItemDTO.fetchItems(response: result)
                state.onNext(.success)
            } catch {
                state.onNext(.failure)
            }
        }
    }
    
}
