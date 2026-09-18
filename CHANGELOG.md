# Changelog

## 0.1.4

- A Pages nav item registered with no `icon:` now gets one automatically
  (`auto_nav_icons`, on by default) — picked deterministically from a
  generic subset of the built-in icon set based on the item's own label,
  so the same label always gets the same icon rather than shuffling
  between page loads. Mainly matters once the sidebar is collapsed to
  its icon-only rail (`sidebar_collapsible`): an unassigned item used to
  render there as just a bare, indistinguishable dot. `icon:` set
  explicitly always wins; `auto_nav_icons = false` restores the old
  no-icon-at-all behavior.
- Every non-Filters sidebar section (ActiveAdmin core's own "Search
  status" panel, when `active_filters_bar` is off, or a host's own custom
  `sidebar "Title" do ... end` block) now flattens every link/button
  inside it into a single "Sidebar Actions" Select2 dropdown when
  `collapsible_filters` is on, instead of each rendering its own
  individually collapsed icon button with nowhere near enough room in
  the 72px gutter that assumed just one — wrapping every word onto its
  own line, or spilling out unclipped over the main content, instead of
  collapsing cleanly. This dropdown renders in the title bar, next to
  (and styled identically to) the consolidated "Actions" dropdown below,
  so the two read as one "more stuff lives here" row instead of two
  disconnected mechanisms in different parts of the page. Picking an
  option fires a real click on the underlying (hidden but still
  DOM-attached, so Rails UJS's `data-method`/`data-confirm` keeps
  working) link/button and resets right back to its placeholder — same
  "jump menu" click-and-reset flow as the "Actions" dropdown, rather than
  opening the section's content in a nested panel. The section itself is
  discarded outright either way, never rendered in `#sidebar`. The
  Filters panel itself is untouched by any of this — it always keeps its
  own plain icon button exactly as before, whether or not any other
  sections exist. A page with only Filters (the common case) shows no
  dropdown at all.
- A title bar with more than `action_items_dropdown_threshold` (default:
  `0`, so this applies from a single extra `action_item` on) `action_item`
  buttons now collapses all of them into a single Select2 "jump menu",
  aligned with the index table's own right edge (not the page's corner,
  which a table's own column-driven width often doesn't reach), instead
  of rendering a multi-row wall of individual buttons — a resource
  registering a dozen+ CSV upload / bulk-action links is a real example
  this was built for. Sits in the same row as the "Sidebar Actions"
  dropdown above when both exist on the same page, with a visible gap
  before the (always excluded, always pinned to the true top-right
  corner) "New Resource" button. Both this and the "Sidebar Actions"
  dropdown above always show Select2's search box, even with just one or
  two options — not gated behind a result-count threshold — so either
  reads unambiguously as Select2 regardless of how many items it
  currently has. Picking an option fires that action immediately (a
  plain link navigates, a `button_to` form submits — whatever it
  actually was, `data-confirm`/`data-method` included) and resets right
  back to its placeholder. Purely client-side: it moves each existing
  action_item element as-is into a hidden holding area and `.click()`s
  the real trigger inside it, so whatever a host's own `action_item`
  block rendered keeps working completely unmodified. Set
  `config.action_items_dropdown = false` to always render every
  action_item inline, matching this gem's behavior before this flag
  existed.
- The active-filters bar (`config.active_filters_bar`) now toggles the
  Filters panel open/closed on click, same as the funnel icon, instead of
  only ever opening it.
- Following any Pages nav item — a plain leaf link, or a parent group
  like "School" — while the sidebar is collapsed to its icon-only rail
  (`config.sidebar_collapsible`) now expands it back out first. A
  parent's own submenu is force-hidden by CSS while collapsed regardless
  of its "open" class, so without this, clicking one did nothing visible
  at all.

## 0.1.3

- A hamburger icon button next to the brand, at the top of the Prism
  sidebar (`config.sidebar_collapsible`, default `true`), collapses it to
  a narrow icon-only rail on desktop, expanding back to full width (with
  labels) on another click — state persists across page loads. Purely a
  desktop feature; the existing off-canvas mobile toggle below 900px is
  unaffected either way. Every nav item keeps a native tooltip (its label,
  on hover) so it stays identifiable while collapsed. Set
  `config.sidebar_collapsible = false` to render no toggle at all — the
  sidebar is always full width, matching this gem's behavior before this
  flag existed.
- Flash messages now render as floating toast cards (icon + message +
  dismiss button + a countdown progress bar), pinned to the top-right
  corner of the viewport and stacking if more than one is active, instead
  of ActiveAdmin's plain inline banner. A type-colored icon
  (`:check_circle`/`:alert_triangle`/`:alert_circle`/`:info`) is selected
  from the flash's key — `:notice`/`:success`, `:alert`/`:warning`,
  `:error`, and anything else, respectively. While `flash_auto_dismiss`
  is on, a bar along the card's bottom edge visually counts down over
  `flash_auto_dismiss_seconds`; hovering the card pauses both that bar
  and the actual removal timer in lockstep (not just the animation), so a
  flash a visitor is mid-read can't vanish out from under them. This
  applies identically to Devise's sign-in/password/etc pages, which
  needed a small layout override of their own — see
  `app/views/layouts/active_admin_logged_out.html.erb` — since those
  route through a completely separate layout ActiveAdmin itself ships
  rather than through this gem's usual Arbre-based override point.
- The active filters bar is now itself a shortcut to the Filters form —
  clicking anywhere on it opens the (possibly collapsed) Filters panel and
  scrolls it into view, instead of only the separate funnel icon doing
  that.
- Fixed: the active filters bar fell 12px short of the table's own right
  edge instead of aligning flush with it — `.table_tools`'s `gap` and the
  bar's `margin-left: auto` (used to push it to the row's far end) are on
  the same axis, and a nonzero column-gap there gets double-counted by
  the auto margin's free-space math, leaving exactly one gap's worth of
  space unclaimed after the last item. Switched to `row-gap` (still
  spaces Batch Actions from the bar vertically if they wrap onto separate
  lines on a narrow viewport, without the bug).
- Fixed: the rail-collapsed sidebar (`config.sidebar_collapsible`) had two
  space issues — a group left open before collapsing kept rendering its
  full submenu (every child's icon *and* label) spilling out past the
  76px rail instead of collapsing to just the parent's own icon (a
  `.prism-nav-item.open > .prism-nav-submenu` rule was more specific than
  the one meant to hide it); and any menu item with no `icon:` set (see
  [Sidebar navigation: icons & badges] in INTEGRATION.md) rendered as
  either an empty color-highlighted box (if `.active`) or a totally blank
  row once its label was hidden, reading as broken dead space. Menu items
  without an icon now get a small dot instead, once collapsed.
- Fixed: the mobile off-canvas sidebar toggle (`.prism-sidebar-mobile-toggle`,
  ≤900px viewports) was rendered completely off-screen and unclickable —
  it's a `position: fixed` descendant of `#header.prism-sidebar`, and that
  element's own `transform: translateX(-100%)` (used to slide the closed
  sidebar off-screen) made it the containing block for that fixed
  descendant too, dragging the toggle button off-screen right along with
  the hidden sidebar. The off-canvas slide now animates `left` instead of
  `transform`, which carries no such side effect.
- The "current scope + active filters" summary (ActiveAdmin core's own
  "Search status" sidebar section, auto-added to every resource) now
  renders as a highlighted pill bar in the same row as the Batch Actions
  button/scope tabs, instead of inside `#sidebar`
  (`config.active_filters_bar`, default `true`) — tinted with the theme's
  primary color so it reads as a clear, eye-catching signal rather than
  another gray panel. It used to get squeezed down to the same 72px icon
  gutter as the Filters form whenever `collapsible_filters` had it
  collapsed, and its content had nowhere to fit in 72px — it overflowed
  out over the table instead of shrinking cleanly. Set
  `config.active_filters_bar = false` to restore ActiveAdmin's stock
  sidebar-based behavior.
- Fixed: a Select2-enhanced `<select>` in the main form (`config.select2`,
  or any field opted in individually) rendered full-width on its own line
  below its label instead of beside it, like every other field. The BFC
  sizing trick used to fit it into ActiveAdmin core's floated-label layout
  only works when the element's width is `auto` — but Select2 always sets
  an inline `width: 100%` on `.select2-container` itself (prism.js's
  auto-init passes `{ width: "100%" }`, and a host's own manual
  `.select2()` call hits the same code path at its default width), so that
  trick never actually engaged. Matches ActiveAdmin core's own input width
  instead.
- Fixed: a field row whose label this theme deliberately doesn't float
  (e.g. a boolean checkbox, or `as: :prism_toggle`) could let the *next*
  row's floated label render up alongside it instead of starting on its
  own line below, since the short row's un-cleared float left no height
  for the next label to clear against. Every field row now clears its own
  floats.

## 0.1.2

- Adds [Select2](https://select2.org) support (`config.select2`, default
  `false` — the only opt-in-by-default flag in this gem) — reskinned to
  match the theme, and now vendored inside the gem's own assets (no
  separate gem/npm dependency, no JS of your own required). Turn it on to
  auto-enhance *every* plain `<select>` (filters, form inputs, association
  pickers) into a searchable widget with zero per-field setup; or leave it
  off and opt individual fields in yourself the same way you would in any
  other Rails app (`input_html: { class: "..." }` + your own `.select2()`
  call) — both approaches coexist without double-initializing the same
  element. Covers single-select, multi-select ("tags"/pill chips), and the
  open dropdown/search box/results list — see
  [Select2](INTEGRATION.md#select2) in INTEGRATION.md. Without the CSS
  half of this, a Select2-enhanced select rendered at its tiny unstyled
  default size, and its open dropdown could clash with the theme entirely.
- Fixed: the collapsible Filters sidebar panel kept `overflow: hidden`
  even while expanded, clipping/garbling any dropdown (Select2 or AA's own
  "select + search" filter widget) that needed to render outside its own
  input's bounds. `&.open`/the `collapsible_filters: false` backstop now
  reset `overflow` back to `visible`.
- Fixed: the Cancel button (and any other `fieldset.actions`/
  `fieldset.buttons` link styled via `prism-button-secondary`) rendered
  with ActiveAdmin's own pill-shaped `border-radius: 200px` instead of
  Prism's — a more specific AA selector was winning on that one property
  even though Prism's color/background already won via `!important`. Both
  button mixins now mark `border-radius` `!important` too.
- Fixed: form action buttons (Create/Update + Cancel) could stack
  vertically instead of sitting side by side. ActiveAdmin lays them out
  via `float: left` on each `<li>`, which is fragile (a longer button
  label, or a host's own CSS, can lose the float); the actions `<ol>` is
  now a flex row instead, which floats have no effect on regardless of
  specificity or content width.

## 0.1.1

- A search box renders at the top of the sidebar's "Pages" nav
  (`config.menu_search`, default `true`), filtering menu items as you
  type without a server round trip. Matching works at any nesting depth:
  a submenu item that matches keeps its parent group visible and expanded
  even though the parent's own label doesn't match; a parent whose own
  label matches instead reveals its entire submenu, expanded, so you
  never have to manually open a group to find something buried in a long
  menu. Clearing the box (or the "x" button, or Escape) resets everything
  back to its normal expand/collapse state.
- **The shipped `prism.css`/`prism.js` are now minified.** `bin/build-css`
  compiles with `style: :compressed` instead of `:expanded`, and a new
  `bin/build-js` (backed by the `terser` dev dependency) minifies the real
  source — moved to `js-src/prism.js`, mirroring `scss-src/`'s role —
  into the compiled `app/assets/javascripts/active_admin_prism/prism.js`.
  Nothing changes for hosts using Sprockets (which already re-minifies on
  its own `assets:precompile`), but this is a real reduction for Propshaft
  hosts, which has no built-in minification step at all. All the
  documentation comments explaining specificity fixes etc. still live in
  `scss-src`/`js-src`, not the compiled output — never hand-edit the
  latter.
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
