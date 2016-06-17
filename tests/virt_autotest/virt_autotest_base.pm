# SUSE's openQA tests
#
# Copyright © 2012-2016 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.
#
package virt_autotest_base;
use strict;
use warnings;
use File::Basename;
use base "opensusebasetest";
use testapi;

use Data::Dumper;
use XML::Writer;
use IO::File;

our $PRODUCT_TESTED_ON = "Product";
our $PROJECT_NAME = "Project Name";
our $PACKAGE_NAME = "Package Name";

sub analyzeResult() {
    die "You need to overload analyzeResult in your class";
}

sub generateXML($) {
    my ($self, $data) = @_;

    print Dumper($data);
    my %my_hash = %$data;

    my $case_num = scalar(keys %my_hash);
    my $case_status;
    my $xml_result;
    my $pass_nums = 0;
    my $fail_nums = 0;
    my $writer = new XML::Writer(DATA_MODE => 'true', DATA_INDENT => 2, OUTPUT=>'self');

    foreach my $item (keys (%my_hash) ) {
        if ($my_hash{$item}->{"status"} =~ m/PASSED/) {
            $pass_nums += 1;
        } else {
            $fail_nums += 1;
        }
    }
    my $count = $pass_nums + $fail_nums;
    $writer->startTag('testsuites', "error" => "0", "failures" => "$fail_nums", "name" => $PROJECT_NAME, "skipped" => "0", "tests" => "$count", "time" => "");
    $writer->startTag('testsuite', "error" => "0", "failures" => "$fail_nums", "hostname" => "`hostname`", "id" => "0", "name" => $PRODUCT_TESTED_ON, "package" => $PACKAGE_NAME, "skipped" => "0", "tests" => $case_num, "time" => "", "timestamp" => "2016-02-16T02:50:00");

    foreach my $item (keys (%my_hash)) {

        if ($my_hash{$item}->{"status"} =~ m/PASSED/) {
            $case_status = "success";
        }
		else {
            $case_status = "failure";
        }

        $writer->startTag('testcase', 'classname' => $item, 'name' => $item, "status" => $case_status, 'time' => $my_hash{$item}->{"time"});
        $writer->startTag('system-err');
        $writer->characters("None");
        $writer->endTag('system-err');

        $writer->startTag('system-out');
        $writer->characters($my_hash{$item}->{"time"});
        $writer->endTag('system-out');

        $writer->endTag('testcase');
    }

    $writer->endTag('testsuite');
    $writer->endTag('testsuites');

    $writer->end();
    $writer->to_string();
}

sub execute_script_run($$) {

    my ($self, $cmd, $timeout) = @_;
    my $pattern = "CMD_FINISHED-" . int(rand(999999));

    if (!$timeout) {
        $timeout = 10;
    }

    type_string "(" . $cmd . "; echo $pattern) | tee -a /dev/$serialdev\n";
    my $ret = wait_serial($pattern, $timeout);

    if ($ret) {
        $ret =~ s/$pattern//g;
            return $ret;
    }
    else {
        die "Timeout due to cmd run :[" . $cmd . "]\n";
        return 1;
    }

}

sub push_junit_log($) {
    my ($self, $junit_content) = @_;

    type_string "echo \'$junit_content\' > /tmp/output.xml\n";
    parse_junit_log("/tmp/output.xml");
}

1;

