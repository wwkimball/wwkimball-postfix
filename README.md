# postfix

[![Build Status](https://travis-ci.org/wwkimball/wwkimball-postfix.svg?branch=master)](https://travis-ci.org/wwkimball/wwkimball-postfix) [![Version](https://img.shields.io/puppetforge/v/wwkimball/postfix.svg)](https://forge.puppet.com/wwkimball/postfix) [![Codacy Badge](https://api.codacy.com/project/badge/Grade/3bfb5fb2b84042cf972b468eb1418b80)](https://www.codacy.com/app/wwkimball/wwkimball-postfix?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=wwkimball/wwkimball-postfix&amp;utm_campaign=Badge_Grade) [![Documentation Coverage](https://inch-ci.org/github/wwkimball/wwkimball-postfix.svg?branch=master)](https://inch-ci.org/github/wwkimball/wwkimball-postfix) [![Coverage Status](https://coveralls.io/repos/github/wwkimball/wwkimball-postfix/badge.svg?branch=master)](https://coveralls.io/github/wwkimball/wwkimball-postfix?branch=master)

### Foreword

The original author of this module has long promoted a line of thinking that
builds off of **Infrastructure As Code** into **Infrastructure As Data**.  With
Hiera and modules like this, end-users can simply import the code they need and
then fully express their entire enterprise infrastructure purely as data without
any more code to write or support (not even antiquated roles/profiles).  As
such, all examples in this document and the module's in-file documentation are
presented strictly as YAML.

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with postfix](#setup)
    * [What postfix affects](#what-postfix-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with postfix](#beginning-with-postfix)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

This module was written from scratch, specifically for Puppet 5 and Hiera 5 to fully manage postfix; nothing more and nothing less.  No assumptions are made as to what you intend to do with postfix other than enjoy full control over it via Hiera in every respect.

Here, "fully manage" means this Puppet module:

* Installs, upgrades, downgrades, version-pins, and uninstalls postfix.
* Controls every line in every postfix configuration file, both vendor- and user-supplied.
* Optionally controls the postfix service.

This is one of a generation of Puppet modules that fully extends control over the subject resources to Hiera.  Use modules like this where you'd rather express your infrastructure as data without any further Puppet code.

## Setup

### What postfix affects

This module specifically affects the following resources:

* The primary postfix package, or whatever it is named for your platform.
* Every line of every file in the postfix configuration directory.
* The postfix service -- by any name -- if you so choose.

### Setup Requirements

Please refer to the *dependencies* section of [metadata.json](metadata.json) to learn what other modules this one needs, if any.

### Beginning with postfix

At its simplest, you can install postfix in its vendor-supplied default state merely with:

```
---
classes:
  - postfix
```

## Usage

Many usage examples are provided via the source code documentation.  Refer to the [Reference](#reference) section to learn how to access it.

## Reference

Pre-generated, web-accessible reference documentation -- with abundant **examples** -- can be found at [GitHub Pages for this project](https://wwkimball.github.io/wwkimball-postfix/puppet_classes/postfix.html), generated via [Puppet Strings](https://github.com/puppetlabs/puppet-strings).  If you do not have access to this on-line documentation, please just run `bundle install && bundle exec rake strings:generate` from this module's top directory to have a local copy of the documentation generated for you in the [docs](docs/index.html) directory.

## Limitations

Please refer to the *operatingsystem_support* section of [metadata.json](metadata.json) for known, proven-in-production OS compatibility.  This is not an exhaustive list.  You will very likely find that this module runs just fine on other operating system and version combinations, given the proper inputs.  In fact, if you do, please report it back so the metadata can be updated!

## Development

Please refer to [CONTRIBUTING](CONTRIBUTING.md) to learn how to hack this module.
