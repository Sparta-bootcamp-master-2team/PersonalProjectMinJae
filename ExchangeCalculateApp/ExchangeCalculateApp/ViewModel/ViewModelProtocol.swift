import Foundation

protocol ViewModelProtocol {
    associatedtype State
    
    var state: State { get set }
}
