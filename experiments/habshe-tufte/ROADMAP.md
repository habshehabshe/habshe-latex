# `habshe-tufte` Experiment — ROADMAP

Development home: experiments/habshe-tufte/. This file records scope,
decisions, and conventions. Rule: a change lands together with the
ROADMAP entries it affects.

## Status
- v0.7 — horizontal layout works; vertical spacing is WIP. Audited 2026-10-24.
- v0.8 — IN PROGRESS: restructure + option/anchor fixes (scope below).
- v0.8 class work COMPLETE & VERIFIED (2026-10-24): first exit-0
clean build; zero errors; matrix dump verified vs hand computation
(anchor, measures, partition identity all exact). Remaining: the
acceptance specimen (B4) — the only unchecked v0.8 box.

## v0.8 — "Structure & semantics"
- [ ] Full restructure into the §N section map with per-section
Purpose/Owns/Depends/Affects conventions and a file index.
- [ ] B1 unknown-option passthrough via \DeclareUnknownKeyHandler.
- [ ] B2 fontsize key: accepts "9" and "9pt" (pt only), parsing-layer idiom.
- [ ] Rename key `paper` -> `papersize`.
- [ ] B3 scale anchored at \regular (k=2), offset -0.35: fontsize now
names the body size exactly. Ladder shifts ~0.4-0.9pt; optical
re-tuning deferred to v0.9.
- [ ] B5 single-source note size (\habshe@margin@note@size) consumed by
both the width formula and \@marginparreset. DECISION PENDING:
median (Tiny) vs worst-case (TINY) sizing.
- [ ] S4 warn on standard size options (10pt/11pt/12pt).
- [ ] S5 conventions: all arithmetic via \fpeval; glue via \habshe@glue
builder; parsing layer separated from calculation layer.
- [ ] S3 rules: every derived dimension gets a load-time guard;
computed matrix echoed to the log (\ClassInfo) at end of load.
- [ ] D4(1) heading state fix: marginpar suppressed in heading titles.
- [ ] Comment invariants: no-negative-afterskip constraint on
\habshe@heading@format; CM / 0.5-char-factor calibration note.
- [ ] New acceptance specimen main.tex (exercises every public API).

## v0.9 — "Vertical space"
- Leading formula (D2): proportional, non-static slope; wire or delete
lead@damper. Retune scale optics post-B3.
- List spacing completion (S1): \@listiii / \@listiv, full audit.
- Skip interplay (D3): heading afterskip vs topic topsep stacking;
addvspace audit at every vertical joint.
- Margin/heading collision (D4): specimen reproductions from v0.8;
design band-allocation instead of manual offsets. This is the seed
of the future sidenote system.
- Top/bottom bands (D6): unusable band + usable band model, like the
margin; headheight/headsep/footskip get real content.

## v0.9 reproduction data (collected from fossil runs)
- "Marginpar on page 7 moved": crowded-note migration observed in
tufte stream near heading — first live sighting of D4 territory.
- Overfull in nested list with long \texttt strings: notes S1 compounding.

## v0.10+ — "Features"
- Headers & footers. Title page (HUGE tier is reserved for this).
- TOC package (separate .sty; custom look — not the class's job).
- Sidenote system: numbered notes, figures/tables in margin, the
margin-queue machinery deferred from v0.9.
- Layout-aware figure/table environments.

## Open questions
- Font stack: CM + fix-cm today (scalable metrics, load-bearing for the
16-tier scale). Candidates: lmodern (drop-in, no fix-cm), fontspec
under LuaLaTeX (the long-term direction; forces an NFSS review).
ANY switch recalibrates the 0.5 char-width factor (CM metrics).
- tocdepth: provisional default; revisit with the TOC package.
- Margin note size: Tiny (median) vs TINY (worst-case) — see v0.8 B5.

## Decision log
- 2026-10-24  B1/B2/B3 accepted; anchor at \regular; fontsize = body size.
- 2026-10-24  fpeval-everywhere convention adopted (calculation layer);
parsing layer stays delimiter-macro; glue via builder.
- 2026-10-24  D1 damper sign RETAINED: constant -1/d slope flattens below
anchor, lift steepens above — matches design premise.
- 2026-10-24  D4: no Tufte-style manual offsets; band allocation later.
- 2026-10-24  REVISED (supersedes same-day anchor-at-SMALL entry):
fontsize = SEED of the scale, anchored at \regular (a=2, o=-0.35):
S(2) = F exactly. The option names the canonical unit, not any
rendered size. Placement follows reserved-range conventions
(ambient body = SMALL ≈ 0.93F), independent of the anchor.
\normalsize stays decoupled from \regular (ambient = SMALL).
- 2026-10-24  REGRESSION FOUND & FIXED (v0.8, mine): "pt" placed INSIDE
\fpeval braces in \habshe@calc@size / \habshe@calc@leading. l3fp
parses trailing "pt" as the constant 1 (juxtaposition), so the unit
silently vanished; TeX's "pt inserted" recovery masked it (32 hard
errors, correct values, exit 1). Rule recorded in §2 Notes: \fpeval
emits bare decimals; units are appended AFTER the closing brace.
- 2026-10-24  Matrix dump VERIFIED against hand computation; §4
partition identity holds (body+gutter+margin = fullwidth, exact).
B2 verified closed in-log. B1 forwarding path verified in-log.
Ladder comment corrected: SMALL = 8.07pt (my 7.92 dropped the lift
term at k=1).
- 2026-10-24  D5 UPDATE: font list in log shows LM-by-alias (modern
TeX Live maps cm -> lm). fix-cm + 0.5 char factor remain valid.
- 2026-10-24  Final-run triage: all remaining log items are
fossil-caused or working-as-designed. No class action items.
Fossil class line updated: paper -> papersize.


## Conventions (normative)
- All arithmetic through \fpeval; glue only via \habshe@glue.
- Section structure per §N map; registers declared where owned;
no forward references between sections.
- No derived quantity without a load-time guard; matrix logged at load.
- Promotion per POLICY.md (shadow rule, git mv).
- Delivery discipline: every class change is followed by a build
BEFORE moving on; errors-recovered-by-TeX never count as passing.
Gate = clean grep for illegal unit/undefined + exit code 0.

