Elvish completions for Chromium dev tools
=========================================

This repository contains completion scripts for [Chromium and Chromium OS
developer tools][dev-tools] (starting with [`gclient`][gclient]) for use with
the [Elvish shell](https://elv.sh/).

[dev-tools]: https://chromium.googlesource.com/chromium/tools/depot_tools.git
[gclient]: https://chromium.googlesource.com/chromium/tools/depot_tools.git/+/HEAD/README.gclient.md

Installation and use
--------------------

Install the package via [epm](https://elv.sh/ref/epm.html):

```elvish
use epm
epm:install github.com/HarryCutts/elvish-chromium-dev
```

Then `use` the completion module:

```elvish
use github.com/HarryCutts/elvish-chromium-dev/gclient
```
