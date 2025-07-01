import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let presenter = MovieQuizPresenter()
    private var questionFactory: QuestionFactoryProtocol?
    private var correctAnswers = 0
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewController = self
        
        statisticService = StatisticServiceImplementation()
        
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter

        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(),
                                              delegate: self)
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - AlertPresenterDelegate
    
    func didAlertPresent(reason: ReasonForAlert) {
        correctAnswers = 0
        presenter.resetQuestionIndex()
        switch reason {
        case .endGame:
            questionFactory?.requestNextQuestion()
        case .errorWithData:
            showLoadingIndicator()
            questionFactory?.loadData()
        }
    }
    
    // MARK: - Private functions
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    private func showNetworkError(message: String) {
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
        if isCorrect {
            correctAnswers += 1
        }
        
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
            self.presenter.correctAnswers = correctAnswers
            self.presenter.questionFactory = self.questionFactory
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
