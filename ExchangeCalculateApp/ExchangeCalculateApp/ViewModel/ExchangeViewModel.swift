import Foundation
import RxSwift

enum DataLoadState {
    case success
    case failure
    case update
}

class ExchangeViewModel: ViewModelProtocol {
    
    typealias State = PublishSubject<DataLoadState>

    var state: RxSwift.PublishSubject<DataLoadState>
    
    private let disposeBag = DisposeBag()
    private let networkManager = NetworkManager()
    // 데이터 담은 객체
    var exchageItemDTO = ExchangeItemDTO()
    // 네트워크 작업 결과 이벤트
    
    init() {
        self.state = .init()
        exchageItemDTO.fetchFavorite()
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
    // 즐겨찾기 항목 저장
    func saveFavorite(currency: String?) {
        guard let currency else { return }
        let item = exchageItemDTO.items.filter{ $0.currencyTitle == currency }
        if item.isEmpty {
            print("filter error")
            return
        }
        
        if item[0].isFavorited {
            exchageItemDTO.removeFavorite(currency)
        } else {
            exchageItemDTO.saveFavorite(currency)
        }
        state.onNext(.update)
    }
    
}
