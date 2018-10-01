# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Added an ISSN prefix to ISSN search link in linked serials [#1972](https://github.com/sul-dlss/SearchWorks/issues/1972)
- Added reCAPTCHA (I am not a robot checkbox) to record email dialog to re-enable anonymous users to send records to themselves [#1942](https://github.com/sul-dlss/SearchWorks/issues/1942)
### Changed
- Replaced OpenSeadragon StackMap image viewer with Leaflet (to improve general page performance) [#1981](https://github.com/sul-dlss/SearchWorks/issues/1981)
- Changed stylesheet loading to a preload mechanism for javascript based browsers (to improve general performance) [#1990](https://github.com/sul-dlss/SearchWorks/issues/1990)
- Optimized requests to index to build the home page (to improve home page load performance) [#2007](https://github.com/sul-dlss/SearchWorks/pull/2007)
- Now using reCAPTCHA to deter spam from anonymous feedback instead of custom spam capturing methods [#2009](https://github.com/sul-dlss/SearchWorks/pull/2009)
- Hides attribution "Leaflet" link in new stackmap display #2010
### Removed
- Removed display of MARC subfield $2 from display [#2001](https://github.com/sul-dlss/SearchWorks/issues/2001)
- Removed dispaly of MARC 776 fields [#2003](https://github.com/sul-dlss/SearchWorks/issues/2003)
### Fixed
- Fixed a bug in Article Search where the date slider facet would disappear for some Databases [#1721](https://github.com/sul-dlss/SearchWorks/issues/1721)
- Fixed a bug where the browse button in the side-nav minimap was rendering when there was no browse section [#1961] (https://github.com/sul-dlss/SearchWorks/issues/1961)
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

[Unreleased]: https://github.com/sul-dlss/SearchWorks/compare/v3.3.3...HEAD
[3.3.3]: https://github.com/sul-dlss/SearchWorks/compare/v3.3.2...v3.3.3
