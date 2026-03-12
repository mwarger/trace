# Spec Ledger

1. `rev-1`
   Rolling summary: event ingestion and normalization are central; reporting is
   downstream from normalized events.
2. `rev-2`
   Rolling summary: report surfaces depend on canonical event names and dedupe.
3. `rev-3`
   Rolling summary: module shape is stable, but retention still blocks some
   long-window design choices.
4. `rev-4`
   Rolling summary: canon is sufficient for conditional planning, with
   retention left as a tracked blocker.
