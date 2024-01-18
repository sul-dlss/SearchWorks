# README

## Developer environment

1. To  test agaist a local instance of searchworks,  point your `settings.local.yml` to the local instance of SearchWorks.
2. Install Gemfile `$ bundle install`
3. Install required node modules (requires [node](https://nodejs.org/en/download) be installed) `npm install`.
2. Run `bin/dev`
3. Now, you can visit http://localhost:3000/ for the Bento app


## Example of running a search from the Rails console

```
client = HTTP.timeout(30)
article_search = QuickSearch::ArticleSearcher.new(client, "covid").search
# could also be CatalogSearcher or ExhibitsSearcher
article_search.total # total number of search results
article_search.results.size # total number of results actually returned for display, configurable with NUM_RESULTS_SHOWN in settings.yml
article_search.results[0].title # title of the search
article_search.results[0].link # link to the results
```

Some of the code in this repository was extracted from [NCSU/quick_search](https://github.com/NCSU-Libraries/quick_search).
```
Copyright 2016 North Carolina State University

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```
