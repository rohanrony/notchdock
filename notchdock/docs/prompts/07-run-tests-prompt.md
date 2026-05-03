# Prompt: NotchDock Test Execution & Regression Audit

## Objective
Execute the full NotchDock test suite and perform a regression audit to ensure the application remains stable, secure, and performant after recent modifications.

## Execution Strategy

### 1. Unit & Integration Tests
Run the primary test suite via the terminal to capture detailed logs:
```bash
xcodebuild -project NotchDock.xcodeproj -scheme NotchDock -destination 'platform=macOS' test
```

### 2. UI & Launch Verification
Instruct the user to:
1. Launch the application from Xcode (**Command + R**).
2. Verify the Notch island appears correctly.
3. Expand the notch and switch between all active modules (Calendar, ToDo, Music, Timer, Quick Access).
4. Open the Settings window and verify all module-specific tabs are accessible.

## Audit Checklist

- **Intelligent Selection**: Does the notch correctly prioritize the Timer (if active) over other modules?
- **Sanitization**: Do all AppleScript-based controls (Music) still function without errors?
- **Persistence**: Do changes to ToDo items or Quick Access snippets survive an app restart?
- **Permission States**: Does the UI correctly reflect "Access Required" if system permissions are revoked?

## Debugging Workflow
If tests fail:
1. **Clean**: `rm -rf ~/Library/Developer/Xcode/DerivedData/NotchDock-*`
2. **Re-build**: **Command + Shift + K** in Xcode.
3. **Isolate**: Run specific tests using the Test Navigator (Command + 6) to identify the exact point of failure.

## Report
Summarize the test results and any manual observations. Flag any UI glitches or logic inconsistencies found during the live run.
