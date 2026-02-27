# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

**Run all offline tests** (no API credentials needed):
```bash
ruby test/test.rb
```

**Run a single test file:**
```bash
ruby test/printjob_test.rb
```

**Run integration tests** (require a live PrintNode API key set in the test files):
```bash
bash test.sh
```

**Build the gem:**
```bash
gem build printnode.gemspec
```

## Architecture

This is a thin Ruby wrapper around the [PrintNode REST API](https://www.printnode.com/docs/api/curl/).

**Entry point:** `lib/printnode.rb` — requires all submodules.

**`PrintNode::Client`** (`lib/printnode/client.rb`) is the core class. All API calls go through it. HTTP methods (`get`, `post`, `patch`, `delete`) are thin public wrappers around the private `execute_request` method, which builds the `Net::HTTP` request, sets auth/headers/body, and calls `instrument` before dispatching via `start_response`. Responses are parsed from JSON into `PrintNode::Response` trees.

**`PrintNode::Response`** (`lib/printnode/response.rb`) — a lightweight value object that wraps API response hashes. Provides dot-notation access (`response.email`, `response.printer.name`). Raises `NoMethodError` for fields not present in the response. `Response.wrap(value)` is the recursive entry point used for array responses — it maps over arrays and wraps nested hashes automatically.

**`PrintNode::Auth`** (`lib/printnode/auth.rb`) — holds credentials. Accepts either an API key (single arg) or email+password (two args). Returns `[key, '']` or `[email, password]` for use with `basic_auth`.

**`PrintNode::APIError`** (`lib/printnode/api_exception.rb`) — raised by `http_error_handler` on any non-2xx response. The HTTP status code is in `error.object`; the response body is `error.message`.

**`PrintNode::Account`** / **`PrintNode::PrintJob`** — simple value objects with `to_hash` for JSON serialisation.

## Instrumentation

`Client#instrument` wraps every HTTP call with `ActiveSupport::Notifications` if it is defined (e.g. in a Rails app). It is a no-op otherwise — ActiveSupport is not a gem dependency. The notification name is `"<event>.printnode"` (e.g. `"get.printnode"`).

## Tests

- `test/printjob_test.rb` — fully offline, tests `PrintNode::PrintJob` serialisation. Safe to run anywhere.
- `test/accounts_test.rb`, `accounts_info_test.rb`, `computers_test.rb` — integration tests that hit the live API. They call `/test/data/generate` in `setup` and clean up in `teardown`.
- `test.sh` runs the integration tests sequentially with `sleep 1` delays between them to avoid rate-limiting.
