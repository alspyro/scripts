#!/usr/bin/env perl
use File::Find;

my $cfg_file="cfg.csv";
my $ctl_file="file.pl.ctl";
my $count = 0;
my $nor = 0;
my $war = 0;
my $min = 0;
my $maj = 0;
my $cri = 0;
our $value = 0;

my $timestamp = `date`; # Part of the new filename (Datime)
$timestamp = substr($timestamp,0,-1);

my $current_date = `date +"%Y%m%d"`;
$current_date = substr($current_date,0,-1);  # Part of the new filename (Date)

my $log_file="file.log";

my %directory_state;
my %checked_process;

my $msg="The nb of files in dir";

my $opcmsg="/opt/OV/bin/opcmsg";


if ($^O =~ /aix/)
{
        $opcmsg="/usr/lpp/OV/bin/opcmsg";
}
elsif ($^O =~ /dec_osf/)
{
        $opcmsg="/usr/opt/OV/bin/opcmsg";
}
elsif (! $^O =~ /hpux|solaris|linux/)
{
        exit 0;
}

chomp(my $hostname=qx{hostname});

open my $append, '>>', $log_file  or die "error trying to create new file: $!";
print $append "Directory number of filtered x files started($hostname): $timestamp \n";
close $append;

[...]

[...]
                           
                        #print "before: $value\n";
                        #$value = $#files;
                        print "$checked_process{$directory}\n";
                        print "$directory_state{$directory}\n";
                        if (! defined $checked_process{$directory})
                        {
                                $count++;
                                my $state=$directory_state{$directory};
                                                        if (!defined $state)
                                                        {
                                                $state=normal;
                                                    }
                                #print "Files: $value  \t ($major)    \t Status: $state  \t Directory: $directory \n";
                                if (defined $critical && $critical ne "" && $value >= $critical)
                                {
                                        may_send_opcmsg($app,$directory,$regex,$value,$critical,"critical",$state,$msg_group,$service_id);
                                        $cri++;
                                }
                                elsif (defined $major && $major ne "" && $value >= $major)
                                {
                                        may_send_opcmsg($app,$directory,$regex,$value,$major,"major",$state,$msg_group,$service_id);
                                        $maj++;
                                }
                                elsif (defined $minor && $minor ne "" && $value >= $minor)
                                {
                                        may_send_opcmsg($app,$directory,$regex,$value,$minor,"minor",$state,$msg_group,$service_id);
                                        $min++;
                                }
                                elsif (defined $warning && $warning ne "" && $value >= $warning)
                                {
                                        may_send_opcmsg($app,$directory,$regex,$value,$warning,"warning",$state,$msg_group,$service_id);
                                        $war++;
                                }
                                else
                                {
                                        may_send_opcmsg($app,$directory,$regex,$value,$major,"normal",$state,$msg_group,$service_id);
                                        $nor++;
                                }
                                $checked_process{$directory}=1
                        }
                }
        }
close CFG_FILE;

open my $append, '>>', $log_file  or die "error trying to create new file: $!";
print $append "Nb of filtered AXE files completed($hostname): $timestamp (Number of directories:$count,Critical:$cri,Major:$maj,Minor:$min,Warning:$war,Normal:$nor)\n";
close $append;

open my $append, '>>', $ctl_file  or die "error trying to create new file: $!";
print $append "Nb of filtered AXE files completed($hostname): $timestamp (Number of directories:$count,Critical:$cri,Major:$maj,Minor:$min,Warning:$war,Normal:$nor)\n";
close $append;
exit 0;


