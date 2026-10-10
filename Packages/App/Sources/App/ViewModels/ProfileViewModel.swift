import Foundation
import Combine
import Common

public class ProfileViewModel: ObservableObject {
    @Published public var userLoadingState: LoadingState<User> = .idle
    @Published public var currentUser: User? = nil
    
    private let cacheService: CacheService
    private let cacheKey = "user_profile_cache"
    
    public init(cacheService: CacheService? = nil) {
        if let cacheService = cacheService {
            self.cacheService = cacheService
        } else {
            self.cacheService = UserDefaultsCacheService()
        }
    }
    
    // MARK: - Loading Profile with LoadingState
    public func loadProfile() async {
        await MainActor.run {
            self.userLoadingState = .loading
        }
        
        do {
            // Try to retrieve from cache first
            if let cached: User = try cacheService.retrieve(
                key: cacheKey,
                defaultValue: nil
            ) {
                await MainActor.run {
                    self.currentUser = cached
                    self.userLoadingState = .success(cached)
                }
                return
            }
            
            // If not in cache, use sample data
            let user = User(
                email: "user@example.com",
                firstName: "John",
                lastName: "Doe",
                state: "Texas"
            )
            
            try cacheService.save(key: cacheKey, value: user)
            
            await MainActor.run {
                self.currentUser = user
                self.userLoadingState = .success(user)
            }
        } catch {
            let appError = error as? AppError ?? .unknown(error.localizedDescription)
            await MainActor.run {
                self.userLoadingState = .failure(appError)
            }
        }
    }
    
    // MARK: - Refresh
    public func refresh() async {
        cacheService.clear(key: cacheKey)
        await loadProfile()
    }
    
    // MARK: - Update Profile
    public func updateProfile(_ user: User) async {
        await MainActor.run {
            self.userLoadingState = .loading
        }
        
        do {
            try cacheService.save(key: cacheKey, value: user)
            
            await MainActor.run {
                self.currentUser = user
                self.userLoadingState = .success(user)
            }
        } catch {
            let appError = error as? AppError ?? .unknown(error.localizedDescription)
            await MainActor.run {
                self.userLoadingState = .failure(appError)
            }
        }
    }
    
    // MARK: - Logout
    public func logout() async {
        cacheService.clear(key: cacheKey)
        await MainActor.run {
            self.currentUser = nil
            self.userLoadingState = .idle
        }
    }
}
