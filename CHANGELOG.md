## 0.4.1

- Synchronize slider render-object radii and refresh value-indicator text when
  the slider theme changes.
- Dispose slider gesture, text, animation, and value-indicator resources when
  their render objects are removed.
- Honor switch tap-target overrides and correctly refresh inactive thumb
  borders and image painters.
- Expand bottom-navigation hit targets while preserving the compact One UI
  splash, and add dialog and popup-menu semantic roles.
- Add widget regression and scroll-physics tests with an enforced coverage
  floor across the supported Flutter matrix.
- Add pub.dev screenshots and deploy the example widget catalog to GitHub
  Pages.

## 0.4.0

- Require Flutter 3.35 or later and Dart 3.9 or later.
- Migrate widgets to current Material, theming, color, and text-scaling APIs.
- Add official One UI semantic color roles for light and dark themes.
- Add an explicit Material You color mode that uses the app's `ColorScheme`.
- Deprecate widget-local One UI color switches in favor of theme-level color
  configuration.
- Add dynamic color and seeded fallback controls to the example catalog.
- Add a complete widget catalog, responsive tests, integration tests, and a CI
  matrix covering Flutter 3.35 and the latest stable release.
- Refresh the Android, iOS, and web example projects, including Flutter 3.35
  plugin-registration and build compatibility fixes.
- Add custom popup-menu trigger builders and preserve their enabled, disabled,
  and feedback behavior.
- Preserve button padding with custom theme font sizes and use semantic inactive
  colors for sliders.
- Enforce a single `child` or `slivers` body source in `OneUIView`, implement
  `actionSpacing`, and handle non-collapsible app-bar height ranges safely.
- Honor app-bar theme centering and bottom height, explicit dialog styling,
  popup icon-trigger options, and bottom-navigation background colors.
- Validate app-bar opacity values and require every bottom-navigation item to
  provide exactly one label source.
- Require an input position when constructing `OneUIInkSplash` directly.
- Refresh the README and public API documentation.

## 0.3.2

- Add `onHover` and `onFocusChange` to `OneUIContainedButton` and
  `OneUIFlatButton`.

## 0.3.1

- Fix dependency resolution.

## 0.3.0

- Add configuration options to `OneUIView`.
- Update widgets for One UI 4.0.

## 0.2.0

- Add `expandedHeight` to `OneUIView`.
- Replace `children` with `child` in `OneUIView`.

## 0.1.0

- Add the example application.
- Update `OneUIView`.

## 0.0.1

- Initial release.
