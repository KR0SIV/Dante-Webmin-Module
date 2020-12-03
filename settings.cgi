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

%access=&get_module_acl;

## put in ACL checks here if needed


## sanity checks



&header($text{'edit_settings'}, "", undef, undef, undef, undef,
        undef);

my $confi_ref=parse_conf(get_clean_conf($config{'conffile'}));

my ($settref, $rulesref)=@{$confi_ref};

my @content=();	# array for form tag generation

push(@content,["compatibility","compatibility",
	mk_select(1,"compatibility",[split(/\s+/,${$settref}{'compatibility'})],["sameport","reuseaddr"],undef)]);
push(@content,["connecttimeout","connecttimeout",
	"<input type=\"text\" name=\"connecttimeout\"
	value=\"${$settref}{'connecttimeout'}\" maxlength=\"4\" size=\"4\">"]);
push(@content,["external","external",
	"<input type=\"text\" name=\"external\"
	value=\"${$settref}{'external'}\" maxlength=\"25\" size=\"20\">"]);
push(@content,["internal","internal","<input type=\"text\" name=\"internal\"
	value=\"${$settref}{'internal'}\" maxlength=\"25\" size=\"20\">"]);
push(@content,["iotimeout","iotimeout",
	"<input type=\"text\" name=\"iotimeout\"
	value=\"${$settref}{'iotimeout'}\" maxlength=\"4\" size=\"4\">"]);
push(@content,["logoutput","logoutput",
	"<input type=\"text\" name=\"logoutput\"
	value=\"${$settref}{'logoutput'}\" size=20 maxlength=100>"]);
push(@content,["method","method",
	"<input type=\"text\" name=\"method\"
	value=\"${$settref}{'method'}\" size=20 maxlength=140>"]);
push(@content,["clientmethod","clientmethod",
	"<input type=\"text\" name=\"clientmethod\"
	value=\"${$settref}{'clientmethod'}\" size=20 maxlength=140>"]);
push(@content,["external.rotation","external.rotation",
	mk_select(1,"external.rotation",[split(/\s+/,${$settref}{'external.rotation'})],["none","route"],undef)]);
push(@content,["srchost","srchost",
	mk_select(2,"srchost",[split(/\s+/,${$settref}{'srchost'})],["nomismatch","nounknown"],1)]);
push(@content,["user\.privileged","user","<input type=\"text\" name=\"user_privileged\"
	value=\"${$settref}{'user.privileged'}\" size=15 maxlength=20> ".user_chooser_button("user_privileged", 0, 0)]);
# Underscore instead of dot, because of the meaning of the dot
# in Javascript
push(@content,["user\.notprivileged","user","<input type=\"text\" name=\"user_notprivileged\"
	value=\"${$settref}{'user.notprivileged'}\" size=15 maxlength=20> ".
	user_chooser_button("user_notprivileged", 0, 0)]);
push(@content,["user\.libwrap","user","<input type=\"text\" name=\"user_libwrap\"
	value=\"${$settref}{'user.libwrap'}\" size=15 maxlength=20> ".
	user_chooser_button("user_libwrap", 0, 0)]);

## Insert Output code here

print "<hr>\n";

print "<form action=\"save\.cgi\" method=\"GET\">", "\n";

# "$text{'rule_nr'.$in{'comefrom'}} $rulenum" head for rules
# head for global settings:
# $text{'edit_settings'}

print create_table($text{'edit_settings'},field_display(\@content,undef));

print "<input type=\"hidden\" name=\"comefrom\" value=\"settings.cgi\">\n";
print "<p><input type=\"submit\" value=\"$text{'save'}\">&nbsp;<input type=\"reset\" value=\"$text{'reset'}\">\n";
# damit save.cgi weiss, wer ihm was mitteilen will
print "</form>", "</p>\n";



&footer("index.cgi", $text{'index'});
# uses the index entry in /lang/en



## if subroutines are not in an extra file put them here
