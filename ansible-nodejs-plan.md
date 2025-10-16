# Plan: Add Node.js Installation to Ansible Playbook (No claude-code)

**Objective:** Extend the existing playbook to install Node.js via nvm for frontend development, without installing claude-code (use official CLI instead).

## Node.js Version Requirements
- Your A4C-AppSuite/frontend project uses Vite 7.0.6
- Vite 7.x requires Node.js 20.19+ or 22.12+
- Install Node.js 22 LTS for optimal compatibility

## Changes to make

### 1. Add macOS Node.js installation (after line 184, following existing nvm block):
- Install Node.js 22 LTS via nvm to meet Vite 7.0.6 requirements
- Use proper nvm environment sourcing in shell commands
- Add idempotent checks with `creates` parameters

### 2. Add Linux Node.js installation (after line 676, following existing nvm block):
- Mirror the macOS implementation for consistent behavior
- Install same Node.js 22 version

## Implementation details
- Use `nvm install 22 --lts` to get Node.js 22.x LTS
- Source nvm.sh script before running nvm commands
- Use shell module with bash executable for nvm compatibility
- No claude-code installation (keep using official CLI)

## Benefits
- Meets Vite 7.0.6 Node.js requirements (20.19+/22.12+)
- Provides clean Node.js environment for frontend development
- Maintains consistency across macOS and Linux platforms
- Avoids npm claude-code permission issues entirely

## Pre-implementation Cleanup Required
1. Exit this claude-code session
2. Uninstall system Node.js: `sudo apt remove nodejs npm`
3. Uninstall npm claude-code: `sudo npm uninstall -g @anthropic-ai/claude-code` (if npm still available)
4. Verify cleanup: `which node` and `which claude` should show official CLI only
5. Run updated playbook