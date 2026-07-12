# Changelog

## Unreleased

- A "Languages" dropdown renders near the top of the sidebar (below the
  brand, above the Pages nav) — no `admin.build_menu :utility_navigation`
  code needed. Ships with 3 languages by default
  (English/Español/Français); `config.languages` is a
  `[{ label:, locale:, url: }, ...]` array you can replace with any list,
  and `config.language_switcher = false` (or an empty `languages` array)
  removes it entirely. Each option links to the current page with
  `?locale=xx` appended (`url_for(locale: ...)`) by default; give an entry
  its own `url:` (`String`/`Proc`/`Symbol`, evaluated the same way an
  `ActiveAdmin::MenuItem`'s own `url:` proc is) to hit a remote/dedicated
  locale-switching endpoint instead. Actually honoring the `locale` param
  is still your own app's responsibility, the same as with a hand-rolled
  utility-nav menu.
- **Added a real RSpec test suite** (`spec/`, with a minimal `spec/dummy`
  Rails+ActiveAdmin+Devise app to exercise it against): configuration
  defaults/`configure`/`reset_configuration!`, `.enable!`'s header
  registration, the sidebar, table-action icons, the collapsible Filters
  panel, flash messages, every Devise auth page's brand treatment
  (including the `config.login_page = false` fallback and custom
  `login_logo`/`login_app_name`/`login_tagline`), the icon/toggle-tag
  helpers, and both generators (`install`, `error_pages`) — 64 examples.
  Run with `bundle install && bundle exec rspec` (or `rake`).
- **Fixed: `f.input :x, as: :prism_toggle`'s wrapping `<label>` rendered a
  stray leading space in its `class` attribute** (`class=" prism-toggle"`)
  — found by the new test suite. `input_html_options`/`label_html_options`
  in `lib/formtastic/inputs/prism_toggle_input.rb` were filtering `nil`
  class values but not blank/empty ones before joining.
- **`config.login_page`'s card/brand-mark treatment now covers every
  Devise auth page**, not just sign-in: sign up, forgot/reset password,
  resend confirmation, and resend unlock all render through the same
  shared `devise/shared/_brand` partial, so they redesign (or degrade back
  to stock ActiveAdmin) together. Each page shows its own action's
  translated title as the subtitle instead of `login_tagline` (which stays
  sign-in's own dedicated line). The submit button on every one of these
  pages is now full-width instead of left-aligned, and ActiveAdmin's
  shared error-messages partial (`#error_explanation`, rendered by every
  page but sign-in) is reskinned to match the flash banners.
- **Fixed: flash messages losing their reskin to ActiveAdmin's own
  `body.logged_in .flash`/`body.logged_out .flash` rules**, which carry
  higher CSS specificity than a flat `.flash` selector regardless of load
  order. Most visible on the sign-in page (a plain bold-text flash with no
  background/border/radius instead of Prism's colored banner), but the same
  rule affected the main app too wherever a property collided. Fixed by
  matching AA's own specificity via `body.active_admin .flash` and relying
  on `prism.css` loading after `active_admin.css` to win the tie.
- **Fixed: sign-in page rendered a redundant "card inside a card"** —
  `fieldset.inputs`'s own border/border-radius (meant for fieldsets sitting
  directly on the gray page background elsewhere in the app) was never
  reset by ActiveAdmin's login-page styles, leaving a second bordered box
  around the email/password fields inside the already-bordered login card.
  Sign-up/forgot-password/etc links are now rendered as a row of pill
  chips instead of a divider line above plain underlined text.
- **Renamed the gem** from `activeadmin_prism_theme` to `active_admin_prism`
  (Ruby constant `ActiveAdminPrismTheme` → `ActiveAdminPrism`). Update your
  `Gemfile` (`gem "active_admin_prism"`), any
  `ActiveAdminPrism.configure`/`.enable!` calls in
  `config/initializers/active_admin.rb`, and the
  `@import "active_admin_prism/variable_overrides";` line in
  `active_admin.scss` (was `active_admin_prism_theme/variable_overrides`).
  The generator commands are now `rails g active_admin_prism:install` and
  `rails g active_admin_prism:error_pages`.
- `ActiveAdminPrism::Configuration` — per-feature toggles (`sidebar`,
  `colorize_action_icons`, `styled_confirms`, `collapsible_filters`,
  `sidebar_footer`, `flash_dismissible`, `flash_auto_dismiss`,
  `flash_auto_dismiss_seconds`, `flash_transition_ms`, `login_page`,
  `login_logo`, `login_app_name`, `login_tagline`) via
  `ActiveAdminPrism.configure { |config| ... }`, letting a host disable
  any single piece of the theme, or all of them, without uninstalling the
  gem.
- Sign-in page (Devise `sessions#new`) gets a centered card, animated brand
  mark, and tidied sign-up/forgot-password links row instead of
  ActiveAdmin's default gradient header box. The mark, app name, and
  tagline are all configurable (`login_logo`/`login_app_name`/
  `login_tagline`, same `String`/`Proc`/`Symbol` convention ActiveAdmin
  itself uses for `config.footer`); `login_page = false` reverts to
  ActiveAdmin's original plain login box.
- `INTEGRATION.md` — new "Markup & CSS class reference" section documenting
  every `prism-*` class/id, the DOM structure it appears in, and the full
  `$prism-*` Sass variable/design-token table.
- `rails g active_admin_prism:error_pages` — copies Prism-styled
  `public/404.html`/`public/500.html` into the host app (static files, so
  this is a separate, explicit generator rather than something `install` or
  `ActiveAdminPrism::Configuration` can drive automatically).
- `prism_toggle_tag(value)` helper — a read-only toggle-switch visual for
  boolean index columns / show `attributes_table` rows.
- Row-level View/Edit/Delete index links render as color-coded icon buttons
  by default (blue eye, purple pencil, red trash).
- `data-confirm` links (not just Batch Actions) now route through
  ActiveAdmin's own styled jQuery UI dialog instead of the native browser
  `confirm()`.
- The "Filters" sidebar panel collapses to a real inline-icon-only button by
  default, expanding to the full form on click (keyboard-accessible); the
  index table/content area reflows to reclaim the freed-up width while
  collapsed.
- Flash messages get a dismiss button, auto-hide after a configurable
  delay, and a smoother, configurable fade/slide transition.
- "Powered by Active Admin" moved from the page footer into the sidebar,
  pinned below the account/logout area regardless of nav length. Toggle
  with `config.sidebar_footer` — off leaves it in ActiveAdmin's original
  page footer instead.
- `variable_overrides.scss` — Prism's values for ActiveAdmin's own default
  Sass palette, auto-wired by the install generator into a host's
  `active_admin.scss` (before `active_admin/mixins`), so components AA
  renders itself (dialogs, dropdown menus) inherit Prism's colors too.
- `INTEGRATION.md` — full integration guide (config reference, feature
  guide, switching/disabling the theme, troubleshooting).
- Several CSS specificity fixes where ActiveAdmin's own ID-scoped selectors
  and `:not(.disabled)`-wrapped hover/active states could beat a
  same-or-lower-specificity theme override regardless of load order.

## 0.1.0

- Initial release: collapsible left sidebar (drop-in `header` replacement),
  card-style panels/tables, reskinned Formtastic forms, opt-in
  `as: :prism_toggle` switch input, curated inline SVG icon set.
- Zero-config asset delivery: precompiled CSS/JS auto-registered by the
  engine, no Sass compiler or manifest edits required in the host app.
- `rails g active_admin_prism:install` enables the theme with one line.
