# Recorded verification

These are results from the development SAP system, not tests automatically rerun by GitHub.

## Policy and access tests — 15 October 2026

- 12 policy and 12 authorization unit tests passed.
- Live regular-user create/save checks succeeded.
- Validate, Approve, and Reject were denied for unauthorized review.
- Reviewer self-review remained denied after reviewer membership was granted.
- UI checks covered claim list/detail, fixed header, logo navigation, approved-claim edit lock, disabled review actions, mobile layout, and logout-link navigation.
- Deployed frontend files matched the version 1.1.2 build.

Logout navigation was tested; actual identity-provider session termination was not verified.

## Demo data refresh — 20 October 2026

- Eight old project claims were backed up before replacement.
- Twelve explicitly fictional claims were inserted in the development system.
- Live RAP validation returned six READY and six FLAGGED results, with zero failed action executions.
- Approve and Reject returned the expected states through the real RAP handlers.
- Those test review decisions were rolled back.
- Final database verification showed twelve claims, all NEW.
- The temporary reset routine was replaced by a read-only listing class.

Synthetic owners are fixtures, not real users. This verification proves reviewer handlers can operate on another owner’s fixtures; it does not prove a second real SAP account was successfully provisioned.

## Known limits

- Sources are snapshots rather than an automatic abapGit installation.
- Target systems require their own provisioning, service publication, and IAM configuration.
- Duplicate detection is heuristic, not a database uniqueness guarantee.
- Policy limits are examples and support INR only.
- No ATC run or complete separate-account claimant/reviewer browser session was recorded.
- No production identity onboarding, payment processing, receipt upload/OCR, or AI inference is implemented.
