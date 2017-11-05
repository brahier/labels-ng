#!/usr/bin/perl

use strict;
use Config::General;
use Cwd;
use Data::Dumper;
use Getopt::Long;
use POSIX;
use Template;
use Template::Filters;

sub latex_filter {
  my $text = shift;
  return $text;
}

my $state = {};
my $content;

my %default = (
  template => 'env.tpl',
  out      => 'out.pdf',
  add      => 3,
  classe   => 30,
  max      => 21,
  spare    => 0,
);

my %opt;
GetOptions (\%opt, qw(debug));

my $file_name = shift;
my %conf = Config::General::ParseConfig($file_name);

print Dumper(\%conf);

foreach (keys %default) {
  $conf{$_} = $default{$_} if not exists $conf{$_}
}

sub attr {
  my $k = shift;
  my $epr = shift;
  my $serie = shift;
  if (defined $serie) {
    return
      defined $conf{epr}->{$epr}->{serie}->{$serie}->{$k} ?
        $conf{epr}->{$epr}->{serie}->{$serie}->{$k} :
      defined $conf{epr}->{$epr}->{$k} ?
        $conf{epr}->{$epr}->{$k} :
      defined $conf{$k} ?
        $conf{$k} :
        undef;
  } elsif (defined $epr) {
    return
      exists $conf{epr}->{$epr}->{$k} ?
        $conf{epr}->{$epr}->{$k} :
      exists $conf{$k} ?
        $conf{$k} :
        undef;
  } else {
    return
      defined $conf{$k} ?
        $conf{$k} :
        undef;
  }
}

sub xsort {
  my ($a1, $a2) = $a =~ /^(\d+)(.*)/;
  my ($b1, $b2) = $b =~ /^(\d+)(.*)/;
   my $res = ($a1 <=> $b1);
   if ($res == 0) {
     $res = ($a2 cmp $b2)
   }
   return $res;
}

my @list;
foreach my $epr (sort xsort keys %{$conf{epr}}) {
  my $n = undef;
  print "EPR : $epr\n";
  if ($conf{epr}->{$epr}->{departs}) {
    my $classe = attr('classe', $epr);
    $n = POSIX::ceil($conf{epr}->{$epr}->{departs} * $classe / 100);
  } elsif ($conf{epr}->{$epr}->{n}) {
    $n = $conf{epr}->{$epr}->{n}
  }
  if ($n > 0) {
    my $max = attr('max', $epr);
    $n = $n + attr('add', $epr);
    $n = $max if $n > $max;
    for (my $i = 0; $i < ($conf{epr}->{$epr}->{repl} > 0 ? $conf{epr}->{$epr}->{repl} : 1); $i++) {
      push @list, {
        no => $epr,
        prix => attr("prix", $epr),
        cat => attr("cat", $epr),
        lieu => attr("lieu", $epr),
        note => attr("note", $epr),
        spare => attr("spare", $epr),
        max => $n,
      };
    }
  }
  if (defined $conf{epr}->{$epr}->{serie}) {
    foreach my $serie (sort {$a cmp $b} keys %{$conf{epr}->{$epr}->{serie}}) {
      my $n = undef;
      if ($conf{epr}->{$epr}->{serie}->{$serie}->{departs}) {
        my $classe = attr('classe', $epr);
        $n = POSIX::ceil(
          $conf{epr}->{$epr}->{serie}->{$serie}->{departs} * $classe / 100
        );
      } elsif ($conf{epr}->{$epr}->{serie}->{$serie}->{n}) {
        $n = $conf{epr}->{$epr}->{serie}->{$serie}->{n}
      }
      if ($n > 0) {
        my $max = attr('max', $epr);
        $n = $n + attr('add', $epr);
        $n = $max if $n > $max;
        my $xno;
        my $xcat;
        if (defined $conf{epr}->{$epr}->{poney}) {
            $xcat = attr("cat", $epr) . "/$serie";
            $xno = ${epr};
        } else {
            if ($serie =~ /\s*[a-zA-Z]/) {
                $xno = "${epr}${serie}";
            } else {
                $xno = "$epr/$serie";
            }
            $xcat = attr("cat", $epr),
        }
        push @list, {
          no => $xno,
          prix => attr("prix", $epr),
          cat => $xcat,
          lieu => attr("lieu", $epr),
          spare => attr("spare", $epr),
          note => attr("note", $epr),
          max => $n,
        };
      }
    }
  }
}

foreach (@list) {
  printf "%-8s %5s %-16s %s\n", $_->{no}, $_->{max}, $_->{cat}, $_->{prix};
}

my $var = {list => \@list};
print Dumper($var) if $opt{debug};

my $template = Template->new (
  RELATIVE=>1,
  ABSOLUTE=>1,
  FILTERS => {
    'latex' => \&latex_filter,
  }
);

$template->process(attr("template"), $var, "envel.$$.tex") or
  die $template->error();
my $cmd = "pdflatex -interaction batchmode envel.$$.tex";
my $res = `$cmd`;

$cmd = sprintf ("mv envel.%s.pdf %s", $$, attr("out"));
system ($cmd);
$cmd = sprintf ("rm envel.%s.*", $$);
system ($cmd);

