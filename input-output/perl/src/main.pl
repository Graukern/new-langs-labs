use strict;
use warnings;

my ($path, $level) = @ARGV;

if (!defined $path || !defined $level) {
    die "Использование: perl src/main.pl ФАЙЛ УРОВЕНЬ\n";
}

open my $file, '<', $path or die "Не удалось открыть $path: $!\n";

my $matches = 0;
while (my $line = <$file>) {
    if ($line =~ /\b\Q$level\E\b/) {
        print $line;
        $matches++;
    }
}

close $file or die "Не удалось закрыть $path: $!\n";
print "Совпадений: $matches\n";
