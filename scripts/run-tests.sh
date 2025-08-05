#!/bin/bash

# Generate mocks with Mockito
echo "Generating mocks..."
flutter pub run build_runner build --delete-conflicting-outputs

# Run tests
echo "Running tests..."
flutter test

# Check if we should generate coverage
if [ "$1" == "--coverage" ]; then
  echo "Generating coverage report..."
  flutter test --coverage
  
  # Check if genhtml is available (requires lcov)
  if command -v genhtml &> /dev/null; then
    genhtml coverage/lcov.info -o coverage/html
    echo "Coverage report generated at coverage/html/index.html"
    
    # Open coverage report if on macOS
    if [ "$(uname)" == "Darwin" ]; then
      open coverage/html/index.html
    fi
  else
    echo "genhtml not found. Install lcov to generate HTML coverage reports."
  fi
fi

echo "Testing completed!"
