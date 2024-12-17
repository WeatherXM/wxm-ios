//
//  AlertHelper.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 24/8/23.
//

import Foundation
import UIKit
import Toolkit

@MainActor
struct AlertHelper {
	struct AlertObject: @unchecked Sendable {
		typealias Action = (title: String, action: @MainActor (String?) -> Void)
        let title: String?
        let message: String?
        var textFieldPlaceholder: String?
        var textFieldValue: String?
        var textFieldDelegate: UITextFieldDelegate?
        var cancelActionTitle: String = LocalizableString.cancel.localized
        var cancelAction: VoidCallback?
        let okAction: Action?
        var secondaryActions: [Action]?

        static func getNavigateToSettingsAlert(title: String?, message: String?) -> AlertObject {
            AlertObject(title: title,
                        message: message,
                        okAction: (LocalizableString.goToSettingsButton.localized, { _ in
                guard let url = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }

                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }))
        }
    }

    func showAlert(_ obj: AlertObject) {
        let alertController = UIAlertController(title: obj.title, message: obj.message, preferredStyle: .alert)

        if let textFieldText = obj.textFieldValue {
            alertController.addTextField { textField in
                textField.text = textFieldText
                textField.placeholder = obj.textFieldPlaceholder
                textField.delegate = obj.textFieldDelegate
            }
        }

        let cancelAction = UIAlertAction(title: obj.cancelActionTitle, style: .cancel) { _ in
            obj.cancelAction?()
        }
        alertController.addAction(cancelAction)

        obj.secondaryActions?.forEach { [weak alertController] action in
            let text = alertController?.textFields?.first?.text
            let alertAction = UIAlertAction(title: action.title, style: .default) { _ in
                action.action(text)
            }

            alertController?.addAction(alertAction)
        }

        if let okTitle = obj.okAction?.title {
            let okAction = UIAlertAction(title: okTitle, style: .default) { [weak alertController] _ in
                let text = alertController?.textFields?.first?.text
                obj.okAction?.action(text)
            }
            alertController.addAction(okAction)
        }

		UIApplication.shared.topViewController?.present(alertController, animated: true)
    }
}
