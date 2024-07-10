//
//  UberTextField.swift
//
//  Created by Manolis Katsifarakis on 30/10/22.
//

import SwiftUI

/**
 A supercharged TextField that:
 • Allows focusing / unfocusing via the `isFirstResponder` binding. It can be used instead of the `@FocusState` property wrapper which is only available on  iOS > 15.
 • Takes up full vertical and horizontal space of its container view, so that the user can focus it by tapping anywhere on it.
 • Is based on a `UITextField` which is provided and can be configured in the `configuration`
 callback (to set for example auto-correction / capitalization properties, enable secure text entry, etc.).
 */
struct UberTextField: UIViewRepresentable {
    @Binding public var isFirstResponder: Bool?
    @Binding public var text: String
    @Binding public var hint: String

    private let onEditingChanged: (UITextField, Bool) -> Void
    private let onSubmit: (UITextField) -> Bool
    private let shouldChangeCharactersIn: (UITextField, NSRange, String) -> Bool

    public var configuration = { (_: UITextFieldWithPrefix) in }

    public init(
        text: Binding<String>,
        hint: Binding<String> = .constant(""),
        isFirstResponder: Binding<Bool?> = .constant(nil),
        onEditingChanged: @escaping (UITextField, Bool) -> Void = { _, _ in },
        shouldChangeCharactersIn: @escaping (UITextField, NSRange, String) -> Bool = { _, _, _ in true },
        onSubmit: @escaping (UITextField) -> Bool = { _ in true },
        configuration: @escaping (UITextFieldWithPrefix) -> Void = { _ in }
    ) {
        self.configuration = configuration
        self.onEditingChanged = onEditingChanged
        self.shouldChangeCharactersIn = shouldChangeCharactersIn
        self.onSubmit = onSubmit
        _text = text
        _hint = hint
        _isFirstResponder = isFirstResponder
    }

    public func makeUIView(context: Context) -> UITextFieldWithPrefix {
        let view = UITextFieldWithPrefix()
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidChange), for: .editingChanged)
        view.delegate = context.coordinator
        return view
    }

    public func updateUIView(_ uiView: UITextFieldWithPrefix, context _: Context) {
        uiView.placeholder = hint
        uiView.text = text
        configuration(uiView)

        guard let isFirstResponder = isFirstResponder else {
            return
        }

		DispatchQueue.main.async {
			switch isFirstResponder {
				case true: uiView.becomeFirstResponder()
				case false: uiView.resignFirstResponder()
			}
		}
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(
            $text,
            isFirstResponder: $isFirstResponder,
            onEditingChanged: onEditingChanged,
            shouldChangeCharactersIn: shouldChangeCharactersIn,
            onSubmit: onSubmit
        )
    }

    open class Coordinator: NSObject, UITextFieldDelegate {
        var text: Binding<String>
        var isFirstResponder: Binding<Bool?>
        let onEditingChanged: (UITextField, Bool) -> Void
        let onSubmit: (UITextField) -> Bool
        let shouldChangeCharactersIn: (UITextField, NSRange, String) -> Bool

        init(
            _ text: Binding<String>,
            isFirstResponder: Binding<Bool?>,
            onEditingChanged: @escaping (UITextField, Bool) -> Void,
            shouldChangeCharactersIn: @escaping (UITextField, NSRange, String) -> Bool,
            onSubmit: @escaping (UITextField) -> Bool
        ) {
            self.text = text
            self.isFirstResponder = isFirstResponder
            self.onEditingChanged = onEditingChanged
            self.shouldChangeCharactersIn = shouldChangeCharactersIn
            self.onSubmit = onSubmit
        }

        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            return onSubmit(textField)
        }

        @objc public func textFieldDidChange(_ textField: UITextField) {
            text.wrappedValue = textField.text ?? ""
        }

        public func textFieldDidBeginEditing(_ tf: UITextField) {
            isFirstResponder.wrappedValue = true
            onEditingChanged(tf, true)
        }

        public func textFieldDidEndEditing(_ tf: UITextField) {
            isFirstResponder.wrappedValue = false
            onEditingChanged(tf, false)
        }

        public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let result = shouldChangeCharactersIn(textField, range, string)
            text.wrappedValue = textField.text ?? ""
            return result
        }
    }

    class UITextFieldWithPrefix: UITextField {

		override var font: UIFont? {
			didSet {
				updateLeftViewPrefix()
			}
		}

		override var textColor: UIColor? {
			didSet {
				updateLeftViewPrefix()
			}
		}

		var prefix: String? {
			didSet {
				updateLeftViewPrefix()
			}
		}

		private func updateLeftViewPrefix() {
			guard let prefix else {
				leftView = nil
				return
			}

			let label = UILabel()
			label.text = prefix
			label.font = font
			label.textColor = textColor
			label.sizeToFit()
			leftView = label
			leftViewMode = .always
		}
    }
}
