import UIKit

protocol AlertPresenterProtocol {
    func requestAlert(on: UIViewController, model: AlertModel)
}
