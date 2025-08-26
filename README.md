[![Actions Status](https://github.com/lizmat/Version-Semver/actions/workflows/linux.yml/badge.svg)](https://github.com/lizmat/Version-Semver/actions) [![Actions Status](https://github.com/lizmat/Version-Semver/actions/workflows/macos.yml/badge.svg)](https://github.com/lizmat/Version-Semver/actions) [![Actions Status](https://github.com/lizmat/Version-Semver/actions/workflows/windows.yml/badge.svg)](https://github.com/lizmat/Version-Semver/actions)

NAME
====

Version::Semver - Implement Semver Version logic

SYNOPSIS
========

```raku
use Version::Semver;

my $left  = Version::Semver.new("1.0.0");
my $right = Version::Semver.new("1.1.0");

# method interface
say $left.cmp($right);  # Less
say $left."<"($right);  # True

# infix interface
say $left cmp $right;  # Less
say $left < $right;    # True
```

DESCRIPTION
===========

The `Version::Semver` distribution provides a `Version::Semver` class which encapsulates the logic for creating a `Version`-like object with semantics matching the [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html) standard.

INSTANTIATION
=============

```raku
my $sv = Version::Semver.new("1.2.3-pre.release+build.data");
```

The basic instantion of a `Version::Semver` object is done with the `new` method, taking the version string as a positional argument.

```raku
my $svb = Version::Semver.new("1.2.3+build.data", :include-build);
```

By default, any "build" expression (any parts after the "+") will be ignored during comparisons. If specified with a true value, then **any** "build" expression **will** be included in any comparisons with the same semantics as the "pre-release" information, but with a reversed result if either side does not have a "build" expression.

ACCESSORS
=========

major
-----

```raku
my $sv = Version::Semver.new("1.2.3");
say $sv.major;  # 1
```

Returns the major version value.

minor
-----

```raku
my $sv = Version::Semver.new("1.2.3");
say $sv.minor;  # 2
```

Returns the minor version value.

patch
-----

```raku
my $sv = Version::Semver.new("1.2.3");
say $sv.patch;  # 3
```

Returns the patch value.

pre-release
-----------

```raku
my $sv = Version::Semver.new("1.2.3-foo.bar");
say $sv.pre-release;  # (foo bar)
```

Returns a `List` with the pre-release tokens.

build
-----

```raku
my $sv = Version::Semver.new("1.2.3+build.data");
say $sv.build;  # (build data)
```

Returns a `List` with the build tokens.

OTHER METHODS
=============

cmp
---

```raku
my $left  = Version::Semver.new("1.0.0");
my $right = Version::Semver.new("1.1.0");

say $left.cmp($left);   # Same
say $left.cmp($right);  # Less
say $right.cmp($left);  # More
```

The `cmp` method returns the `Order` of a comparison of the invocant and the positional argument, which is either `Less`, `Same`, or `More`. This method is the workhorse for comparisons.

eqv
---

```raku
my $left  = Version::Semver.new("1.0.0");
my $right = Version::Semver.new("1.0.0+build.data");

say $left.eqv($right);  # True
```

The `eqv` method returns whether the internal state of two `Version::Semver` objects is identical. Note that does not necessarily means that their stringification is the same, as any build data is ignored in these comparisons.

== != < <= > >=
---------------

```raku
my $left  = Version::Semver.new("1.2.3");
my $right = Version::Semver.new("1.2.4");

say $left."=="($left);  # True
say $left."<"($right);  # True
```

These oddly named methods provide the same functionality as their infix counterparts. Please note that you **must** use the `"xx"()` syntax, because otherwise the Raku compiler will assume you've made a syntax error.

EXPORTED INFIXES
================

The following `infix` candidates handling `Version::Semver` are exported:

  * cmp (returns `Order`)

  * eqv == != < <= > >= (returns `Bool`)

AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/Version-Semver . Comments and Pull Requests are welcome.

If you like this module, or what I’m doing more generally, committing to a [small sponsorship](https://github.com/sponsors/lizmat/) would mean a great deal to me!

COPYRIGHT AND LICENSE
=====================

Copyright 2025 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

