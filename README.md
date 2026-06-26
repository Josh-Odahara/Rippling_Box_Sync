# Rippling_box_sync

An Elixir CLI tool that syncs employee HR documents from Rippling (HRIS) into organized Box folders, then sorts I-9-related documents into a separate folder for compliance review.

Built as a portfolio project to practice OTP-adjacent design patterns (mock adapters, behavior-style contracts, error routing) ahead of a transition into a junior Elixir developer role.

## What it does

Phase 1 — Sync (mix sync)
Reads an employee CSV export, fetches each employee's documents from Rippling (mocked), and uploads them into per-employee folders in Box (mocked as local filesystem storage). Employees whose record is missing required data are routed to a _retry folder with a logged reason, instead of stopping the whole batch.

Phase 2 — Sort (mix sort, in progress)
Scans already-synced documents and identifies I-9-related files — including unlabeled supporting documents (e.g. a driver's license scan with a generic filename like IMG_5545.jpg) — using keyword matching against filename and document content, then moves matches into a dedicated I-9 review folder.

## Why mocked APIs

This project was inspired by an internal tool idea that used real Rippling and Box API access. Since this version doesn't have access to either, both integrations are mocked behind the same function contracts a real integration would use (fetch_employee_docs/1, create_employee_folder/1, upload_file/2, etc.) — Box is simulated as local folders under box_storage/, and Rippling is simulated with realistic mock data. Swapping in real API calls later would mean rewriting the inside of these functions, not anything that calls them.

## Usage

mix deps.get
mix sync

This parses employees.csv, syncs every employee's mock documents into box_storage/, and routes any employee with missing required fields into box_storage/_retry/ along with a text file explaining why.

## How matching works (Phase 2)

Scanner.score_doc/1 downcases a document's filename and content, then counts how many entries from Keywords.i9_keywords/0 appear as substrings in each, returning a combined score. A higher score indicates stronger I-9 relevance. The keyword list lives in its own module so it can be edited or swapped without touching the scanning logic.

## Known limitations

- Keyword matching is exact-substring after downcasing — it does not handle typos, abbreviations, or synonyms. A misspelled keyword (or a misspelled document) will silently fail to match with no error.
- Document content is mock plain text, not real file contents. There is no PDF parsing yet — a real implementation would need a PDF text-extraction library to scan actual uploaded documents.
- The "always fails" condition in fetch_employee_docs/1 (missing first/last name) is the only simulated failure case. A real Rippling integration could fail in other ways (network errors, employee not found, API rate limits) that aren't modeled here.
box_storage/ is a local filesystem stand-in for Box. No real Box API integration exists yet.


## Future improvements

- Real Box API integration, replacing the local filesystem mock.
- Real Rippling API integration, replacing the mocked document data.
- PDF text extraction for scanning real document content instead of mock strings.
- Have Scanner.score_doc/1 return which keywords matched (not just the count), to make scoring decisions explainable rather than just a number.
- Per-employee retry folders that preserve any documents that succeeded before a failure, rather than just logging the reason.
- Configurable/toggleable failure simulation for testing, rather than relying on real data conditions.
- mix sort (Phase 2 orchestration) — not yet built.
