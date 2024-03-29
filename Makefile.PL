use inc::Module::Install;
include 'Module::AutoInstall';

name 'Dist-Joseki-Command-depends';
all_from 'lib/Dist/Joseki/Command/depends.pm';
readme_from_pod;
readme_markdown_from_pod;

auto_set_homepage;
auto_set_bugtracker;
auto_set_repository;

requires 'Cwd';
requires 'Dist::Joseki';
requires 'File::Find';
requires 'File::Slurp';
requires 'Module::CoreList';
requires 'Module::ExtractUse';
requires 'Parse::CPAN::Packages';
requires 'Perl::Version';

test_requires 'Test::More' => '0.70';
extra_tests;

author_requires 'ShipIt';
author_requires 'ShipIt::Step::DistClean';
author_requires 'ShipIt::Step::DistTestExtra';
author_requires 'ShipIt::Step::Manifest';
author_requires 'ShipIt::Step::Twitter';
author_requires 'Test::Compile';
author_requires 'Test::Perl::Critic';
author_requires 'Test::Pod';
author_requires 'Test::Spelling';
author_requires 'Pod::Wordlist::hanekomu';
author_requires 'Test::Pod::Coverage';
# author_requires 'Test::Kwalitee';
author_requires 'Test::YAML::Meta';
author_requires 'Test::Portability::Files';
author_requires 'Test::Synopsis';
author_requires 'Test::MinimumVersion';
author_requires 'Test::HasVersion';
author_requires 'Test::CheckChanges';
author_requires 'Test::DistManifest';

auto_install;
auto_include;
WriteAll;
