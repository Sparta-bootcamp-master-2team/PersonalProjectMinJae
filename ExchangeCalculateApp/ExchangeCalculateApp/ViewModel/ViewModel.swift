import Foundation
import RxSwift

enum DataLoadState {
    case success
    case failure
}

class ViewModel: ViewModelProtocol {
    
    private let disposeBag = DisposeBag()
    private let networkManager = NetworkManager()
    // 데이터 담은 객체
    var exchageItemDTO = ExchangeItemDTO()
    // 네트워크 작업 결과 이벤트
    var dataLoadState = PublishSubject<DataLoadState>()
    
    // 데이터 불러오고 이벤트 방출
    func fetchData() {
        Task {
            do {
                let result = try await networkManager.fetch(type: Response.self, for: ServerURL.string)
                exchageItemDTO.fetchItems(response: result)
                dataLoadState.onNext(.success)
            } catch {
                dataLoadState.onNext(.failure)
            }
        }
    }
    
}
