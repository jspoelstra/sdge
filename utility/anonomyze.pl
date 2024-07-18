use strict;
use warnings;
use Text::CSV;
use File::Copy qw(move);

# Get the file name from a command-line argument
my $filename = $ARGV[0];
my $tempfile = 'temp.csv';

# Create a CSV parser object
my $csv = Text::CSV->new({ binary => 1, eol => $/ });

# Open the input and temp files
open my $in, '<', $filename or die "Cannot open '$filename': $!";
open my $out, '>', $tempfile or die "Cannot open '$tempfile': $!";

# Process the CSV file line by line
while (my $row = $csv->getline($in)) {
    # Redact fields based on keywords
    if (($row->[0] =~ /^Name|^Address|^Account Number|^Meter Number$/) && $row->[1] ne 'Date') {
        $row->[1] = 'REDACTED';  # Redact the value in the second column
    } elsif ($row->[0] =~ /^\d+$/ && @$row == 7 && $row->[1] =~ /^\d{1,2}\/\d{1,2}\/\d{4}$/) {
        $row->[0] = 'REDACTED';  # Redact meter number in data lines
    }
    $csv->print($out, $row);
}

# Close the files
close $in;
close $out;

# Move the temp file to replace the original file
move($tempfile, $filename) or die "Cannot move '$tempfile' to '$filename': $!";

print "File obfuscation complete.\n";
