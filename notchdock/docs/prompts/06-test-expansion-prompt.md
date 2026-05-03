# Prompt: NotchDock Test Suite Expansion & Execution

## Objective
Review the current state of the NotchDock codebase and expand the Test Suite to cover any new logic, modules, or security requirements. Then, execute the tests to ensure no regressions.

## Context & Standards
Before writing or running tests, you MUST review the following specifications:
- **Primary Guide**: [11-testing-and-build-workflow.md](../11-testing-and-build-workflow.md)
- **Security Standards**: [10-security-checks.md](../10-security-checks.md)

## Task 1: Test Expansion

1. **Logic Coverage**:
   - Identify new ViewModels (e.g., `QuickAccessViewModel`, `ToDoViewModel`).
   - Add unit tests to `notchdockTests.swift` that verify:
     - Initialization states.
     - Mutation logic (adding/deleting/moving items).
     - JSON encoding/decoding for persistence.
   
2. **Intelligent Selection Logic**:
   - If changes were made to `AppState.effectiveCompactExtensionID`, update `testIntelligentSelectionLogic` to ensure priority rules (Timer > Nudge > Live > Manual) are still enforced.

3. **Security Validation**:
   - Verify all new AppleScript interpolations use `sanitizedForAppleScript()`.
   - Add test cases to verify that empty or malicious strings are handled correctly by the sanitization logic.

4. **Module Registry**:
   - Verify new modules are correctly registered in `AppState`.

## Task 2: Test Execution

1. **Xcode Workflow**:
   - Instruct the user to run **Command + U** in Xcode.
   - Monitor the output for any failures in the Test Navigator.

2. **Command Line Workflow**:
   - If running in a terminal-only environment, use:
     ```bash
     xcodebuild -project NotchDock.xcodeproj -scheme NotchDock -destination 'platform=macOS' test
     ```
   - NOTE: If tests fail due to "DerivedData" permissions, run:
     ```bash
     rm -rf ~/Library/Developer/Xcode/DerivedData/NotchDock-*
     ```

## Output
- Provide the code updates for `notchdockTests.swift`.
- Summarize the test results (Pass/Fail) and specific logic branches covered.
- If failures occur, provide a debugging plan based on the error logs.

