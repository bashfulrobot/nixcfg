# Nix Style Guide

## Formatting Rules
- Use 2 spaces for indentation
- Place semicolons at the end of attribute sets
- Use trailing commas in multi-line lists and attribute sets
- Place each attribute on its own line in multi-line sets
- Align equals signs vertically when beneficial for readability

## Example Package Derivation

```nix
{ lib, pkgs, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "my-package";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner   = "myorg";
    repo    = pname;
    rev     = "v${version}";
    sha256  = "...";
  };

  buildInputs = [
    pkgs.cmake
    pkgs.pkg-config
  ];

  configureFlags = [
    "--prefix=${placeholder "out"}"
    "--enable-feature"
  ];

  meta = with lib; {
    description = "A sample package";
    homepage    = "https://github.com/myorg/${pname}";
    license     = licenses.mit;
    platforms   = platforms.unix;
  };
}
```

## Best Practices
- Avoid `rec` attribute sets; use `let...in` instead
- Use `assert` statements for input validation
- Keep derivations deterministic and reproducible

## Comments
- Use `#` for single-line comments
- Use `/* */` for multi-line comments
- Comment complex expressions and non-obvious configurations

## Naming Conventions
- Use camelCase for variable and function names
- Use kebab-case for attribute names and package names
- Use descriptive names that clearly indicate purpose
- Prefix internal/private functions with underscore

## Import and With Statements
- Import only what you need to reduce scope pollution
- Use `with` sparingly and only for well-known, stable sets
- Prefer explicit imports over `with` for clarity
- Group imports logically at the top of expressions

## Functions
- Use curried functions for partial application
- Provide default values for optional parameters: `{ enable ? true }`
- Keep functions pure and avoid side effects

## String Interpolation and Paths
- Use `${}` for variable interpolation in strings
- Use relative paths with `./` prefix for local files
- Use `toString` when converting paths to strings

## Code Formatting Tools
- Use `nixfmt` for official Nix code formatting
- `alejandra` is an alternative formatter with opinionated style choices
- Run formatters on Nix files before committing to maintain code quality
- Configure your editor to format on save for consistent style
