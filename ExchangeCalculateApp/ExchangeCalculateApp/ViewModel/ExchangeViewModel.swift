import Foundation
import RxSwift

enum ExchangeViewModelState {
    case dataFetchSuccess
    case dataFetchFailure
    case dataUpdated
    case coreDataFetchFailure
}

class ExchangeViewModel: ViewModelProtocol {
    
    typealias State = PublishSubject<ExchangeViewModelState>

    var state: RxSwift.PublishSubject<ExchangeViewModelState>
    
    private let disposeBag = DisposeBag()
    private let networkManager = NetworkManager()
    // 데이터 담은 객체
    var exchageItemDTO = ExchangeItemDTO()
    // 네트워크 작업 결과 이벤트
    
    init() {
        self.state = .init()
        let _ = exchageItemDTO.fetchCoreData(entity: .lastExchangeItem) 
        exchageItemDTO.fetchCoreData(entity: .favorite) ? nil : state.onNext(.coreDataFetchFailure)
        
    }
    
    // 데이터 불러오고 이벤트 방출
    func fetchData() {
        Task {
            do {
                let result = try await networkManager.fetch(type: Response.self, for: ServerURL.string)
                await MainActor.run {
                    exchageItemDTO.fetchItems(response: result)
                }
                state.onNext(.dataFetchSuccess)
            } catch {
                state.onNext(.dataFetchFailure)
            }
        }
    }
    // 즐겨찾기 항목 저장
    func fetchFavorite(currency: String?) {
        guard let currency else { return }
        let item = exchageItemDTO.items.filter{ $0.currencyTitle == currency }
        if item.isEmpty {
            return
        }
        var result = false
        
        if item[0].isFavorited {
            result = exchageItemDTO.removeFavorite(currency)
        } else {
            result = exchageItemDTO.saveCoreData(entity: .favorite, currency: currency)
        }
        result ? state.onNext(.dataUpdated) : state.onNext(.coreDataFetchFailure)
    }
    
    // 마지막 선택된 환율 이름 저장
    func fetchLastSelectedCurrency(currency: String?) {
        guard let currency else { return }
        var coreDataHandler = CoreDataHandler()
        let _ = exchageItemDTO.saveCoreData(entity: .lastCurrency,
                                    currency: currency)
    }
    
}
