#!/usr/bin/perl
use strict;

use URI;
use HTTP::Request;
use HTTP::Cookies;
use LWP::UserAgent;
use HTTP::Request::Common;
use LWP::Authen::Ntlm;
use JSON;

my $main_url = "http://tzwebportal/DynamicsAX/SitePages/tzinoutreg.aspx";

my $login_url = "http://tzwebportal/_layouts/15/TZInOutRegisterNew/TzInOutWebService.aspx";

my $in_out = ($ARGV[0] eq 'in')?1:0;
my $test_weekend_and_holidays = ($ARGV[1] eq 'all')?0:1;

sleep(int(rand(5 * 60)));

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year += 1900;
my @abbr = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
my @wdays = qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);

print "\n\nNow $mday $abbr[$mon] $year $wdays[$wday] ($wday): $hour:$min. " . (($in_out)?'Try to login.':'Try to logout.') . "\n";

my @holidays = ({'year' => 2015, 'mon' => 11, 'mday' => 31},
		{'year' => 2016, 'mon' => (1 - 1), 'mday' => 1},
		{'year' => 2016, 'mon' => (1 - 1), 'mday' => 2},
		{'year' => 2016, 'mon' => (1 - 1), 'mday' => 3},
		{'year' => 2016, 'mon' => (1 - 1), 'mday' => 4},
		{'year' => 2016, 'mon' => (1 - 1), 'mday' => 5},
		{'year' => 2016, 'mon' => (1 - 1), 'mday' => 6},
		{'year' => 2016, 'mon' => (1 - 1), 'mday' => 7},
		{'year' => 2016, 'mon' => (1 - 1), 'mday' => 8},
		{'year' => 2016, 'mon' => (1 - 1), 'mday' => 9},
		{'year' => 2016, 'mon' => (1 - 1), 'mday' => 10},
		{'year' => 2016, 'mon' => (2 - 1), 'mday' => 22},
		{'year' => 2016, 'mon' => (2 - 1), 'mday' => 23},
		{'year' => 2016, 'mon' => (3 - 1), 'mday' => 7},
		{'year' => 2016, 'mon' => (3 - 1), 'mday' => 8},
		{'year' => 2016, 'mon' => (5 - 1), 'mday' => 2},
		{'year' => 2016, 'mon' => (5 - 1), 'mday' => 3},
		{'year' => 2016, 'mon' => (5 - 1), 'mday' => 9},
		{'year' => 2016, 'mon' => (6 - 1), 'mday' => 13},
		{'year' => 2016, 'mon' => (11 - 1), 'mday' => 3},
		{'year' => 2016, 'mon' => (11 - 1), 'mday' => 4}
		);

if($test_weekend_and_holidays){
	if($wday == 6 || $wday == 0){die ("Weekend.\n")}
	for my $cur_day (@holidays){
		if($cur_day->{'year'} == $year && $cur_day->{'mon'} == $mon && $cur_day->{'mday'} == $mday)
			{die("Holidays.\n")}
	}
}

# Set up the ntlm client and then the base64 encoded ntlm handshake message
my $ua = LWP::UserAgent->new(keep_alive=>1);
$ua->credentials('tzwebportal:80', '', "tzmoscow\\s.harchenko", 'EhHh77562743');

$ua->agent("Mozilla/5.0 (Windows NT 5.1; rv:42.0) Gecko/20100101 Firefox/42.0");

my $request = GET $main_url;
print "--Performing request (main page )now...-----------\n";
my $response = $ua->request($request);
print "--Done with request (main page)-------------------\n";

if ($response->is_success)
{
	print "It worked!->" . $response->code . "\n";
	
	my $user_status;#0: not comeing; 1: in office; 2: go away.
	&read_user_status(\$user_status) or die("Failed to read user status.");
	print "\tUSER STATUS: $user_status.\n";

	$in_out?(&log_in or die("Failed to logIn")):
		(&log_out or die("Failed to logOut"));

	&read_user_status(\$user_status) or die("Failed to read user status.");
	print "\tUSER STATUS: $user_status.\n";

}else {print "It didn't work!->" . $response->code . "\n"}

#End of main script.

sub read_user_status{
	my $status_ref = shift;
	$$status_ref = undef;
	my $request = GET $login_url."?cmd=getuserstatus";#&_=1447143965904";
print "--Performing request (getuserstatus)now...-----------\n";
	my $response = $ua->request($request);
print "--Done with request (getuserstatus)-------------------\n";
	print "Response code : " . $response->code ."\n";
	if($response->is_success){
		print $response->content."\n";
		my $res_ref = decode_json($response->content);
		if($res_ref->{PROCESS}->{ERROR} eq '0'){$$status_ref = $res_ref->{PROCESS}->{STATUS}}
		else{
			print "Error: " . $res_ref->{PROCESS}->{ERRORTEXT}."\n";
		}
	}
	return $response->is_success;
}

sub log_in{
	log_in_out('btnComeIn');
}

sub log_out{
	log_in_out('btnGoOut');
}

sub log_in_out{
	my $btn = shift;
	return undef unless $btn;

	my $data = '{report:"", reporttype:""}';

	$request = POST $login_url."/$btn",
			Referer => $main_url,
			Content_Type => 'application/json; charset=UTF-8',
			Content => $data;
print "--Performing request ($btn) now...-----------\n";
	my $response = $ua->request($request);
print "--Done with request (getuserstatus)-------------------\n";
	print "Response code : " . $response->code ."\n";
	if($response->is_success){print $response->content."\n"}
	return $response->is_success;
}

