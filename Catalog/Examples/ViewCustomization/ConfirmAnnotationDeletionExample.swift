//
//  Copyright © 2021-2023 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import PSPDFKit
import PSPDFKitUI

class ConfirmAnnotationDeletionExample: Example, PDFViewControllerDelegate {

    override init() {
        super.init()
        title = "Confirm Annotation Deletion"
        contentDescription = "Shows how to present a confirmation sheet before deleting annotations."
        category = .viewCustomization
    }

    override func invoke(with delegate: ExampleRunnerDelegate) -> UIViewController? {
        PDFViewController(document: AssetLoader.document(for: .annualReport), delegate: self)
    }

    func pdfViewController(_ sender: PDFViewController, menuForAnnotations annotations: [Annotation], onPageView pageView: PDFPageView, appearance: EditMenuAppearance, suggestedMenu: UIMenu) -> UIMenu {
        // Create a custom Delete action that presents a confirmation alert.
        let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: [.destructive]) { _ in
            let alert = UIAlertController(
                // A custom localization dictionary must be used for correct
                // localization. Some languages have more forms of pluralization
                // than English.
                title: annotations.count == 1 ? "Delete annotation?" : "Delete \(annotations.count) annotations?",
                message: nil,
                preferredStyle: .actionSheet
            )
            alert.addAction(.init(
                title: "Cancel",
                style: .cancel
            ))
            alert.addAction(.init(
                title: "Delete",
                style: .destructive,
                handler: { _ in
                    sender.document?.remove(annotations: annotations)
                }
            ))
            // Present as popover on iPad.
            alert.popoverPresentationController?.sourceRect = annotations.map { pageView.convert($0.boundingBox, from: pageView.pdfCoordinateSpace) }.reduce(CGRect.zero) { $0.union($1) }
            alert.popoverPresentationController?.sourceView = pageView
            sender.present(alert, animated: true)
        }
        // Compose the final menu.
        return suggestedMenu.filterActions(noneOf: [.PSPDFKit.delete]).prepend([deleteAction])
    }

}
