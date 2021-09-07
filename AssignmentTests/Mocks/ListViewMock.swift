import Foundation

@testable import Assignment

class ListViewMock: ListViewProtocol {

	var displayListCalled = false
	var displayErrorCalled = false

	func displayList(_ viewObject: ListViewObject) {
		displayListCalled = true
	}

	func displayError(error: CommonAPIError) {
		displayErrorCalled = true
	}

}
