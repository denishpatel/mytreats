#!/usr/bin/perl
sub usage;

my $TIMEOUT = 15;
my $MYSQL = "/opt/mysql5/bin/mysql";

my %ERRORS = ('UNKNOWN' , '3',
              'OK' , '0',
              'CRITICAL', '2');

my $host = shift || &usage(%ERRORS);
my $user = shift || &usage(%ERRORS);
my $pass = shift || "";
my $DB = shift || "test";
my $TABLE = shift || "heartbeat";
my $ok = shift || 1;
my $crit = shift || 0;

my $state = "OK";
my $count = 2;
my $status = "";


$SIG{'ALRM'} = sub {
     print ("ERROR: No response from MySQL server (alarm)\n");
     exit $ERRORS{"UNKNOWN"};
};
alarm($TIMEOUT);
my $SQL = "select count(1) cnt from $TABLE where ts >   date_sub(now(), interval 20 minute);";
#print "SQL: $SQL\n";
open (OUTPUT, "$MYSQL -h $host -u $user --password=\"$pass\" $DB -e '$SQL' 2>&1 |");

while (<OUTPUT>) {
  if (/failed/) { $state="CRITICAL"; s/.*://; last; }
  chomp;
  $count = $_;
}

#print $count;
if ($count == $crit) { $state = "CRITICAL"; }
if ($count == $ok) { $state = "OK"; }

$status="Mysql Slave Hearbeat is $state";

print $status;
exit $ERRORS{$state};

sub usage {
   print "Required arguments not given!\n\n";
   print "Usage: check_mysql_count.pl <host> <user> [<pass> <db> <table> <cond> [<ok> [<crit>]]]\n\n";
   print "       <pass> = password with SELECT privilege to use for <user> at <host>\n";
   print "       <db> = DB where table is placed\n";
   print "       <table> = table in DB\n";
   print "       <ok> = number of rows to ok state\n";
   print "       <crit> = number of rows to critical state\n";
   exit $ERRORS{"UNKNOWN"};
}
