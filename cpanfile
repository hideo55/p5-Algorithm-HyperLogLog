#!perl
requires 'perl' => '5.008003';
requires 'XSLoader';
requires 'Carp';

on 'configure' => sub {
    requires 'Module::Build::Pluggable';
    requires 'Module::Build::Pluggable::GithubMeta';
    requires 'Module::Build::Pluggable::CPANfile';
    requires 'Module::Build::Pluggable::XSUtil';
};

on 'build' => sub {
    requires 'Module::Build::Pluggable';
    requires 'Module::Build::Pluggable::GithubMeta';
    requires 'Module::Build::Pluggable::CPANfile';
    requires 'Module::Build::Pluggable::XSUtil';
};

on 'test' => sub {
    requires 'Test::More'     => '0.98';
    requires 'Test::Fatal'    => '0.008';
};

on 'develop' => sub {
    requires 'Test::Spelling';
    requires 'Test::Perl::Critic';
    requires 'Test::Pod';
    requires 'Test::Pod::Coverage';
};

