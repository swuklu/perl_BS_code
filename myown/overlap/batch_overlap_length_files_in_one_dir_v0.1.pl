#!/usr/bin/perl -w

#v0.1 
# put label at last col

#v0.0
# length overlap

use strict;
use File::Spec;


my $debug = 0;


#############################
my $p = 1;
if($debug){
	print STDERR "debug = $debug\n\n";
}

#my $script = "/Users/tang58/Weiqiang_idm1_1_Nature_paper/add_annotation_Kai_v1.7_TAIR10.pl";
#my $script  = "./overlap_bed_first_in_second.pl";
#die unless (-e $script);

my $usage = "$0 \n<indir> <output>\n\n";

die $usage unless (@ARGV == 2);
my $dir = shift or die $usage;
my $output = shift or die "output";
die if(-e $output);

die "wrong dir" unless (-d $dir );

opendir (DIR, $dir) or die "cannot open $dir: $!";

my @files = grep /\.txt$/, readdir DIR;

my @labels;
foreach my $i(0..$#files){
	my $file = $files[$i];
	if($file =~ /(\S+)\.txt$/){
		$labels[$i] = $1;
	}else{
		die $file;
	}
}

if ($debug){
	print STDERR join("\n", @files),"\n\n";
	print STDERR join("\n", @labels),"\n";
	
	exit;
}

my @nums;

for my $i(0.. ($#files)){
	for my $j ( 0..$#files){
		$nums[$i][$j] = "--";
	}
}

if(!$debug){
	open( OUT, ">>$output" ) or die;
}

for my $i(0.. ($#files)){
	for my $j ( 0..$#files){
		my $first = File::Spec->catfile($dir, $files[$i]);
		my $second = File::Spec->catfile($dir, $files[$j]);
		next if($first eq $second);
		if($p){
			print STDERR join("\t", ($i, $j)), "\n";
		}
		if(!$debug){
			#$nums[$i][$j] = overlap($first, $second);
			$nums[$i][$j] = length_overlap($first, $second);
		}
		else{
			print STDERR join("\t", ($first, $second)), "\n";
		}
	}
}

if(!$debug){
#	print OUT join("\t", ("label", @labels)), "\n";
#	print OUT join("\t", ("label", 1..scalar(@labels))), "\n";
	print OUT join("\t", (  1..scalar(@labels), "label" ) ), "\n";
	for my $i(0.. ($#files)){
#		print  OUT  $i+1 . "_" . $labels[$i], "\t";
		for my $j ( 0..$#files){
			print  OUT $nums[$i][$j];
			if($j != $#files){print  OUT "\t"}
			else{
			#	print  OUT  "\n";
				print OUT "\t",  $i+1 . "_" . $labels[$i],"\n";

			}
		}
	}
}

#print  OUT "\n";

exit;

sub length_overlap{
	my ($first, $second) = @_;
	open (IN1, $first)  or die "cannot open $first: $!";
	open (IN2, $second) or die "cannot open $second: $!";

	my %beds;
	my $num_f2 = 0;
	my $h = <IN2>;
	while (<IN2>){
		#$num_f2++;
		chomp;
		my @a = split /\t/ ;
		my $chr = lc $a[0];
		my $start = $a[1];
		my $end = $a[2];
		die $_ if($end <= $start);
		my $len = $end - $start + 1;
		$num_f2 += $len;
		for my $i ($start..$end){
			$beds{$chr}->[$i] = 1;
		}
	}
	
	my $num_f1 = 0;
	my $num_overlap = 0;
	$h = <IN1>;
	while (<IN1>){
		# $num_f1 ++;
		chomp;
		my @a = split /\t/ ;
		my $chr = lc $a[0];
		my $start = $a[1];
		my $end = $a[2];
		
		die $_ if($end <= $start);
		
		
				
		$num_f1 += ($end - $start + 1);
		

		for my $i ($start..$end){
			if(defined $beds{$chr}->[$i]){
				$num_overlap++;				
			}
		}
	}
	
	my $per = sprintf ("%.1f",100 * $num_overlap / $num_f1);
	return "$num_overlap/$num_f1 = $per" . "%";
}

=head
#sub overlap{
	my ($first, $second) = @_;
	open (IN1, $first)  or die "cannot open $first: $!";
	open (IN2, $second) or die "cannot open $second: $!";

	my %beds;
	my $num_f2 = 0;
	my $h = <IN2>;
	while (<IN2>){
#	next if (/Start/);
		$num_f2++;
		chomp;
		my @a = split /\t/ ;
		my $chr = lc $a[0];
		my $start = $a[1];
		my $end = $a[2];
	#	my $new_start = $start - $allowed_gap;
	
	#	my $new_start = $start;
	#	if($new_start <= 0 ){$new_start = 1}
	
		#for my $i ( $new_start..($end + $allowed_gap))
		for my $i ($start..$end){
			$beds{$chr}->[$i] = 1;
		}
	}

	my $num_f1 = 0;
	my $num_overlap = 0;
	$h = <IN1>;
	while (<IN1>){
		$num_f1 ++;
		chomp;
		my @a = split /\t/ ;
		my $chr = lc $a[0];
		my $start = $a[1];
		my $end = $a[2];
		my $flag = 0;
		for my $i ($start..$end){
			if(defined $beds{$chr}->[$i]){
				$flag = 1;
				last;
			}
		}
	
		if ($flag == 1){$num_overlap++}
	
	}
	my $per = sprintf ("%.1f",100 * $num_overlap / $num_f1);
	return "$num_overlap/$num_f1 = $per" . "%";
}
=cut