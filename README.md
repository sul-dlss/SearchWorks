![Build Status](https://github.com/sul-dlss/SearchWorks/workflows/CI/badge.svg) | 
[![Code Climate](https://codeclimate.com/github/sul-dlss/SearchWorks/badges/gpa.svg)](https://codeclimate.com/github/sul-dlss/SearchWorks) | 
[![Code Climate Test Coverage](https://codeclimate.com/github/sul-dlss/SearchWorks/badges/coverage.svg)](https://codeclimate.com/github/sul-dlss/SearchWorks/coverage)

# SearchWorks

The Stanford library searchable catalog.

## Local Installation

You'll need common dependencies for building rails applications such as a javascript runtime (e.g. v8).  If you don't want to have the mysql gem installed for local development you can run the bundle install command below with the `--without production deployment` flag

After cloning the repository

    $ bundle install
    $ yarn install
    $ rake searchworks:install

The installation script will

1. Migrate the database

You will need to update the configuration in `config/settings.yml` for various parts of the app to work.  Please check that file for more information.

### Start Solr

There are at least two options for starting Solr.

#### Docker compose

```shell
docker compose up
```

#### solr_wrapper 
To start Solr, you can use the `solr_wrapper` command. However, if starting from a fresh instance, you may first need to run `rake searchworks:install` or `rake ci` so that the CJK tokenizer gets copied into the appropriate directory.  There is also a separate task (`rake searchworks:copy_solr_dependencies`) available if you find that you need to clean solr and the CJK tokenizer is getting removed.

    $ solr_wrapper

### Start the rails app
Start the rails app

    $ bin/dev

## Getting data in development

Once you have Solr running you can load fixture data using `bin/rails searchworks:fixtures`
We have included fixture files in the `spec/fixtures/solr_documents` directory.

If you want to add other documents you can add the identifiers into `FixtureHarvester`. This will download more yml files to the fixture folder. Run `bin/rails searchworks:fixtures` again to reindex.  Please submit your changes and the new yaml files via a pull request. Please use this judiciously as adding many fixtures may add unnecessary complexity and size to the codebase.

## "Logging in" as a User in development

Given that this app is using shibboleth + devise for login, it can be tricky to get a user context set.  The user itself can be set by starting rails with a `REMOTE_USER` env var set (e.g. `REMOTE_USER=jstanford bin/dev`).

If you need to set your affiliation attribute (e.g. `stanford:staff`) for things like testing article search, you can start rails with a `suAffiliation` env var set (e.g. `REMOTE_USER=jstanford suAffiliation=stanford:staff bin/dev`).

One caveat to this is that you may still need to go through the login path `/sso/login` in order to ensure proper session setup (e.g. eds guest flag set).

## Testing

There is one testing task: `rake ci`

#### ci

This is intended for running tests against the fixtures in the local index.

    $ rake ci

## MCP Server (Model Context Protocol)

SearchWorks provides an MCP endpoint through the Rails application. Start the server with `bin/rails server`, then configure an HTTP-capable MCP client to use:

```
POST http://localhost:3000/mcp
Content-Type: application/json
```

To list the available tools:

```bash
curl -X POST http://localhost:3000/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": "1",
    "method": "tools/list"
  }'
```

To search the catalog:

```bash
curl -X POST http://localhost:3000/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": "2",
    "method": "tools/call",
    "params": {
      "name": "catalog_search_tool",
      "arguments": {
        "query": "machine learning",
        "rows": 5
      }
    }
  }'
```

The endpoint exposes five tools:

- `catalog_search_tool` searches the library catalog.
- `article_search_tool` searches scholarly articles when EDS is enabled.
- `get_catalog_record` retrieves detailed metadata for a catalog search result.
- `get_article` retrieves detailed metadata and an available abstract for an article search result.
- `get_availability` retrieves current item-level availability with physical library/location details, direct request links, and online source links.

### Using the endpoint with Claude Code

To use a local SearchWorks server with Claude Code, start Rails and add the endpoint:

```bash
bin/rails server
claude mcp add --transport http searchworks http://localhost:3000/mcp
```

Run `/mcp` in Claude Code to verify the connection.

### Using the endpoint with Claude Desktop

To use the endpoint with Claude or Claude Desktop, deploy SearchWorks at a public HTTPS URL, then:

1. Edit `~/Library/Application Support/Claude/claude_desktop_config.json`
2. Add the endpoint URL to the `claude_desktop_config.json` file:
   ```json
   {
     "mcpServers": {
       "searchworks-gryphon": {
         "command": "npx",
         "args": [
           "-y", "mcp-remote",
           "https://gryphon-search.stanford.edu/mcp",
           "--transport", "http-only"
         ]
       }
     },
     "preferences": { "...leave your existing preferences block as-is..." }
   }
   ```

We can't use "Connectors", yet, because on Team and Enterprise plans, an organization owner must add the connector under **Organization settings > Connectors** before members can enable it.

## Chat assistant

The home page can switch between the search form and an AI chat assistant ("Ask the assistant"). The
assistant runs the same tools as the MCP server, in-process, with a model served by a
[LiteLLM proxy](https://docs.litellm.ai/) through its OpenAI-compatible streaming
`POST /v1/chat/completions` endpoint. It is off unless `Settings.chat.enabled` is true (it is on in
development and test).

Configure:

- `LITELLM_API_BASE`: proxy API base URL, with or without `/v1`
- `LITELLM_API_KEY`: proxy master or virtual key
- `LITELLM_CHAT_MODEL`: the model alias; it must support OpenAI-compatible tool calling and streaming
- `LITELLM_CHAT_REASONING_EFFORT`: optional, defaults to `low`. Don't use `none` with Gemini on Vertex AI,
  which rejects the `THINKING_LEVEL_MINIMAL` that LiteLLM maps it to.

The system prompt and the conversation, tool, and output limits are under `config.x.chat` in
`config/initializers/chat.rb`; the MCP server instructions (`SearchworksMcp::INSTRUCTIONS`) are prepended
to the prompt. Sending a message requires login (see "Logging in" above). Article tools query EDS as a
guest unless the user is on campus or Stanford-affiliated, as the articles UI does. When
`THROTTLE_TRAFFIC` is on, `Settings.chat.throttle` limits turns per user.

Conversations are held in the browser's `sessionStorage` and are not stored by Rails. Each turn logs
`request.litellm`, `start.mcp_tool`, and `call.mcp_tool` events with the question's tool inputs and token
usage, correlated by request ID but without user identity.

### Chat quality evaluations

`bin/rails chat:evaluate` asks the questions in `lib/chat_evaluation/chat_evaluations.yml` in-process,
against the catalog, EDS, and FOLIO of the environment it runs in, and has an independent LiteLLM model
judge each answer against a reference answer and rubric. Cases can also require citations of returned
records, and require or forbid particular tools. Ordinary test runs make no network requests.

```sh
LITELLM_EVAL_MODEL=claude-sonnet-5 bin/rails chat:evaluate
```

Useful overrides: `CHAT_EVAL_CASE` (one case ID), `CHAT_EVAL_RUNS` (attempts per case, default 1),
`CHAT_EVAL_PASS_RATE` (default 1.0), `CHAT_EVAL_MIN_SCORE` (default 0.8), and `CHAT_EVAL_REPORT` (report
path; otherwise under `tmp/chat_evaluations`).
