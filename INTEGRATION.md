# Prism integration guide

A complete walkthrough of installing, configuring, and — if you ever need
to — switching off `active_admin_prism` in a Rails app. For a quick
start, see [README.md](README.md); this document goes deeper on every
option and the reasoning behind it.

**Live demo:** [prism-demo.onrender.com/admin](https://prism-demo.onrender.com/admin) —
`admin@example.com` / `password`. Hosted on Render's free tier, so the
first request after a period of inactivity can take up to a minute to
spin up.

## Contents

- [Requirements](#requirements)
- [Install](#install)
- [Manual install](#manual-install)
- [Verifying the install](#verifying-the-install)
- [Configuration reference](#configuration-reference)
- [Plug-and-play: switching the theme on/off](#plug-and-play-switching-the-theme-onoff)
- [Feature guide](#feature-guide)
- [Error pages (404/500)](#error-pages-404500)
- [Markup & CSS class reference](#markup--css-class-reference)
- [Customizing colors](#customizing-colors)
- [Troubleshooting](#troubleshooting)
- [Upgrading](#upgrading)
- [Uninstalling](#uninstalling)

## Requirements

- ActiveAdmin `>= 3.0, < 4`
- Rails `>= 7.0`
- Ruby `>= 3.1`
- Sprockets or Propshaft asset pipeline (the theme ships precompiled CSS/JS;
  no Sass compiler or JS bundler is required to install it). If your app
  has its own `app/assets/stylesheets/active_admin.scss` (i.e. you ran
  `rails g active_admin:assets`, the Sprockets/Sass path — not
  Webpacker/importmap), you get one extra, automatic benefit: see
  [Customizing colors](#customizing-colors).

## Install

```ruby
# Gemfile
gem "active_admin_prism"
```

```sh
bundle install
rails g active_admin_prism:install
```

The generator makes two changes, both idempotent (safe to run more than
once):

1. Appends `ActiveAdminPrism.enable!` to
   `config/initializers/active_admin.rb`. This is what swaps ActiveAdmin's
   top nav bar for the Prism sidebar (unless you've disabled that — see
   [Configuration reference](#configuration-reference)).
2. If `app/assets/stylesheets/active_admin.scss` exists, injects
   `@import "active_admin_prism/variable_overrides";` immediately
   before `@import "active_admin/mixins";`. This brings ActiveAdmin's own
   default gray palette onto Prism's colors at the source — see
   [Customizing colors](#customizing-colors) for why this matters.

Nothing else is required. The theme's CSS/JS are registered automatically
by the gem's `Rails::Engine` — there's no manifest to edit and no build
step, regardless of whether your app uses Sprockets or Propshaft.

## Manual install

If you'd rather not run the generator (or it skipped step 2 because you
don't have an `active_admin.scss` yet):

```ruby
# config/initializers/active_admin.rb
ActiveAdmin.setup do |config|
  # ... your existing config ...
end

ActiveAdminPrism.enable!
```

```scss
// app/assets/stylesheets/active_admin.scss (only if this file exists)
@import "active_admin_prism/variable_overrides";
@import "active_admin/mixins";
@import "active_admin/base";
```

## Verifying the install

1. Start your server and sign in to `/admin`.
2. You should see a left sidebar (brand/logo, "PAGES" section, your
   resources) instead of ActiveAdmin's default top bar.
3. View source (or DevTools → Network) and confirm two stylesheets load in
   this order: `active_admin.css` (or `.scss` output) **then**
   `active_admin_prism/prism.css`. Order matters — Prism's CSS must
   load second to correctly override ActiveAdmin's own styles.
4. Click a row's Delete icon — you should see a purple/white styled confirm
   dialog, not your browser's native popup.

If any of this doesn't match, see [Troubleshooting](#troubleshooting) before
assuming something's broken — asset caching is the most common cause.

## Configuration reference

`ActiveAdminPrism::Configuration` holds one flag per independently
toggleable feature. Every flag defaults to fully on; an app that never
touches this is unaffected.

```ruby
# config/initializers/active_admin.rb, anywhere before `enable!`
ActiveAdminPrism.configure do |config|
  config.sidebar = true                    # default: true
  config.colorize_action_icons = true      # default: true
  config.styled_confirms = true            # default: true
  config.collapsible_filters = true        # default: true
  config.sidebar_footer = true             # default: true
  config.flash_dismissible = true          # default: true
  config.flash_auto_dismiss = true         # default: true
  config.flash_auto_dismiss_seconds = 5    # default: 5
  config.flash_transition_ms = 320         # default: 320
  config.login_page = true                 # default: true
  config.login_logo = nil                  # default: nil (Prism's built-in mark)
  config.login_app_name = nil              # default: nil (falls back to AA's site_title)
  config.login_tagline = "Sign in to your admin dashboard" # default shown
  config.language_switcher = true          # default: true
  config.languages = [                     # default: these 3
    { label: "English", locale: :en },
    { label: "Español", locale: :es },
    { label: "Français", locale: :fr }
  ]
  config.menu_search = true                # default: true
end

ActiveAdminPrism.enable!
```

| Option                          | Default | Effect when `false` (or, for the last two, when changed) |
| -------------------------------- | ------- | ---------------------------------------------------------------- |
| `sidebar`                        | `true`  | `enable!` no-ops the header swap; ActiveAdmin's stock top nav renders instead. Everything else (panels, tables, forms, buttons, icons, flash/confirm styling) is unaffected. |
| `colorize_action_icons`          | `true`  | Index-table View/Edit/Delete render as ActiveAdmin's plain text links instead of color-coded icon buttons. |
| `styled_confirms`                | `true`  | Row-level `data-confirm` links (View/Edit/Delete, or anything else using Rails UJS's `data-confirm`) fall back to the browser's native `confirm()`. Batch Actions confirms are unaffected either way — they always use ActiveAdmin's own dialog. |
| `collapsible_filters`            | `true`  | The "Filters" sidebar panel always renders fully expanded (ActiveAdmin's own default) instead of collapsing to a single icon button that expands on click. |
| `sidebar_footer`                 | `true`  | "Powered by Active Admin" (or your own `config.footer`) stays in ActiveAdmin's original page-level `#footer` instead of moving into the sidebar. |
| `flash_dismissible`              | `true`  | Flash messages render as ActiveAdmin's original plain `<div>` (no dismiss button). |
| `flash_auto_dismiss`             | `true`  | Flash messages stay on screen until the next page load (ActiveAdmin's default) instead of disappearing on their own. |
| `flash_auto_dismiss_seconds`     | `5`     | How long a flash stays visible before auto-dismissing (only relevant while `flash_auto_dismiss` is `true`). |
| `flash_transition_ms`            | `320`   | How long the fade/slide-out transition takes when a flash is dismissed (manually or automatically). |
| `login_page`                     | `true`  | Every Devise auth page (sign in, sign up, forgot/reset password, resend confirmation, resend unlock) renders ActiveAdmin's original plain gradient-header box instead of Prism's centered card/brand mark. |
| `login_logo`                     | `nil`   | `nil` renders Prism's built-in mark. A `String`/`Proc`/`Symbol` overrides it — see [Sign-in page](#sign-in-page). |
| `login_app_name`                 | `nil`   | `nil` falls back to ActiveAdmin's own `config.site_title`. A `String`/`Proc`/`Symbol` overrides it. |
| `login_tagline`                  | `"Sign in to your admin dashboard"` | `nil` renders no tagline at all. |
| `language_switcher`              | `true`  | No "Languages" dropdown renders in the sidebar at all — see [Language switcher](#language-switcher). |
| `languages`                      | 3 entries (English/Español/Français) | The list the dropdown renders; an empty array (`[]`) has the same effect as `language_switcher = false`. |
| `menu_search`                    | `true`  | No search box renders above the sidebar's "Pages" nav — see [Menu search](#menu-search). |

**How this crosses the server/client boundary.** `sidebar`,
`colorize_action_icons`, and the `login_*` flags are pure server-side
decisions — Ruby renders different markup depending on the flag, full stop
(see [Sign-in page](#sign-in-page) for why `login_page` needs a Gemfile
ordering note despite being server-side). `styled_confirms`,
`collapsible_filters`, `sidebar_footer`, and the flash-related flags are
read by client-side JS/CSS (`prism.js` / `scss-src`), which can't see Ruby
config directly — so the relevant Ruby view code renders the *current*
value into the page on every request (a `prism-styled-confirms-disabled` /
`prism-filters-collapsible-disabled` / `prism-sidebar-footer-disabled`
class on `<body>`, and `data-prism-auto-dismiss-ms` /
`data-prism-transition-ms` attributes on the flash wrapper). That means all
of these are safe to change at runtime (e.g. from a feature-flag service)
without restarting your server — the very next page render picks up the
new value.

`flash_transition_ms` specifically is applied by `prism.js` as an inline
`transition-duration` on each flash (overriding the CSS default of 320ms),
and reused as the delay before the element is actually removed from the
DOM — so the fade-out animation and the removal always stay in sync
regardless of the configured duration.

`reset_configuration!` (mainly for test suites) resets every flag back to
its default:

```ruby
ActiveAdminPrism.reset_configuration!
```

## Plug-and-play: switching the theme on/off

Three levels, from "turn off one thing" to "fully revert to stock
ActiveAdmin":

**1. Turn off one feature.** Use the [Configuration reference](#configuration-reference)
above — e.g. `config.sidebar = false` to keep your existing top nav while
still getting the panel/table/form/button reskin and the flash/confirm
polish.

**2. Fully disable Prism, temporarily, without uninstalling.** Since every
Ruby-level override checks `ActiveAdminPrism.configuration` at render
time, setting every flag to `false` and skipping the sidebar swap gets you
back to (almost) stock ActiveAdmin behavior while the gem stays installed:

```ruby
ActiveAdminPrism.configure do |config|
  config.sidebar = false
  config.colorize_action_icons = false
  config.styled_confirms = false
  config.collapsible_filters = false
  config.sidebar_footer = false
  config.flash_dismissible = false
  config.flash_auto_dismiss = false
  config.login_page = false
  config.language_switcher = false
end
# Note: still calling enable! here would be a no-op for the sidebar since
# config.sidebar is false, but there's no need to call it at all in this case.
```

This is useful for a gradual rollout or A/B test — gate the whole block
behind your own condition:

```ruby
if Rails.env.production? && !FeatureFlag.enabled?(:active_admin_prism)
  ActiveAdminPrism.configure do |c|
    c.sidebar = false
    c.colorize_action_icons = false
    c.styled_confirms = false
    c.collapsible_filters = false
    c.sidebar_footer = false
    c.flash_dismissible = false
    c.flash_auto_dismiss = false
    c.login_page = false
    c.language_switcher = false
  end
end
ActiveAdminPrism.enable!
```

Note this doesn't touch the **CSS reskin** of panels/tables/forms/buttons —
those are unconditional (pure CSS, not gated by config) since they only
restyle existing ActiveAdmin markup and have no interactive behavior to
turn off. If you need the *visual* theme fully gone too (not just the
interactive bits), see level 3.

**3. Fully revert to stock ActiveAdmin, including CSS.** Remove (or
comment out) the two things the generator added:

```ruby
# config/initializers/active_admin.rb
# ActiveAdminPrism.enable!   <- comment out or delete
```

```scss
// app/assets/stylesheets/active_admin.scss
// @import "active_admin_prism/variable_overrides";   <- comment out or delete
@import "active_admin/mixins";
@import "active_admin/base";
```

The gem's CSS/JS are still *registered* (the engine does that
unconditionally at boot), but with nothing in the page referencing Prism's
classes (no `prism-sidebar`, no `prism-nav-*`, etc.) and ActiveAdmin's own
Sass variables back to their stock defaults, the visual result is stock
ActiveAdmin. You don't need to remove the gem from your Gemfile to do this
— it's a two-line, fully reversible toggle.

## Feature guide

### Sidebar navigation: icons & badges

Menu items are still defined the normal ActiveAdmin way — nested groups,
`priority`, `if:` all work unchanged. Two extra, optional conventions:

```ruby
# app/admin/orders.rb
menu label: "Orders", parent: "E-Commerce", priority: 2,
     html_options: { icon: :receipt }

menu label: -> { "Messages #{content_tag(:span, unread_count, class: 'nav-badge')}".html_safe },
     html_options: { icon: :message }
```

`icon:` (inside `html_options:` — ActiveAdmin's own `MenuItem` already
passes this hash through untouched) accepts: `:dashboard`, `:users`,
`:cart`, `:box`, `:receipt`, `:credit_card`, `:message`, `:settings`,
`:home`, `:list`, `:folder`, `:bell`, `:search`, `:menu`, `:logout`,
`:check`, `:x`, `:chevron_down`, `:eye`, `:pencil`, `:trash`, `:filter`.

### Parent groups & submenus (nested navigation)

Nested groups (e.g. an "E-Commerce" group containing "Products" and
"Orders") are plain ActiveAdmin `menu` DSL — `PrismSidebar` only changes how
the existing `ActiveAdmin::Menu`/`MenuItem` tree is drawn, not how it's
built, so this works exactly like it would with the stock top nav.

**Create a child under a parent** with `parent:` (a string/symbol — it's
matched case-insensitively and normalized the same way ActiveAdmin
normalizes any menu id):

```ruby
# app/admin/products.rb
ActiveAdmin.register Product do
  menu label: "Products", parent: "E-Commerce", priority: 1,
       html_options: { icon: :box }
end

# app/admin/orders.rb
ActiveAdmin.register Order do
  menu label: "Orders", parent: "E-Commerce", priority: 2,
       html_options: { icon: :receipt }
end
```

The first time either file registers, ActiveAdmin auto-creates an
"E-Commerce" parent item for you (non-clickable — its url defaults to `"#"`,
which is exactly what `PrismSidebar` checks to decide whether to render a
group toggle instead of a link). Both children then attach to that same
auto-created parent, sorted by `priority` within the group.

**Give the parent its own icon/priority** by declaring it explicitly, once,
with no `parent:` of its own — anywhere it'll load before (or alongside)
its children, e.g. in one of the resource files or in a dedicated
`app/admin/dashboard.rb`-style file:

```ruby
menu label: "E-Commerce", priority: 2, html_options: { icon: :cart }
```

ActiveAdmin de-dupes by the normalized menu id (`"e-commerce"`), so this
becomes the *same* parent item `parent: "E-Commerce"` above attaches to —
whichever file happens to register first, the icon/priority you set here
wins for the group itself.

**Deeper nesting** — `parent:` also accepts an array for a multi-level
chain, auto-creating every intermediate level that doesn't already exist:

```ruby
menu label: "Conversion", parent: ["Analytics", "Reports"], priority: 1
# => Analytics > Reports > Conversion
```

**Active/expanded state** is automatic, not something you configure:
`PrismSidebar` marks a group `.active` (and starts it `.open`) whenever the
current page is that group or one of its descendants
(`ActiveAdmin::MenuItem#current?`); `prism.js` then persists whichever
groups a visitor has manually opened/closed to `localStorage`, keyed per
item, so their choice survives navigating to an unrelated page instead of
resetting to that server-rendered default on every request.

There's no Prism-specific config for nesting itself — the only lever that
affects it at all is the top-level `config.sidebar` flag (see
[Configuration reference](#configuration-reference)): turn it off and this
same `menu`/`parent:` tree renders through ActiveAdmin's own stock
top-nav dropdown behavior instead of the Prism sidebar.

### Language switcher

A "Languages" dropdown renders near the top of the sidebar, between the
brand and the Pages nav — no `admin.build_menu :utility_navigation do |menu|
... end` code required in your own initializer, unlike the equivalent
hand-rolled setup in stock ActiveAdmin. Ships with 3 languages by default;
replace the whole list to add, remove, reorder, or fully localize it:

```ruby
ActiveAdminPrism.configure do |config|
  config.languages = [
    { label: "English", locale: :en },
    { label: "Deutsch", locale: :de },
    { label: "日本語", locale: :ja }
  ]
end
```

Each entry is a `{ label:, locale:, url: }` hash (`url:` optional) —
`label` is the text shown (and matched against `I18n.locale` to decide
which option gets `.active` and shows as the dropdown's current
selection). With no `url:`, `locale` builds the link via
`url_for(locale: ...)`, appending `?locale=xx` to the *current* page
(preserving whatever path/params you're already on) — the same
query-param convention an ActiveAdmin app already reaches for by hand for
this.

Give an entry its own `url:` when switching locale needs to do more than
change a query param on the current page — hitting a remote/dedicated
endpoint that sets a cookie, session key, or subdomain before redirecting
back, for instance:

```ruby
config.languages = [
  { label: "English", locale: :en },
  { label: "日本語", locale: :ja,
    url: -> { "https://example.com/set_locale?locale=ja&return_to=#{request.path}" } }
]
```

`url:` accepts a `String`, `Proc`, or `Symbol` — same
`nil`/`String`/`Proc`/`Symbol` convention as `login_logo`. A `Proc` is
evaluated the exact same way an `ActiveAdmin::MenuItem`'s own `url:` proc
already is elsewhere in ActiveAdmin (bare `url_for`/`request`/any other
view helper is available inside it via Arbre's own delegation to the view
context — no `helpers.` prefix needed — matching the
`url: proc { url_for(locale: l.locale) }` pattern an ActiveAdmin app
already reaches for by hand for this).

This gem only renders the dropdown and its links; actually switching
`I18n.locale` based on the param your link lands on (typically a
`before_action { I18n.locale = params[:locale] || I18n.default_locale }`
in your own `ApplicationController` or `Admin::BaseController`) is your
app's own responsibility, same as it would be with a hand-rolled
utility-nav menu — this gem doesn't touch your controllers to avoid
guessing at a locale strategy (query param vs. subdomain vs. session vs.
path prefix) that varies widely between apps.

Set `config.languages = []` or `config.language_switcher = false` to
remove the dropdown entirely — an empty list and the flag have the exact
same effect, so use whichever reads more clearly for your case.

Unlike the rest of the sidebar (built once from your `menu do |m| ... end`
blocks each request re-renders, same as everything else here), this
dropdown is constructed fresh on every render directly from
`ActiveAdminPrism.configuration.languages` rather than through
ActiveAdmin's own `Menu`/`MenuItem`/`build_menu` machinery — see
[Language switcher markup](#language-switcher-markup) for why, and for the
full class/id reference.

### Menu search

A search box renders at the top of the sidebar, between the language
switcher (if any) and the "Pages" nav — no setup required beyond the
default `config.menu_search = true`. It filters your existing `menu do |m|
... end` items by label as you type; there's no server round trip and no
change to how those blocks are authored in `app/admin/*.rb` — see
`lib/active_admin/views/prism_sidebar.rb#render_search_box` for the markup
and `js-src/prism.js` for the filtering logic itself.

Matching is case-insensitive and works at any nesting depth, since the
whole menu tree is already rendered up front and the filtering happens
purely client-side over the existing DOM:

- A submenu item that matches keeps its parent group visible **and
  expanded**, even though the parent's own label doesn't match — so a
  match buried a couple of levels deep is never hidden behind a collapsed
  group.
- A parent whose own label matches reveals its **entire** submenu,
  expanded, regardless of whether any individual child also matches.
- Items that don't match (and have no matching descendant) get
  `.prism-nav-hidden`; if nothing in the whole nav matches, a
  `.prism-nav-empty` "No matching menu items" message takes their place.

Clearing the input — via the "x" button (`data-prism-nav-search-clear`,
only shown while there's a query) or pressing <kbd>Escape</kbd> while the
input has focus and a value — resets the nav back to its normal
expand/collapse state (whatever `.open`/`.active` state it already had
from user-toggling or the current page, unrelated to search).

Turn it off with `config.menu_search = false` — no search box renders at
all, and the "Pages" nav starts directly below the brand/language
switcher, matching this gem's behavior before the feature existed.

### Icon helper

Available anywhere in your admin views (not just the sidebar):

```ruby
prism_icon(:cart, css_class: "prism-icon", size: 18)
```

### Toggle switch — form input

```ruby
form do |f|
  f.input :active, as: :prism_toggle
end
```

Only the wrapping markup changes — submitted params are identical to
`as: :boolean`.

### Toggle switch — read-only index/show

```ruby
index do
  column :active do |product|
    prism_toggle_tag product.active
  end
end

show do
  attributes_table do
    row :active do |product|
      prism_toggle_tag product.active
    end
  end
end
```

Explicit opt-in per column/row — ActiveAdmin's default `status_tag`
"Yes"/"No" pill is untouched everywhere you don't call it.

### Row-level action icons

View/Edit/Delete on index pages render as color-coded icon buttons (blue
eye, purple pencil, red trash) automatically — no setup needed, and no
change to your `actions`/`index` blocks. Turn it off entirely with
`config.colorize_action_icons = false` if you'd rather keep plain text
links.

### Confirm dialogs

Every `data-confirm` link — row-level actions or your own custom ones —
routes through ActiveAdmin's own styled jQuery UI dialog instead of the
native browser `confirm()`. No-ops gracefully if your app doesn't use
jquery-rails/jquery-ujs. Turn off with `config.styled_confirms = false`.

### Collapsible "Filters" sidebar

The "Filters" panel (ActiveAdmin's `filters_sidebar_section`) starts
collapsed to a single filter-icon button; clicking it expands the full form
in place (also keyboard-accessible — Enter/Space toggle it, and it exposes
`aria-expanded`). The index table/main content area reflows to reclaim the
freed-up width while collapsed, and gives it back when expanded. No setup
needed, and it only targets that specific panel — any other sidebar section
(dashboard panels, custom `sidebar :title do ... end` blocks) is untouched.
Turn it off with `config.collapsible_filters = false` to always show it
fully expanded, matching ActiveAdmin's own default (and the table/content
area at its normal, non-reflowing width).

The reflow relies on the CSS `:has()` selector (broadly supported in
current browsers); without it, the Filters panel still collapses/expands
correctly, it just won't reclaim the extra width.

### Flash messages

Flash messages get a dismiss button, auto-hide after a configurable delay,
and fade/slide out with a smooth, configurable transition — see
[Configuration reference](#configuration-reference) for
`flash_dismissible`, `flash_auto_dismiss(_seconds)`, and
`flash_transition_ms`.

### Sidebar footer ("Powered by Active Admin")

This is moved from ActiveAdmin's own page-level `#footer` into the sidebar
itself, pinned below the account/logout area — a `flex: 0 0 auto` box that
doesn't get pushed down as the nav menu grows. Any custom
`config.footer = "..."` text you've set (a string, symbol, or proc) is used
as-is. Turn it off with `config.sidebar_footer = false` to leave the
original `#footer` visible in its normal place instead, matching
ActiveAdmin's own default.

### Sign-in page

Every Devise auth page ActiveAdmin renders — sign in (`sessions#new`,
usually `/admin/login`), sign up (`registrations#new`), forgot/reset
password (`passwords#new`/`#edit`), resend confirmation
(`confirmations#new`), and resend unlock (`unlocks#new`) — gets a centered
card, animated brand mark, full-width submit button, and a tidied-up row
of pill-shaped links instead of ActiveAdmin's default gradient header box.
No setup needed; whichever of these your app actually uses (most apps
don't enable Devise's `:confirmable`/`:lockable` modules, so those two
routes may not exist at all — that's fine, unrouted pages just never
render).

```ruby
ActiveAdminPrism.configure do |config|
  config.login_logo = -> { image_tag "my_logo.svg", height: 40 }
  config.login_app_name = "My Company Admin"
  config.login_tagline = "Internal operations console"
end
```

The brand mark and app name are shared across *all* of these pages (one
consistent identity, wherever a visitor lands); only the tagline differs
per page — `login_tagline` is sign-in's own, independently configurable
line, while every other page shows its own action's own translated title
underneath instead (e.g. "Sign up", "Forgot your password?"), which isn't
a separate config option since it's just naming what the page in front of
you already does.

`login_logo`, `login_app_name`, and `login_tagline` each accept:

- `nil` — the built-in default (Prism's own animated prism mark for
  `login_logo`; ActiveAdmin's own `config.site_title` for `login_app_name`;
  a plain default sentence for `login_tagline`, or no tagline at all if you
  explicitly set it to `nil`).
- A `String` — used as-is (for `login_logo` this must be trusted, already
  html-safe markup, e.g. the result of `image_tag`, not raw untrusted
  input).
- A `Proc` — `instance_exec`'d in the page's own view context, so ordinary
  view helpers are available, including this gem's own `prism_icon`:
  `-> { prism_icon(:cart, size: 40) }`.
- A `Symbol` — called as a method on the view context.

This is the same `nil`/`String`/`Proc`/`Symbol` convention ActiveAdmin
itself already uses for `config.footer` and `config.site_title_image`.

Turn the whole thing off with `config.login_page = false` to render
ActiveAdmin's original plain login box on every one of these pages instead
(see [Configuration reference](#configuration-reference)).

**How this actually overrides ActiveAdmin's pages.** Unlike most of Prism
(which reopens an existing Ruby class or targets existing CSS selectors),
these pages are customized by the gem shipping its own copies of
`app/views/active_admin/devise/{sessions/new,registrations/new,
passwords/new,passwords/edit,confirmations/new,unlocks/new}.html.erb` (plus
a shared `devise/shared/_brand` partial all six render, so they redesign
together instead of drifting out of sync) — Rails resolves an engine's
`app/views` directory as a view path, and engines initialized later end up
higher priority than ones initialized earlier (each engine
`prepend_view_path`s its own directory in turn). Since a Gemfile naturally
lists `gem "active_admin_prism"` after `gem "activeadmin"` (the theme
depends on it), this gem's copies of those views are what Rails renders,
without you doing anything — this has been verified against the real
Bundler/Rails load order in this gem's own demo app. If your Gemfile
somehow requires `active_admin_prism` *before* `activeadmin` (unusual,
but possible with certain `group`/`require:` combinations), ActiveAdmin's
own plain views would win instead — the rest of the theme (CSS reskin,
sidebar, etc.) is unaffected either way, since none of that depends on view
path ordering. The actual authentication forms and field lists inside
every one of these views are untouched, byte-for-byte identical to
ActiveAdmin's own templates — only the surrounding brand markup is new.

## Error pages (404/500)

```sh
rails g active_admin_prism:error_pages
```

Copies Prism-styled `public/404.html` and `public/500.html` (matching the
card/blob visual language of the sign-in page) into your app.

This is deliberately **not** part of `rails g active_admin_prism:install`,
and **not** gated by `ActiveAdminPrism::Configuration`, unlike every
other piece of this theme:

- **Static exception pages can't be "registered" or overridden by a gem at
  all.** `config.exceptions_app`'s default
  (`ActionDispatch::PublicExceptions`) reads `public/404.html`/`500.html`
  straight off disk from `Rails.public_path`, completely outside the asset
  pipeline and outside Rails' view-resolution/engine-view-path mechanism —
  the same mechanism the [sign-in page](#sign-in-page) override relies on
  doesn't exist here. Copying the files into the host app (the same way
  `rails new` scaffolds its own default `public/404.html`) is the only way
  a gem can deliver this at all.
- **A host's `public/404.html`/`500.html` are usually already
  customized/committed.** Silently overwriting them on every `install` run
  — or worse, ambushing an unrelated `install` with `copy_file`'s
  interactive overwrite prompt — would be surprising. This generator is a
  separate, explicit opt-in you run (and re-run, if you want a newer
  version of the gem's default templates) whenever you actually want them.

Once copied, these are plain static HTML with an inline `<style>` block —
no ERB, no `@import "prism.css"`, no `ActiveAdminPrism::Configuration`
read at request time (a truly static file has no request to read config
during). The colors are hand-copied from `scss-src/_variables.scss`'s
defaults as of this gem's current version rather than referencing them, so
they won't automatically track a host's own color customization
([Customizing colors](#customizing-colors)) — re-run the generator, or
hand-edit the copied files, if you want them to match. The action button
`href`s (`Back to Dashboard`, `Report Issue`) are placeholders — a static
file has no Rails route helpers available to point them at your actual
admin path automatically, so edit those after copying.

## Markup & CSS class reference

Everything below is either existing ActiveAdmin markup Prism reskins in
place (no new classes — just a CSS rule targeting AA's own selector), or a
`prism-*`-prefixed class/id Prism itself renders. Use this as the map for
writing your own CSS on top of the theme, or for understanding what a given
`prism-*` class in DevTools corresponds to. Source of truth for all of this
is `scss-src/*.scss` (edit + `bin/build-css` if you fork the gem) and the
Ruby view files under `lib/active_admin/views/`.

### Sidebar (`ActiveAdmin::Views::PrismSidebar`)

```
#header.prism-sidebar                    <- drop-in replacement for AA's header slot
  span.prism-sidebar-mobile-toggle       <- hamburger, ≤900px viewports only
  div.prism-sidebar-inner
    div.prism-sidebar-brand
      #site_title                       <- AA's own site_title verb, unchanged
    div.prism-sidebar-lang              <- only if config.language_switcher and #languages is non-empty
    div.prism-sidebar-search            <- only if config.menu_search
      svg.prism-nav-icon.prism-search-icon
      input.prism-nav-search-input[type=search][data-prism-nav-search]
      span.prism-nav-search-clear[data-prism-nav-search-clear]
        svg.prism-nav-icon              <- the :x icon
    div.prism-sidebar-scroll
      div.prism-nav-section-label       <- "PAGES"
      ul.prism-nav
        li.prism-nav-item[#prism_nav_<id>]
          [.has-children]               <- item.items.any?
          [.active]                     <- item.current?(current_tab)
          [.open]                       <- has-children && active, or user-toggled, or search match (see below)
          [.prism-nav-hidden]           <- filtered out by menu search, toggled client-side
          [.prism-search-open]          <- this item or a descendant matches the current search query
          span.prism-nav-group-toggle   <- only when .has-children
            svg.prism-nav-icon
            span.prism-nav-label
            svg.prism-chevron
          a.prism-nav-link              <- leaf items only (real url? see below)
            svg.prism-nav-icon
            span.prism-nav-label
          ul.prism-nav-submenu          <- only when .has-children, nested li.prism-nav-item...
      div.prism-nav-empty[.prism-nav-empty-visible]  <- "No matching menu items", shown when search yields zero results
    div.prism-sidebar-utility           <- only if the utility menu has items
      ul.prism-nav.prism-nav-utility
        li#prism_nav_current_user
        li#prism_nav_logout
    div.prism-sidebar-footer            <- only if config.sidebar_footer
```

Notes:
- A leaf item renders as `a.prism-nav-link` only when its url is a "real"
  url (present and not `"#"`); otherwise it renders as a plain
  `span.prism-nav-link` (see `real_url?` in `prism_sidebar.rb`) — this is
  also exactly how ActiveAdmin auto-created parent groups end up as
  non-clickable toggles (see [Parent groups & submenus](#parent-groups--submenus-nested-navigation)).
- `#prism_nav_current_user` / `#prism_nav_logout` are ActiveAdmin's own
  stable ids for the default utility nav (`Namespace#build_default_utility_nav`)
  — style hooks, not Prism inventions.
- `.nav-badge` (not `prism-`-prefixed — it's a convention *you* opt into via
  `label:`, see [Sidebar navigation: icons & badges](#sidebar-navigation-icons--badges)) is the
  class used in the README/INTEGRATION examples for badge counts; it has no
  built-in styling of its own beyond what you see in `_sidebar.scss` — it's
  just an example class name, feel free to use your own.
- Body-level state: `body.prism-sidebar-open` (mobile off-canvas open,
  toggled by `prism.js`), `body.prism-sidebar-footer-disabled` (set when
  `config.sidebar_footer` is `false` — see [Configuration reference](#configuration-reference)).

### Language switcher markup

```
div.prism-sidebar-lang[.open]                <- ".open" toggled by prism.js, not server-rendered
  span.prism-lang-toggle[aria-expanded]
    svg.prism-nav-icon                       <- the :globe icon
    span.prism-lang-current                  <- the option whose locale matches I18n.locale (or the first one)
    svg.prism-chevron
  ul.prism-lang-menu
    li
      a.prism-lang-option[.active]           <- href="<current path>?locale=<locale>", or the entry's own :url if set
```

Unlike every other piece of navigation in this gem (which walks
ActiveAdmin's own `Menu`/`MenuItem` tree, built via `menu do |m| ... end`
DSL calls in `app/admin/*.rb`), this one is constructed directly from
`ActiveAdminPrism.configuration.languages` at render time — there's no
`ActiveAdmin::Menu` object backing it, no `admin.build_menu
:utility_navigation` call needed, and no per-namespace setup. That also
means it re-renders from the *current* config on every request, the same
as `sidebar_footer`/`collapsible_filters` elsewhere in this gem, rather
than being fixed at boot the way the sidebar's own header-swap
registration is (see [Sign-in page](#sign-in-page) for the other example
of that "built once at boot vs. re-read every request" distinction).

### Menu search markup

```
div.prism-sidebar-search
  svg.prism-nav-icon.prism-search-icon
  input.prism-nav-search-input[type=search][data-prism-nav-search][placeholder="Search menu"]
  span.prism-nav-search-clear[data-prism-nav-search-clear][.prism-nav-search-clear-visible]
    svg.prism-nav-icon                          <- the :x icon
```

All filtering state lives on the existing `li.prism-nav-item` tree
rendered by [Sidebar](#sidebar-activeadminviewsprismsidebar) — `prism.js`
reads `[data-prism-nav-search]`'s value on every `input` event and, per
item, toggles:

- `.prism-nav-hidden` — item (and every descendant) doesn't match and has
  no matching descendant; hidden via CSS.
- `.prism-search-open` — item itself matches, or has a matching
  descendant; combined with `.has-children`, this is what keeps a group
  expanded during a search independently of its own user-toggled `.open`
  state.
- `.prism-nav-search-clear-visible` on the clear button, and
  `.prism-nav-empty-visible` on `div.prism-nav-empty`, both mirroring
  whether the query is non-empty / yields zero matches.

<kbd>Escape</kbd> while the input is focused and non-empty, or a click on
`[data-prism-nav-search-clear]`, clears the value and re-triggers the same
filtering pass (an empty query matches everything, restoring the nav's
prior expand/collapse state). None of this touches the server — the menu
tree itself is rendered once, same as without `config.menu_search`.

### Panels & cards

Pure CSS reskin of AA's existing `Panel`/`Component` markup — no new
classes:

```
.panel                     <- white card, border, shadow, border-radius
  > h3                     <- panel title bar
  .panel_contents           <- body padding
  .header_action            <- float:right slot (AA's own convention)
.columns > .column          <- flex card grid (dashboard layout)
```

The "Filters" sidebar section specifically (`#filters_sidebar_section`) gets
extra markup and classes — see
[Filters sidebar panel](#filters-sidebar-panel-filters_sidebar_section)
below.

### Index tables & row actions

```
table.index_table
  th[.sorted-asc/.sorted-desc]
  tr[.even][.selected]
  td.col-actions
    .table_actions                      <- wraps View/Edit/Delete for a row
      a.view_link                       <- icon: eye, color: info-blue
        svg.prism-action-icon
        span.prism-visually-hidden      <- original text label, screen-reader only
      a.edit_link                       <- icon: pencil, color: primary
      a.delete_link                     <- icon: trash, color: danger
.status_tag[.yes/.no]                   <- AA's default boolean pill (untouched markup, reskinned colors)
```

`view_link` / `edit_link` / `delete_link` are ActiveAdmin's **own** classes
(`IndexTableFor#defaults`) — Prism's `index_table_actions.rb` override only
swaps the link's *content* (icon + hidden label instead of plain text) when
`config.colorize_action_icons` is `true`; with it `false`, `item(...)`
falls back to AA's plain `link_to` untouched, and none of the
`prism-action-icon`/`prism-visually-hidden` markup is added.

### Forms & toggle switches

```
form fieldset.inputs
  li[.error]                            <- p.inline-errors, red border on the field
ul.errors                               <- error summary box

// as: :boolean (AA default) — reskinned checkbox, no new classes:
input[type="checkbox"] / input[type="radio"]

// as: :prism_toggle (opt-in, PrismToggleInput):
label.prism-toggle
  input.prism-toggle-input              <- visually hidden (width/height:0), still focusable
  span.prism-toggle-track               <- the visible pill+thumb, :checked~ sibling selector drives it

// prism_toggle_tag(value) (opt-in, read-only index/show helper):
span.prism-toggle-tag[.on/.off]
  span.prism-toggle-track
```

`.prism-toggle-track` is shared between the live form input and the
read-only tag — same pill/thumb CSS, driven by a sibling `:checked`
selector in the form case and by the `.on`/`.off` class in the read-only
case (there's no real `<input>` on an index/show page).

### Filters sidebar panel (`#filters_sidebar_section`)

Only this specific `SidebarSection` (AA's built-in id for the Filters
panel) gets the extra icon/collapse markup — any other sidebar section
(dashboard panels, a host's own `sidebar :title do ... end`) is untouched:

```
#sidebar                                <- AA's own right-hand content sidebar (not Prism's left nav)
  .panel#filters_sidebar_section.prism-collapsible-panel[.open]
    > h3                                <- the icon-only button when collapsed
      svg.prism-filter-icon
      span.prism-filter-label           <- visually hidden (max-width:0) while collapsed
    .panel_contents                     <- max-height:0 while collapsed, animates open
      form.filter_form
        .filter_form_field[.select_and_search][.filter_date_range]
```

`.prism-collapsible-panel` and the icon/label markup are only added when
`config.collapsible_filters` is `true`; `prism.js` mirrors the panel's
`.open` state onto `body.prism-filters-open`, which is what
`#active_admin_content`/`#sidebar`'s reflow rules key off (`:has()` — see
[Collapsible "Filters" sidebar](#collapsible-filters-sidebar)). With the config `false`,
`body.prism-filters-collapsible-disabled` is the backstop class that forces
the panel back to always-expanded.

### Flash messages markup

```
.flashes[data-prism-transition-ms][data-prism-auto-dismiss-ms]
  .flash.flash_notice / .flash_error / .flash_alert [.prism-flash-hide]
    span.prism-flash-message
    button.prism-flash-dismiss[data-prism-flash-dismiss]   <- only if config.flash_dismissible
      svg.prism-flash-dismiss-icon
```

`flash_notice`/`flash_error`/`flash_alert` are ActiveAdmin's own type
classes (from `flash_messages.each { |type, ...| }`); Prism just colors
each one distinctly. `.prism-flash-hide` is added by `prism.js` right
before removal (opacity/transform transition), timed against the
`data-prism-transition-ms` attribute — see
[Flash messages](#flash-messages) / [Configuration reference](#configuration-reference).

### Confirm dialog (jQuery UI)

Not Prism markup at all — this is ActiveAdmin's own `$.fn.dialog` output
(`active_admin/base.js`), reskinned by targeting jQuery UI's own classes:

```
.ui-widget-overlay
.ui-dialog
  .ui-dialog-titlebar
  form > ul > li                        <- batch-action inputs, if any (empty <ul> for a plain confirm)
  .ui-dialog-buttonpane
    .ui-dialog-buttonset
      button:first-child                <- OK/Confirm — prism-button-primary
      button:last-child                 <- Cancel — prism-button-secondary
```

### Sign-in page markup

This same structure is shared by all six auth pages (see
[Sign-in page](#sign-in-page)) — `form#session_new` below is whichever
form that particular action renders (`#registration_new` for sign up,
etc.), byte-for-byte ActiveAdmin's own template either way:

```
body.logged_out
  #wrapper
    #content_wrapper                    <- centered 400px column when .prism-login-brand is present
      .flashes
      #active_admin_content              <- the white card itself
        #login.prism-login
          [devise/shared/_brand partial:]
            div.prism-login-brand       <- only when config.login_page is true
              div.prism-login-logo
                svg.prism-login-mark    <- default mark; absent if login_logo renders something else
                  .prism-login-tri      <- the triangle (animated glow)
                  .prism-login-beam     <- each dispersed line (animated dash-flow)
              h2.prism-login-title
              p.prism-login-tagline      <- login_tagline on sessions#new; the page's own action title everywhere else
            [h2 (plain, no wrapper)]     <- rendered instead of .prism-login-brand when config.login_page is false
          #error_explanation            <- ActiveAdmin's own shared error-messages partial (every page but sessions#new, which uses the flash instead)
          form#session_new              <- untouched Devise/Formtastic form markup
            fieldset.inputs              <- border/radius suppressed here (see below) — redundant inside the card
            fieldset.actions             <- submit button stretched full-width (see below)
          div.prism-login-links         <- wraps active_admin/devise/shared/_links.erb's sign-up/forgot-password/etc links, now pill-chip styled
    #footer
```

All of the card/blob/centering CSS is scoped under
`body.logged_out:has(.prism-login-brand)` (see `scss-src/_login.scss`) —
it only ever applies on these actual auth pages, and never when
`config.login_page` is `false` (since `.prism-login-brand` then never
renders at all). `#wrapper` itself gets its `display: block` layout back
via a `body:not(.logged_out)` guard on the sidebar's own `#wrapper` grid
rule in `scss-src/_sidebar.scss`, since that id is reused (with a totally
different two-child structure) by the logged-out layout.

Two more fixes live in that same scoped block: `fieldset.inputs`'s own
card border/radius (right everywhere else a fieldset sits directly on the
gray page background) is suppressed here specifically, since it otherwise
draws a redundant second box inside the already-bordered auth-page card;
and the submit button (`fieldset.actions input[type="submit"]`) is
stretched to the full card width rather than left-aligned, so it's never
ambiguously off-center against the centered brand block above it or the
centered link chips below it.

### Body-level state classes

All of these are added/removed by `body_classes` in
`lib/active_admin/views/flash_messages.rb` (server-rendered, current on
every request) or toggled by `prism.js` at runtime — see
[How this crosses the server/client boundary](#configuration-reference):

| Class | Meaning |
| --- | --- |
| `prism-sidebar-open` | Mobile off-canvas sidebar is open (≤900px viewports). Runtime only, via `prism.js`. |
| `prism-filters-open` | Filters panel is currently expanded — drives the content-area reflow. Runtime only, mirrors `#filters_sidebar_section.open`. |
| `prism-styled-confirms-disabled` | `config.styled_confirms` is `false` — `prism.js`'s `$.rails.allowAction` override no-ops. |
| `prism-filters-collapsible-disabled` | `config.collapsible_filters` is `false` — Filters panel forced always-expanded. |
| `prism-sidebar-footer-disabled` | `config.sidebar_footer` is `false` — original `#footer` stays visible; the sidebar's own footer div isn't rendered at all. |

### Design tokens (Sass variables)

Defined in `scss-src/_variables.scss`, all `!default`. These compile into
the shipped, precompiled `prism.css` — they are **not** overridable from a
host app (see [Customizing colors](#customizing-colors) for why, and for
the separate, host-overridable set of ActiveAdmin's own variables via
`variable_overrides.scss`):

| Variable | Default | Used for |
| --- | --- | --- |
| `$prism-color-primary` | `#6d5bd0` | Active nav item, primary buttons, links, focus rings |
| `$prism-color-primary-dark` | `#5949b8` | Hover/active state of the above |
| `$prism-color-primary-light` | `#f2ecfd` | Active nav background, selected table row, hover backgrounds |
| `$prism-color-success` / `-light` | `#22c55e` / `#e8f9ee` | Notice flash, "yes" status tag |
| `$prism-color-danger` / `-light` | `#ef4444` / `#fdecec` | Error/alert flash, "no" status tag, delete action, field errors |
| `$prism-color-warning` | `#f59e0b` | Reserved (no default component uses this yet) |
| `$prism-color-info` | `#3b82f6` | View action icon |
| `$prism-bg-page` | `#f4f5f7` | Page background, table header background |
| `$prism-bg-card` | `#ffffff` | Panel/card/dialog background |
| `$prism-bg-sidebar` | `#ffffff` | Sidebar background |
| `$prism-text-heading` / `-body` / `-muted` / `-inverse` | `#1a1f36` / `#384250` / `#6b7280` / `#ffffff` | Text color scale |
| `$prism-border-color` / `-strong` | `#e6e8ec` / `#d6d9e0` | Hairline borders / stronger input borders |
| `$prism-sidebar-width` | `264px` | **Prism's own** sidebar column width (CSS Grid) — separate from AA's own `$sidebar-width` (320px, set in `variable_overrides.scss`, which sizes the *Filters* sidebar and is host-overridable) |
| `$prism-radius` / `-sm` / `-pill` | `10px` / `6px` / `999px` | Border-radius scale (cards / buttons+inputs / pills+toggles) |
| `$prism-shadow-card` / `-popover` | see source | Box-shadow scale |
| `$prism-font-family` | system font stack | Body font |
| `$prism-transition-fast` | `120ms ease` | Hover/focus transitions |
| `$prism-filters-collapsed-gutter` (`_panels.scss`) | `72px` | Width the content area reflows to when the Filters panel is collapsed |

## Customizing colors

There are two independent color surfaces, because ActiveAdmin's own CSS
and Prism's CSS are two separately-compiled stylesheets:

**1. Prism's own palette** (`scss-src/_variables.scss` in this gem's
source — `$prism-color-primary`, `$prism-bg-page`, `$prism-sidebar-width`,
etc.). To change these you need to fork the gem's SCSS source, edit the
variables, and run `bin/build-css` to produce your own `prism.css` — there's
no way to override these from a host app, since `prism.css` ships
precompiled specifically so installing the gem doesn't require a Sass
compiler.

**2. ActiveAdmin's own default palette**
(`active_admin/mixins/_variables.scss` and `_gradients.scss` in the
`activeadmin` gem — `$primary-color`, `$text-color`, etc.), which drives
things Prism doesn't have Ruby-level control over: the jQuery UI
batch-actions dialog, the dropdown menu popup, anything you build yourself
with `panel`/`section-background`. The gem ships
[`variable_overrides.scss`](app/assets/stylesheets/active_admin_prism/_variable_overrides.scss) —
Prism's values for every one of these — which the install generator wires
up automatically (see [Install](#install)). Every variable in that file is
itself `!default`, so to customize further, set your own value **before**
that `@import` in your `active_admin.scss` and it wins:

```scss
// app/assets/stylesheets/active_admin.scss
$primary-color: #your-brand-color;
@import "active_admin_prism/variable_overrides";
@import "active_admin/mixins";
@import "active_admin/base";
```

## Troubleshooting

**"I made a change and nothing looks different."** By far the most common
cause in practice: browser caching. The gem fingerprints its assets by
content hash, so a genuinely new `prism.css`/`prism.js` always gets a new
URL — but the *HTML page* referencing the old URL can still be served from
your browser's cache. Hard-refresh; if that doesn't help, open a private/
incognito window, which guarantees zero cached anything.

**"A button/link still shows ActiveAdmin's default gray, not Prism's
colors."** ActiveAdmin's own CSS uses some ID-scoped selectors (e.g.
`#header a`) and wraps hover/active states in `:not(.disabled)` — both add
specificity that a naive class-based override can lose to regardless of
load order. If you're overriding something yourself (custom CSS on top of
Prism), match ActiveAdmin's actual selector path rather than a flatter one,
or reach for `!important` on the specific property that's losing.

**"The confirm dialog / dismiss button isn't behaving."** These are
client-side JS (`prism.js`) — if `jquery-rails`/`jquery-ujs` isn't loaded
in your app, the confirm-dialog override no-ops silently by design (falls
back to the native browser confirm rather than erroring).

**"Sass compile error mentioning `$primary-color` or a missing mixin."**
Make sure `@import "active_admin_prism/variable_overrides"` comes
**before** `@import "active_admin/mixins"`, and that you haven't
accidentally commented out `active_admin/mixins` while leaving
`active_admin/base` active — `base` depends on `mixins` being loaded
first.

**"The sign-in page still looks like stock ActiveAdmin even though
`config.login_page` is `true`."** This one specific piece of Prism (see
[Sign-in page](#sign-in-page)) depends on Gemfile order: `gem
"active_admin_prism"` needs to be declared **after** `gem
"activeadmin"` so this gem's view overrides ActiveAdmin's own. This is the
natural, expected order already (the theme depends on ActiveAdmin), so it's
rarely an issue in practice — but if your Gemfile has an unusual `group`/
`require:` setup that changes load order, reordering those two lines fixes
it. Nothing else in the theme (CSS reskin, sidebar, tables, forms) depends
on this ordering — only the sign-in page's brand markup does.

## Upgrading

Since Prism is CSS/JS/light Ruby overrides on top of ActiveAdmin's public
extension points (`ViewFactory.register`, documented `item()` hooks,
`!default` Sass variables) rather than a fork, upgrading `activeadmin` or
this gem independently is expected to keep working across minor versions.
After upgrading either, re-run through
[Verifying the install](#verifying-the-install) once.

## Uninstalling

1. Remove `ActiveAdminPrism.enable!` from
   `config/initializers/active_admin.rb`.
2. Remove `@import "active_admin_prism/variable_overrides";` from
   `active_admin.scss`, if present.
3. Remove `gem "active_admin_prism"` from your Gemfile and
   `bundle install`.
