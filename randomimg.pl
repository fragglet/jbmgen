

my @files = qw(gmini120.png gmini220.png gmini220_headphones.png);

my $file = $files[int(rand(3))];

print "<img src=\"$file\" border=\"0\" align=\"right\">";

