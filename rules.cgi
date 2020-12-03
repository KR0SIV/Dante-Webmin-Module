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

# use strict;

require './dante-lib.pl';

do '../web-lib.pl';
$|=1;
&init_config("dante");

my %access=&get_module_acl;

## put in ACL checks here if needed


## sanity checks



&header($text{'index_title'}, "", "socks_rules", undef, undef, undef,
        undef);
# uses the index_title entry from ./lang/en or appropriate

## Insert Output code here
my $confi_ref=parse_conf(get_clean_conf($config{'conffile'}));

my ($settref, $rulesref)=@{$confi_ref};

# the order:
#     block/pass
#		from to
#		method
# 		user
#		command
#		libwrap
#		log
#		protocol
#		proxyprotocol
my @order=(	"context", "from","to","method","user","pam.servicename","command","libwrap",
		"log","protocol","proxyprotocol");

print "<hr><br>\n";

my ($table_in,$last_client,$last)=@{create_rule_list(\@order,"socks",@{$confi_ref})};

print create_table($text{'rules.cgi'},$table_in);

print "<a href=\"edit_rules.cgi?rule=$last&method=insert&comefrom=rules.cgi\">
	$text{'insert_new_rule'}</a>\n";	# Eine andere Möglichkeit um
									# eine Regel hinten anzuhängen.

print "<br><hr>\n";

&footer("index.cgi", $text{'index'});

