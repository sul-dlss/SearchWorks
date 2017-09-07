[![Build Status](https://travis-ci.org/sul-dlss/SearchWorks.svg?branch=master)](https://travis-ci.org/sul-dlss/SearchWorks) | [![Coverage Status](https://coveralls.io/repos/sul-dlss/SearchWorks/badge.png)](https://coveralls.io/r/sul-dlss/SearchWorks) |
[![Dependency Status](https://gemnasium.com/sul-dlss/SearchWorks.svg)](https://gemnasium.com/sul-dlss/SearchWorks)

# SearchWorks

This is the codebase for the SearchWorks redesign.

## Local Installation

You'll need common dependencies for building rails applications such as a javascript runtime (e.g. v8).  If you don't want to have the mysql gem installed for local development you can run the bundle install command below with the `--without production deployment` flag

After cloning the repository

    $ bundle install
    $ rake searchworks:install

The installation script will

1. Migrate the database
2. Download jetty to the rails root if does not already exist.
3. Unzip the downloaded jetty
4. Copy over local solr configuration and schema
5. Index the local development/test fixtures

You will need to update the configuration in `config/settings.yml` for various parts of the app to work.  Please check that file for more information.

Start jetty

    $ rake jetty:start

or

    $ cd jetty
    $ java -jar start.jar

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
