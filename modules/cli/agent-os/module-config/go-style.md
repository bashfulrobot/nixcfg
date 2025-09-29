# Go Style Guide

## Formatting Rules
- Use tabs for indentation (Go standard)
- Keep lines under 100 characters when possible
- Place opening braces on the same line as declaration
- Use trailing commas in multi-line slices, maps, and structs
- Group imports: standard library, third-party, local packages

## Example Go Code Structure

```go
package main

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/gorilla/mux"
	"go.uber.org/zap"

	"github.com/myorg/myapp/internal/config"
	"github.com/myorg/myapp/internal/handlers"
)

// User represents a user in the system
type User struct {
	ID        int64     `json:"id"`
	Name      string    `json:"name"`
	Email     string    `json:"email"`
	CreatedAt time.Time `json:"created_at"`
}

// UserService defines user operations
type UserService interface {
	GetUser(ctx context.Context, id int64) (*User, error)
	CreateUser(ctx context.Context, user *User) error
}

// userService implements UserService
type userService struct {
	logger *zap.Logger
	db     Database
}

// NewUserService creates a new user service
func NewUserService(logger *zap.Logger, db Database) UserService {
	return &userService{
		logger: logger,
		db:     db,
	}
}

// GetUser retrieves a user by ID
func (s *userService) GetUser(ctx context.Context, id int64) (*User, error) {
	if id <= 0 {
		return nil, fmt.Errorf("invalid user ID: %d", id)
	}

	user, err := s.db.GetUser(ctx, id)
	if err != nil {
		s.logger.Error("failed to get user",
			zap.Int64("user_id", id),
			zap.Error(err),
		)
		return nil, fmt.Errorf("get user: %w", err)
	}

	return user, nil
}
```

## Naming Conventions
- Use PascalCase for exported functions, types, and variables
- Use camelCase for unexported functions, types, and variables
- Use short, descriptive names for variables in small scopes
- Use descriptive names for package-level variables and functions
- Package names should be short, lowercase, and descriptive

## Package Organization
- Group standard library imports first
- Group third-party imports second
- Group local package imports last
- Separate import groups with blank lines
- Use meaningful package names that describe functionality

## Error Handling
- Always handle errors explicitly
- Use `fmt.Errorf` with `%w` verb to wrap errors
- Return errors as the last return value
- Use descriptive error messages with context
- Check for specific error types when needed

## Best Practices
- Prefer composition over inheritance
- Use interfaces to define behavior contracts
- Keep interfaces small and focused
- Use zero values effectively
- Avoid global variables when possible
- Use context.Context for cancellation and timeouts

## Comments
- Use `//` for single-line comments
- Use `/* */` for multi-line comments
- Document all exported functions, types, and variables
- Start comments with the name of the item being documented
- Use complete sentences in documentation comments

## Code Formatting Tools
- Use `gofmt` for standard Go code formatting
- Use `goimports` to automatically manage imports
- Use `golangci-lint` for comprehensive linting
- Run formatters and linters before committing to maintain code quality
- Configure your editor to format on save for consistent style