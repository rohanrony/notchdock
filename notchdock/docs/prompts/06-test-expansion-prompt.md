# Prompt: Test Suite Expansion & Validation

## Objective
Review the current state of the NotchDock codebase and expand the Test Suite to cover any new logic, modules, or security requirements introduced in recent changes.

## Context & Standards
Before writing any tests, you MUST review the following specifications:
- **Primary Guide**: [11-testing-and-build-workflow.md](../11-testing-and-build-workflow.md)
- **Security Standards**: [10-security-checks.md](../10-security-checks.md)

## Task Requirements

1. **Logic Coverage**:
   - Identify new ViewModels or managers.
   - Add unit tests to `NotchDockTests.swift` that verify state transitions and data persistence.
   
2. **Priority Validation**:
   - If changes were made to `AppState.effectiveCompactExtensionID`, update `testIntelligentSelectionLogic` to ensure priority rules (Timer > Nudge > Live > Manual) are still enforced.

3. **Security Check**:
   - Verify all new AppleScript interpolations use `sanitizedForAppleScript()`.
   - Add a test case in the sanitization suite for any new dynamic input types.

4. **Registry Verification**:
   - If a new module was added, verify it is correctly registered in `AppState.init()` and add a corresponding check in `testExtensionRegistryCompleteness`.

## Output
Provide the code updates for `notchdockTests.swift` and summarize which specific logic branches are now covered by the new tests.
