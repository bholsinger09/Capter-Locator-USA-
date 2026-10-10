import Foundation
import Combine

/// Utility for debouncing search input to reduce CPU usage during rapid typing
public class DebouncedSearch: ObservableObject {
    @Published public var searchText: String = ""
    @Published public var debouncedText: String = ""
    
    private var cancellable: AnyCancellable?
    private let delayMs: Int
    
    /// Initialize with custom delay
    /// - Parameter delayMs: Delay in milliseconds (default: 300ms)
    public init(delayMs: Int = 300) {
        self.delayMs = delayMs
        setupDebounce()
    }
    
    private func setupDebounce() {
        cancellable = $searchText
            .debounce(for: .milliseconds(delayMs), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] value in
                self?.debouncedText = value
            }
    }
    
    deinit {
        cancellable?.cancel()
    }
}

/// Extension for applying debounce to any Publisher<String, Never>
public extension Publisher where Output == String, Failure == Never {
    func debounced(
        delayMs: Int = 300,
        scheduler: RunLoop = RunLoop.main
    ) -> AnyPublisher<String, Failure> {
        self
            .debounce(for: .milliseconds(delayMs), scheduler: scheduler)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
