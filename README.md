[![Build Status](https://travis-ci.org/sul-dlss/SearchWorks.svg?branch=master)](https://travis-ci.org/sul-dlss/SearchWorks) |
[![Code Climate](https://codeclimate.com/github/sul-dlss/SearchWorks/badges/gpa.svg)](https://codeclimate.com/github/sul-dlss/SearchWorks)
[![Code Climate Test Coverage](https://codeclimate.com/github/sul-dlss/SearchWorks/badges/coverage.svg)](https://codeclimate.com/github/sul-dlss/SearchWorks/coverage)

# SearchWorks

This is the codebase for the SearchWorks redesign.

## Local Installation

You'll need common dependencies for building rails applications such as a javascript runtime (e.g. v8).  If you don't want to have the mysql gem installed for local development you can run the bundle install command below with the `--without production deployment` flag

After cloning the repository

    $ bundle install
    $ rake searchworks:install

The installation script will

1. Migrate the database

You will need to update the configuration in `config/settings.yml` for various parts of the app to work.  Please check that file for more information.

Start Solr

To start Solr, you can use the `solr_wrapper` command. However, if starting from a fresh instance, you may first need to run `rake searchworks:install` or `rake ci` so that the CJK tokenizer gets copied into the appropriate directory.  There is also a separate task (`rake searchworks:copy_solr_dependencies`) available if you find that you need to clean solr and the CJK tokenizer is getting removed.

    $ solr_wrapper

Start the rails app

    $ rails s

## "Logging in" as a User in development

Given that this app is using shibboleth + devise for login, it can be tricky to get a user context set.  The user itself can be set by starting rails with a `REMOTE_USER` env var set (e.g. `REMOTE_USER=jstanford rails s`).

If you need to set your affiliation attribute (e.g. `stanford:staff`) for things like testing article search, you can start rails with a `suAffiliation` env var set (e.g. `REMOTE_USER=jstanford suAffiliation=stanford:staff rails s`).

One caveat to this is that you may still need to go through the login path `/webauth/login` in order to ensure proper session setup (e.g. eds guest flag set).

## Testing

There are two testing tasks: `rake ci` and `rake jenkins`

#### ci

This is intended for running tests against the fixtures in the local index.

    $ rake ci

#### jenkins

This is intended for running production data integration tests against the remote index.

    $ TEST_SOLR_URL=http://example-solr.stanford.edu:8983/solr rake jenkins
