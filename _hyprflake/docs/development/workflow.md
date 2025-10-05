# Development Workflow

## Development Environment

### Setup
```bash
# Enter development shell
nix develop

# Or use direnv for automatic activation
echo "use flake" > .envrc && direnv allow
```

### Available Tools
- **nil**: Nix language server for IDE support
- **statix**: Nix linter for code quality
- **deadnix**: Dead code elimination
- **nixpkgs-fmt**: Code formatter

## Validation Commands

### Syntax Checking
```bash
# Validate entire flake
nix flake check

# Quick syntax validation
nix-instantiate --parse-only <file.nix>
```

### Code Quality
```bash
# Lint all Nix files
statix check .

# Format code
nixpkgs-fmt **/*.nix

# Find dead code
deadnix
```

## Development Process

### 1. Module Development
- Work in `modules/` for NixOS configurations
- Work in `modules/home-manager/` for user configurations
- Keep one concern per file
- Use descriptive variable names

### 2. Testing Strategy
- **No building during development** - focus on syntax validation
- Use `nix flake check` for configuration validation
- Test imports and module structure
- Validate with statix linting

### 3. Documentation
- Document new modules in `docs/modules/`
- Update options documentation in `docs/options/`
- Include practical examples
- Cross-reference related configurations

## Porting from Main Repository

### Identification Process
1. Locate relevant configurations in main nixcfg repository
2. Identify dependencies and imports
3. Extract utility functions to `lib/`
4. Adapt paths and references for standalone use

### Extraction Guidelines
- Remove user-specific hardcoded values
- Replace absolute paths with relative references
- Extract reusable functions to lib
- Maintain original functionality while improving modularity

### Validation Steps
1. Syntax check with `nix-instantiate --parse-only`
2. Flake validation with `nix flake check`
3. Lint with `statix check`
4. Review for hardcoded dependencies

## Git Workflow

### Commit Standards
- Use conventional commits with semantic prefixes
- Sign all commits for authenticity
- Keep commits atomic and focused
- Reference issues when applicable

### Branch Strategy
- Work on feature branches for major changes
- Use descriptive branch names
- Merge to main when validation passes
- Tag releases with semantic versioning

## Release Process

### Pre-Release Checklist
- [ ] All syntax validation passes
- [ ] Statix linting clean
- [ ] Documentation updated
- [ ] No hardcoded user configurations
- [ ] Module structure validated

### Versioning
- Follow semantic versioning (semver)
- Tag releases in git
- Update flake lock file
- Document breaking changes