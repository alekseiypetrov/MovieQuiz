import XCTest
@testable import MovieQuiz

final class MovieQuizControllerMock: MovieQuizViewControllerProtocol {
    func show(quiz step: MovieQuiz.QuizStepViewModel) {
    }
    
    func show(quiz result: MovieQuiz.QuizResultsViewModel) {
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
    }
    
    func buttonToggleSwitch(to flag: Bool) {
    }
    
    func showLoadingIndicator() {
    }
    
    func hideLoadingIndicator() {
    }
    
    func showNetworkError(message: String) {
    }
}


final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertMode() throws {
        let viewControllerMock = MovieQuizControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "QuestionText", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "QuestionText")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
