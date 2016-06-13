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
    $pre_test_cmd .= "-run 03";

    return "$pre_test_cmd";
}

sub run() {
    my $self = shift;

    # Set the correct serial dev for ipmi xen and non-xen host according to the installed product release
    # &virt_utils::set_serialdev();

    # Got script run according to different kind of system
    my $pre_test_cmd = $self->get_script_run();

    # Execute script run
    my $ret = $self->execute_script_run($pre_test_cmd, 5400);
    save_screenshot;

    script_run("tar cvf /tmp/host-upgrade-postVerify-logs.tar /var/log/qa/ctcs2/;rm  /var/log/qa/ctcs2/* -r", 60);

    upload_logs "/tmp/host-upgrade-postVerify-logs.tar";

    if ($ret !~ /Test run completed successfully/) {
        die "Host upgrade verification failed!";
    }

    # TODO: parse the logs into junit format
    #    my $tc_result = $self->analyzeResult($ret);
    #    my $xml_result = $self->generateXML($tc_result);
    #
    #    # Upload and parse junit file.
    #    $self->push_junit_log($xml_result);

}

1;

