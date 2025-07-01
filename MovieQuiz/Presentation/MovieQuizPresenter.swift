import UIKit

final class MovieQuizPresenter {
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var correctAnswers = 0
    var currentQuestion: QuizQuestion?
    var questionFactory: QuestionFactoryProtocol?
    var statisticService: StatisticServiceProtocol!
    weak var viewController: MovieQuizViewController?
    
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
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
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            let game = GameResult(correct: correctAnswers,
                                  total: self.questionsAmount,
                                  date: Date())
            statisticService.store(currentGame: game)
            let bestGame = statisticService.bestGame
            let result = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text:
"""
Ваш результат: \(correctAnswers)/\(self.questionsAmount)
Количество сыгранных квизов: \(statisticService.gamesCount)
Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
""",
                buttonText: "Сыграть еще раз")
            viewController?.show(quiz: result)
        }
        else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
}
