# Deployment Truth

## Surfaces

| Surface | Owner | Build | Deploy | Live verification | Rollback |
|---|---|---|---|---|---|
| <surface> | <human or role> | `<command>` | `<command>` | `<command or procedure>` | `<procedure>` |

## Approval

Production deployment, money, destructive operations, permissions, legal text, and price changes require explicit human approval recorded in the change record.

A successful deployment command is not proof that the changed behavior is live.

Build and review stages do not receive production credentials. Deployment authority is short-lived where the platform supports it and is granted only after the Regression Certificate and required human decision exist.
