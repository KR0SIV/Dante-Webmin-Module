#!/usr/bin/perl
#
#    dante Webmin Module
#    Copyright (C) 2002 by Hubert Krause
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    This module inherited from the Webmin Module Template 0.79.1 by tn

#use strict;

require './dante-lib.pl';

do '../web-lib.pl';

$|=1;

&init_config("dante");

my %access=&get_module_acl;

## put in ACL checks here if needed


## sanity checks



&header($text{'index_title'}, "", "client_rules", undef, undef, undef,
        undef);
# uses the index_title entry from ./lang/en or appropriate

## Insert Output code here

# in $confi_ref there is an array with two refs
# 1.) $settref: don't used here it is a hashref with global settings
# (key is command, value is value)
# 2.) $rulesref contains an array with the rules (in order of apperance in conffile)
# every element is a hashref like $settref with key as command and value as value
my $confi_ref=parse_conf(get_clean_conf($config{'conffile'}));

print "<hr><br>\n";


# order of rules (client)
#  Rules:
#	client block/pass
#		from to
#		libwrap
#		log
#
my @order=(	"context", "from","to","method","user","pam.servicename",
		"libwrap","log");

my ($table_in,$last_client,$last)=@{create_rule_list(\@order,"client",@{$confi_ref})};

print create_table($text{'client_rules.cgi'},$table_in);

print "<a href=\"edit_rules.cgi?rule=$last_client&method=insert&comefrom=client_rules.cgi\">
	$text{'insert_new_rule'}</a>\n";

print "<br><hr>\n";

&footer("index.cgi", $text{'index'});
