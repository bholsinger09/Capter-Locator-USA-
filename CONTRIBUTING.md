# Contributing to Chapter Locator USA

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on the best interest of the community

## Getting Started

1. Fork the repository
2. Clone your fork locally
3. Create a new branch for your feature/fix
4. Make your changes
5. Write/update tests
6. Ensure all tests pass
7. Submit a pull request

## Development Workflow

### Branch Naming

- Feature: `feature/description-of-feature`
- Bug fix: `fix/description-of-fix`
- Refactor: `refactor/description`
- Tests: `test/description`

### Commit Messages

Follow conventional commits format:

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `test`: Adding or updating tests
- `refactor`: Code refactoring
- `style`: Code style changes (formatting, etc.)
- `chore`: Maintenance tasks

Examples:
```
feat(chapters): add chapter filtering by university
fix(auth): resolve login validation issue
test(viewmodels): add tests for ChaptersViewModel
docs(readme): update setup instructions
```

## MVVM Architecture Guidelines

### Adding New Features

1. **Create Protocol First** (if new service needed)
   ```swift
   protocol NewServiceProtocol: AnyObject {
       // Define interface
   }
   ```

2. **Implement Service**
   ```swift
   class NewService: ObservableObject, NewServiceProtocol {
       // Implementation
   }
   ```

3. **Create Mock Service**
   ```swift
   class MockNewService: NewServiceProtocol {
       // Mock implementation for testing
   }
   ```

4. **Create ViewModel**
   ```swift
   class NewViewModel: ObservableObject {
       private let service: NewServiceProtocol
       
       init(service: NewServiceProtocol) {
           self.service = service
       }
   }
   ```

5. **Write Tests**
   ```swift
   class NewViewModelTests: XCTestCase {
       var viewModel: NewViewModel!
       var mockService: MockNewService!
       
       override func setUp() {
           mockService = MockNewService()
           viewModel = NewViewModel(service: mockService)
       }
       
       // Test cases
   }
   ```

6. **Create View**
   ```swift
   struct NewView: View {
       @StateObject private var viewModel: NewViewModel
       
       var body: some View {
           // UI implementation
       }
   }
   ```

## Testing Requirements

### All contributions must include tests:

1. **Model Tests**
   - Test initialization
   - Test computed properties
   - Test Codable conformance

2. **ViewModel Tests**
   - Test all public methods
   - Test form validation
   - Test state changes
   - Test error handling

3. **Service Tests**
   - Test CRUD operations
   - Test data persistence
   - Test error scenarios

### Test Coverage

- Aim for >80% code coverage
- All new ViewModels must have comprehensive tests
- Critical paths must have 100% coverage

### Running Tests

```bash
# Run all tests
⌘ + U

# Run specific test
Click diamond icon next to test

# Check coverage
Enable "Gather coverage data" in scheme settings
```

## Code Style

### Swift Style Guide

Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)

Key points:
- Use descriptive names
- Prefer clarity over brevity
- Use camelCase for properties and methods
- Use PascalCase for types
- Include documentation for public APIs

### SwiftUI Best Practices

- Keep Views simple and focused
- Extract complex views into separate components
- Use `@StateObject` for owned ViewModels
- Use `@ObservedObject` for injected ViewModels
- Avoid logic in Views - delegate to ViewModels

### Example

```swift
// Good ✅
class AuthenticationViewModel: ObservableObject {
    @Published var email = ""
    @Published var errorMessage: String?
    
    private let authService: AuthenticationServiceProtocol
    
    init(authService: AuthenticationServiceProtocol) {
        self.authService = authService
    }
    
    /// Validates email format and attempts login
    func login() {
        guard isValidEmail(email) else {
            errorMessage = "Invalid email format"
            return
        }
        authService.login(email: email, password: password)
    }
}

// Bad ❌
class AuthenticationViewModel: ObservableObject {
    var e = ""  // Unclear name
    
    func l() {  // Unclear name
        // Logic mixed with service calls
        if e.contains("@") {
            AuthenticationManager.shared.login(email: e, password: p)
        }
    }
}
```

## Pull Request Process

1. **Before submitting:**
   - Ensure all tests pass
   - Update documentation if needed
   - Add entry to CHANGELOG (if applicable)
   - Verify no SwiftLint warnings (if configured)

2. **PR Description should include:**
   - What: Description of changes
   - Why: Reason for changes
   - How: Implementation approach
   - Testing: How it was tested
   - Screenshots (for UI changes)

3. **PR Review:**
   - Address all review comments
   - Keep PR focused and reasonably sized
   - Squash commits if requested

## Documentation

- Update README.md for user-facing changes
- Update ARCHITECTURE.md for architectural changes
- Add inline comments for complex logic
- Write clear commit messages

## Questions?

- Open an issue for bug reports
- Start a discussion for feature requests
- Comment on existing issues before starting work

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

Thank you for contributing! 🎉
