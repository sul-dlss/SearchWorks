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

SearchWorks includes MCP (Model Context Protocol) support that allows AI assistants and other MCP-compatible tools to search the Stanford library catalog and article databases. Two interfaces are available:

1. **stdio MCP Server** - For AI assistants and MCP clients
2. **HTTP MCP API** - For web applications and custom integrations

### stdio MCP Server

#### Quick Test
```bash
./bin/test-mcp-server
```

#### Usage with AI Assistants

The stdio MCP server can be integrated with:
- Claude Desktop
- Cursor IDE
- Continue.dev
- Zed
- And other MCP-compatible clients

Add the server to your client configuration:

```json
{
  "mcpServers": {
    "searchworks": {
      "command": "/full/path/to/SearchWorks/bin/mcp-server",
      "args": [],
      "env": {
        "RAILS_ENV": "development"
      }
    }
  }
}
```

### HTTP MCP API

The HTTP MCP API provides the same functionality via JSON-RPC over HTTP, making it accessible to web applications and environments where stdio MCP clients aren't available.

#### Quick Test
```bash
# Start Rails server
rails server

# Run HTTP API tests
./bin/test-mcp-http
```

#### Connecting MCP Clients to HTTP Server

For MCP clients that support HTTP transport, configure them to connect to:

```
POST http://localhost:3000/mcp
Content-Type: application/json
```

**Example client configurations:**

```json
{
  "mcpServers": {
    "searchworks-http": {
      "transport": "http",
      "url": "http://localhost:3000/mcp",
      "headers": {
        "Content-Type": "application/json"
      }
    }
  }
}
```

**Manual JSON-RPC requests:**

```bash
# List available tools
curl -X POST http://localhost:3000/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": "1",
    "method": "tools/list"
  }'

# Search the catalog
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

### Available Tools

1. **catalog_search_tool** - Search books, journals, media, and other library materials
   - Supports dynamic facet filtering (format, language, access, etc.)
   - Returns comprehensive metadata and refinement suggestions

2. **article_search_tool** - Search scholarly articles and publications (requires EDS)
   - Access to millions of scholarly articles
   - Includes abstracts, authors, and full-text links

### Documentation

- **Quick Start**: See [QUICKSTART_MCP.md](QUICKSTART_MCP.md) for setup guide
- **HTTP API**: See [MCP_HTTP_API.md](MCP_HTTP_API.md) for complete HTTP API documentation
