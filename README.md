# postfix

### Foreword

The author of this module has long promoted a line of thinking that builds off of **Infrastructure As Code** into **Infrastructure As Data**.  With Hiera and modules like this, you can express your entire enterprise infrastructure purely as data without any more code for you to write or manage (not even antiquated roles/profiles).  As such, all examples in this document and the module's in-file documentation are presented strictly as YAML.

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

This module was written from scratch, specifically for Puppet 5 and Hiera 5 to fully manage postfix; nothing more and nothing less.  No assumptions are made as to what you intend to do with postfix other than install or uninstall it, configure it or delete its configuration files, and -- when not ignoring it -- keep its service running or not running.

Here, "fully manage" means this Puppet module:

* Installs, upgrades, downgrades, version-pins, and uninstalls postfix.
* Controls every line in every postfix configuration file, both vendor- and user-supplied.
* Optionally controls the postfix service.

This is one of a generation of Puppet modules that fully extends control over the subject resources to Hiera.  Use modules like this where you'd rather express your infrastructure as data without any further Puppet code beyond the modules that make this possible.

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

This module is extensively documented via [Puppet Strings](https://github.com/puppetlabs/puppet-strings).  Install support for and run the `puppet strings` command to access the navigable documentation.

## Limitations

Please refer to the *operatingsystem_support* section of [metadata.json](metadata.json) for OS compatibility.  This is not an exhaustive list.  You will very likely find that this module runs just fine on other operating system and version combinations, given the proper inputs.

## Development

This module was written so generically that there really shouldn't be any need to change any of the Puppet code.  However, there is abundant opportunity to add more default Hiera data for operating systems that I simply don't bother with.  Should you find yourself interested in adding support for your favorite operating system -- and the existing defaults specifically do not cover it -- please feel free to open a Pull Request that adds the missing data.
