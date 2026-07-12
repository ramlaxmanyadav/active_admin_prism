// Prism sidebar behaviour: collapsible nav groups + mobile off-canvas
// toggle. Vanilla JS, no dependency on jQuery/Stimulus/a bundler — this file
// is registered as-is via ActiveAdmin.application.register_javascript and
// served through the host's existing asset pipeline.
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

// Flash messages: dismiss button + auto-hide. See
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

  document.addEventListener("DOMContentLoaded", function () {
    var flashesWrapper = document.querySelector(".flashes");
    var flashes = document.querySelectorAll(".flashes .flash");
    if (!flashes.length) return;

    var transitionMs = (flashesWrapper && parseInt(flashesWrapper.dataset.prismTransitionMs, 10)) || DEFAULT_TRANSITION_MS;
    var autoDismissMs = flashesWrapper && parseInt(flashesWrapper.dataset.prismAutoDismissMs, 10);

    if (autoDismissMs) {
      flashes.forEach(function (flash) {
        setTimeout(function () {
          dismiss(flash, transitionMs);
        }, autoDismissMs);
      });
    }

    document.addEventListener("click", function (event) {
      var button = event.target.closest("[data-prism-flash-dismiss]");
      if (!button) return;
      dismiss(button.closest(".flash"), transitionMs);
    });
  });
})();

// "Filters" sidebar panel: collapses to a single icon button, expanding to
// the full form on click. See scss-src/_panels.scss (#filters_sidebar_section)
// for the actual collapse/expand styling — this only toggles the ".open"
// class an inline click responds to. Skipped entirely when
// ActiveAdminPrism.configuration.collapsible_filters is false (the
// "prism-filters-collapsible-disabled" body class, set in
// lib/active_admin/views/flash_messages.rb#body_classes).
(function () {
  "use strict";

  document.addEventListener("DOMContentLoaded", function () {
    if (document.body.classList.contains("prism-filters-collapsible-disabled")) return;

    var section = document.getElementById("filters_sidebar_section");
    if (!section) return;

    var toggle = section.querySelector(":scope > h3");
    if (!toggle) return;

    toggle.setAttribute("role", "button");
    toggle.setAttribute("tabindex", "0");
    toggle.setAttribute("aria-expanded", section.classList.contains("open") ? "true" : "false");
    // Mirrored onto <body> because #main_content (the table/grid area)
    // is a *sibling* of #sidebar, not a descendant of this section — CSS
    // can't reach across siblings, so scss-src/_panels.scss keys the
    // #main_content/#sidebar width reflow off this body class instead.
    document.body.classList.toggle("prism-filters-open", section.classList.contains("open"));

    function toggleOpen() {
      var open = section.classList.toggle("open");
      toggle.setAttribute("aria-expanded", open ? "true" : "false");
      document.body.classList.toggle("prism-filters-open", open);
    }

    toggle.addEventListener("click", toggleOpen);
    toggle.addEventListener("keydown", function (event) {
      if (event.key !== "Enter" && event.key !== " ") return;
      event.preventDefault();
      toggleOpen();
    });
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
