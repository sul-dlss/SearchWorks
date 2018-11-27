# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
### Changed
### Removed
### Fixed
### Security

## [3.3.12] - 2018-11-27
### Added
### Changed
- Improves search performance by pushing additional work into the indexer [#2043](https://github.com/sul-dlss/SearchWorks/pull/2043)
### Removed
### Fixed
### Security
- Dependency updates to address vulnerabilities in upstream gems [#2215](https://github.com/sul-dlss/SearchWorks/pull/2215)

## [3.3.11] - 2018-11-21

### Added
### Changed
- Redesign record view for SDR items [#2126](https://github.com/sul-dlss/SearchWorks/pull/2126)
### Removed
### Fixed
- Fixes link styling for multiple PURL embed side-panel so that they doesn't always appear active [#2203](https://github.com/sul-dlss/SearchWorks/pull/2203)
- Fixes online label styling for brief view search results [#2206](https://github.com/sul-dlss/SearchWorks/pull/2206)
### Security

## [3.3.10] - 2018-11-20

### Added
- Added the ability to add Articles+ records to selection lists [#2094](https://github.com/sul-dlss/SearchWorks/pull/2094)
- Added various click tracking to help us refine features
### Changed
- Update to non-deprecated Google Analytics tracking [#2158](https://github.com/sul-dlss/SearchWorks/pull/2158)
- Changed how we handle metadata parsing of MODS data in search results to improve performance [#2042](https://github.com/sul-dlss/SearchWorks/pull/2042)
- Changes the "Request" link text to "Request on-site Access" for certain locations [#2166](https://github.com/sul-dlss/SearchWorks/pull/2166)
- Changes content and layout of the SDR and Digital collections access point mastheads [#2170](https://github.com/sul-dlss/SearchWorks/pull/2170)
- Updated various styling around the application [#2172](https://github.com/sul-dlss/SearchWorks/pull/2172) [#2174](https://github.com/sul-dlss/SearchWorks/pull/2174) [#2180](https://github.com/sul-dlss/SearchWorks/pull/2180)
- Adds in "Last search" to user feedback form [#2187](https://github.com/sul-dlss/SearchWorks/pull/2187)
### Removed
- Removed the Google Book link from the Available Online panel when we have and SFX link [#2185](https://github.com/sul-dlss/SearchWorks/pull/2185)
### Fixed
- Fixed issue with SEE-OTHER location having no availability information in search results [#2182](https://github.com/sul-dlss/SearchWorks/pull/2182)
### Security

## [3.3.9] - 2018-11-12

### Added
### Changed
 - Updates various dependencies [#2153](https://github.com/sul-dlss/SearchWorks/pull/2153)
### Removed
### Fixed
 - Fixes an issue where the "Full Text" label was cut off [#2155](https://github.com/sul-dlss/SearchWorks/pull/2155)
 - Fixes an issue where the "Online" label in gallery view was sometimes overlapping with the preview button [#2154](https://github.com/sul-dlss/SearchWorks/pull/2154)
 - Partially fixes an issue where some links and modals did not properly work [#2156](https://github.com/sul-dlss/SearchWorks/pull/2156)
### Security

## [3.3.8] - 2018-11-09

### Added
- Adds the ability to track outbound links for usage analysis [#2135](https://github.com/sul-dlss/SearchWorks/pull/2135)
### Changed
- Now returning a 404 Not Found error when an article record is not found [#2133](https://github.com/sul-dlss/SearchWorks/pull/2133)
- Updates the way that Hoover Archive records are requested and shown in the access panel [#2123](https://github.com/sul-dlss/SearchWorks/pull/2123)
### Removed
### Fixed
- Updated the EBSCO gem to 1.0.5 to address issues around records throwing errors when trying to sanitize HTML [#1704](https://github.com/sul-dlss/SearchWorks/issues/1704)
- Fixed a visual display issue that was cause a dot to display beneath the Stanford Only S icon in some cases [#2113](https://github.com/sul-dlss/SearchWorks/pull/2113)
### Security

## [3.3.7] - 2018-11-06

### Added
- Importing Article record into RefWorks [#2073](https://github.com/sul-dlss/SearchWorks/pulls/2073)
- Adds IIIF drag n drop badge to items with IIIF manifest URL [#2097](https://github.com/sul-dlss/SearchWorks/pulls/2097)
- Adds a more useful error message when selections/bookmarks have failed [#2103](https://github.com/sul-dlss/SearchWorks/pulls/2103)
### Changed
- Updated results metadata styling and formatting for both MODS and MARC records [#2053](https://github.com/sul-dlss/SearchWorks/issue/2053)
- Updated 404 and 500 pages to link to status page [#2079](https://github.com/sul-dlss/SearchWorks/pulls/2079) [#2078](https://github.com/sul-dlss/SearchWorks/pulls/2078)
- Update matching algorithm for sidebar finding aid link (supports Hoover OAC new url pattern)[#2069](https://github.com/sul-dlss/SearchWorks/issues/2069)
- Updates mods display and display additional titles [#1996](https://github.com/sul-dlss/SearchWorks/pulls/1996)
### Removed
### Fixed
- Fixed a bug where HTML was being rendered in the multiple managed purl sidebar [#2081](https://github.com/sul-dlss/SearchWorks/issues/2081)
- Clears EDS cache on deploy [#2075](https://github.com/sul-dlss/SearchWorks/pulls/2075)
### Security
- Loofah security update, other dependency updates [#2093](https://github.com/sul-dlss/SearchWorks/pulls/2093) [#2098](https://github.com/sul-dlss/SearchWorks/pulls/2098)

## [3.3.6] - 2018-10-24

### Added
- Adds an OKComputer status check for degraded performance alerts from NewRelic (for the status dashboard) [#2051](https://github.com/sul-dlss/SearchWorks/pull/2051)
- Adds citations to the "Cite" modal for article records [#1727](https://github.com/sul-dlss/SearchWorks/pull/1727)
- Adds the display of vernacular subjects to the record view [#1971](https://github.com/sul-dlss/SearchWorks/pull/1971)
### Changed
- Updated to [ModsDisplay 0.5.1](https://github.com/sul-dlss/mods_display/releases/tag/v0.5.1) [#2062](https://github.com/sul-dlss/SearchWorks/pull/2062)
  - Most notable changes are labeling authors by their roles and splitting out host/constituent related items into separate section that renders full MODS representation
- Updated Schema.org type mappings around Theses, Video Games, and Equipment [#2047](https://github.com/sul-dlss/SearchWorks/pull/2047)
- Changed labels and sort for digital serials when a relevant label or sort key is present [#2037](https://github.com/sul-dlss/SearchWorks/issues/2037)
### Removed
### Fixed
- Updates Blacklight to v6.16.0 which fixes part of select button issues #1370. [#2063](https://github.com/sul-dlss/SearchWorks/pull/2063)
- Fixes an accessibility issue with expanding/collapsing sort widgets and facets [#2067](https://github.com/sul-dlss/SearchWorks/pull/2067)
- Fixes a bug in exporting diacritics to RefWorks [#1944](https://github.com/sul-dlss/SearchWorks/issues/1944)
### Security

## [3.3.5] - 2018-10-12

### Added
- Adds links to the SearchWorks status dashboard [#2027](https://github.com/sul-dlss/SearchWorks/pull/2027) [#2032](https://github.com/sul-dlss/SearchWorks/pull/2032) [#2046](https://github.com/sul-dlss/SearchWorks/pull/2046)
- Adds basic Schema.org JSON-LD markup [#2030](https://github.com/sul-dlss/SearchWorks/pull/2030).
### Changed
- Changed the way that bound with items are displayed. Bound with call numbers are removed from search results. On a show page, the notes are formatted in a more pleasant way while the live lookup data information is removed. [#1345](https://github.com/sul-dlss/SearchWorks/pull/1345)
- Changes the "zero results" page in the following ways: change copy of headings, simplifies formatting of list elements, adds mini-bento search results for alternate search backends, adds more options for search results, moves the chat link and adds live hours. [#2014](https://github.com/sul-dlss/SearchWorks/pull/2014)
- Changes the way SDR objects in search results are looked up. Now this happens in the background not blocking the page load which speeds up search results significantly. [#2031](https://github.com/sul-dlss/SearchWorks/pull/2031)
- Updates the EDS gem used for article search [#1951](https://github.com/sul-dlss/SearchWorks/pull/1951)
### Removed
- Removed Ruby 2.3 build as production was upgraded to Ruby 2.5.1 [#2045](https://github.com/sul-dlss/SearchWorks/pull/2045)
- Removed links to Google Book on search results for SDR objects with managed purls [#2049](https://github.com/sul-dlss/SearchWorks/pull/2049)
### Fixed
- Reverts stylesheet preloading as it was causing an issue in FireFox. [#2019](https://github.com/sul-dlss/SearchWorks/pull/2019)
- Fixes an issue where mhld records were overflowing onto other parts of the page [#2034](https://github.com/sul-dlss/SearchWorks/pull/2034)

## [3.3.4] - 2018-10-01

### Added
- Added an ISSN prefix to ISSN search link in linked serials [#1972](https://github.com/sul-dlss/SearchWorks/issues/1972)
- Added reCAPTCHA (I am not a robot checkbox) to record email dialog to re-enable anonymous users to send records to themselves [#1942](https://github.com/sul-dlss/SearchWorks/issues/1942)
### Changed
- Replaced OpenSeadragon StackMap image viewer with Leaflet (to improve general page performance) [#1981](https://github.com/sul-dlss/SearchWorks/issues/1981)
- Changed stylesheet loading to a preload mechanism for javascript based browsers (to improve general performance) [#1990](https://github.com/sul-dlss/SearchWorks/issues/1990)
- Optimized requests to index to build the home page (to improve home page load performance) [#2007](https://github.com/sul-dlss/SearchWorks/pull/2007)
- Now using reCAPTCHA to deter spam from anonymous feedback instead of custom spam capturing methods [#2009](https://github.com/sul-dlss/SearchWorks/pull/2009)
- Hides attribution "Leaflet" link in new stackmap display [#2010](https://github.com/sul-dlss/SearchWorks/issues/2010)
### Removed
- Removed display of MARC subfield $2 from display [#2001](https://github.com/sul-dlss/SearchWorks/issues/2001)
- Removed dispaly of MARC 776 fields [#2003](https://github.com/sul-dlss/SearchWorks/issues/2003)
### Fixed
- Fixed a bug in Article Search where the date slider facet would disappear for some Databases [#1721](https://github.com/sul-dlss/SearchWorks/issues/1721)
- Fixed a bug where the browse button in the side-nav minimap was rendering when there was no browse section [#1961](https://github.com/sul-dlss/SearchWorks/issues/1961)
### Security

## [3.3.3] - 2018-09-26
### Added
- Added a new Stanford Student Work facet [#1937](https://github.com/sul-dlss/SearchWorks/issues/1937)
- Added the Curriculum Collection value to the Location facet for Education [#1635](https://github.com/sul-dlss/SearchWorks/issues/1635)
- Added data from the SFX API (similar to Articles) to the Online column for catalog records [#1882](https://github.com/sul-dlss/SearchWorks/issues/1882)
- This CHANGELOG!
### Changed
- Changed Hoover Library hours API and website configurations for the combining of the Archives and Library [#1948](https://github.com/sul-dlss/SearchWorks/pull/1948)
- Changed various `-LOAN` location translations [#1879](https://github.com/sul-dlss/SearchWorks/issues/1879)
- Changed bookplates masthead text [#1878](https://github.com/sul-dlss/SearchWorks/issues/1878)
- Changed thesis and dissertation masthead text [#1937](https://github.com/sul-dlss/SearchWorks/issues/1937)
- Changed databases masthead text and styling [#1658](https://github.com/sul-dlss/SearchWorks/issues/1658)
- Use a Font Loader to help improve client side performance [#1980](https://github.com/sul-dlss/SearchWorks/pull/1980)
### Removed
- Removed MARC subfield $1 from display [#1582](https://github.com/sul-dlss/SearchWorks/issues/1582)
- Removed "Author" from list of fields we claim to export in brief emails (as we do not include that data) [#1943](https://github.com/sul-dlss/SearchWorks/issues/1943)
### Fixed
### Security

[Unreleased]: https://github.com/sul-dlss/SearchWorks/compare/v3.3.12...HEAD
[3.3.12]: https://github.com/sul-dlss/SearchWorks/compare/v3.3.11...v3.3.12
[3.3.11]: https://github.com/sul-dlss/SearchWorks/compare/v3.3.10...v3.3.11
[3.3.10]: https://github.com/sul-dlss/SearchWorks/compare/v3.3.9...v3.3.10
[3.3.9]: https://github.com/sul-dlss/SearchWorks/compare/v3.3.8...v3.3.9
[3.3.8]: https://github.com/sul-dlss/SearchWorks/compare/v3.3.7...v3.3.8
[3.3.7]: https://github.com/sul-dlss/SearchWorks/compare/v3.3.6...v3.3.7
[3.3.6]: https://github.com/sul-dlss/SearchWorks/compare/v3.3.5...v3.3.6
[3.3.5]: https://github.com/sul-dlss/SearchWorks/compare/v3.3.4...v3.3.5
[3.3.4]: https://github.com/sul-dlss/SearchWorks/compare/v3.3.3...v3.3.4
[3.3.3]: https://github.com/sul-dlss/SearchWorks/compare/v3.3.2...v3.3.3
