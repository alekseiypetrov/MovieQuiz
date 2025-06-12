import UIKit

enum ReasonForAlert {
    case errorWithData, endGame
}

class AlertPresenter: AlertPresenterProtocol {
    
    weak var delegate: AlertPresenterDelegate?

    func requestAlert(on controller: UIViewController, model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        let reason = model.title == "Ошибка" ? ReasonForAlert.errorWithData : ReasonForAlert.endGame
        let action = UIAlertAction(title: model.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.didAlertPresent(reason: reason)
        }
        alert.addAction(action)
        controller.present(alert, animated: true, completion: model.completion)
    }
}

