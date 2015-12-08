package backend::ipmi;
use strict;
use base ('backend::baseclass');
use threads;
use threads::shared;
require File::Temp;
use File::Temp ();
use Time::HiRes qw(sleep gettimeofday);
use IO::Select;
use IO::Socket::UNIX qw( SOCK_STREAM );
use IO::Handle;
use Data::Dumper;
use POSIX qw/strftime :sys_wait_h/;
use JSON;
require Carp;
use Fcntl;
use bmwqemu qw(fileContent diag save_vars diag);
use testapi qw(get_required_var);
use IPC::Run ();
require IPC::System::Simple;
use autodie qw(:all);

sub new {
    my $class = shift;
    get_required_var('WORKER_HOSTNAME');
    return $class->SUPER::new;
}

use Time::HiRes qw(gettimeofday);

sub ipmi_cmdline {
    my ($self) = @_;

    return ('ipmitool', '-H', $bmwqemu::vars{IPMI_HOSTNAME}, '-U', $bmwqemu::vars{IPMI_USER}, '-P', $bmwqemu::vars{IPMI_PASSWORD});
}

sub ipmitool {
    my ($self, $cmd) = @_;

    my @cmd = $self->ipmi_cmdline();
    push(@cmd, split(/ /, $cmd));

    my ($stdin, $stdout, $stderr, $ret);
    $ret = IPC::Run::run(\@cmd, \$stdin, \$stdout, \$stderr);
    chomp $stdout;
    chomp $stderr;

    die join(' ', @cmd) . ": $stderr" unless ($ret);
    bmwqemu::diag("IPMI: $stdout");
    return $stdout;
}

sub restart_host {
    my ($self) = @_;

    $self->ipmitool("chassis power off");
    while (1) {
        my $stdout = $self->ipmitool('chassis power status');
        last if $stdout =~ m/is off/;
        $self->ipmitool('chassis power off');
        sleep(2);
    }

    $self->ipmitool("chassis power on");
    while (1) {
        my $ret = $self->ipmitool('chassis power status');
        last if $ret =~ m/is on/;
        $self->ipmitool('chassis power on');
        sleep(2);
    }
}

sub relogin_vnc {
    my ($self) = @_;

    if ($self->{vnc}) {
        close($self->{vnc}->socket);
        sleep(1);
    }

    my $vnc = $testapi::distri->add_console(
        'sut',
        'vnc-base',
        {
            hostname => $bmwqemu::vars{IPMI_HOSTNAME},
            port     => 5900,
            username => $bmwqemu::vars{IPMI_USER},
            password => $bmwqemu::vars{IPMI_PASSWORD},
            ikvm     => 1
        });
    $vnc->backend($self);
    $self->select_console({testapi_console => 'sut'});

    return 1;
}

sub do_start_vm() {
    my ($self) = @_;

    # remove backend.crashed
    $self->unlink_crash_file;
    $self->restart_host;
    $self->relogin_vnc;
    $self->start_serial_grab;
    return {};
}

sub do_stop_vm {
    my ($self) = @_;

    $self->ipmitool("chassis power off");
    $self->stop_serial_grab();
    return {};
}

sub do_savevm {
    my ($self, $args) = @_;
    print "do_savevm ignored\n";
    return {};
}

sub do_loadvm {
    my ($self, $args) = @_;
    die "if you need loadvm, you're screwed with IPMI";
}

sub status {
    my ($self) = @_;
    print "status ignored\n";
    return;
}

# serial grab

sub start_serial_grab {
    my ($self) = @_;

    $self->{serialpid} = fork();
    if ($self->{serialpid} == 0) {
        setpgrp 0, 0;
        open(my $serial, '>',  $self->{serialfile});
        open(STDOUT,     ">&", $serial);
        open(STDERR,     ">&", $serial);
        my @cmd = ('/usr/sbin/ipmiconsole', '-h', $bmwqemu::vars{IPMI_HOSTNAME}, '-u', $bmwqemu::vars{IPMI_USER}, '-p', $bmwqemu::vars{IPMI_PASSWORD});

        # zypper in dumponlyconsole, check devel:openQA for a patched freeipmi version that doesn't grab the terminal
        push(@cmd, '--dumponly');

        # our supermicro boards need workarounds to get SOL ;(
        push(@cmd, qw/-W nochecksumcheck/);

        exec(@cmd);
        die "exec failed $!";
    }
    return;
}

sub stop_serial_grab {
    my ($self) = @_;
    return unless $self->{serialpid};
    kill("-TERM", $self->{serialpid});
    return waitpid($self->{serialpid}, 0);
}

# serial grab end

1;

# vim: set sw=4 et:
