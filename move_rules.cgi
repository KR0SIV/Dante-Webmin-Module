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


## Insert Output code here

my $rulecount=-1;
my $count=-1;	# counter forrules
my $curr_rule=0;
my $end_rule=0;	# end_rule is the offset from curr_rule to the end

my $lines_ref=read_file_lines($config{'conffile'});	# read configfile.

if($in{'method'} eq "up"){	# Erst Vorhergehende löschen und diese dann hinten wieder dranhängen.
				# Probleme werden auftreten, wenn jemand hier von Hand eingreifen will,
				# und die erste Regel 0 nach oben verschoben werden soll. Das muß überprüft werden.
	$in{'rule'}--;
}

# there will be the rule to be moved in
my @dup=@{common_rules($lines_ref,"delete",$in{'rule'})};

# Jetzt muß etwas mit in{rule} definiert werden.
# Das einzusetzende muß vor die nächste Regel.
$in{'rule'}++;

#$rulecount=$count=-1;
#$curr_rule=$end_rule=0;

foreach my $val (@{$lines_ref}) {	#
	$count++;

	if ($val =~ /\{/ and $val !~ /^\s*#/ and $val !~ /^\s*$/){
		$rulecount++;
		if($rulecount == $in{'rule'}){
			$curr_rule=$count;
		}
	}
}

if($curr_rule == 0){	# Wir haben die vorletzte Regel nach unten verschoben,
			# also wurde $curr_rule nie gesetzt. Klatschen wirs hinten dran.
	push(@{$lines_ref},@dup);
} else {
	splice(@{$lines_ref},$curr_rule,0,@dup);
}

&flush_file_lines();


&redirect($in{'comefrom'});
