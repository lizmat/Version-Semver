#- Version::Semver -----------------------------------------------------------
class Version::Semver:ver<0.0.2>:auth<zef:lizmat> {
    has UInt $.major is required;
    has UInt $.minor is required;
    has UInt $.patch is required;
    has      @.pre-release is List;
    has      @.build       is List;
    has Bool $.include-build = False;

    multi method new(Version::Semver: Str:D $spec is copy) {
        my %args = %_;

        $spec .= substr(1) if $spec.starts-with("v");  # semver 1.0 compat

        # Generic pre-release / build parsing logic
        my sub parse($index, $type --> Nil) {
            my $target := $spec.substr($index + 1);
            $spec = $spec.substr(0, $index);

            die "$type.tc() info contains illegal characters"
              if $target.contains(/ <-[a..z A..Z 0..9 . -]> /);
            my @parts is List = $target.split(".");
            die "$type.tc() info may not contain empty elements"
              with @parts.first(* eq '');
            die "$type.tc() info may not contain leading zeroes"
              if @parts.first: { .starts-with("0") && .Int }

            %args{$type} := @parts.map({ .Int // $_ }).List;
        }

        # Parse from end to front
        parse($_, 'build')       with $spec.index("+");
        parse($_, 'pre-release') with $spec.index("-");

        # Parse the version info
        die "Version can not be empty"
          unless $spec;
        die "Version contains illegal characters"
          if $spec.contains(/ <-[0..9 .]> /);
        die "Version contains empty elements"
          if $spec.contains(/ '..' /);

        my @version = $spec.split(".");
        die "Version must contain 3 elements, not @version.elems()"
          if @version != 3;
        die "Version may not contain leading zeroes"
          if @version.first: { .starts-with("0") && .Int }

        @version := @version.map(*.Int).List;
        die "Version must just consist of integer values"
          unless @version.are(Int);

        %args<major> := @version[0];
        %args<minor> := @version[1];
        %args<patch> := @version[2];

        self.bless(|%args)
    }

    multi method Str(Version::Semver:D:) {
        "$!major.$!minor.$!patch"
          ~ ("-@!pre-release.join(".")" if @!pre-release)
          ~ ("+@!build.join(".")"       if @!build)
    }
    multi method raku(Version::Semver:D:) {
        self.^name ~ '.new(' ~ self.Str.raku ~ ')'
    }

    method cmp(Version::Semver:D: Version::Semver:D $other --> Order) {
        $!major cmp $other.major
          || $!minor cmp $other.minor
          || $!patch cmp $other.patch
          || self!compare-non-version(
               @!pre-release, $other.pre-release, Less
             )
          || ($other.include-build
               ?? $!include-build
                 ?? self!compare-non-version(
                      @!build, $other.build, More
                    )
                 !! ($other.build ?? Less !! Same)  
               !! $!include-build
                 ?? @!build ?? More !! Same
                 !! Same)
    }

    method eqv(Version::Semver:D: Version::Semver:D $other) {
        $!major eqv $other.major
          && $!minor eqv $other.minor
          && $!patch eqv $other.patch
          && self!compare-non-version(
               @!pre-release, $other.pre-release, Less
             ) == Same
          && ($other.include-build
               ?? $!include-build
                 ?? self!compare-non-version(
                      @!build, $other.build, More
                    ) == Same
                 !! !$other.build  
               !! $!include-build
                 ?? ?@!build
                 !! True)
    }

    method !compare-non-version(@lefts, @rights, $default) {

        # at least one piece of data on the right
        if @rights {

            # at least one on left
            if @lefts {
                my int $i;
                for @lefts -> $left {
                    with @rights[$i++] -> $right {
                        if $left.WHAT =:= $right.WHAT {
                            if $left cmp $right -> $diff {
                                return $diff;  # UNCOVERABLE
                            }
                        }
                        else {
                            return $left ~~ Int ?? $default !! More
                        }
                    }
                    else {
                        return More;
                    }
                }

                # right not exhausted yet?
                $i <= @rights.end ?? $default !! Same
            }

            # data right, not on left
            else {
                $default == Less ?? More !! Less
            }
        }

        # no pre-release on right
        else {
            @lefts ?? $default !! Same
        }
    }

    multi method ACCEPTS(Version::Semver:D: Version::Semver:D $other) {
        self.cmp($other) == Same
    }
}

#- infixes ---------------------------------------------------------------------
my multi sub infix:<cmp>(
  Version::Semver:D $a, Version::Semver:D $b
--> Order:D) is export {
    $a.cmp($b)
}

my multi sub infix:<eqv>(
  Version::Semver:D $a, Version::Semver:D $b
--> Bool:D) is export {
    $a.eqv($b)
}

my multi sub infix:<==>(
  Version::Semver:D $a, Version::Semver:D $b
--> Bool:D) is export {
    $a.cmp($b) == Same
}

my multi sub infix:<!=>(
  Version::Semver:D $a, Version::Semver:D $b
--> Bool:D) is export {
    $a.cmp($b) != Same
}

my multi sub infix:«<» (
  Version::Semver:D $a, Version::Semver:D $b
--> Bool:D) is export {
    $a.cmp($b) == Less
}

my multi sub infix:«<=» (
  Version::Semver:D $a, Version::Semver:D $b
--> Bool:D) is export {
    $a.cmp($b) != More
}

my multi sub infix:«>» (
  Version::Semver:D $a, Version::Semver:D $b
--> Bool:D) is export {
    $a.cmp($b) == More
}

my multi sub infix:«>=» (
  Version::Semver:D $a, Version::Semver:D $b
--> Bool:D) is export {
    $a.cmp($b) != Less
}

#- other infix methods ---------------------------------------------------------
# Note that this is a bit icky, but it allows for a direct mapping of the
# infix op name to a method for comparison with the $a."=="($b) syntax,
# without having to have the above infixes to be imported
BEGIN {
    Version::Semver.^add_method: "~~", { $^a.cmp($^b) == Same }  # UNCOVERABLE
    Version::Semver.^add_method: "==", { $^a.cmp($^b) == Same }  # UNCOVERABLE
    Version::Semver.^add_method: "!=", { $^a.cmp($^b) != Same }  # UNCOVERABLE
    Version::Semver.^add_method: "<",  { $^a.cmp($^b) == Less }  # UNCOVERABLE
    Version::Semver.^add_method: "<=", { $^a.cmp($^b) != More }  # UNCOVERABLE
    Version::Semver.^add_method: ">",  { $^a.cmp($^b) == More }  # UNCOVERABLE
    Version::Semver.^add_method: ">=", { $^a.cmp($^b) != Less }  # UNCOVERABLE
}

# vim: expandtab shiftwidth=4
