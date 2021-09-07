import Foundation
import Alamofire

protocol DataProviderProtocol {
	func request(with spec: RequestSpec, _ completionHandler: @escaping (Result<DataProviderResponse, Error>) -> Void)
}

struct DataProviderResponse {
	let data: Data
	let response: URLResponse?
}

protocol RequestSpec {

	var baseURLString: String { get }
	var path: String { get }
	var method: HTTPMethod { get }
	var headers: HTTPHeaders? { get }
	var params: [String: Any]? { get }
	var parameterEncoding: ParameterEncoding { get }
}

extension RequestSpec {

	var url: String {
        return baseURLString.appending(path)
	}
}

class DataProvider: DataProviderProtocol {

    let sessionManager: Session = {
      let configuration = URLSessionConfiguration.af.default
      configuration.requestCachePolicy = .returnCacheDataElseLoad
      let responseCacher = ResponseCacher(behavior: .modify { _, response in
        let userInfo = ["date": Date()]
        return CachedURLResponse(response: response.response, data: response.data, userInfo: userInfo, storagePolicy: .allowed)
      })
      return Session(configuration: configuration, cachedResponseHandler: responseCacher)
    }()

    func request(with spec: RequestSpec, _ completionHandler: @escaping (Result<DataProviderResponse, Error>) -> Void) {

        sessionManager.request(spec.url, method: spec.method, parameters: spec.params, encoding: spec.parameterEncoding, headers: spec.headers)
			.validate()
			.responseJSON { (response) in
				switch response.result {
				case .success:
					if let error = response.error { completionHandler(.failure(error)); return }
					guard let data = response.data else {
						completionHandler(.failure(NSError.noDataReceived))
						return
					}
					completionHandler(.success(DataProviderResponse(data: data, response: response.response)))
				case .failure(let error):
					completionHandler(Result.failure(error))
				}
			}
	}

}

extension NSError {
    static var noDataReceived: Error {
        return NSError(domain: "NO_DATA", code: 0, userInfo: nil)
    }
}

//extension DataProvider {
//
//	static func getMethod(stringMethod: String?) -> HTTPMethod {
////		let method = HTTPMethod(rawValue: (stringMethod ?? "get").uppercased()) else {
//			return .get
////		}
////		return method
//	}
//}

enum CommonAPIError: Error, Equatable {
	case parseResponseFailed(_ error: Error)
	case backendFailure(_ error: Error)
	case connectionFailed
	case requestTimedOut
	case invalidRequest
	case unknown

	static func parseFailed(_ error: Error) -> CommonAPIError {
		safeprint("PARSING ERROR: \(String(describing: error))")
		return CommonAPIError.parseResponseFailed(error)
	}

	static func resolveError(_ error: Error) -> CommonAPIError {
		safeprint(error.localizedDescription)
		switch (error as NSError).code {
		case NSURLErrorCannotConnectToHost,
			 NSURLErrorCannotFindHost,
			 NSURLErrorNetworkConnectionLost,
			 NSURLErrorSecureConnectionFailed,
			 NSURLErrorNotConnectedToInternet:
			return .connectionFailed
		case NSURLErrorTimedOut:
			return .requestTimedOut
		default:
			if (error as? CommonAPIError) == invalidRequest {
				return .invalidRequest
			} else {
				return backendFailure(error)
			}
		}
	}

	static func == (lhs: CommonAPIError, rhs: CommonAPIError) -> Bool {
		switch (lhs, rhs) {
		case let (.backendFailure(errorA), .backendFailure(errorB)):
			return (errorA as NSError).code  == (errorB as NSError).code
		case (.parseResponseFailed, .parseResponseFailed):
			return true
		default:
			return (lhs as NSError).code == (rhs as NSError).code
		}
	}
}
