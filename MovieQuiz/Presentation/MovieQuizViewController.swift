import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate {
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var presenter: MovieQuizPresenter!
    private var alertPresenter: AlertPresenterProtocol!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter(delegate: self)
    }
    
    // MARK: - AlertPresenterDelegate
    
    func didAlertPresent(reason: ReasonForAlert) {
        showLoadingIndicator()
        presenter.restartGame(dueTo: reason)
    }
    
    // MARK: - Updating UI
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func buttonToggleSwitch(to flag: Bool) {
        yesButton.isEnabled = flag
        noButton.isEnabled = flag
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderWidth = 0
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        hideLoadingIndicator()
    }
    
    // MARK: - Showing Alerts
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз",
                               completion: nil)
        alertPresenter?.requestAlert(on: self, model: model)
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let model = AlertModel(title: result.title,
                               message: result.text,
                               buttonText: result.buttonText,
                               completion: nil)
        alertPresenter?.requestAlert(on: self, model: model)
    }

    // MARK: - Actions
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        buttonToggleSwitch(to: false)
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        buttonToggleSwitch(to: false)
        presenter.yesButtonClicked()
    }
}
