# Rippling_box_sync

An Elixir CLI tool that syncs employee HR documents from Rippling (HRIS) into organized Box folders, then sorts I-9-related documents into a separate folder for compliance review.

Built as a portfolio project to practice OTP-adjacent design patterns (mock adapters, behavior-style contracts, error routing) ahead of a transition into a junior Elixir developer role.

## What it does

Phase 1 — Sync (mix sync)
Reads an employee CSV export, fetches each employee's documents from Rippling (mocked), and uploads them into per-employee folders in Box (mocked as local filesystem storage). Employees whose record is missing required data are routed to a _retry folder with a logged reason, instead of stopping the whole batch.

Phase 2 — Sort (mix sort)
Scans each employee's already-synced documents directly off disk and identifies I-9-related files — including unlabeled supporting documents (e.g. a driver's license scan with a generic filename like IMG_5545.jpg) — by scoring filename and content against a configurable keyword list. Matches are moved into box_storage/I9_files/<employee>/, leaving non-matching documents in place. Employees with no synced folder (e.g. a failed sync) are logged and skipped rather than crashing the batch.

## Why mocked APIs

This project was inspired by an internal tool idea that used real Rippling and Box API access. Since this version doesn't have access to either, both integrations are mocked behind the same function contracts a real integration would use (fetch_employee_docs/1, create_employee_folder/1, upload_file/2, etc.) — Box is simulated as local folders under box_storage/, and Rippling is simulated with realistic mock data. Swapping in real API calls later would mean rewriting the inside of these functions, not anything that calls them.

## Project structure

rippling_box_sync/
├── employees.csv              # sample employee data (associate_id, first_name, last_name, department)
├── lib/
│   ├── employee.ex            # %Employee{} struct — fixed internal contract for employee data
│   ├── csv_parser.ex          # parses employees.csv into %Employee{} structs
│   ├── rippling.ex            # mocked Rippling API — fetch_employee_docs/1
│   ├── box.ex                 # mocked Box API — folder creation, file upload, retry folder
│   ├── phase_one/
│   │   └── sync.ex            # orchestrates fetch → folder → upload, with retry routing
│   ├── phase_two/
│   │   ├── keywords.ex        # configurable I-9 keyword list
│   │   ├── scanner.ex         # scores a document's I-9 relevance, returns a yes/no decision
│   │   └── sort.ex            # reads synced files off disk, moves I-9 matches to a review folder
│   └── mix/
│       └── tasks/
│           ├── sync.ex        # `mix sync` — runs Phase 1
│           └── sort.ex        # `mix sort` — runs Phase 2
└── box_storage/                # local stand-in for Box (created at runtime)
    ├── _retry/                 # employees whose sync failed land here
    └── I9_files/                # I-9-related documents land here, organized per employee

## Usage

mix deps.get
mix sync
mix sort

- mix sync parses employees.csv and syncs every employee's mock documents into box_storage/, routing anyone with missing required fields into box_storage/_retry/ along with a text file explaining why.

- mix sort then scans every employee's synced folder, identifies I-9-related documents, and moves them into box_storage/I9_files/<employee>/. Employees with no synced folder are logged and skipped.

## How matching works (Phase 2)

Scanner.score_doc/1 downcases a document's filename and content, then counts how many entries from Keywords.i9_keywords/0 appear as substrings in each, returning a combined score. Scanner.i9_related?/1 calls score_doc/1 and applies a threshold (score ≥ 3) to return a yes/no decision. The keyword list lives in its own module so it can be edited or swapped without touching the scanning logic.

Sort.sort_employee/1 reads each file directly off disk (via File.ls/1 and File.read/1), reconstructs just enough of a document shape (filename, content) to check with Scanner.i9_related?/1, and moves matches with File.rename!/2.

## Known limitations

- Keyword matching is exact-substring after downcasing — it does not handle typos, abbreviations, or synonyms. A misspelled keyword (or a misspelled document) will silently fail to match with no error. (This bit us once already during development — a typo in the keyword list silently dropped a match until it was traced down.)
- The score ≥ 3 threshold in Scanner.i9_related?/1 is a placeholder based on mock data, not real-world calibration. It should be revisited once real document content (e.g. via PDF parsing) is available to test against.
- Document content is mock plain text, not real file contents. There is no PDF parsing yet — a real implementation would need a PDF text-extraction library to scan actual uploaded documents.
- The "missing first or last name" condition in fetch_employee_docs/1 is the only simulated sync failure case. A real Rippling integration could fail in other ways (network errors, employee not found, API rate limits) that aren't modeled here.
- Sort.sort_employee/1 has no retry-folder mechanism of its own — a missing employee folder is logged and skipped, not routed anywhere for follow-up the way Phase 1 failures are.
- box_storage/ is a local filesystem stand-in for Box. No real Box API integration exists yet.


## Future improvements

- Real Box API integration, replacing the local filesystem mock.
- Real Rippling API integration, replacing the mocked document data.
- PDF text extraction for scanning real document content instead of mock strings, and re-calibrating the match threshold against real data.
- Have Scanner.score_doc/1 return which keywords matched (not just the count), to make scoring decisions explainable rather than just a number.
- Per-employee retry folders that preserve any documents that succeeded before a failure, rather than just logging the reason (Phase 1), and a similar mechanism for Phase 2 sort failures.
- Configurable/toggleable failure simulation for testing, rather than relying on real data conditions.
