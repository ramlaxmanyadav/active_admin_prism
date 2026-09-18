// This is the real source — mirrors scss-src/*.scss's role for the CSS
// side. `bin/build-js` minifies this into
// app/assets/javascripts/active_admin_prism/prism.js, the file actually
// registered via ActiveAdmin.application.register_javascript and shipped
// to hosts. Never hand-edit that compiled copy — edit this file and
// rebuild. See bin/build-css's own comment for why shipping pre-minified
// assets matters even though Sprockets hosts would otherwise re-minify on
// their own `assets:precompile` — Propshaft hosts have no such step.
//
// Prism sidebar behaviour: collapsible nav groups + mobile off-canvas
// toggle. Vanilla JS, no dependency on jQuery/Stimulus/a bundler.
(function () {
  "use strict";

  var STORAGE_PREFIX = "prism_sidebar_";

  function storageKey(li) {
    return STORAGE_PREFIX + li.id;
  }

  function setOpen(li, open) {
    li.classList.toggle("open", open);
    try {
      window.localStorage.setItem(storageKey(li), open ? "1" : "0");
    } catch (e) {
      // localStorage unavailable (private mode, disabled, etc.) — degrade to
      // in-memory only, no persistence across reloads.
    }
  }

  function restoreGroupState(sidebar) {
    var groups = sidebar.querySelectorAll(".prism-nav-item.has-children");
    groups.forEach(function (li) {
      var stored;
      try {
        stored = window.localStorage.getItem(storageKey(li));
      } catch (e) {
        stored = null;
      }

      if (stored === "1") {
        li.classList.add("open");
      } else if (stored === "0") {
        li.classList.remove("open");
      }
      // stored === null: leave the server-rendered default (open only when
      // it contains the active item) untouched.
    });
  }

  function onToggleClick(event) {
    var toggle = event.target.closest("[data-prism-toggle]");
    if (!toggle) return;

    var li = toggle.closest(".prism-nav-item");
    if (!li) return;

    setOpen(li, !li.classList.contains("open"));
  }

  function onSidebarButtonClick(event) {
    var button = event.target.closest("[data-prism-toggle-sidebar]");
    if (!button) return;

    document.body.classList.toggle("prism-sidebar-open");
  }

  document.addEventListener("DOMContentLoaded", function () {
    var sidebar = document.getElementById("header");
    if (!sidebar || !sidebar.classList.contains("prism-sidebar")) return;

    restoreGroupState(sidebar);
    sidebar.addEventListener("click", onToggleClick);
    sidebar.addEventListener("click", onSidebarButtonClick);
  });
})();

// Desktop sidebar rail-collapse toggle (ActiveAdminPrism::Configuration
// #sidebar_collapsible) — separate from the mobile off-canvas toggle above:
// that one slides the whole sidebar on/off screen below 900px; this one
// shrinks it to a narrow icon-only rail on desktop instead, and the two
// don't interact (scss-src/_sidebar.scss scopes rail-collapse to nothing in
// particular, but the mobile media query's own `transform`/`position: fixed`
// rules take over below 900px regardless of this class). State persists to
// localStorage under its own key, same convention as the nav-group state
// above, so a returning visitor keeps their last choice.
(function () {
  "use strict";

  var STORAGE_KEY = "prism_sidebar_collapsed";

  function setCollapsed(toggle, collapsed) {
    document.body.classList.toggle("prism-sidebar-collapsed", collapsed);
    toggle.setAttribute("aria-expanded", collapsed ? "false" : "true");
    toggle.setAttribute("aria-label", collapsed ? "Expand sidebar" : "Collapse sidebar");
    try {
      window.localStorage.setItem(STORAGE_KEY, collapsed ? "1" : "0");
    } catch (e) {
      // localStorage unavailable — degrade to in-memory only, no
      // persistence across reloads.
    }
  }

  document.addEventListener("DOMContentLoaded", function () {
    var toggle = document.querySelector("[data-prism-toggle-sidebar-collapse]");
    if (!toggle) return;

    var stored;
    try {
      stored = window.localStorage.getItem(STORAGE_KEY);
    } catch (e) {
      stored = null;
    }
    if (stored === "1") setCollapsed(toggle, true);

    toggle.addEventListener("click", function () {
      setCollapsed(toggle, !document.body.classList.contains("prism-sidebar-collapsed"));
    });
    toggle.addEventListener("keydown", function (event) {
      if (event.key !== "Enter" && event.key !== " ") return;
      event.preventDefault();
      setCollapsed(toggle, !document.body.classList.contains("prism-sidebar-collapsed"));
    });
  });
})();

// Sidebar menu search box (lib/active_admin/views/prism_sidebar.rb
// #render_search_box) — filters the "Pages" nav as the visitor types,
// matching an item's own label at ANY nesting depth, not just top-level
// entries. A submenu item that matches keeps every one of its ancestors
// visible and forced open; a parent whose own label matches instead keeps
// its *entire* subtree visible and expanded, even children that don't
// match on their own — either way via ".prism-search-open", distinct from
// the persisted/manual ".open" class above so clearing the search can't
// clobber a group the visitor had manually pinned open.
(function () {
  "use strict";

  function normalize(text) {
    return (text || "").trim().toLowerCase();
  }

  function ownLabel(li) {
    var el = li.querySelector(
      ":scope > .prism-nav-link .prism-nav-label, :scope > .prism-nav-group-toggle .prism-nav-label"
    );
    return el ? normalize(el.textContent) : "";
  }

  function directChildItems(li) {
    var submenu = li.querySelector(":scope > .prism-nav-submenu");
    if (!submenu) return [];
    return Array.prototype.filter.call(submenu.children, function (child) {
      return child.classList.contains("prism-nav-item");
    });
  }

  // Recurses depth-first, carrying `ancestorOwnMatch` down (true once any
  // ancestor's own label has matched) so a matched group reveals its whole
  // subtree, not just itself — and returns whether this node's own label
  // or any descendant's matched (ignoring ancestorOwnMatch), so that signal
  // keeps bubbling up to open every group on the path to a deep match
  // regardless of how many submenu levels separate it from the top.
  function matchItem(li, query, ancestorOwnMatch) {
    var ownMatch = !!query && ownLabel(li).indexOf(query) !== -1;
    var childMatch = false;

    directChildItems(li).forEach(function (child) {
      if (matchItem(child, query, ancestorOwnMatch || ownMatch)) childMatch = true;
    });

    var visible = !query || ancestorOwnMatch || ownMatch || childMatch;
    li.classList.toggle("prism-nav-hidden", !visible);
    li.classList.toggle("prism-search-open", !!query && (ownMatch || childMatch || ancestorOwnMatch));

    return ownMatch || childMatch;
  }

  function applySearch(sidebar, query) {
    var nav = sidebar.querySelector(".prism-sidebar-scroll > .prism-nav");
    if (!nav) return;

    var anyVisible = false;
    Array.prototype.forEach.call(nav.children, function (li) {
      if (!li.classList.contains("prism-nav-item")) return;
      if (matchItem(li, query, false)) anyVisible = true;
    });

    var empty = sidebar.querySelector(".prism-nav-empty");
    if (empty) empty.classList.toggle("prism-nav-empty-visible", !!query && !anyVisible);

    var clear = sidebar.querySelector("[data-prism-nav-search-clear]");
    if (clear) clear.classList.toggle("prism-nav-search-clear-visible", !!query);
  }

  document.addEventListener("DOMContentLoaded", function () {
    var sidebar = document.getElementById("header");
    if (!sidebar || !sidebar.classList.contains("prism-sidebar")) return;

    var input = sidebar.querySelector("[data-prism-nav-search]");
    if (!input) return;

    input.addEventListener("input", function () {
      applySearch(sidebar, normalize(input.value));
    });

    input.addEventListener("keydown", function (event) {
      if (event.key !== "Escape" || !input.value) return;
      input.value = "";
      applySearch(sidebar, "");
    });

    var clearBtn = sidebar.querySelector("[data-prism-nav-search-clear]");
    if (clearBtn) {
      clearBtn.addEventListener("click", function () {
        input.value = "";
        applySearch(sidebar, "");
        input.focus();
      });
    }
  });
})();

// Routes every plain `data-confirm` link (row-level View/Edit/Delete
// actions, any other rails-ujs confirm) through ActiveAdmin's own styled
// jQuery UI dialog — the same one it already uses for Batch Actions —
// instead of the native, unstylable browser confirm(). Batch Actions links
// are left alone; they already run their own confirm flow (with dynamic
// per-action inputs) via active_admin/base.js.
//
// This overrides $.rails.allowAction, jquery-ujs's documented extension
// point for custom confirm dialogs (jquery_ujs.js: "may be overridden with
// custom confirm dialog in $.rails.confirm" / allowAction). allowAction is
// called synchronously and expects true/false; since our dialog is async,
// we return false to block the original action, then re-`click()` the same
// element after the user confirms — allowAction runs again, sees the
// "prismConfirmed" flag, and returns true so rails-ujs's normal
// data-method handling proceeds untouched.
(function () {
  "use strict";

  document.addEventListener("DOMContentLoaded", function () {
    // Set by Pages::Base#body_classes when
    // ActiveAdminPrism.configuration.styled_confirms is false.
    if (document.body.classList.contains("prism-styled-confirms-disabled")) return;
    if (typeof jQuery === "undefined" || !jQuery.rails || !window.ActiveAdmin || !window.ActiveAdmin.ModalDialog) {
      return;
    }

    var $ = jQuery;
    var originalAllowAction = $.rails.allowAction;

    $.rails.allowAction = function (element) {
      var message = element.data("confirm");
      if (!message) return originalAllowAction.call($.rails, element);
      if (element.closest(".batch_actions_selector").length) {
        return originalAllowAction.call($.rails, element);
      }
      if (element.data("prismConfirmed")) {
        element.removeData("prismConfirmed");
        return true;
      }

      new window.ActiveAdmin.ModalDialog(message, {}, function () {
        element.data("prismConfirmed", true);
        element[0].click();
      });

      return false;
    };
  });
})();

// Flash messages: dismiss button + auto-hide, toast-style (see
// scss-src/_base.scss for the floating card layout and the
// ".prism-flash-progress" countdown bar this keeps in sync with). See
// lib/active_admin/views/flash_messages.rb, which renders the
// ".prism-flash-dismiss" button markup this responds to, and two data
// attributes this reads at runtime so Ruby-side config controls behavior
// without needing to rebuild this static asset:
//   - "data-prism-auto-dismiss-ms" (present only when
//     ActiveAdminPrism.configuration.flash_auto_dismiss is true)
//   - "data-prism-transition-ms" (ActiveAdminPrism::Configuration
//     #flash_transition_ms) — applied as an inline transition-duration
//     (overriding the CSS default) and reused as the removal delay, so the
//     fade-out animation and the element's actual removal always stay in
//     sync regardless of the configured duration.
(function () {
  "use strict";

  var DEFAULT_TRANSITION_MS = 320;

  function dismiss(flash, transitionMs) {
    if (flash.dataset.prismDismissed) return;
    flash.dataset.prismDismissed = "true";
    flash.style.transitionDuration = transitionMs + "ms";
    flash.classList.add("prism-flash-hide");
    setTimeout(function () {
      flash.remove();
    }, transitionMs);
  }

  // Hovering a toast pauses both its countdown bar (CSS
  // "animation-play-state: paused" on :hover, in scss-src/_base.scss) and
  // the actual removal timer here, tracking whatever time was left rather
  // than restarting from the full duration — a flash a visitor is
  // mid-read shouldn't silently vanish out from under them just because
  // its timer happened to elapse while their mouse was still over it.
  function armAutoDismiss(flash, totalMs, transitionMs) {
    var remainingMs = totalMs;
    var timer = null;
    var startedAt = null;

    function start() {
      startedAt = Date.now();
      timer = setTimeout(function () {
        dismiss(flash, transitionMs);
      }, remainingMs);
    }

    function pause() {
      if (!timer) return;
      clearTimeout(timer);
      timer = null;
      remainingMs -= Date.now() - startedAt;
    }

    flash.addEventListener("mouseenter", pause);
    flash.addEventListener("mouseleave", start);
    start();
  }

  document.addEventListener("DOMContentLoaded", function () {
    var flashesWrapper = document.querySelector(".flashes");
    var flashes = document.querySelectorAll(".flashes .flash");
    if (!flashes.length) return;

    var transitionMs = (flashesWrapper && parseInt(flashesWrapper.dataset.prismTransitionMs, 10)) || DEFAULT_TRANSITION_MS;
    var autoDismissMs = flashesWrapper && parseInt(flashesWrapper.dataset.prismAutoDismissMs, 10);

    if (autoDismissMs) {
      flashes.forEach(function (flash) {
        armAutoDismiss(flash, autoDismissMs, transitionMs);
      });
    }

    document.addEventListener("click", function (event) {
      var button = event.target.closest("[data-prism-flash-dismiss]");
      if (!button) return;
      dismiss(button.closest(".flash"), transitionMs);
    });
  });
})();

// Collapsible sidebar sections: collapse to a single icon button by
// default, expanding to the full panel on click. See
// scss-src/_panels.scss (.prism-collapsible-panel) for the actual
// collapse/expand styling — this only toggles a section's own ".open"
// class an inline click responds to. Applies to every section, not just
// Filters — see lib/active_admin/views/filters_sidebar.rb, which
// generalized this from a Filters-only treatment to cover any sidebar
// section, including a host's own custom `sidebar "Title" do ... end`
// block. Skipped entirely when
// ActiveAdminPrism.configuration.collapsible_filters is false (the
// "prism-filters-collapsible-disabled" body class, set in
// lib/active_admin/views/flash_messages.rb#body_classes).
(function () {
  "use strict";

  var onOpenChange = null;

  function setOpen(section, toggle, open) {
    section.classList.toggle("open", open);
    toggle.setAttribute("aria-expanded", open ? "true" : "false");
    // The Filters section specifically also mirrors its state onto
    // <body> — #main_content (the table/grid area) is a *sibling* of
    // #sidebar, not a descendant of this section, so CSS can't reach
    // across siblings any other way. scss-src/_panels.scss's own
    // #sidebar width reflow no longer needs this (that rule now reacts
    // to ANY section's ".open" via ":has()" instead of this one
    // specifically), but a host's own CSS may already key off this
    // documented class, so it's kept.
    if (section.id === "filters_sidebar_section") {
      document.body.classList.toggle("prism-filters-open", open);
    }
    if (onOpenChange) onOpenChange();
  }

  function wireUp(section) {
    var toggle = section.querySelector(":scope > h3");
    if (!toggle) return null;

    toggle.setAttribute("role", "button");
    toggle.setAttribute("tabindex", "0");
    toggle.setAttribute("aria-expanded", section.classList.contains("open") ? "true" : "false");

    toggle.addEventListener("click", function () {
      setOpen(section, toggle, !section.classList.contains("open"));
    });
    toggle.addEventListener("keydown", function (event) {
      if (event.key !== "Enter" && event.key !== " ") return;
      event.preventDefault();
      setOpen(section, toggle, !section.classList.contains("open"));
    });

    return toggle;
  }

  // Every OTHER collapsible section — anything besides Filters, e.g. a
  // host's own custom `sidebar "..." do ... end` block — gets consolidated
  // into a single "More Actions"-labeled Select2 dropdown instead of each
  // rendering its own individually collapsed icon button; picking one
  // opens it and closes every other non-Filters section (a section's own
  // header still opens/closes it directly too, syncing the dropdown's
  // value either way). Filters is deliberately excluded from this and
  // always keeps its own plain icon button exactly as before, whether or
  // not any other sections exist — see ActiveAdminPrism::Configuration
  // #collapsible_filters.
  function buildOtherSectionsDropdown(sidebar, entries) {
    if (typeof jQuery === "undefined" || !jQuery.fn.select2) return;

    sidebar.classList.add("prism-sidebar-multi-panel");

    var wrapper = document.createElement("div");
    wrapper.className = "prism-sidebar-panel-select-wrapper";

    var label = document.createElement("span");
    label.className = "prism-sidebar-panel-select-label";
    label.textContent = "More Actions";
    label.id = "prism-sidebar-panel-select-label";

    var select = document.createElement("select");
    select.className = "prism-sidebar-panel-select";
    select.setAttribute("aria-labelledby", label.id);
    // A real leading <option value=""> is what lets Select2 show a
    // placeholder on a *single* select, and (with allowClear) is what
    // "x" resets to — closing every section, back to a fully collapsed
    // gutter with nothing open.
    select.appendChild(document.createElement("option"));

    var openIndex = -1;
    entries.forEach(function (entry, index) {
      var option = document.createElement("option");
      option.value = String(index);
      option.textContent = entry.section.getAttribute("data-prism-panel-title") || "Panel " + (index + 1);
      select.appendChild(option);
      if (entry.section.classList.contains("open")) openIndex = index;
    });

    wrapper.appendChild(label);
    wrapper.appendChild(select);
    // Placed right where the first non-Filters section would otherwise
    // have rendered its own icon button — not forced to the very top of
    // #sidebar, which would visually queue it ahead of Filters.
    sidebar.insertBefore(wrapper, entries[0].section);

    var $select = jQuery(select).select2({
      width: "100%",
      placeholder: "Select an action",
      allowClear: true,
      minimumResultsForSearch: 6
    });

    if (openIndex >= 0) $select.val(String(openIndex)).trigger("change");

    $select.on("select2:select", function (event) {
      var index = parseInt(event.params.data.id, 10);
      entries.forEach(function (entry, i) {
        setOpen(entry.section, entry.toggle, i === index);
      });
    });

    $select.on("select2:clear", function () {
      entries.forEach(function (entry) {
        setOpen(entry.section, entry.toggle, false);
      });
    });

    // Keeps the dropdown in sync when a section is opened/closed some
    // other way (its own header) instead of through this dropdown.
    onOpenChange = function () {
      var current = entries.filter(function (entry) {
        return entry.section.classList.contains("open");
      })[0];
      var index = current ? String(entries.indexOf(current)) : "";
      if ($select.val() !== index) $select.val(index).trigger("change");
    };
  }

  document.addEventListener("DOMContentLoaded", function () {
    if (document.body.classList.contains("prism-filters-collapsible-disabled")) return;

    var sidebar = document.getElementById("sidebar");
    var filtersSection = document.getElementById("filters_sidebar_section");
    var filtersToggle = null;
    var otherEntries = [];

    document.querySelectorAll(".prism-collapsible-panel").forEach(function (section) {
      var toggle = wireUp(section);
      if (!toggle) return;

      if (section === filtersSection) {
        filtersToggle = toggle;
        return;
      }

      var titleEl = toggle.querySelector(".prism-filter-label");
      section.setAttribute("data-prism-panel-title", titleEl ? titleEl.textContent : section.id);
      otherEntries.push({ section: section, toggle: toggle });
    });

    if (filtersSection) {
      document.body.classList.toggle("prism-filters-open", filtersSection.classList.contains("open"));
    }

    if (sidebar && otherEntries.length > 0) buildOtherSectionsDropdown(sidebar, otherEntries);

    // The active-filters bar (see lib/active_admin/views/active_filters_bar.rb,
    // ActiveAdminPrism::Configuration#active_filters_bar) is a shortcut
    // straight to the Filters form itself — clicking anywhere on it always
    // *opens* the panel (never toggles it closed; that's still the
    // funnel icon's job) and scrolls it into view, since #sidebar isn't
    // sticky the way the left nav is and can scroll out of view on a
    // long table.
    var activeFiltersBar = document.getElementById("prism_active_filters_bar");
    if (activeFiltersBar && filtersSection && filtersToggle) {
      activeFiltersBar.setAttribute("role", "button");
      activeFiltersBar.setAttribute("tabindex", "0");
      activeFiltersBar.setAttribute("aria-label", "Show filters");

      var openFromBar = function (event) {
        if (event.type === "keydown" && event.key !== "Enter" && event.key !== " ") return;
        if (event.type === "keydown") event.preventDefault();
        setOpen(filtersSection, filtersToggle, true);
        filtersSection.scrollIntoView({ behavior: "smooth", block: "nearest" });
      };

      activeFiltersBar.addEventListener("click", openFromBar);
      activeFiltersBar.addEventListener("keydown", openFromBar);
    }
  });
})();

// "Languages" sidebar dropdown (see
// lib/active_admin/views/prism_sidebar.rb#render_language_switcher) —
// click/keyboard toggle plus click-outside-to-close, matching how a normal
// dropdown popover behaves. Absent from the page entirely (nothing for this
// to attach to) when ActiveAdminPrism.configuration.language_switcher or
// #languages is empty, so no explicit disabled-body-class check is needed
// here, unlike prism.js's other config-gated behaviors.
(function () {
  "use strict";

  function closeAll(except) {
    document.querySelectorAll(".prism-sidebar-lang.open").forEach(function (wrapper) {
      if (wrapper === except) return;
      wrapper.classList.remove("open");
      var toggle = wrapper.querySelector(".prism-lang-toggle");
      if (toggle) toggle.setAttribute("aria-expanded", "false");
    });
  }

  document.addEventListener("DOMContentLoaded", function () {
    var toggle = document.querySelector(".prism-lang-toggle");
    if (!toggle) return;

    var wrapper = toggle.closest(".prism-sidebar-lang");

    function toggleOpen() {
      var open = wrapper.classList.toggle("open");
      toggle.setAttribute("aria-expanded", open ? "true" : "false");
      if (open) closeAll(wrapper);
    }

    toggle.setAttribute("role", "button");
    toggle.setAttribute("tabindex", "0");

    toggle.addEventListener("click", function (event) {
      event.stopPropagation();
      toggleOpen();
    });
    toggle.addEventListener("keydown", function (event) {
      if (event.key !== "Enter" && event.key !== " ") return;
      event.preventDefault();
      toggleOpen();
    });

    document.addEventListener("click", function () {
      closeAll();
    });
  });
})();

// Auto-enhances every plain <select> ActiveAdmin renders (filters, form
// inputs, association pickers) into a searchable Select2 widget when
// ActiveAdminPrism.configuration.select2 is true (the
// "prism-select2-enabled" body class, set in
// lib/active_admin/views/flash_messages.rb#body_classes). Select2 itself
// (vendor/select2/select2.full.min.js, MIT licensed) is concatenated just
// above this file in the compiled asset (see bin/build-js) — turning this
// flag on needs no host-side JS/npm setup of its own. Skips any <select>
// a host already initialized manually (the per-field
// input_html: { class: "..." } + own .select2() call approach predating
// this flag, still documented in INTEGRATION.md) so the two can coexist
// without double-initializing the same element.
(function () {
  "use strict";

  document.addEventListener("DOMContentLoaded", function () {
    if (!document.body.classList.contains("prism-select2-enabled")) return;
    if (typeof jQuery === "undefined" || !jQuery.fn.select2) return;

    var $ = jQuery;
    $("select").each(function () {
      var $select = $(this);
      if ($select.data("select2")) return;
      $select.select2({ width: "100%" });
    });
  });
})();

// Consolidates a title bar with many `action_item` buttons (a resource
// that registers a dozen+ CSV upload / bulk-action links is a real
// example this was built for) into a single Select2 "jump menu" instead
// of a multi-row wall of individual buttons. See
// ActiveAdminPrism::Configuration#action_items_dropdown/
// #action_items_dropdown_threshold and lib/active_admin/views/title_bar.rb
// for the Ruby side (the "data-prism-action-items-threshold" attribute
// this reads — its mere presence also means #action_items_dropdown is
// on). Purely client-side DOM restructuring: each existing `.action_item`
// element is moved as-is (not a clone) into a hidden holding area, so
// whatever Ruby/Arbre content a host's own `action_item` block rendered —
// a plain link, a `button_to` form (its own data-method/data-confirm
// included), anything — keeps working completely unmodified; selecting an
// option here just finds and `.click()`s the real trigger inside it,
// rather than this file trying to reimplement navigation/submission
// itself. Select2 (vendor/select2/select2.full.min.js) is concatenated
// into this same compiled asset regardless of
// ActiveAdminPrism.configuration.select2 (that flag only controls
// auto-enhancing a *host's own* selects) — jQuery itself is always
// present too, since ActiveAdmin's own base.js already depends on it —
// so both are always available here with no extra host setup.
(function () {
  "use strict";

  document.addEventListener("DOMContentLoaded", function () {
    var right = document.getElementById("titlebar_right");
    if (!right || !right.dataset.prismActionItemsThreshold) return;
    if (typeof jQuery === "undefined" || !jQuery.fn.select2) return;

    var threshold = parseInt(right.dataset.prismActionItemsThreshold, 10);
    var container = right.querySelector(":scope > .action_items");
    if (!threshold || !container) return;

    var items = Array.prototype.slice.call(container.querySelectorAll(":scope > .action_item"));
    if (items.length <= threshold) return;

    var wrapper = document.createElement("span");
    wrapper.className = "prism-action-items-dropdown";

    var holding = document.createElement("div");
    holding.className = "prism-action-items-holding";
    holding.hidden = true;

    var select = document.createElement("select");
    select.className = "prism-action-items-select";
    // A real leading <option value=""> (kept selected, non-removable via
    // Select2's "x") is what lets Select2 show a placeholder on a
    // *single* select at all — see its own docs on this requirement.
    select.appendChild(document.createElement("option"));

    items.forEach(function (item, index) {
      var trigger = item.querySelector("a, button, input[type=submit]");
      var label = trigger ? (trigger.value || trigger.textContent) : item.textContent;

      var option = document.createElement("option");
      option.value = String(index);
      option.textContent = (label || "").trim();
      select.appendChild(option);

      item.dataset.prismActionItemsIndex = String(index);
      holding.appendChild(item);
    });

    wrapper.appendChild(select);
    wrapper.appendChild(holding);
    container.appendChild(wrapper);

    var $select = jQuery(select).select2({
      width: "220px",
      placeholder: "Actions (" + items.length + ")",
      minimumResultsForSearch: 6
    });

    $select.on("select2:select", function (event) {
      var index = event.params.data.id;
      var item = holding.querySelector('[data-prism-action-items-index="' + index + '"]');
      var trigger = item && item.querySelector("a, button, input[type=submit]");
      if (trigger) trigger.click();
      // Resets to the placeholder right away rather than showing the just-
      // picked label — this is a jump menu (fires an action), not a
      // persistent filter/setting, so there's nothing meaningful for it to
      // stay "set" to.
      $select.val("").trigger("change");
    });

    // Aligns the dropdown's right edge with the index table's own right
    // edge instead of #title_bar's (a table's columns don't necessarily
    // stretch to fill the full content width, so those two edges often
    // don't line up — and #title_bar itself spans wider than the table's
    // own container to begin with, since it sits above the #main_content/
    // #sidebar split rather than inside it). `transform: translateX`
    // shifts it left from wherever it already renders in normal flow —
    // deliberately not `position: absolute/fixed`, which would need a
    // containing block that actually shares the table's right edge, and
    // none of this element's ancestors do. Staying in normal flow (just
    // visually shifted) is also what keeps it aligned with the top of
    // #title_bar for free, reading as a top-level menu rather than
    // something floating at an offset.
    var table = document.querySelector("#main_content table");

    function alignToTable() {
      if (!table) return;
      wrapper.style.transform = "none";
      var wrapperRect = wrapper.getBoundingClientRect();
      var tableRect = table.getBoundingClientRect();
      if (!tableRect.width || !wrapperRect.width) return;

      var shift = wrapperRect.right - tableRect.right;
      wrapper.style.transform = shift > 0 ? "translateX(-" + shift + "px)" : "none";
    }

    // Run once immediately, but layout isn't necessarily final yet at
    // DOMContentLoaded — a scrollbar appearing/disappearing, webfonts, or
    // anything else nudging the table's own width afterward all happen
    // without the *window* itself ever resizing, so plain "resize"/"load"
    // listeners can miss them (observed in practice: the table shrank by
    // ~40px sometime after both had already fired). A ResizeObserver on
    // the table itself sidesteps guessing which event actually catches
    // it — it re-runs on any future width change, from any cause,
    // including ones years from now this comment didn't anticipate.
    alignToTable();

    if (typeof ResizeObserver !== "undefined") {
      new ResizeObserver(alignToTable).observe(table);
    } else {
      window.addEventListener("load", alignToTable);
      var resizeTimer = null;
      window.addEventListener("resize", function () {
        clearTimeout(resizeTimer);
        resizeTimer = setTimeout(alignToTable, 150);
      });
    }
  });
})();
