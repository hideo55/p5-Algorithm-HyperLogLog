#!perl
requires 'perl' => '5.008008';
requires 'XSLoader';
requires 'Carp';

on 'configure' => sub {
    requires 'Module::Build::Pluggable';
    requires 'Module::Build::Pluggable::GithubMeta';
    requires 'Module::Build::Pluggable::CPANfile';
    requires 'Module::Build::Pluggable::XSUtil';
};

on 'build' => sub {
};

on 'test' => sub {
    requires 'Test::More'  => '0.98';
    requires 'Test::Fatal' => '0.008';
    requires 'File::Temp';
};

on 'develop' => sub {
    requires 'Test::Spelling';
    requires 'Test::Perl::Critic';
    requires 'Test::Pod';
    requires 'Test::Pod::Coverage';
    requires 'Software::License';
};

