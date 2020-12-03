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


&header($text{'index_title'}, "", undef, 1, 1, undef,
        $text{'written_by'});
# uses the index_title entry from ./lang/en or appropriate

## Insert Output code here

icons_table(["settings.cgi","client_rules.cgi","rules.cgi"],
	[$text{'edit_settings'},$text{'edit_client_rules'},
	$text{'edit_rules'}],["images/global.gif",
	"images/client.gif","images/rules.png"]);

print "<hr>\n";

# one button for restarting, one for stopping
# but the one for stopping only in case of a running
# sockd
print "<form action=\"restart.cgi\"><input type=\"submit\" name=\"restart\" value=\"";
# is dante started or not?
if(${start_stop_reload($config{'sockd.pid'}, $config{'executable'},$config{'start.cmd'},$config{'stop.cmd'},"check")}[0]==0){
	print "$text{'reload'}\">\n";
	print "<input type=\"hidden\" name=\"startmethod\" value=\"reload\">";
	print "</form>\n";
	print "<form action=\"restart.cgi\"><input type=\"submit\" name=\"stop\" value=\"$text{'stop'}\">\n";
	print "<input type=\"hidden\" name=\"startmethod\" value=\"stop\"></form>\n";
} else {
	print "$text{'start'}\">\n";
	print "<input type=\"hidden\" name=\"startmethod\" value=\"start\"></form>\n";
}


&footer("/", $text{'others'});
