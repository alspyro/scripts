#!/usr/bin/env perl
use File::Find;
#
#
# Determines the number of files matching the regex in
# the directories specified in Parallon_Num_Files.csv
#
#
# Raymond A. Meijer
# Parallon Systems
#
# Version 1.00, 17-06-2010, initial version
# Version 1.10, 21-06-2010, added name for message keys
# Version 1.11, 02-07-2010, updated shebang
# Version 1.12, 13-07-2010, removed debugging

my $cfg_file="/cdr/mz/system/scripts/Monitoring/HPOVO/CFG/Monitor_cos_AXE_filter_num_of_files.csv";
my $ctl_file="/cdr/mz/system/scripts/Monitoring/HPOVO/CTL/Cosmote_MZ_AXE_filtered_Num_File.pl.ctl";
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

my $log_file="/cdr/mz/system/scripts/Monitoring/HPOVO/LOG/OVO_log_trace_$current_date.log";

my %directory_state;
my %checked_process;

my $msg="The number of files in directory";

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
print $append "MZ Directory number of filtered AXE files started($hostname): $timestamp \n";
close $append;

sub read_state()
{
        if (open STATE_FILE, "<$ctl_file")
        {
                while (<STATE_FILE>)
                {
                        chomp;
                        my ($directory,$value,$threshold,$state)=split /,/;
                        $directory_state{$directory}=$state;
                }
                close STATE_FILE;
        }
}

sub header()
{
        if (open STATE_FILE, ">$ctl_file")
        {
                                                                open my $append, '>>', $ctl_file  or die "error trying to create new file: $!";
                                                                print $append "MZ Directory number of filtered AXE files started($hostname): $timestamp \n";
                                                                close $append;
                close STATE_FILE;
        }
}

sub may_send_opcmsg($$$$$$$$$)
{
        my ($app,$directory,$regex,$value,$threshold,$severity,$state,$msg_group,$service_id)=@_;
        if ((defined $state && $state ne $severity) || ! defined $state || ( $severity ne "normal" ))
        {
                                                                #$per=sprintf("%.2f", 100*$value/$threshold);
                                                                $per=100;
                                                                print "Path:$directory,Files:$value,Threshold:$threshold($per%),New_Status:$severity,Old_Status:$state\n";
                                                                open my $append, '>>', $ctl_file  or die "error trying to create new file: $!";
                                                                print $append "$directory,$value,$threshold,$severity,$state\n";
                                                                close $append;
                if ($msg_group ne "")
                {
                 qx{$opcmsg severity=$severity application=$app object="Num_Files" msg_text="$msg $directory matching subdir FSC_FAILED  is $value [threshold=$threshold]" msg_grp=$msg_group service_id=$service_id -option name="$directory"};
                }
                $directory_state{$directory}=$severity;
        }
                                else {
                                                                #$per=sprintf("%.2f", 100*$value/$threshold);
                                                                $per=0;
                                                                print "Path:$directory,Files:$value,Threshold:$threshold($per%),New_Status:$severity,Old_Status:$state\n";
                                                                open my $append, '>>', $ctl_file  or die "error trying to create new file: $!";
                                                                print $append "$directory,$value,$threshold,$severity,$state\n";
                                                                close $append;
        }
}

read_state;

header;

open CFG_FILE, "<$cfg_file" or die "Unable to open '$cfg_file' for input: $!\n";
        while (<CFG_FILE>)
        {
                chomp;
                s/"//g;
                my ($host,$app,$directory,$regex,$critical,$major,$minor,$warning,$msg_group,$service_id)=split /[,;]/;
                #print "$directory - $regex - $critical\n";
                if ($hostname =~ /^$host$/)
                {
                        if (! -d $directory)
                        {
                                qx{$opcmsg severity=warning application=$app msg_grp=$msg_group object=Num_Files msg_text="Directory $directory doesn't exist"};

                        }
                        #opendir DIR, $directory or die "Couldn't open directory $directory for reading: $!!\n";
                        #        my @files = grep { /$regex/ and -f "$directory/$_" } readdir DIR;
                        #close DIR;
                        #$value=0;
                        my @files=find(\&Wanted, glob ($directory));
                         sub Wanted
                         {
                           #print "$File::Find::dir - $_\n";
                           #if ( /$regex/ and $File::Find::dir =~ /FSC_FAILED/) {
                           if ( $File::Find::dir =~ /FSC_FAILED/) {
                              $value++;
                                 #print "iin : $_\n";
                           }
                        }
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
print $append "MZ Directory number of filtered AXE files completed($hostname): $timestamp (Number of directories:$count,Critical:$cri,Major:$maj,Minor:$min,Warning:$war,Normal:$nor)\n";
close $append;

open my $append, '>>', $ctl_file  or die "error trying to create new file: $!";
print $append "MZ Directory number of filtered AXE files completed($hostname): $timestamp (Number of directories:$count,Critical:$cri,Major:$maj,Minor:$min,Warning:$war,Normal:$nor)\n";
close $append;
exit 0;
