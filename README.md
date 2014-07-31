[![Build Status](https://travis-ci.org/sul-dlss/SearchWorks.svg?branch=master)](https://travis-ci.org/sul-dlss/SearchWorks) | [![Coverage Status](https://coveralls.io/repos/sul-dlss/SearchWorks/badge.png)](https://coveralls.io/r/sul-dlss/SearchWorks) |
[![Dependency Status](https://gemnasium.com/sul-dlss/SearchWorks.svg)](https://gemnasium.com/sul-dlss/SearchWorks)

# SearchWorks

This is the codebase for the SearchWorks redesign.

## Local Installation

After cloning the repository

    $ bundle install
    $ rake searchworks:install

The installation script will

1. Migrate the database
2. Download jetty to the rails root if does not already exist.
3. Unzip the downloaded jetty
4. Index the local development/test fixtures
5. Create a local development development config file `config/settings.yml`

You will need to update the configuration in `config/settings.yml` to the correct URL for the following:
 - `HOURS_API`
 - `EMAIL_TO`

Start jetty

    $ rake jetty:start

or

    $ cd jetty
    $ java -jar start.jar

Start the rails app

    $ rails s

## Testing

There are two testing tasks: `rake ci` and `rake jenkins`

#### ci

This is intended for running tests against the fixtures in the local index.

    $ rake ci

#### jenkins

This is intended for running production data integration tests agains the remote index.

    $ TEST_SOLR_URL=http://example-solr.stanford.edu:8983/solr rake jenkins
