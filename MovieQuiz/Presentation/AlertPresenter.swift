import UIKit

enum ReasonForAlert {
    case errorWithData, endGame
}

class AlertPresenter: AlertPresenterProtocol {
    
    private weak var delegate: AlertPresenterDelegate?
    
    init(delegate: AlertPresenterDelegate) {
        self.delegate = delegate
    }

    func requestAlert(on controller: UIViewController, model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        
        alert.view.accessibilityIdentifier = model.title == "Этот раунд окончен!" ? "Game result" : "Error"
        
        let reason = model.title == "Ошибка" ? ReasonForAlert.errorWithData : ReasonForAlert.endGame
        let action = UIAlertAction(title: model.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.didAlertPresent(reason: reason)
        }
        alert.addAction(action)
        controller.present(alert, animated: true, completion: model.completion)
    }
}

