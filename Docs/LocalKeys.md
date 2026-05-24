Local Keys and Secure API configuration
=====================================

This project supports reading API keys from a local, gitignored xcconfig so keys are not committed to source control.

1) Local xcconfig (already created)

- File: Config/Local.xcconfig
- Add your keys to this file. Example:

  CONGRESS_API_KEY = your_real_congress_api_key_here
  PROPUBLICA_API_KEY = your_real_propublica_key_here

2) Wire the key into your app's Info.plist

- In your app target's `Info.plist`, add a string entry named `CONGRESS_API_KEY` with the value `$(CONGRESS_API_KEY)` (include the parentheses and dollar sign). Xcode will substitute the value at build time from the active build settings.

Example Info.plist snippet (XML view):

  <key>CONGRESS_API_KEY</key>
  <string>$(CONGRESS_API_KEY)</string>

3) Set the xcconfig file for your build configurations

- Open the project in Xcode → Project (top-level) → Info tab → Configurations.
- For each configuration (Debug/Release), set the "Based on configuration file" to `Config/Local.xcconfig`.

Alternative (per-developer):

- Instead of using an xcconfig, you can set a scheme environment variable (Xcode → Product → Scheme → Edit Scheme → Run → Arguments → Environment Variables) with `CONGRESS_API_KEY` set to your key. This keeps it local to your machine and avoids changing project files.

CI / Automation

- Do NOT commit keys to the repo. Instead, configure your CI provider's secret storage and expose keys as environment variables when running `xcodebuild`.
- Example for CI run:

  - export CONGRESS_API_KEY="${CONGRESS_API_KEY}"
  - xcodebuild -scheme "SwiftChapterUSA_finder" -destination "platform=iOS Simulator,name=iPhone 14" build

Notes

- The code already checks `Bundle.main.infoDictionary` and `ProcessInfo.processInfo.environment` for keys. Both methods above will make the key available at runtime when used correctly.
- Keep `Config/Local.xcconfig` out of source control — it is added to `.gitignore`.
