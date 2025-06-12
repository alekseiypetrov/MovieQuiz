import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func didAlertPresent(reason: ReasonForAlert)
}
