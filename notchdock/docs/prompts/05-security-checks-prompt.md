# Prompt: NotchDock Security & Privacy Audit

## Objective
Perform a comprehensive security and privacy audit of the NotchDock codebase to ensure compliance with professional macOS standards and our internal security specification.

## Reference Document
You MUST use [10-security-checks.md](../10-security-checks.md) as the authoritative standard for this audit.

## Audit Tasks

1. **Secret Scanning**:
   - Check all source files and `Info.plist` for hardcoded API keys, tokens, or credentials.
   - Verify that any required secrets are retrieved from the macOS Keychain (using `KeychainHelper`).

2. **Script Injection Audit**:
   - Audit all `Process` and `osascript` calls (especially in `MusicModule`).
   - Ensure all dynamic strings interpolated into shell/AppleScript commands are wrapped in `.sanitizedForAppleScript()` or equivalent protection.

3. **Permission & Entitlement Review**:
   - Compare `NotchDock.entitlements` and `Info.plist` against actual app usage.
   - Flag any unnecessary permissions (e.g., Microphone, Camera, or Files access) that are not actively used by enabled modules.

4. **Data Privacy**:
   - Ensure no Personally Identifiable Information (PII) is written to standard console logs.
   - Verify that `UserDefaults` is only used for non-sensitive configuration, with sensitive data moved to the Keychain.

5. **IPC & External Data**:
   - Validate data integrity for any information retrieved from external processes (e.g., Music metadata).

## Report Format
Provide a structured report including:
- **Summary**: Overall security posture.
- **Violations**: List of specific rule breaches from `10-security-checks.md` with file/line references.
- **Suggested Fixes**: Actionable code changes to resolve each violation.
- **General Risks**: Any other security concerns identified.