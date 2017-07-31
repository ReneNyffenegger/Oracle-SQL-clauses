package OracleSQLClause;
use warnings;
use strict;

use LWP::UserAgent;
use HTTP::Request;
use File::Slurp;

sub fetch_clause {

  my $clause = shift;

  my ($fetched) = glob ("fetched/*.$clause");

  if ($fetched) {

    print "Already fetched: $clause\n";

    return '' unless $fetched =~ /^fetched.200\./;

    my $html = read_file($fetched);
    return html_2_ebnf($html);

  }
  else {
  
    print "have to fetche: $clause\n";

    my $ua   = LWP::UserAgent->new or die;
    my $req  = HTTP::Request ->new(GET => "https://docs.oracle.com/database/122/SQLRF/img_text/$clause.htm") or die;
    my $resp = $ua->request($req);

    write_file("fetched/" . $resp->code . ".$clause", $resp->content);
  
    return '' unless $resp->code == 200;
  
    my $html = $resp->content;
    return html_2_ebnf($html);
  
  
  }

}

sub html_2_ebnf {
  my $html = shift;

  $html =~ s/^.*<pre[^>]*>\n//s;
  $html =~ s/\n<\/pre>.*//s;
  
  $html =~ s/<span class="bold">/'/g;
  $html =~ s/<\/span>/'/g;

  return $html;

}

1;
