import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate {
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var presenter: MovieQuizPresenter!
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        
        statisticService = StatisticServiceImplementation()
        
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter
    }
    
    // MARK: - AlertPresenterDelegate
    
    func didAlertPresent(reason: ReasonForAlert) {
        showLoadingIndicator()
        presenter.restartGame(dueTo: reason)
    }
    
    // MARK: - Private functions
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз",
                               completion: nil)
        alertPresenter?.requestAlert(on: self, model: model)
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderWidth = 0
        
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        hideLoadingIndicator()
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let model = AlertModel(title: result.title,
                               message: result.text,
                               buttonText: result.buttonText,
                               completion: nil)
        alertPresenter?.requestAlert(on: self, model: model)
    }
    
    func showAnswerResult(isCorrect: Bool) {
        presenter.didAnswer(isCorrectAnswer: isCorrect)
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        switch isCorrect {
        case true:
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
        case false:
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        
        self.showLoadingIndicator()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.presenter.statisticService = self.statisticService
            self.presenter.showNextQuestionOrResults()
            buttonToggleSwitch(to: true)
        }
    }
    
    private func buttonToggleSwitch(to flag: Bool) {
        yesButton.isEnabled = flag
        noButton.isEnabled = flag
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
