# Implementation Plan

- [ ] 1. Update data models to match new API specifications
  - [x] 1.1 Update User model with new API fields
    - Modify User class to include display_name, is_verified, is_new, email_verified, is_active, date_joined fields
    - Update fromJson/toJson methods to handle new API response structure
    - Update unit tests for User model with new fields
    - _Requirements: 4.2, 4.5_

  - [x] 1.2 Update SignUpRequest model for new API
    - Change username field to display_name in SignUpRequest
    - Update toJson method to match /accounts/register/ endpoint payload
    - Update validation to handle display_name instead of username
    - Update unit tests for SignUpRequest model
    - _Requirements: 2.1, 2.4, 2.5_

  - [x] 1.3 Create new response models for API endpoints
    - Implement SignUpResponse and SignUpData models for registration endpoint
    - Implement LoginResponse model with roles, profile_complete, onboarding_complete fields
    - Implement UserProfileResponse model for /accounts/me/ endpoint
    - Implement LogoutResponse model for logout endpoint
    - Write unit tests for all new response models
    - _Requirements: 2.2, 2.6, 3.2, 3.5, 3.6, 4.2, 4.5, 4.6_

- [x] 2. Update AuthResult model for enhanced functionality
  - [x] 2.1 Enhance AuthResult with new API data
    - Add loginData field to store LoginResponse information
    - Add signUpData field to store SignUpResponse information
    - Update AuthResult to handle rich user profile data
    - Write unit tests for enhanced AuthResult model
    - _Requirements: 3.5, 3.6, 8.1, 8.2_

- [x] 3. Update API client for new endpoints
  - [x] 3.1 Update ApiClient interface with specific endpoint methods
    - Add register(), login(), getCurrentUser(), logout() methods to ApiClient interface
    - Update HttpApiClient implementation to handle new API endpoints
    - Implement proper request/response handling for each endpoint
    - Update authorization header handling for Token-based auth
    - Write unit tests for new endpoint methods
    - _Requirements: 2.1, 3.1, 4.1, 5.1_

  - [x] 3.2 Implement field-specific error handling
    - Update error parsing to handle field-specific errors (e.g., email already exists)
    - Implement proper error response parsing for validation errors
    - Update ValidationException to handle field-specific error messages
    - Write unit tests for field-specific error scenarios
    - _Requirements: 2.3, 7.2_

- [x] 4. Update authentication repository for new API
  - [x] 4.1 Update AuthRepository interface and implementation
    - Update AuthRepository methods to return new response models
    - Modify AuthRepositoryImpl to handle LoginResponse and UserProfileResponse
    - Update token management to work with new API token format
    - Handle rich user profile data storage and retrieval
    - Write unit tests for updated repository methods
    - _Requirements: 2.1, 2.2, 3.1, 3.2, 3.5, 4.1, 4.2, 4.5_

- [-] 5. Enhance authentication state management
  - [x] 5.1 Update AuthState to include user profile information
    - Extend AuthState to include user roles, profile completion status
    - Add onboarding status and app access information to state
    - Update AuthStateNotifier to handle rich user profile data
    - Write unit tests for enhanced state management
    - _Requirements: 6.3, 8.1, 8.2, 8.3, 8.4_

- [ ] 6. Update authentication service for enhanced functionality
  - [ ] 6.1 Update AuthService interface with user profile methods
    - Add methods to access user roles, profile completion status
    - Add methods to get onboarding status and app access information
    - Update AuthServiceImpl to handle rich user profile data
    - Implement proper state management for user profile information
    - Write unit tests for enhanced authentication service
    - _Requirements: 1.1, 1.2, 3.5, 3.6, 4.5, 4.6, 8.1, 8.2, 8.3, 8.4_

- [ ] 7. Update QuestionAuth facade for new API functionality
  - [ ] 7.1 Enhance QuestionAuth with user profile access methods
    - Add userRoles, profileComplete, onboardingComplete properties
    - Add appAccess property and related getter methods
    - Update getCurrentUser method to return UserProfileResponse
    - Ensure proper integration with updated AuthService
    - Write unit tests for enhanced QuestionAuth facade
    - _Requirements: 1.1, 1.2, 1.3, 4.5, 4.6, 8.1, 8.2, 8.3, 8.4_

- [ ] 8. Update validation for new API requirements
  - [ ] 8.1 Update client-side validation for display_name
    - Update SignUpRequest validation to handle display_name instead of username
    - Add display_name format validation and length requirements
    - Update password matching validation for confirm_password field
    - Write unit tests for updated validation logic
    - _Requirements: 2.4, 2.5_

- [ ] 9. Update test utilities for new API models
  - [ ] 9.1 Update mock classes and test utilities
    - Update AuthTestUtils to create test data for new API models
    - Create helper methods for LoginResponse, UserProfileResponse, SignUpResponse
    - Update mock implementations to handle new API endpoints
    - Write example usage tests for new API functionality
    - _Requirements: 9.1, 9.2, 9.3, 9.4_

- [ ] 10. Update authentication persistence for user profile data
  - [ ] 10.1 Enhance token and user profile persistence
    - Update token storage to include user profile information
    - Implement persistence for user roles, profile completion status
    - Add automatic restoration of user profile data on app startup
    - Handle user profile data updates and synchronization
    - Write integration tests for enhanced persistence scenarios
    - _Requirements: 6.4, 4.3, 8.5_

- [ ] 11. Update package exports and documentation
  - [ ] 11.1 Update library exports for new API models
    - Export new response models (LoginResponse, UserProfileResponse, SignUpResponse)
    - Update library documentation with new API functionality
    - Create comprehensive usage examples for new features
    - Update README with examples of user profile data access
    - _Requirements: 1.1, 1.2_

- [ ] 12. Create comprehensive integration tests for new API
  - [ ] 12.1 Write end-to-end tests for updated authentication flows
    - Test complete registration flow with new API response handling
    - Test login flow with user profile data retrieval and storage
    - Test user profile information access and updates
    - Test logout flow with proper cleanup
    - Verify all new requirements are met through integration tests
    - _Requirements: All updated requirements verification_