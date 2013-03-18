#!perl

requires 'XSLoader';

on 'configure' => sub{
    requires 'Module::Build::Pluggable';
    requires 'Module::Build::Pluggable::CPANfile';
    requires 'Module::Build::Pluggable::XSUtil';
    requires 'Module::Build::Pluggable::GithubaMeta';
};

on 'build' => sub {
};

on 'test' => sub {
    requires 'Test::More'     => '0.98';
    requires 'Test::Fatal'    => '0.008';
};

on 'develop' => sub {
};
