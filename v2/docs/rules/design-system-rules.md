# Design System Rules

`docs/DESIGN_SYSTEM.md` documents the system. `<path-to-token-implementation>` implements it.

## Single source

1. Views use named color, spacing, typography, radius, shadow, and motion tokens.
2. Raw visual values require either a new token or a documented exception.
3. Existing components are reused before new variants are created.
4. A new component includes its interaction, empty, loading, error, disabled, focus, and accessibility states as relevant.
5. New interactive elements receive stable test identifiers in the same change.
6. Responsive behavior and supported accessibility sizes are part of the component contract.

## Verification

- Run the UI or snapshot suite.
- Search changed UI files for raw colors, spacing, and fonts.
- Compare the rendered result at required breakpoints and accessibility settings.
- Add each real visual drift class to the design reviewer checklist or a static check.
