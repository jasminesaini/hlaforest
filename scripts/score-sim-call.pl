#!/usr/bin/env perl
#
# Given a simulated chosen haplotype file
# and the haplotypes.txt file generated by the pipeline,
# score the accuracy of the simulation
#

use warnings;
use strict;
use Getopt::Long;

my ($true_file, $predicted_file);

GetOptions('t|true=s'=>\$true_file, 'p|predicted=s'=>\$predicted_file);

my %true_haplotypes;
my @predicted_haplotypes;


# Read in true file
open (my $true_fh, "<", $true_file);
while (<$true_fh>) {
    chomp($_);
    my ($imgt_id, $haplotype, $length, $bp) = split /_/, $_;
    $true_haplotypes{$haplotype} = $_;
}
close ($true_fh);

# Create a hash of all reference


# Read in the predicted haplotypes
open (my $predicted_fh, "<", $predicted_file);
while (<$predicted_fh>) {
    chomp ($_);
    $_ =~ s/ROOT://g;
    my (@predictions) = split "[\t ]", $_;
    push (@predicted_haplotypes, \@predictions);
}
close ($predicted_fh);


# For each of the true haplotypes
# report the maximally scoring called haplotype
foreach my $true_haplotype (sort keys %true_haplotypes) {
    my ($call, $max_score) = max_score($true_haplotype, \@predicted_haplotypes);
    my @true_split = split /[\*:]/, $true_haplotype;
    print join "\t", $true_haplotype, $call, scalar(@true_split),$max_score;
    print "\n";

}

exit(0);


sub score {
    my $true_haplotype = shift;
    my $prediction_ptr = shift;
    my @prediction = @$prediction_ptr;
    my @haplotype = split /[\*:]/, $true_haplotype;
    my $score = 0;

    for (my $i = 0; $i <= $#haplotype; $i++) {
        my $predicted_haplotype = $prediction[$i];
        my @predicted_split = split /:/, $predicted_haplotype;
        my $last_tier = pop @predicted_split;

        if ($haplotype[$i] eq $last_tier) {
#            print $haplotype[$i] . "\t" . $prediction[$i] . "\n";
        }
        else {
            last;
        }
        $score++;

    }

    return $score;
}
sub max_score {
    my $true_haplotype = shift;
    my $predicted_haplotypes_ptr = shift;
    my @predicted_haplotypes = @$predicted_haplotypes_ptr;
    my %scores;
    foreach my $prediction_ptr(@predicted_haplotypes) {
#        my $max_score = score($true_haplotype, $prediction_ptr);
        $scores{join "\t", @$prediction_ptr} = score($true_haplotype, $prediction_ptr);
    }
    my @sorted_keys = sort {$scores{$b} <=> $scores{$a}}keys %scores;
    return ($sorted_keys[0],$scores{$sorted_keys[0]});
}
