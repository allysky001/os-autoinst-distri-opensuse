# SUSE's openQA tests
#
# Copyright © 2012-2016 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.
#
use base "host_upgrade_base";
use testapi;
use strict;

sub get_script_run() {
    my $self = shift;

    my $pre_test_cmd = $self->get_test_name_prefix;
    $pre_test_cmd .= "-run 01";

    return "$pre_test_cmd";
}

sub run() {
    my $self = shift;
    # Got script run according to different kind of system
    my $pre_test_cmd = $self->get_script_run();

    # Execute script run
    my $ret = $self->execute_script_run($pre_test_cmd, 5400);
    save_screenshot;

    assert_script_run("tar cvf /tmp/host-upgrade-updateVirtRpms-logs.tar /var/log/qa/ctcs2/; rm  /var/log/qa/ctcs2/* -r", 60);

    upload_logs("/tmp/host-upgrade-updateVirtRpms-logs.tar");

    if ($ret !~ /Test run completed successfully/) {
        die "Update virt rpms failed!";
    }
}

1;
