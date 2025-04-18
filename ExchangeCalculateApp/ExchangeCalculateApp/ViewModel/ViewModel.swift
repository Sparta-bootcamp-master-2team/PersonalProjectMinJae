import Foundation
import RxSwift

enum DataLoadState {
    case success
    case failure
}

class ViewModel: ViewModelProtocol {
    
    private let disposeBag = DisposeBag()
    private let networkManager = NetworkManager()
    var exchageItemDTO = ExchangeItemDTO()
    
    var dataLoadState = PublishSubject<DataLoadState>()
    
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
