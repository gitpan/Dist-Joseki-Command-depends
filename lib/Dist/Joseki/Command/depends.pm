package Dist::Joseki::Command::depends;
use 5.008;
use strict;
use warnings;
use Cwd;
use File::Find;
use File::Slurp;
use Module::CoreList;
use Module::ExtractUse;
use Parse::CPAN::Packages;
use Perl::Version;
our $VERSION = '0.01';
use base 'Dist::Joseki::Cmd::Multiplexable';

sub options {
    my ($self, $app, $cmd_config) = @_;
    return (
        $self->SUPER::options($app, $cmd_config),
        [   'cpan|c=s',
'only print one requirement per CPAN distribution; value is location of 02packages.details.txt.gz file',
            { default => '' },
        ],
        [   'version|v=s',
            'assuming the given perl version, only print non-core requirements',
            { default => '' },
        ],
    );
}

sub get_primary_package_from_dist {
    my ($self, $parser, $dist_prefix) = @_;
    return $1 if $dist_prefix =~ /\/(perl-[\d\.]+)\.tar\.gz$/;
    my $distribution = $parser->distribution($dist_prefix);
    my @dist_packages =
      sort { length($a) <=> length($b) }
      map { $_->package } @{ $distribution->packages || [] };
    $dist_packages[0];
}

sub restrict_to_CPAN_distributions {
    my ($self, @packages) = @_;
    return @packages unless $self->opt_has_value('cpan');
    my @result;
    my %dist_seen;
    my $parser = Parse::CPAN::Packages->new($self->opt('cpan'));
    for my $package (@packages) {
        my $pkg_obj = $parser->package($package);

        # if there is no such package in any CPAN distribution, just add it as
        # a requirement
        unless (defined $pkg_obj) {
            push @result => $package;
            next;
        }

        # use the distribution object's prefix() as a hash key because we can
        # get back to the distribution from that
        $dist_seen{ $pkg_obj->distribution->prefix }++;
    }
    push @result => map { $self->get_primary_package_from_dist($parser, $_) }
      sort keys %dist_seen;
    @result;
}

sub get_core_list_version_string {
    my ($self, $version) = @_;

    # Module::CoreList expects 5.6.0 as 5.006, but Perl::Version would return
    # 5.006000, so chop off any subversion 0.
    $version =~ s/^(\d.\d+)\.0$/$1/;
    Perl::Version->new($version)->numify;
}

sub restrict_to_non_core_modules {
    my ($self, @packages) = @_;
    return @packages unless $self->opt_has_value('version');
    my $core_list =
      $Module::CoreList::version{ $self->get_core_list_version_string(
            $self->opt('version')) };
    unless (defined $core_list) {
        warn sprintf "no core module list for perl version %s, skipping\n",
          $self->opt('version');
        return @packages;
    }
    grep { !exists $core_list->{$_} } @packages;
}

sub run_single {
    my $self = shift;
    $self->SUPER::run_single(@_);
    $self->assert_is_dist_base_dir;
    my %modules;
    my %packages;
    find(
        sub {
            return unless -f && /\.pm$/;
            my $source = read_file($_);
            my $p      = Module::ExtractUse->new;
            $p->extract_use(\$source);
            @modules{ $p->array } = ();
            my @packages = ($source =~ /^package\s*(\w+(?:::\w+)*)\s*;/gsm);
            @packages{@packages} = ();
        },
        getcwd()
    );

    # packages found in this distribution aren't external requirements
    delete @modules{ keys %packages };
    print "$_\n"
      for $self->restrict_to_CPAN_distributions(
        $self->restrict_to_non_core_modules(sort keys %modules,));
}
1;
__END__

=head1 NAME

Dist::Joseki::Command::depends - show your distribution's dependencies

=head1 SYNOPSIS

    # dist depends

=head1 DESCRIPTION

This command plugin for L<Dist::Joseki> gives you a new command: C<dist
depends> lists the distribution's module dependencies.

=head1 METHODS

=over 4

=back

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests through the web interface at
L<http://rt.cpan.org>.

=head1 INSTALLATION

See perlmodinstall for information and options on installing Perl modules.

=head1 AVAILABILITY

The latest version of this module is available from the Comprehensive Perl
Archive Network (CPAN). Visit L<http://www.perl.com/CPAN/> to find a CPAN
site near you. Or see
L<http://search.cpan.org/dist/Dist-Joseki-Command-depends/>.

The development version lives at
L<http://github.com/hanekomu/dist-joseki-command-depends/>.  Instead of
sending patches, please fork this project using the standard git and github
infrastructure.

=head1 AUTHORS

Marcel GrE<uuml>nauer, C<< <marcel@cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright 2010 by Marcel GrE<uuml>nauer

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
