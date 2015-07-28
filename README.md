# Documentation Theme for Jekyll

This Jekyll theme is specifically designed to render markdown documentation. It combines the essential features that may come in handy when building documentation for tech projects as it supports:

* separate documentation versions for different project releases; 
* integrated search;
* multilanguage documentation;
* multilevel navigation sidebar. 

######This theme was built using:

* Twitter Bootstrap;
* lunr.js search library;
* Integration between Jekyll and lunr.js, written by Ben Smith (@slashdotdash).

## Installation

#### Prerequisites

To install this Jekyll theme successfully, the following software components shall be preinstalled:

* [bundler](http://bundler.io/)
* [bower](http://bundler.io/)

#### Installation

Two methods of installation are available:

* fork this repository;
* download archive from GitHub.

To download all required assets, issue the following command:

```bash
    bower install
```

To start Jekyll instance use this command:

```bash
    bundle exec rake
```

This way you start Jekyll server with ```--watch``` parameter.

## Usage

Two ways to use this theme are available:

### Manual

You can copy you documentation as a number of Jekyll pages with the following folder structure for multiple languages and versions: 

```
jekyll-root
|- en
| |- latest
| |- 1.0
| |- 1.1
| |- 1.2
|- fr
| |- 1.0
| |- 1.1
```

These folders are rendered in the same way. Jekyll generates a separate search index for each language and version.
```index.html``` file in the root folder always redirects a user to the en/latest version.

As a result, the site can be pushed to any hosting, for example [Github pages](https://pages.github.com/).

### Automatic

This theme contains rake tasks aimed at building the documentation site automatically from the repository specified in the configuration.
This method is used to analyze branches and create the structure automatically. 
Branches should have the following naming: ```master, 1.1, 1.1-fr, 2.0-es```. If a language is not specified in the branch name, English is used by default.

```bash
bundle exec rake buildfinal
```

## Configuration

You can use the configuration provided by [Jekyll](http://jekyllrb.com/docs/configuration/) and [lunr.js integration](https://github.com/slashdotdash/jekyll-lunr-js-search).

In addition, this theme has the following configuration: 

```yaml
documentation:
  repository: <repository>
  alias:
    master: latest
  ignore: ["gh-pages"]
```
**Parameters**

Name  | Description
:------------- | :-------------
repository  | Is presented as a URL to the repository where the actual documentation is hosted.
alias  | The list of branches and their aliases. Currently one alias can be assigned to one branch.
ignore | The list of branches that shall be ignored.


## Todo

- update 404 page
- generate index files
- generate root index file to custom version