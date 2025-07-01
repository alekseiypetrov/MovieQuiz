import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers = 0
    private var currentQuestion: QuizQuestion?
    
    private var statisticService: StatisticServiceProtocol
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate

    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Updating numerical properties
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame(dueTo reason: ReasonForAlert) {
        currentQuestionIndex = 0
        correctAnswers = 0
        switch reason {
        case .endGame:
            questionFactory?.requestNextQuestion()
        case .errorWithData:
            questionFactory?.loadData()
        }
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    // MARK: - Buttons' actions
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer { correctAnswers += 1}
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // MARK: - Other functions
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func makeResultsModel(of game: GameResult) -> QuizResultsViewModel {
        statisticService.store(currentGame: game)
        let bestGame = statisticService.bestGame
        
        let title = "Этот раунд окончен!"
        let currentGameResult = "Ваш результат: \(correctAnswers)/\(self.questionsAmount)"
        let totalPlays = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let bestGameInfo = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
        let averageAccuracy = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        let text = [currentGameResult, totalPlays, bestGameInfo, averageAccuracy].joined(separator: "\n")
        let buttonText = "Сыграть еще раз"
        
        return QuizResultsViewModel(
            title: title,
            text: text,
            buttonText: buttonText)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        viewController?.showLoadingIndicator()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
            self.viewController?.buttonToggleSwitch(to: true)
        }
    }
    
    private func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            let game = GameResult(correct: correctAnswers,
                                  total: self.questionsAmount,
                                  date: Date())
            let result = makeResultsModel(of: game)
            viewController?.show(quiz: result)
        }
        else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
}
