# Frontend & Design Study — Finobe, Tadah, Kapish

A study of the frontend and visual design of three defunct old-Roblox-revival (ORC)
communities, based on reading the actual source of six cloned repositories.

Scope is deliberately limited to **frontend, layout, styling, and design systems**.
Backend, game-server, and client-protocol concerns are out of scope.

---

## 0. Repositories studied

| Project | Repository | Branch | Last push | Stars | License |
|---|---|---|---|---|---|
| Finobe | `github.com/finobenet/finobenet` | `main` | 2025-10-02 | 19 | MIT (composer.json); no repo license file |
| Kapish | `github.com/conewasnthere/kapish-web-trunk` | `master` | 2025-01-02 | 3 | none |
| Tadah (legacy) | `github.com/Casenn05/tadah-site-classic` | `trunk` | 2023-01-18 | 3 | AGPL-3.0 |
| Tadah (rewrite) | `github.com/suush-ii/web` | `trunk` | 2022-10-22 | 6 | AGPL-3.0 |
| Tadah Eleven | `github.com/kineryy/tadah-eleven` | `main` | 2022-03-13 | 7 | GPL-3.0 |
| Tadah launcher | `github.com/Casenn05/Tadah-2014-Launcher-Decompiled-Source` | `main` | 2023-04-26 | 2 | none |

**Not reachable:** `gitlab.com/tadah/web-trunk` is listed by revival-list.com as the canonical
Kapish source, but GitLab's TLS handshake fails from this sandbox (`SSL_ERROR_SYSCALL`).
The GitHub mirror `conewasnthere/kapish-web-trunk` was used instead. **Unchecked** whether the
GitLab copy contains anything the mirror lacks.

### Kapish and Tadah are the same codebase

Verified, not inferred — from `composer.json`:

- `Casenn05/tadah-site-classic` → `"name": "tadah/tadah"`
- `conewasnthere/kapish-web-trunk` → `"name": "tadah/tadah"` *(package name never changed after the rebrand)*

Kapish's own README is titled **"Kapish Website (formerly Tadah)"**, and its footer links to
`discord.gg/kapish` alongside `gitlab.com/tadah`. The Tadah legacy README states the site
"started in August of 2021" and "is replaced with the Tadah rewrite on February of 2022…
archived in its original state on January 17th, 2023. The last modification to the original
repository was on June 12th, 2022."

So the real tree is:

```
Tadah (Aug 2021, Laravel 8)
├── Tadah Eleven  — Aug 2021 code + unfinished 2011-Roblox views
├── Kapish        — Tadah rebranded, kapish.fun
└── Tadah rewrite (Feb 2022, Laravel 9) — tadah.rocks, the "BALL stack"

Finobe / Aesthetiful — unrelated lineage, different stack
```

---

## 1. Stack comparison (frontend only)

| | Finobe | Kapish / Tadah legacy | Tadah rewrite |
|---|---|---|---|
| Framework | Laravel 12, PHP 8.2 | Laravel 8, PHP 7.3/8.0 | Laravel 9, PHP 8.1 |
| Templating | **Twig** (`rcrowe/twigbridge` ^0.14.5) | Blade | Blade **components** |
| CSS framework | Bootstrap 4 (precompiled) | Bootstrap 4 (SCSS) | Bootstrap 5 (selective SCSS) |
| Build | Vite + Tailwind v4 *(unused, see §2.1)* | Laravel Mix + SCSS | Laravel Mix + SCSS |
| JS | jQuery 3.3/3.6, Popper, Vue (original only) | jQuery 3.6, Livewire | Alpine, Livewire |
| Icons | Font Awesome 5.10 Pro (CDN) | Font Awesome 5.15.4 Pro (CDN) | Font Awesome 6.1.2 Pro (**self-hosted**) |
| Fonts | Source Sans Pro, proxima-nova (headings) | Source Sans Pro | Source Sans Pro, Cascadia Code, Twemoji Mozilla |
| View files | 115 (113 `.twig`) | 122 (121 `.php`) | 98 (all `.php`) |

Every one of them is **Laravel + Bootstrap + Source Sans Pro + Font Awesome**. That combination
is the Laravel UI preset, which means the shared ORC "look" is less a design decision than a
shared starting point that nobody ever really left.

---

## 2. Finobe — an archival artifact, not a source codebase

### 2.1 The Tailwind/Vite setup is a red herring

`composer.json` pins `laravel/framework: ^12.0` and `vite.config.js` registers `@tailwindcss/vite`.
But `resources/css/app.css` is **11 lines** — the stock Tailwind 4 stub:

```css
@import 'tailwindcss';
@theme {
    --font-sans: 'Instrument Sans', ui-sans-serif, system-ui, sans-serif, ...;
}
```

Nothing in the site uses it. The real stylesheets are precompiled static files in `public/s/css/`:

| File | Size |
|---|---|
| `light.css` | 1,419,710 bytes |
| `light copy.css` | 1,244,379 bytes |
| `night.css` | 99,985 bytes |
| `add.css` | 73,577 bytes |
| `bzr7dxi.css` | 21,540 bytes |
| `v1/app.css` | (v1 generation) |

### 2.2 Provenance: reconstructed from the Wayback Machine

The evidence, all measured from the clone:

| Check | Command result |
|---|---|
| `.vue` files in repo | **0** |
| Unique Vue scoped-CSS hashes (`data-v-XXXXXXXX`) in views | **27** |
| Vue template directives (`v-if`, `v-for`, `@click`, `:class`) in `v2/` | **0** |
| Views referencing `wombat` / `bundle-playback` / `web.archive.org` | **3** |
| Wayback timestamps in hardcoded script URLs | `web/20171119185443`, `web/20201202223618` |

Plus the Wayback replay chrome committed as site assets: `wombat.js`, `bundle-playback.js`,
`banner-styles.css`, `iconochive.css`.

**Conclusion:** the original Finobe v2 frontend was a **Vue SPA** (the 27 `data-v-` scoped-style
hashes are Vue SFC fingerprints). This repository is the *served HTML* captured from the Internet
Archive and re-wrapped in Laravel 12 + Twig. A hardcoded CSRF token survives in
`v1/Modules/head.twig`: `0ZIrKUk6NMuBUyxYyPJk9XNSojt3HlX6N3oc5zVc`.

**What this means practically:** you can lift Finobe's CSS, markup patterns, and information
architecture. You cannot learn anything about its component structure from this repo, because
that source is not here. The schema story is similar — 4 migrations plus a full dump
(`aesthetiful.sql`) rather than a real migration history.

### 2.3 Two complete design generations side by side

`resources/views/v1/` and `resources/views/v2/` are full parallel sites, each with its own
`Modules/{head,nav,footer}.twig` (v2 adds `css.twig`, 591 lines of inlined component styles).

Page sets:

- **v1** (17 root pages): `Landing`, `Welcome`, `Login`, `Create`, `Character`, `User`, `Users`,
  `User_friends`, `User_friends_incoming`, `Transactions`, `Bans`, `Rules`, `Terms`,
  `About-us`, `403`, `404`
- **v2** (23 root pages): v1's set **plus** `Register`, `Reset`, `Verify`, `Trades`, `Election`,
  `Moderation`

v1 was already deprecated when the archive was taken — `v1/Modules/nav.twig` renders a standing
banner:

> "Version 1 is currently broken following the release of the rewrite, it may be fixed in the
> future or deprecated. Only the absolute essentials work for you to switch back to Version 2."

**v1 landing** (`v1/Landing.twig`) is a plain, text-first hero:

```
h1  "We make old new again"
p   "Finobe's goal is to emulate an old brickbuilding game."
a.btn.btn-primary.btn-lg  "Get started ›"
```

followed by a four-up `col-lg-3` card row (Discord / YouTube / Twitter / Subreddit), each card
an `<a class="catalog-card">` wrapping a Bootstrap card with a 30×30 inline logo.

**v2 landing** (`v2/Welcome.twig`) is a single centred `col-md-9` card with a
`bg-primary text-white` header — the site's rules text is the landing content. A much more
closed-community posture than v1's marketing page.

### 2.4 Per-user theming and easter eggs

Finobe v2 has the most elaborate personalisation of the three, driven by `data.user.*`:

| Flag | Effect |
|---|---|
| `theme` | `0` → `light.css`, `1` → `night.css` |
| `branding` | `"finobe"` vs `"aesthetiful"` — swaps logo and site name |
| `logo` | `"v1"` → `BUSY.png`, `"v2"` → `finnobe3.png`, else `finnobe3logo.png` |
| month == 10 | Halloween navbar variant `navbar-light-halloween`, logo `halloween3.png` |
| month == 11/12 | Logo `finobe_xmas.png` **and** a CSS snowfall overlay |
| `gary` | Forces dark theme + a fixed full-viewport `me_irl_lol_23423.png` at `opacity: 0.05`, `z-index: 9999999` |
| `upsidedown` | `body { transform: rotate(180deg); transform-origin: center; }` |

The snowfall is 12 hardcoded `<div class="snowflake">❅/❆</div>` elements animated by
`snowflakes-fall` / `snowflakes-shake` keyframes, gated server-side on
`"now"|date("m") == "11" or "12"`.

Theme classes also appear in selectors: `.Aesthetiful-light` / `.Aesthetiful-dark` scope link
colours (`#212529` vs `#ececec`).

### 2.5 Typography and palette

From `v2/Modules/head.twig`:

```css
h1..h6:not(.forum-header) { font-family: "proxima-nova", "Source Sans Pro", "Helvetica Neue",
  Roboto, "Chiron Sans HK WS", "Microsoft JhengHei", "PingFang HK", "MingLiU", Arial, sans-serif; }
*, html, body, button, input, textarea, select { font-family: "Source Sans Pro", "Helvetica Neue",
  Roboto, "Chiron Sans HK WS", ... , Arial, sans-serif; }
```

A two-tier type stack with real CJK fallbacks — unusual thoroughness for a revival.

Most frequent colours in `night.css` (by occurrence count):

```
32 × #6c757d   29 × #ececec   28 × #e53e3e   25 × #3182ce   23 × #3d5784
22 × #11b0ff   17 × #313437   17 × #212529   13 × #e9ecef   11 × #38a169
10 × #854a8f    9 × #cd9701    8 × #ced4da    7 × #495057    6 × #dee2e6
```

`#e53e3e` / `#3182ce` / `#38a169` / `#805ad5`-family is the **Chakra UI** palette; `#6c757d`,
`#212529`, `#ced4da`, `#dee2e6`, `#f8f9fa` are **Bootstrap 4** grays. So Finobe's palette is
Chakra semantics layered on a Bootstrap 4 skeleton.

### 2.6 Navigation (v2)

`Home | Profile | Games | Catalog | Forum | Users | Blog | More▾ (Wiki, Videos) | Admin`

Right cluster: inbox with `badge badge-danger badge-notification` count, a notifications
dropdown with "Mark all as read", currency pill (icon `/s/img/v1/owo_16.png`, currency called
**Dius**) with a live JS countdown to the next daily reward, and a user dropdown
(Add Server / Character / Settings / Logout).

The countdown is inline jQuery in the nav partial, recomputed with `setInterval(..., 1000)` and
written back by mutating `.tooltip-inner` text and the `data-original-title` attribute.

---

## 3. Kapish / Tadah legacy — Bootstrap 4, done competently

### 3.1 Design tokens (`resources/sass/_variables.scss`)

```scss
$body-bg: #f8fafc;
$font-family-sans-serif: 'Source Sans Pro', sans-serif;
$font-size-base: 0.9rem;      // deliberately tighter than Bootstrap's 1rem
$line-height-base: 1.6;

$blue:   #5e60e7;  $indigo: #6574cd;  $purple: #9561e2;  $pink: #f66d9b;
$red:    #ec3c3c;  $orange: #f6993f;  $yellow: #f8bd1c;  $teal: #4dc0b5;
$green:  rgb(32, 212, 107);  $cyan: #6cb2eb;

$alert-bg-level: -2;  $alert-border-level: -3;  $alert-color-level: -10;
```

This is the **Laravel Nova preset** palette, not Bootstrap's defaults — that's where the whole
ORC look comes from.

Brand surfaces from `_extra.scss`:

```scss
.navbar        { background-color: rgb(71, 73, 189) !important; }  // #4749bd indigo
.navbar-second { background-color: rgb(38, 39, 65) !important; }
.footer-dark   { background-color: rgb(38, 39, 65); }
.headshot-bg   { background-color: rgb(195, 195, 195); }
.text-booster  { color: #ff73fa !important; }
```

### 3.2 The two-tier navbar is the signature layout

`layouts/app.blade.php` renders two stacked navbars:

**Tier 1** (`navbar navbar-expand-md navbar-dark bg-white shadow-sm`) — logo + site name, then
left nav `Home · Servers · Catalog · Users · Forums`, each with a Font Awesome icon and an
active state derived from `Request::segment(1)`. Right side: admin link with a live
`Item::where('approved', 0)->count()` badge, the **dahllor** currency pill with reward countdown,
and the user dropdown (Profile / Character / Admin / Settings / Logout).

**Tier 2** (`navbar-scroller navbar-second bg-dark py-0 shadow-sm`) — contextual sub-nav:
`Profile · Character · Friends (badge) · Account · Invites`. Only rendered `@guest @else`.

This two-bar structure is a direct descendant of 2010s Roblox's own chrome, and it's the single
most recognisable thing about the genre.

### 3.3 Layout branching

One template handles both chrome'd pages and full-bleed pages via `@isset($landing)` —
when set, `<main>`, both navbars, the footer and the ad slots are all skipped and only
`@yield('content')` renders. Functional but coarse: the branch wraps a large fraction of the file.

### 3.4 Theming — and why it fails

The mechanism is clean:

```blade
@if ($theme != 'default')
    <link href="{{ asset('css/app_'.$theme.'.css?v='.rand(1,1000)) }}" rel="stylesheet">
@endif
```

with `$theme` read from a forever-cookie, validated against `config('app.themes')`:

```php
'themes' => ['default', 'dark'],
```

`UsersController.php:244` sets it:
`->withCookie(cookie()->forever('theme', $theme))->with('message', 'Theme changed successfully.'); // frfr`

**But `public/css/app_dark.css` (2,684 lines) is a Dark Reader export.** The file's own header:

```
/*! Dark reader generated CSS | Licensed under MIT https://github.com/darkreader/darkreader ... */
html { background-color: #191b1c !important; }
html { color-scheme: dark !important; }
a    { color: #3491fe; }
```

So the dark mode is an automatic colour inversion of the light theme, committed as a build
artifact. It's the clearest anti-pattern across all three projects — and note the
`?v=<?= rand(1,1000) ?>` cache-buster, which means it is re-fetched on every page load.

### 3.5 Notable patterns

**Old-Roblox text outline** — the four-direction `text-shadow` trick, still the standard way to
get that look:

```scss
.motto {
    color: white;
    text-shadow: -1px -1px 0 #000, 1px -1px 0 #000, -1px 1px 0 #000, 1px 1px 0 #000;
}
```

**Fullscreen background video on the landing page:**

```scss
.landing-page video {
    position: fixed; z-index: -1; top: 0; width: 100%;
    object-fit: cover; min-height: 100%; min-width: 100%;
}
```

**Lazy thumbnails via data attributes** — a global JS object plus declarative hooks, which is a
nicely portable pattern:

```blade
<script>
  tadah = { baseUrl: "{{ config('app.url') }}" };
  @if (Auth::check()) tadah.session = { userId: {{ Auth::user()->id }} }; @endif
</script>

<img src="{{ Thumbnail::static_image('blank.png') }}"
     data-tadah-thumbnail-id="{{ Auth::user()->id }}"
     data-tadah-thumbnail-type="user-headshot"
     class="rounded-circle mr-1 shadow-sm" width="25">
```

**Floating tabs** — a segmented-control look built by overriding Bootstrap's nav borders:

```scss
.floating-tab-page       { background: $white; border: 1px solid #dee2e6; border-radius: .25rem; padding: 1rem; }
.floating-tab-page.start { border-radius: 0 .25rem .25rem .25rem; }
.floating-tab.active     { border-color: #dee2e6 #dee2e6 $white; }
.floating-nav-tabs       { border-bottom: 0; }
```

**Ops dashboard** — colour-coded status bars per subsystem, including a diagonal-striped
"in progress" variant:

```scss
.progress-indicator-tadah    { color: #5154ee }   // blue
.progress-indicator-laravel  { color: #f05340 }
.progress-indicator-database { color: #6cb2eb }   // cyan
.progress-indicator-cdn      { color: #23c767 }   // green
.progress-indicator-renders  { color: #4dc0b5 }   // teal
.progress-3d_renders { background-image: linear-gradient(45deg, rgba(255,255,255,.15) 25%, transparent 25%, ...); }
```

**Monetisation** — two 728×90 AdSense leaderboards injected directly into the content column
(publisher `ca-pub-3972374207754919`, slot `1122913432`), one above and one below `<main>`.

**Footer** — a five-item horizontal link list (Terms / Rules / Privacy / Credits / Statistics),
a logo at `opacity: .3`, social icons at `opacity: .25` fading to `1` on hover, and a
"Built with ♥ and Laravel" line. Footer links use `text-light fw-light h5` — Bootstrap 5
utility classes on a Bootstrap 4 build, i.e. dead classes.

---

## 4. Tadah rewrite — the only real design system of the three

Self-described **"BALL stack": Bootstrap, Alpine, Livewire, Laravel.**

### 4.1 Selective Bootstrap imports

`app.scss` does not import Bootstrap wholesale. It pulls `functions`, then a custom
`tadah/bootstrap` override layer, then ~35 individually chosen partials
(`root, reboot, type, images, containers, grid, tables, forms, buttons, transitions, dropdown,
button-group, nav, navbar, card, accordion, breadcrumb, pagination, badge, alert, progress,
list-group, close, toasts, modal, tooltip, popover, carousel, spinners, offcanvas,
placeholders, helpers, utilities/api`).

Overrides are minimal and confident — four lines:

```scss
// tadah/_bootstrap.scss
$body-bg: #fcfcfc;
$blue: #455dd8;
$green: #38c172;
$cyan: #3dbbff;
$enable-negative-margins: true;
```

### 4.2 Typography done properly

Three fonts, each with a job, and two of them bundled locally:

```scss
@import url("https://fonts.googleapis.com/css?family=Source+Sans+Pro");
@import url("https://cdn.jsdelivr.net/npm/@xz/fonts@1/serve/cascadia-code.min.css");

@font-face {
    font-family: "Twemoji Mozilla";
    src: url("/fonts/TwemojiMozilla.ttf") format("truetype");
    font-display: block; font-weight: 400;
}

$font-family-sans-serif: "Source Sans Pro", sans-serif, "Twemoji Mozilla";
```

Twemoji-as-a-font means emoji render identically on every platform — a real decision, since
usernames and forum posts on these sites are emoji-heavy. Font Awesome 6 Pro is also compiled
and vendored (`resources/css/fa6-pro.min.css`) with a warning comment:
`// NOTE: This is a compiled asset. Don't change it!` — no third-party CDN dependency, unlike
the other two.

### 4.3 Semantic colour names

Instead of `text-primary`, custom named utilities:

```scss
.text-horizon  { color: #405263 !important; }
.border-horizon{ border-color: #405263 !important; }
.text-telescope{ color: #4040c8 !important; }
.border-telescope { border-color: #4040c8 !important; }
```

Naming colours after objects rather than roles is arguably worse than tokens — but it is at
least *naming*, which neither of the other two does.

### 4.4 Layout as a Blade component with a `$fluff` switch

The cleanest structural idea in the whole study. `layouts/app.blade.php` is only 58 lines and is
backed by `app/View/Components/AppLayout.php`:

```blade
<body class="d-flex flex-column h-100">
    @if ($fluff) @include('partials.navigation') @endif
    @if ($fluff)
        <main class="flex-shrink-0 py-3"><div class="container">
            {{ pre-rendered empty alert containers }}
            {{ $slot }}
        </div></main>
    @else
        {{ $slot }}
    @endif
    @if ($fluff) @include('partials.footer') @endif
</body>
```

Named slots `$slot`, `$title`, `$head`, `$scripts`, plus a single boolean `$fluff` that toggles
all page chrome. Compare Kapish's `@isset($landing)`, which had to wrap ~90% of a 200-line
template in an `@else`. Same problem, far better solution.

Alerts are pre-rendered **empty** and filled by JS:

```blade
<div class="alert alert-success mb-4 shadow-sm d-none fade show alert-dismissible" id="container-success">
    <span></span>
    <button class="btn-close" data-bs-dismiss="alert"></button>
</div>
```

Global JS context is a single JSON injection: `window.tadah = @json($context)`.

### 4.5 Navigation

`partials/navigation.blade.php` — single dark `navbar navbar-expand-lg navbar-dark bg-primary`,
items `Home · Games · Catalog · People · Develop · Forum`, with:

- `@class(['nav-link', 'active' => active_link('catalog')])` — an `active_link()` helper instead
  of inline `Request::segment()` comparisons
- `Home` uses `active_link('dashboard', 2)` — a depth argument so sub-pages of the dashboard
  still highlight the parent
- A **Livewire search bar** as a first-class navbar citizen
  (`<livewire:layout.search-bar />`), responsive: `col-lg-4 col-xl-4 col-sm-8 col-md-4`
- `data-bs-toggle` (Bootstrap 5) throughout

### 4.6 Ops/admin UI craft

`_extra.scss` is 720 hand-written lines. The admin tooling gets genuine attention:

```scss
.arbiter-output {                    // terminal-style log console
    display: flex; flex-direction: column;
    background-color: #0c0c0c; color: #ccc;
    border-radius: .3rem; padding: .7rem;
    height: 300px; overflow: scroll;
    font-size: .85rem;
    font-family: 'Cascadia Code', var(--bs-font-monospace);
}
.arbiter-blur      { filter: blur(5px); transition: .2s; }
.arbiter-blur:hover{ filter: blur(0); }        // hide sensitive log output until hovered
.blinking::after   { content: ""; display: inline-block; background: #f2f2f2;
                     width: 1px; height: 21.4px; animation: blink 1s step-end infinite; }

.blurred-loading-wrapper { position: relative; display: none; }
.blurred-loading         { position: absolute; z-index: 1; width: 100%; }
```

`.arbiter-blur` — blur-to-hide, hover-to-reveal — is a genuinely thoughtful micro-interaction
for an admin surface, and the blinking caret gives the log console a real terminal feel.

The currency icon is a CSS **mask**, so it inherits the surrounding text colour instead of
needing a separate asset per theme:

```scss
.dahllor-icon { mask: url("/img/logo/dahllor.svg") no-repeat 50% 50%;
                display: inline-block; mask-size: cover; }
```

That one line is the difference between Kapish's two hardcoded PNGs and something themeable.

Also present: `vanillajs-datepicker` imported as Bootstrap 5 SCSS, `phpstan.neon` for static
analysis, `partials/language-dropdown.blade.php` for i18n.

---

## 5. Shared design language of the genre

What all three converge on, and where it comes from:

1. **Laravel + Bootstrap + Source Sans Pro + Font Awesome.** The Laravel UI preset, essentially
   unmodified. The "ORC look" is mostly an inherited default.
2. **Two-tier navigation.** Brand/utility bar over a contextual sub-nav. Direct inheritance from
   2010s Roblox itself, and the strongest visual signal of the genre.
3. **Card + thumbnail grid** for catalog, games, and user lists; headshots lazy-loaded through
   `data-*` attributes with a placeholder `blank.png`.
4. **A custom virtual currency** with an icon in the navbar and a daily-reward countdown:
   Finobe's **Dius** (`owo_16.png`), Tadah/Kapish's **dahllor**.
5. **Seasonal and joke theming** as a community feature — snowfall, Halloween logos, `gary`,
   `upsidedown`, `.text-booster { color: #ff73fa }`. These sites treated visual easter eggs as
   a retention mechanic.
6. **Ads in the content column.** 728×90 leaderboards inline above and below `<main>`.
7. **Forum + catalog + users + profile** as the four content pillars, plus admin tooling that
   grew real UI (moderation queues, ops consoles, item-approval badges in the navbar).
8. **Dark mode bolted on, always badly.** Kapish shipped a Dark Reader dump; Finobe maintains a
   separate 100 KB `night.css` plus a 1.4 MB `light.css` with a stray `light copy.css`.

---

## 6. Frontend-craft ranking

| | Score | Why |
|---|---|---|
| **Tadah rewrite** | Best | Blade component layouts with slots, `$fluff` chrome toggle, selective Bootstrap 5 imports, 4-line token override, locally bundled fonts + icons, `active_link()` helper, Livewire search bar, thoughtful admin micro-interactions, CSS-mask currency icon |
| **Kapish / Tadah legacy** | Middle | Coherent SCSS token file, good two-tier nav, portable lazy-thumbnail pattern — undercut by a Dark Reader dark mode, `!important` overrides, `rand()` cache-busting, and BS5 classes on a BS4 build |
| **Finobe** | Worst *as code* | Not a source codebase (§2.2). 591 lines of `<style>` pasted into a Twig partial, 1.4 MB stylesheets, dead Vite/Tailwind config, inline jQuery in layout partials |

But Finobe is the most valuable **as a design reference**: it preserves two full generations of
a real production design, with the seasonal theming, the easter eggs, and the complete page
inventory intact. For *visual* study it beats the other two; for *engineering* study it's last.

---

## 7. What's worth stealing

If you're building something in this style:

**Take from the Tadah rewrite**
- Blade component layout with named slots + a single `$fluff` boolean for chrome vs. full-bleed
- `@class([...])` + an `active_link($name, $depth)` helper for nav active states
- Selective Bootstrap partial imports; keep the override file to a handful of tokens
- CSS `mask` for icons that need to inherit `currentColor`
- Bundle your fonts and icon font; don't depend on a Pro CDN kit
- Blur-to-reveal for sensitive admin output

**Take from Kapish**
- The two-tier navbar — it's the genre's signature and it genuinely works for this IA
- `data-*`-driven lazy thumbnails with a placeholder asset
- `.motto` four-direction `text-shadow` for the old-Roblox outlined text
- The fullscreen `position: fixed; z-index: -1` landing video

**Take from Finobe**
- The per-user theming surface area (theme + branding + logo variant) as a real feature
- Seasonal asset swapping driven server-side off the month
- The two-tier type stack with CJK fallbacks

**Avoid**
- Auto-inverted dark modes — design the dark palette or don't ship one
- `?v=<?= rand() ?>` cache-busting
- Committing a second copy of a 1.2 MB stylesheet (`light copy.css`)
- `<style>` blocks in layout partials
- A build toolchain in the manifest that the site doesn't use

---

## 8. Reproducing this study

Clones were shallow (`--depth 1`) into `/tmp/orc/`:

```bash
for r in finobenet/finobenet conewasnthere/kapish-web-trunk kineryy/tadah-eleven \
         suush-ii/web Casenn05/tadah-site-classic \
         Casenn05/Tadah-2014-Launcher-Decompiled-Source; do
  git clone --depth 1 https://github.com/$r "$(basename $r)" &
done; wait
```

Disk usage after cloning: finobenet 57M, tadah-eleven 58M, web 49M,
kapish-web-trunk 33M, tadah-site-classic 19M, launcher 1.2M.

### Open items / not verified

- `gitlab.com/tadah/web-trunk` — inaccessible from this environment (TLS handshake failure).
  The canonical Kapish source per revival-list.com. Unknown whether it differs from the
  GitHub mirror.
- Whether the original Finobe Vue SPA source exists anywhere public — not searched.
- Finobe's `resources/views/v1/Modules/head.twig` embeds a large minified Bootstrap CSS blob
  inline; I sampled it but did not diff it against a known Bootstrap 4 build.
- The 1,724 SVGs in `finobenet` were counted but not individually inspected.

### Legal note

These are community revival projects for a proprietary game. `tadah-site-classic`, `suush-ii/web`
and `kineryy/tadah-eleven` carry AGPL-3.0 / GPL-3.0 licenses; `finobenet/finobenet` declares MIT
in `composer.json` but ships no `LICENSE` file, and its assets are archived captures of a live
site. `conewasnthere/kapish-web-trunk` has no license at all, which legally means
all-rights-reserved regardless of the README's tone. Treat this document as design research,
and check licensing and trademark exposure before reusing any code or asset.
