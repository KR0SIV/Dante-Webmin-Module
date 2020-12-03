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

# erstmal schauen, läuft der schon?




&header($text{'index_title'}, "", undef, undef, undef, undef,
        undef);
# uses the index_title entry from ./lang/en or appropriate

my $confi_ref=parse_conf(get_clean_conf($config{'conffile'}));	# eine routine (2 routinen) um
								# die informationen aus dem configfile zu ziehen

my ($settref, $rulesref)=@{$confi_ref};	# settref ist eine referenz auf einen hash mit den globalen settings
					# $rulesref ist eine referenz auf einen array mit referenzen auf einen hash
					# mit den settings der jeweiligen rule

my %rules=();

my $methods="";	# dort kommen die methoden rein um eine userliste zu bekommen

my $insert=$in{'rule'};	# wenn ein insert gemacht wird muß die angezeigte regelnummer um eins erhöht sein!

my $user_ref=user_list("username");	# there is a  strange error with nsslib and ldap. If you call the
									# routine user_list twice you only get the ldap user the second
									# run.

if($in{'method'} eq "edit"){
	%rules=%{${$rulesref}[$in{'rule'}]};
} elsif($in{'method'} eq "insert"){	# es ist ein insert, die nummer wird erhöht (kosmetik;)
	$insert++;
}

# create the contentarray to fill out the form tag table:
my @content=();

my @visible=();	# containerarray for in this form visible rules

push(@visible,"context");
push(@content,[$text{'context'},"context",
	mk_select(1,"context",[split(/\s+/,$rules{'context'})],["pass","block"],undef)]);
# in configfile there is "client pass" or "pass" only. so mk_select has to check values not so
# carefuly
push(@visible,"from");
push(@content,["from","from","<input type=\"text\" name=\"from\"
	value=\"$rules{'from'}\" size=30 maxlength=60>"]);
push(@visible,"to");
push(@content,["to","to","<input type=\"text\" name=\"to\"
	value=\"$rules{'to'}\" size=30 maxlength=60>"]);
push(@visible,"libwrap");
push(@content,["libwrap","libwrap","<input type=\"text\" name=\"libwrap\"
	value=\"$rules{'libwrap'}\" size=30 maxlength=40>"]);
push(@visible,"log");
push(@content,["log","log",
	mk_select(4,"log",[split(/\s+/,$rules{'log'})],["connect","disconnect","data","error","iooperation"],1)]);

push(@visible,"user");
push(@content,["user ($text{'systemuser'})","systemuser",
	mk_select(4,"user",[split(/\s+/,$rules{'user'})],$user_ref,1)]);
# the value of the otheruser field should be the list of user not in user_list("method")
push(@content,["user ($text{'otheruser'})","otheruser","<input type=\"text\" name=\"user\"
	value=\"".join(" ",@{not_in_array([split(/\s+/,$rules{'user'})],$user_ref)}).
	"\" size=30 maxlength=20000>"]);

# choose on context witch helptext to show:
my $help_method="";

if ($in{'comefrom'} eq "client_rules.cgi"){
	$help_method="clientmethod";
} else {
	$help_method="method";
}

push(@visible,"method");
push(@content,["method",$help_method,"<input type=\"text\" name=\"method\"
	value=\"$rules{'method'}\" size=30 maxlength=100>"]);

push(@visible,"pam.servicename");
push(@content,["pam.servicename","pam.servicename","<input type=\"text\" name=\"pam.servicename\"
	value=\"$rules{'pam.servicename'}\" size=30 maxlength=100>"]);

# there should be a second method entry, for changing global methods for
# this and the following rules. Therefore I have to rewrite how this
# modul write and read from dante configfile. So this is put
# to the todolist

if($in{'comefrom'} eq "rules.cgi"){	# extra fields for socks rules

push(@visible,"command");
push(@content,["command","command",
	mk_select(4,"command",[split(/\s+/,$rules{'command'})],
	["bind","bindreply","connect","udpassociate","udpreply"],1)]);
push(@visible,"protocol");
push(@content,["protocol","protocol",
	mk_select(2,"protocol",[split(/\s+/,$rules{'protocol'})],["tcp","udp"],1)]);
push(@visible,"proxyprotocol");
push(@content,["proxyprotocol","proxyprotocol",
	mk_select(2,"proxyprotocol",[split(/\s+/,$rules{'proxyprotocol'})],["socks_v4","socks_v5"],1)]);


}

## Insert Output code here

print "<form action=\"save\.cgi\" method=\"GET\">", "\n";


# do the output of table and content
print create_table($text{'rule_nr'.$in{'comefrom'}}." ".$insert,field_display(\@content,undef));

print "<p><input type=\"submit\" value=\"$text{'save'}\">&nbsp;<input type=\"reset\" value=\"$text{'reset'}\">\n";
print "<input type=\"hidden\" value=\"$in{'rule'}\" name=\"rule\">\n<input type=\"hidden\" value=\"$in{'method'}\" name=\"edit_method\">\n";
print "<input type=\"hidden\" value=\"$in{'comefrom'}\" name=\"comefrom\">\n";

foreach my $val (@{not_in_array([keys(%rules)],[unique(@visible)])}){
	# @{not_in_array((keys %rules),@visible)} -> unknown command-value pairs
	print "<input type=\"hidden\" value=\"$rules{$val}\" name=\"$val\">\n";
}

print "</form>", "</p>\n";

&footer($in{'comefrom'}, $text{$in{'comefrom'}});

## if subroutines are not in an extra file put them here
