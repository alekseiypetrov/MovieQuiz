import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statisticService = StatisticServiceImplementation()
        
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter
        
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        
        self.questionFactory?.requestNextQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - AlertPresenterDelegate
    
    func didAlertPresent() {
        correctAnswers = 0
        currentQuestionIndex = 0
        questionFactory?.requestNextQuestion()
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
                               message: "Невозможно загрузить данные",
                               buttonText: "Попробовать еще раз",
                               completion: nil)
        alertPresenter?.requestAlert(on: self, model: model)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderWidth = 0
        
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let model = AlertModel(title: result.title,
                               message: result.text,
                               buttonText: result.buttonText,
                               completion: nil)
        alertPresenter?.requestAlert(on: self, model: model)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            let game = GameResult(correct: correctAnswers,
                                    total: questionsAmount,
                                    date: Date())
            statisticService.store(currentGame: game)
            let bestGame = statisticService.bestGame
            let result = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: 
"""
Ваш результат: \(correctAnswers)/\(questionsAmount)
Количество сыгранных квизов: \(statisticService.gamesCount)
Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
""",
                buttonText: "Сыграть еще раз")
            show(quiz: result)
        }
        else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
        buttonToggleSwitch(to: true)
    }
    
    private func buttonToggleSwitch(to flag: Bool) {
        yesButton.isEnabled = flag
        noButton.isEnabled = flag
    }
    
    // MARK: - Actions
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        buttonToggleSwitch(to: false)
        let givenAnswer = false
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        buttonToggleSwitch(to: false)
        let givenAnswer = true
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
