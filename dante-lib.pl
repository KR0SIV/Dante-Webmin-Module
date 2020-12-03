#!/usr/bin/perl -T
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

# standart Start:
do '../web-lib.pl';
&init_config();

$|=1;

sub create_table {
	# diese Subroutine erzeugt eine Grundtabelle mit
	# Überschrift und rahmen drumherum, auf das man
	# seinen Inhalt darin hüpsch aufbewaren kann
	# Der inhalt kommt in input, die Überschrift
	# in den header

	my ($header, $input)=@_;

	my $output="<table border width=100\% $cb ><tr $tb>\n";
	$output=$output."\t\t<td><b>$header</b></td>\n\t</tr><tr><td>\n";
	$output=$output.$input;
	$output=$output."</td></tr></table>\n";

	return $output;
}

# start output table here
# this routine create a list of rules
# for that it to knows wich rules to show
# (its different for client and for socks rules)

sub create_rule_list {

# in order_ref there is an arrayref with the commands that belong to a rule
# in the order "from left to right"
# type contains client or socks for the two different rule types

my ($order_ref,$type,$settref, $rulesref)=@_;

my $last_client=-1;	# the last client rule (+1=the first socks rule)
my $count=-1;	# rule counter

my $out="";	# return string

# $out=$out."<table border=\"2\" $cb cellspacing=\"0\" cellpadding=\"2\" width=\"100%\">", "\n";
# $out=$out."<tr >", "\n";
# $out=$out."<td $tb width=\"100%\" colspan=\"".(scalar(@{$order_ref})+1)."\"> <b>".ucfirst($type)." Rules</b> </td>", "\n";
# $out=$out."</tr><tr>\n";
$out=$out."<table border=\"1\" $cb cellspacing=\"0\" cellpadding=\"2\" width=100\%><tr>";

foreach my $val (@{$order_ref}){	# table heading
	$out=$out."<td> <b>";
	if ($val eq "context"){	# special treatment for context
		$out=$out."block/pass";
	} else {
		$out=$out.$val;	# rest is straight forward
	}
	$out=$out."</b> </td>\n";
}
# I don't think it is nessesary to translate the words in @{$order_ref}
$out=$out. "<td> <b>$text{'edit-actions'}</b> </td>", "\n";
$out=$out."</tr>", "\n";
# how many rules to handle? we have to know what the first rule is and what the last.
# for client rules it will be rule 0 to ...
# for socks rules it will be ... to last
# first and last rule is easy to get:
# first is 0, last is scalar(@{$rulesref})-1

my $last=scalar(@{$rulesref})-1;

foreach my $val (@{$rulesref}){
	if(${$val}{'context'} =~ /^client/){
		$last_client++;
	}
}

foreach my $val (@{$rulesref}){

	$count++; # which rule is current? (numbering from first client to last socks)

	if($type eq "client" and $count > $last_client){	# for client rules
		next;
	} elsif ($type eq "socks" and $count <= $last_client){	# for socks rules
		next;
	}

	$out=$out."<tr>\n";
	foreach my $key (@{$order_ref}){	# hier werden die zeilen gefüllt
		if($key eq "user" and ${$val}{$key} ne ""){	# we dont want to show every user
								# in this list so we show the number
								# of users (not 0)
			my $how_many=split(/\s+/,${$val}{$key});
			$out=$out."<td align=\"center\">$how_many</td>\n";
		} else {
			$out=$out."<td>${$val}{$key}</td>\n";
		}
	}
	$out=$out."<td>\n";

	my $comefrom="";	# to set the comfrom cgi-value correct

	if($type eq "client"){
		$comefrom="client_rules.cgi";
	}elsif($type eq "socks"){
		$comefrom="rules.cgi";
	}
	# display Icons for actions
	$out=$out."<a href=\"edit_rules.cgi?rule=$count&method=edit&comefrom=$comefrom\"><img src=\"images/echain.edit.gif\" alt=\"$text{'editing_rule'}\"></a>\n";
	$out=$out."<a href=\"delete_rules.cgi?rule=$count&comefrom=$comefrom\"><img src=\"images/echain.delete.gif\" alt=\"$text{'delete_rule'}\"></a>\n";
	$out=$out."<a href=\"clone_rules.cgi?rule=$count&comefrom=$comefrom\"><img src=\"images/echain.clone.gif\" alt=\"$text{'clone_rule'}\"></a>\n";
	$out=$out."<a href=\"edit_rules.cgi?rule=$count&method=insert&comefrom=$comefrom\"><img src=\"images/echain.insert.gif\" alt=\"$text{'insert_rule'}\"></a>\n";
	if($count !=0 and $count != $last_client+1){	# you can not make the first rule "more first"
		$out=$out."<a href=\"move_rules.cgi?rule=$count&method=up&comefrom=$comefrom\"><img src=\"images/echain.up.gif\" alt=\"$text{'up_rule'}\"></a>\n";
	}
	if($count != $last_client and $count != $last){	# you can not make the last rule more last
		$out=$out."<a href=\"move_rules.cgi?rule=$count&method=down&comefrom=$comefrom\"><img src=\"images/echain.down.gif\" alt=\"$text{'down_rule'}\"></a>\n";
	}
	$out=$out."</td>\n";
	$out=$out."</tr>\n";
}

$out=$out."</table> ", "\n\n";

return [$out,$last_client,$last];

}

# this routine is to create tables for settings and edit_rules
# values for this routine are:
# $number for number of field rows (default 2)
# a field is always a descriptive text and a form tag beside it
# $field is an arrayref with array refs with three values
# descriptiv text, name of the helpfile (without .lang.html)
# and formtag.

sub field_display {
	my ($field,$number)=@_;	# number is optional so put it to the end

	$number=2 if !defined($number);
	my $out="";	# return value
	my $count=1;	# to count columns
	$out=$out."<table width=100\% $cb>\n";

	foreach my $val (@{$field}){
		if($count==1){
			$out=$out."<tr>\n";
		}

		$out=$out."<td>".hlink(${$val}[0],${$val}[1])."</td>\n<td>".${$val}[2]."</td>\n";
		# descriptiv text, name of helpfile, formtag
		if($count==$number){
			$count=1;
			$out=$out."</tr>\n";
		} else {
			$count++;
		}
	}

	$out=$out."</table>";

	return $out;

}

# this routine should compare to lists (a,b) and return a reference
# to a list with elemets from a not in b
# it is perl cookbook recipe 4.7

sub not_in_array {
my ($a_ref,$b_ref)=@_;

my %seen=();
my @aonly=();

# create lookup table

foreach my $val (@{$b_ref}){
	$seen{$val}=1;
}

foreach my $val (@{$a_ref}){
	unless ($seen{$val}){
		# not in %seen so put it to aonly
		push(@aonly,$val);
	}
}

return \@aonly;
}


# this routine will take three arguments,
# size, name, arrayref for selected items
# an arrayref for items and multiple
# size contains the size value of the
# selecttag, name contains the name value
# and if multiple is defined, the selecttag will
# be a mulitple choice tag

sub mk_select {

	my ($size,$name,$selected_ref,$items_ref,$multiple)=@_;

	my $out="";	# returnvalue
	$out=$out."<select name=\"$name\" size=$size ";
	if (defined($multiple)){
		$out=$out."multiple";
	}
	$out=$out.">\n";
	foreach my $val (@{$items_ref}){
		$out=$out."\t<option value=\"$val\"  ";
		#foreach my $hill (@
		if(grep(index($val,$_)!=-1,@{$selected_ref})){	# check if $val is a substring in selected_ref
								# (because of the difference of "client pass" and "pass")!
			$out=$out."selected";
		}
		$out=$out.">$val</option>\n";
	}

	return $out;
}

sub parse_conf {
########################################
# diese routine zerlegt den inhalt des übergebenen konfigurations arrays in
# einen hash settings, dessen key das kommando und dessen wert die argumenten des kommandos sind.
# Und sie zerlegt die rules in einen array (in der reiehenfolge der rules)
# mit einer hashreferenz mit den settings dieser rule als key,
# und den argumenten als value und einem key context mit dem
# regelcontext als value (client pass, pass, block, ...)
# die reihenfolge in dem hash ist egal, da es eine von der
# configfile ändern routine fest vorgegebene reihenfolge gibt

	my ($confref)=@_;

	my %settings=();
	my @rules=();
	my $context="global";;
	my $left="";
	my $right="";
	my $rule="";	# referenz auf einen anonymen hash


	foreach my $element (@{$confref}){
		# zunächst mal schauen ob sich der context ändert
		if($element =~ /^(.*)?\{/){
			$context=$1;
			$rule={'context' => $context};	# hier wird ein anonymer hash erzeugt
							# weil nur dieser für jede regel neu erzeugt wird.
							# ein "echter" hash hat immer die gleiche referenz
							# womit nur die letzte regel gemerkt werden kann
		} elsif ($element =~ /\}/){
			$context="global";
			push(@rules,$rule);
		} elsif($context eq "global"){
			# hier werden die serversettings zerlegt
			($left,$right)=split(/:/,$element);
			$right =~ /^\s+(.*?)\s*$/;
			$settings{$left}=$1;
		} else {
			($left,$right)=split(/:/,$element);
			$right =~ /^\s+(.*?)\s*$/;
			${$rule}{$left}=$1;
			# $out=$out."<b>$context</b>: $left = $right<br> \n";
		}
	}

	return [\%settings,\@rules];
}



sub get_clean_conf {
########################################
# Diese routine extrahiert die wichtigen informationen und formatiert
# die angaben, auf das sie von anderen routinen besser lesbar werden
# zumbeispiel bekommt die { klammer ein eigenes feld, und hinter
# der { klamm kommt nichts zu stehen (davor ist der context)
# ich hab mich bemüht, das idiotensicher zu machen, und eine relativ freie
# formatierung zuzulassen. Ich hab allerdings nicht alles getestet.
# wer auf nummer sicher gehen will, formatiert sein konfigurationsfile
# wie die beispiele es zeigen
my ($conffile) = @_;	# the location of configfile

my @conffile=();	# array mit den wichtigen zeilen

my $left="";
my $right="";
my $incr="";
my $count="";	# zerlegungsvariablen

open(CONF,"<$conffile") or return ["error", "nopen_conffile",""];	# nopen_conffile is a %text key
									# for the errormessage

while(<CONF>){
	if($_ =~ /^#/ or $_ =~ /^\s+$/ or $_ =~ /^\s+#/ ){ 	# das sind alles komentare und leerzeilen
								# wie ist daws aber mit den auskomentierten rules?
								# wie werden wir die behandeln? möglichkeit:
								# and $_ !~ /[\{|\}]/ hab ich aber erstmal wieder verworfen
		next;
	} elsif($_ =~ /#/){
		$_ =~ s/#.*$//g;	# komentarzeilen abschneiden (die eventuell hinten
					# dran sitzen
	}
	if($_ =~ /\{/) {	# es geht hier darum, das hinter den klammern nichts steht,
				# und nur vor der { klammer etwas steht (der rule kontext)
		($left,$right)=split(/\{/,$_);
		if($left !~ /\}/){
			push(@conffile,$left."{");
		} else {
			my $right="";	# das original right wird noch gebraucht
			($left,$right)=split(/\}/,$left);
			if($left !~ /^\s*$/){
				push(@conffile,$left,"}",$right."{"); # ist left leer?
			} else {
				push(@conffile,"}",$right."{");
			}
		}
		if($right =~ /\}/){
			($left,$right)=split(/\}/,$right);
			# wenn im neu entstandene right gar nichts drin ist, solls auch nicht
			# ins array
			if($right =~ /^\s*$/){
				push(@conffile,$left,"}");
			} else {
				push(@conffile,$left,"}",$right);
			}
		} else {
			# wenn im right gar nichts drin ist, solls auch nicht
			# ins array
			if($right !~ /^\s*$/){
				push(@conffile,$right);
			}
		}
	} elsif($_ =~ /\}/) {
		($left,$right)=split(/\}/,$_);
		# wenn im right gar nichts drin ist, solls auch nicht
		# ins array, genauso für left natürlich (} steht meistens allein
		if($right !~ /^\s*$/ and $left !~ /^\s*$/){
			push(@conffile,$left,"}",$right);
		} elsif($left !~ /^\s*$/) {
			push(@conffile,$left,"}");
		} else {
			push(@conffile,"}");
		}
	} else {
		# eine bemerkung: from: to: steht meist hintereinander, diese werden ebenfalls
		# untereinander in das array gepackt, und ausserdem wird ihre reihenfolge vertauscht
		# das ist aber nicht so erheblich, da die reihenfolge von der interface bildenden
		# routine und von der abspeichern routine gekannt wird
		$incr=$_;
		while($incr !~ /^\s*$/){	# schleife durchlaufen bis nichts mehr vom string übrig ist
			$count=rindex($incr,":");	# position des letzten :
			$right=substr($incr,$count+1,length($incr)-$count-1,"");
			# (string, position nach dem : , wieviele zeichen gehts ab da bis zum ende?, ersetzen mit nix
			$incr=~ /([A-Za-z_\.0-9]*\:)$/;	# eine ansammlung von buchstaben und Punkten endend mit :
			$count=rindex($incr,$1);	# wo beginnt der settingsname?
			$left=substr($incr,$count,length($incr)-$count,"");
			push(@conffile,$left." ".$right);
		}
	}
}

close(CONF);

chomp(@conffile); # kein newline mehr

return \@conffile;
}

sub save_settings {
# diese subroutine soll settings abspeichern, und zwar an den stellen, an denen Sie erwartet werden.
# das heist, wenn ein setting nicht komentiert ist, aber aktiviert werden soll, dann muß das genau an der
# Stelle geschehen. wenn dasselbe
# umgekehrt passieren soll, so wird hier nicht gelöscht, sondern auskomnentiert.
# in dem klassischen beispiel für ein konfigurationsscript für sockd tauchen viele settings mehrmals auf.
# eine regel das richtige zu finden ist das letzte was auftaucht zu verwenden.
# Das bedeutet, das wir für jedes element die überreichte liste (die Zeilen) einmal durchgehen müssen.
# Was aber, wenn in dem Text gar kein solches Setting ist?
# dann wird eben ein auskomentiertes eingefügt. an der richtigen stelle
# am besten wird es sein, wenn wir uns das script blockweise reinziehen. Also die letzte Zeile eine blockes ist
# das letzte vorkommen eines schlüsselwortes.
# natürlich ist dieses konzept anfällig. Es wird höchst kompliziert, wenn komentare das schlüsselwort auch nach dem
# ein neues schlüsselwort auftauchte sehen. (zb der hinweis "siehe auch dingens: bums")

# ich mache jetzt einfach mal die einschränkung, es gibt nur das was ich kenne und sonst nichts.
# also erzeuge ich mir einen array mit der reihenfolge des auftretens
# The configfile is divided into two parts; first serversettings,
# then the rules.
#
# The recommended order is:
#   Serversettings:
#               logoutput
#               internal
#               external
#               method
#               clientmethod
#               users
#               compatibility
#               external.rotation
#               connecttimeout
#               iotimeout
#		srchost
#

my $count=-1;	# counter für die zeilennummer in der das element zuletzt auftaucht
my $flag=0,	# damit wir nicht in den rules rumrühren
my $previous=0;	# da wird die vorhergehende zeile drin gemerkt.
my @order=(	"logoutput","internal","external","method","clientmethod","user.privileged",
		"user.notprivileged","user.libwrap","compatibility","external.rotation",
		"connecttimeout","iotimeout","srchost");

my ($new_settings,$conf_array)=@_;

my %line_number=();

foreach my $key (@order){
	foreach	my $val (@{$conf_array}){
		$count++;
		# jetzt folgt die überprüfumg, ist das der eintrag oder nicht
		# das erkennt man daran, das vor dem eintrag nur nichts, leerzeichen oder
		# komentarzeichen stehen.
		my $test=index(${$conf_array}[$count], $key.":");
		if (${$conf_array}[$count] =~ /\{/){
			$flag=1;
			next;
		} elsif (${$conf_array}[$count] =~ /\}/){
			$flag=0;
			next;
		}

		if($test==-1){
			# nichts vorhanden
		} elsif ($test==0 and $flag==0){
			$line_number{$key}=$count;
			$previous=$count;
		} elsif (substr(${$conf_array}[$count],0,$test-1) =~ /^[\s#]*$/ and $flag==0){
			$line_number{$key}=$count;
			$previous=$count;
		}
	}

	$count=-1;$flag=0;

	# jetzt gibt es mehrere Möglichkeiten.Das element $line_number{$key} existiert nicht,
	# dann muß nach dem letzten vorkommen die entsprechende Zeile eingefügt werden.

	if(!defined($line_number{$key}) and ${$new_settings}{$key} ne ""){	# diesen eintrag gabs nicht im conffile und
										# der neue eintrag ist nicht leer
		splice(@{$conf_array},$previous,0,("",$key.": ".${$new_settings}{$key},""));
	} elsif (!defined($line_number{$key}) and ${$new_settings}{$key} eq ""){
		splice(@{$conf_array},$previous,0,("","# ".$key.": ",""));
	} elsif (defined($line_number{$key}) and ${$new_settings}{$key} ne ""){
		splice(@{$conf_array},$line_number{$key},1,($key.": ".${$new_settings}{$key}));
	} elsif (defined($line_number{$key}) and ${$new_settings}{$key} eq "" and ${$conf_array}[$line_number{$key}] !~ /^\s*#/){
		splice(@{$conf_array},$line_number{$key},1,("# ".${$conf_array}[$line_number{$key}]));
	}
}


}

sub user_list{
# This routine returns a list of usernames known to the System
# (used in case of method "username", not pam or rfc
my ($method)=@_;

# in the future, there may be code for other methods then username
if($method ne "username"){
	return;
}

my @user=();

while(my ($user) = getpwent()){
	push(@user,$user);
}


return \@user;

}

sub cleanup_settings{
# diese routine soll das was via cgi reinkommt bereinigen
# also zumbeispiel \0 durch " " ersetzen, oder
# die user_bla schlüssel durch user.bla ersetzen

# for better capsulating:

my ($in_ref)=@_;

my %in=%{$in_ref};

my %settings=();

foreach my $key (keys %in){
	if ($key eq "user_privileged"){
		$settings{'user.privileged'}=$in{$key};
	} elsif ($key eq "user_notprivileged"){
		$settings{'user.notprivileged'}=$in{$key};
	} elsif ($key eq "user_libwrap"){
		$settings{'user.libwrap'}=$in{$key};
	#} elsif ($key eq "srchost"){
	#	$in{$key} =~ s/\0/ /g;
	#	$settings{$key}=$in{$key};
	#	if($settings{$key} !~ /nomismatch/ and $settings{$key} !~ /nounknown/){
	#		$settings{$key}="";
	#	}
	#} elsif ($key eq "user"){
	#	$in{$key} =~ s/\0/ /g;
	#	$settings{$key}=$in{$key};
	} elsif ($key eq "comefrom" or $key eq "rule" or $key eq "edit_method"){	# nicht zur socks configuration gehörige variablen
		next;
	} else {
		$in{$key} =~ s/\0/ /g;
		$settings{$key}=$in{$key};
	}
}

return \%settings;
}

sub common_rules {
# diese routine bekommt die referenz auf das conffilearray
# und arbeitet damit
# action ist, was die routine damit machen soll
# rule_nr ist, was mit in{'rule'} übergeben wird

my ($lines_ref,$action,$rule_nr,$rule_array)=@_;

my $rulecount=-1;
my $count=-1;	# zählt die regeln
my $curr_rule=0;
my $end_rule=0;

my @dup=();	# dort kommt die zu dublizierende rule rein

foreach my $val (@{$lines_ref}) {	#
	$count++;

	if ($val =~ /\{/ and $val !~ /^\s*#/ and $val !~ /^\s*$/){
		$rulecount++;
		if($rulecount == $rule_nr){
			$curr_rule=$count;
		}
	}

	if($rulecount == $rule_nr){
		push(@dup,${$lines_ref}[$count]);
		$end_rule++;
	}
}

if($action eq "clone"){
	splice(@{$lines_ref},$curr_rule,0,@dup);
} elsif ($action eq "delete"){
	splice(@{$lines_ref},$curr_rule,$end_rule);
} elsif ($action eq "edit"){
	splice(@{$lines_ref},$curr_rule,$end_rule);
	splice(@{$lines_ref},$curr_rule,0,@{$rule_array});
} elsif ($action eq "insert"){
	splice(@{$lines_ref},$curr_rule+$end_rule,0,@{$rule_array});
}

return \@dup;

}

sub create_rule_array {
# hier soll aus dem übergebenen hash ein rulearray werden. es muß noch
# gewußt werden, ob es sich um client oder normal handelt $type "client" oder "rule"

my ($sett_ref,$type)=@_;

my @array=();	# da kommt nachher das array rein

my $from_to="";	# da kommt das zusammengesetzte kommando from to rein
# die reihenfolge:
#     block/pass
#		from to
#		method
# 		user
#		command*
#		libwrap
#		log
#		protocol*
#		proxyprotocol*
#		pam.servicename

# remove \0 fom multiple choyce fields:

foreach my $val (keys %{$sett_ref}){
	${$sett_ref}{$val} =~ s/\0/ /g;
}

my @rule_order=("context",
				"from",
				"to",
				"method",
				"user",
				"libwrap",
				"log",
				"pam.servicename",
				"command",
				"protocol",
				"proxyprotocol");

if(defined(${$sett_ref}{"context"})){

	if($type eq "client"){
		$type="client ";
	} else {
		$type="";
	}

	push(@array, $type.${$sett_ref}{"context"}." {");
	if(defined(${$sett_ref}{"from"})){
		$from_to="\t from: ".${$sett_ref}{"from"};
	}
	if(defined(${$sett_ref}{"to"})){
		$from_to=$from_to."\t to: ".${$sett_ref}{"to"}
	}



	push(@array, $from_to);
	push(@array, "\t method: ".${$sett_ref}{"method"}) if ${$sett_ref}{"method"} !~ /^\s*$/;
	push(@array, "\t user: ".${$sett_ref}{"user"}) if ${$sett_ref}{"user"}  !~ /^\s*$/;
	push(@array, "\t command: ".${$sett_ref}{"command"}) if ${$sett_ref}{"command"}  !~ /^\s*$/ and $type eq "";
	push(@array, "\t libwrap: ".${$sett_ref}{"libwrap"}) if ${$sett_ref}{"libwrap"}  !~ /^\s*$/;
	push(@array, "\t log: ".${$sett_ref}{"log"}) if ${$sett_ref}{"log"}  !~ /^\s*$/;
	push(@array, "\t protocol: ".${$sett_ref}{"protocol"}) if ${$sett_ref}{"protocol"}  !~ /^\s*$/ and $type eq "";
	push(@array, "\t proxyprotocol: ".${$sett_ref}{"proxyprotocol"}) if ${$sett_ref}{"proxyprotocol"}  !~ /^\s*$/ and $type eq "";
	push(@array, "\t pam.servicename: ".${$sett_ref}{"pam.servicename"}) if ${$sett_ref}{"pam.servicename"} !~ /^\s*$/;

	# and now the unknown values??

	foreach my $val (@{not_in_array([keys(%{$sett_ref})],\@rule_order)}){
		push(@array, "\t $val: ".${$sett_ref}{$val}) if ${$sett_ref}{$val}  !~ /^\s*$/;
	}

	push(@array, ("}",""));

}

return \@array;	# abgeben...

}

# this routine will start, stop the dante socks daemon
# and is capable of requesting a reload of dantes configfile.
# Additional it is capable of checking wether Dante is running
# it has to know where to find the pid file, the path to the socks daemon itself
# the commandline to start, the commandline to stop and what
# to do (start,stop,reload,check)
#

sub start_stop_reload {

my ($pid_file, $sockd_path, $start_cmd, $stop_cmd, $action)=@_;

&foreign_require("proc","proc-lib.pl");	# we need start stop routines from proc module

# does it exists on this OS?

if(!(&foreign_check("proc"))){
	return [128,"check for proc"];	# special error, proc-webminmodul is not available for this OS
}

my $doit=0;	# there will be several checks before we will execute
			# $start_cmd. the bits of doit will represent
			# wich of these tests fail (0)


# extract the name of the sockd-binary:
$sockd_path =~ /\/(\w+)$/;
my $sockd=$1;

my $pid=-1;	# container for the PID
############################
# start
if ($action eq "start"){
	# check if the command is bad
	my @cmd_line=split(/\s+/,$start_cmd);

	# the first element must be an executable
	if (!(-f $cmd_line[0] and -s $cmd_line[0] and -x $cmd_line[0])){
		$doit=$doit+1;
	}
	# the pidfile does not exist, or has zero bytes
	if(-s $pid_file and -f $pid_file){
	# if the pid_file exist and is not zero bytes
		open(PID,"<$pid_file") or
				die "Fatal error in start_stop_reload while starting. This should never happen?!?!\n";
		$pid=<PID>;
		close(PID);
		chomp($pid);
	# the pid pidfile exist but is no file 
	} elsif(!(-f $pid_file) and -e $pid_file){
		$doit=$doit+2;
	}
	
	# a pid exists, but the prozess is dead
	# for that we will use a function from proc module
	if($pid != -1){	# $pid is valid
		my ($pid_info_ref)=&foreign_call("proc","list_processes",$pid);
		# check if pid exists and is the socks daemon
		if(${$pid_info_ref}{'pid'} == $pid and index(${$pid_info_ref}{'args'},$sockd) != -1){
			$doit=$doit+4;
		}
	}

	#print "<p>",$cmd_line[0],"</p>\n";	# debug
	# now do the startcommand, if $doit is 0
	if($doit ==0){
		if(system($start_cmd)==0){
			return [$doit,"start"];
		} else {
			return [$doit,$?];
		}
	} else {
		return [$doit,"start"];
	}

###########################
# stop
} elsif ($action eq "stop"){
	# check if the command is bad
	my @cmd_line=split(/\s+/,$stop_cmd);

	# the first element must be an executable
	if (!(-f $cmd_line[0] and -s $cmd_line[0] and -x $cmd_line[0])){
		$doit=$doit+1;
	}
	# the pidfile does exist, and hasn't zero bytes
	if(-s $pid_file and -f $pid_file){
	# if the pid_file exist and is not zero bytes
		open(PID,"<$pid_file") or
				die "Fatal error in start_stop_reload while stoping. This should never happen?!?!\n";
		$pid=<PID>;
		close(PID);
		chomp($pid);
	} else {
		$doit=$doit+2;
	}
	# a pid exists, but the prozess is dead
	# for that we will use a function from proc module
	if($pid != -1){	# $pid is valid
		my ($pid_info_ref)=&foreign_call("proc","list_processes",$pid);
		# check if pid not exists or is not the socks daemon
		if(${$pid_info_ref}{'pid'} != $pid or index(${$pid_info_ref}{'args'},$sockd) == -1){
			$doit=$doit+4;
		}
	}

	# now do the stopcommand, if $doit is 0
	if($doit ==0){
		if(system($stop_cmd)==0){
			return [$doit,"stop"];
		} else {
			return [$doit,$?];
		}
	# if $stop_cmd is not defined we will get
	# a doit of 1. Then we will do stopping with the pid
	} elsif ($cmd_line[0] eq "" and $doit == 1){
		if(kill("TERM",$pid)){
			return [$doit+8,"stop"];
		} else{
			return [$doit,"stop"];
		}
	} else {
		return [$doit,"stop"];
	}
##################################
# reload
} elsif ($action eq "reload"){

	# the pidfile does exist, and hasn't zero bytes
	if(-s $pid_file and -f $pid_file){
		open(PID,"<$pid_file") or
				die "Fatal error in start_stop_reload while stoping. This should never happen?!?!\n";
		$pid=<PID>;
		close(PID);
		chomp($pid);
	} else {
 		$doit=$doit+2;
	}
	# a pid exists, but the prozess is dead?
	# for that we will use a function from proc module
	if($pid != -1){	# $pid is valid
		my ($pid_info_ref)=&foreign_call("proc","list_processes",$pid);
		# check if pid not exists or is not the socks daemon
		if(${$pid_info_ref}{'pid'} != $pid or index(${$pid_info_ref}{'args'},$sockd) == -1){
			$doit=$doit+4;
		}
	}

	#print "<p>",$doit,"</p>\n";	# debug

	# now do the kill -HUP, if $doit is 0
	if ($doit == 0){
		if(!(kill("HUP",$pid))){
			#print "<p>",$doit,"</p>\n";	# debug
			return [$doit+8,"reload"];
		} else{
			return [$doit,"reload"];
		}
	} else {
		return [$doit,"reload"];
	}
##################################
# check
# if dante is running, check returns 0
} elsif ($action eq "check"){

	# the pidfile does exist, and hasn't zero bytes
	if(-s $pid_file and -f $pid_file){
		open(PID,"<$pid_file") or
				die "Fatal error in start_stop_reload while stoping. This should never happen?!?!\n";
		$pid=<PID>;
		close(PID);
		chomp($pid);
	} else {
 		$doit=$doit+2;
	}
	# a pid exists, but the prozess is dead?
	# for that we will use a function from proc module
	if($pid != -1){	# $pid is valid
		my ($pid_info_ref)=&foreign_call("proc","list_processes",$pid);
		# check if pid not exists or is not the socks daemon
		if(${$pid_info_ref}{'pid'} != $pid or index(${$pid_info_ref}{'args'},$sockd) == -1){
			$doit=$doit+4;
		}
	}

	#print "<p>",$doit,"</p>\n";	# debug

	return [$doit,"check"];
}

return [64,"error"];

}
