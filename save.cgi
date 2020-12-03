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


## Insert Output code here

my $settings_ref=&cleanup_settings(\%in);

my $confi_ref=parse_conf(get_clean_conf($config{'conffile'}));
# File locking und einlesen in einen array (Zeile für Zeile).

my ($old_settings_ref, $rulesref)=@{$confi_ref};

my $lines_ref=read_file_lines($config{'conffile'});

my $flag=0;
my $line="";

if ($in{'comefrom'} eq "settings.cgi"){

&save_settings($settings_ref, $lines_ref);

} elsif ($in{'comefrom'} eq "rules.cgi" or $in{'comefrom'} eq "client_rules.cgi"){
# Es geht hier nach der rule Nummer, vieleicht bekommen wir Schützenhilfe von
# clone, move, delete_rules...

# Zunächst müssen die Zeilen erzeugt werden und in den array @dup eingefügt werden.
my $what_is="";

if ($in{'comefrom'} eq "rules.cgi"){
	$what_is="rule";
}else{
	$what_is="client";
}

my $rule_array=create_rule_array($settings_ref,$what_is);

if($in{'edit_method'} eq "edit"){
	&common_rules($lines_ref,"edit",$in{'rule'},$rule_array);
} elsif($in{'edit_method'} eq "insert"){
	&common_rules($lines_ref,"insert",$in{'rule'},$rule_array);
}

}

&flush_file_lines();

my $redirect=$in{'comefrom'};

if($in{'comefrom'} eq "settings.cgi"){
	$redirect="index.cgi";
}

&redirect($redirect);
