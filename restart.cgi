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

&ReadParse();

my %access=&get_module_acl;

## put in ACL checks here if needed


## sanity checks

&header($text{'restart_title'}, "", undef, undef, undef, undef,
        undef);
# uses the index_title entry from ./lang/en or appropriate

## Insert Output code here

# if(-e $config{'sockd.pid'}){
# 	$sysstring="/bin/kill -HUP `cat $config{'sockd.pid'}`\n";
# } else {
# 	$sysstring="$config{'executable'} -D -f $config{'conffile'}\n";
# }
#
# if(system($sysstring) == 0){
# 	print "<center><h1>$text{'restarted'}</h1></center>\n";
# }else{
# 	print "<center><h1>$text{'notrestarted'}: $?</h1></center>\n";
# }

my $result="";	# message from start_stop_reload

# do we need to reload, restart or stop the socks-daemon?

if($in{'startmethod'} eq "reload"){
	$result=start_stop_reload($config{'sockd.pid'}, $config{'executable'},$config{'start.cmd'},$config{'stop.cmd'},"reload");
} elsif ($in{'startmethod'} eq "start"){
	$result=start_stop_reload($config{'sockd.pid'}, $config{'executable'},$config{'start.cmd'},$config{'stop.cmd'},"start");
} elsif ($in{'startmethod'} eq "stop"){
	$result=start_stop_reload($config{'sockd.pid'}, $config{'executable'},$config{'start.cmd'},$config{'stop.cmd'},"stop");
}

# now check if it was succesfull:

sleep(5);	# wait a moment (hope 5s is enough)

if(${$result}[0] == 0
	and ${start_stop_reload($config{'sockd.pid'}, $config{'executable'},$config{'start.cmd'},$config{'stop.cmd'},"check")}[0]==0
	and $in{'startmethod'} ne "stop"){
	print "<center><h1>$text{$in{'startmethod'}} $text{'success'}</h1></center>\n";
} elsif (${$result}[0] == 0
	and ${start_stop_reload($config{'sockd.pid'}, $config{'executable'},$config{'start.cmd'},$config{'stop.cmd'},"check")}[0]!=0
	and $in{'startmethod'} eq "stop"){
	print "<center><h1>$text{$in{'startmethod'}}  $text{'success'}</h1></center>\n";
} else {
	print "<center><h1>$text{$in{'startmethod'}}  $text{'nosuccess'}</h1>\n";
	print "$text{'error'}: ${$result}[0], $text{'message'}: ${$result}[1]</center>\n";
}

# debug
# print $sysstring;

&footer("index.cgi", $text{'index'});
