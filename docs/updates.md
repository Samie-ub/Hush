# Signed app updates

Sparkle is pinned through SwiftPM. `scripts/build-app.sh` embeds the framework and signs
its helpers and the app locally. `config/updates.json` owns the displayed version,
monotonically increasing build number, HTTPS feed URL, and public signing key.

The private key is stored only in the login Keychain under Sparkle account
`com.local.notchtimer`. It is not in Git. Keep a secure backup using Sparkle's
`generate_keys --account com.local.notchtimer -x <secure-path>` when needed. Never commit
that export. Without Developer ID signing, losing this key means existing installations
cannot trust releases signed with a replacement key.

## Prepare a release

1. Test and promote the intended changes to `main` using the repository workflow.
2. Increase both `version` and `build` in `config/updates.json` for each new release.
   Commit that metadata through the same workflow. Never reuse a published version.
3. From the production commit, run `bash scripts/prepare-update.sh` on the Mac holding
   the signing key.
4. Review `dist/releases/<version>-<build>/`. It contains the ZIP and signed update entry in
   `appcast.xml`. The script does not publish. It refuses to overwrite a release folder.
5. Publish a GitHub Release tagged `v<version>` at that exact production commit and upload
   **both** `hush-<version>.zip` and `appcast.xml`. Mark it the latest non-prerelease.
   For example, with GitHub CLI after explicitly authorizing publication and setting
   `VERSION` and `BUILD` to the values in `config/updates.json`:

   ```sh
   gh release create "v$VERSION" "dist/releases/$VERSION-$BUILD/hush-$VERSION.zip" "dist/releases/$VERSION-$BUILD/appcast.xml" --target <production-commit> --title "hush $VERSION" --notes 'Release notes' --latest
   ```

The configured feed is
`https://github.com/Samie-ub/Hush/releases/latest/download/appcast.xml`.
The repository/release assets must be publicly readable without authentication.
Never edit the generated enclosure signature or ZIP after signing.

Builds currently target the architecture of the build Mac. `generate_appcast` includes
the architecture requirement, so incompatible Macs should not be offered the update.
Use a universal build before supporting Intel and Apple Silicon from one archive.
Full ZIP updates are used initially; delta generation is disabled.

## Verify

Run `swift test --disable-sandbox`, `bash scripts/build-app.sh`, and
`bash scripts/prepare-update.sh`. Bundle verification runs as part of the build.
For an end-to-end test, install an older updater-enabled build, publish a higher-build
release to a separate HTTPS test feed, and check/download/install/relaunch from that
build. Verify idle installation, running and paused timer restoration, stopwatch restoration,
completion during restart, update cancellation, and offline errors. Do not change a signed
installed bundle's plist to simulate an older version.

The original app has no updater: it must be replaced manually once. Future updates
still compile once when preparing the release; installed users do not build anything.
Chrome's unpacked companion extension may still need a manual Reload in Chrome after
an update. No automatic GitHub publishing or CI signing secrets are configured.
