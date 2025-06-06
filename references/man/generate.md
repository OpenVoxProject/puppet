---
layout: default
built_from_commit: 812d7420ea5d7e19e8003b26486a7c8847afdb25
title: 'Man Page: puppet generate'
canonical: "/puppet/latest/man/generate.html"
---

# Man Page: puppet generate

> **NOTE:** This page was generated from the Puppet source code on 2024-10-18 17:22:50 +0000

## NAME
**puppet-generate** - Generates Puppet code from Ruby definitions.

## SYNOPSIS
puppet generate *action*

## OPTIONS
Note that any setting that\'s valid in the configuration file is also a
valid long argument, although it may or may not be relevant to the
present action. For example, **server** and **run_mode** are valid
settings, so you can specify **\--server \<servername\>**, or
**\--run_mode \<runmode\>** as an argument.

See the configuration file documentation at
*https://puppet.com/docs/puppet/latest/configuration.html* for the full
list of acceptable parameters. A commented list of all configuration
options can also be generated by running puppet with **\--genconfig**.

\--render-as FORMAT

:   The format in which to render output. The most common formats are
    **json**, **s** (string), **yaml**, and **console**, but other
    options such as **dot** are sometimes available.

\--verbose

:   Whether to log verbosely.

\--debug

:   Whether to log debug information.

## ACTIONS
**types** - Generates Puppet code for custom types

:   **SYNOPSIS**

    puppet generate types \[\--format *format*\] \[\--force\]

    **DESCRIPTION**

    Generates definitions for custom resource types using Puppet code.

    Types defined in Puppet code can be used to isolate custom type
    definitions between different environments.

    **OPTIONS** *\--force* - Forces the generation of output files
    (skips up-to-date checks).

    *\--format \<format*\> - The generation output format to use.
    Supported formats: pcore.

## EXAMPLES
**types**

Generate Puppet type definitions for all custom resource types in the
current environment:



    $ puppet generate types

Generate Puppet type definitions for all custom resource types in the
specified environment:



    $ puppet generate types --environment development

## COPYRIGHT AND LICENSE
Copyright 2016 by Puppet Inc. Apache 2 license; see COPYING
