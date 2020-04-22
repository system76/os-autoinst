requires 'B::Deparse';
requires 'Benchmark';
requires 'Carp';
requires 'Carp::Always';
requires 'Class::Accessor::Fast';
requires 'Config';
requires 'Cpanel::JSON::XS';
requires 'Crypt::DES';
requires 'Cwd';
requires 'Data::Dumper';
requires 'Digest::MD5';
requires 'DynaLoader';
requires 'Exception::Class';
requires 'Exporter';
requires 'ExtUtils::MakeMaker', '>= 7.12';
requires 'ExtUtils::testlib';
requires 'Fcntl';
requires 'File::Basename';
requires 'File::Find';
requires 'File::Path';
requires 'File::Spec';
requires 'File::Temp';
requires 'File::Which';
requires 'IO::Handle';
requires 'IO::Scalar';
requires 'IO::Select';
requires 'IO::Socket';
requires 'IO::Socket::INET';
requires 'IO::Socket::UNIX';
requires 'IPC::Open3';
requires 'IPC::Run::Debug';
requires 'IPC::System::Simple';
requires 'List::MoreUtils';
requires 'List::Util';
requires 'Mojo::IOLoop::ReadWriteProcess', '0.21';
requires 'Mojo::Log';
requires 'Mojo::URL';
requires 'Mojo::UserAgent';
requires 'Mojolicious::Lite';
requires 'Net::DBus';
requires 'Net::SNMP';
requires 'Net::SSH2';
requires 'POSIX';
requires 'Thread::Queue';
requires 'Time::HiRes';
requires 'Try::Tiny';
requires 'XML::LibXML';
requires 'base';
requires 'constant';
requires 'strict';
requires 'warnings';

on 'test' => sub {
  requires 'Devel::Cover';
  requires 'File::Touch';
  requires 'Perl::Critic';
  requires 'Perl::Critic::Freenode';
  requires 'Perl::Tidy', '== 20200110';
  requires 'Pod::Coverage';
  requires 'Socket::MsgHdr';
  requires 'Test::Exception';
  requires 'Test::Fatal';
  requires 'Test::Mock::Time';
  requires 'Test::MockModule';
  requires 'Test::MockObject';
  requires 'Test::Mojo';
  requires 'Test::More';
  requires 'Test::Output';
  requires 'Test::Pod';
  requires 'Test::Simple';
  requires 'Test::Strict';
  requires 'Test::Warnings';
  requires 'XML::SemanticDiff';
};

feature 'coverage', 'coverage for travis' => sub {
  requires 'Devel::Cover::Report::Coveralls';
};
