use strict;
use warnings;
use utf8;
use open qw(:std :encoding(UTF-8));

@ARGV == 2 or die "Использование: perl src/main.pl ДО.txt ПОСЛЕ.txt\n";

sub read_stock {
    my ($path) = @_;
    open my $file, '<', $path or die "Не удалось открыть $path: $!\n";

    my %stock;
    my $line_number = 0;
    while (my $line = <$file>) {
        ++$line_number;
        my ($sku, $quantity) = $line =~ /\A\s*(\S+)\s+([0-9]+)\s*\z/;
        defined $quantity or die "$path, строка $line_number: ожидались артикул и количество\n";
        exists $stock{$sku} and die "$path, строка $line_number: повтор артикула $sku\n";
        $quantity =~ s/\A0+(?=[0-9])//;
        $stock{$sku} = $quantity;
    }
    close $file or die "Не удалось закрыть $path: $!\n";
    return \%stock;
}

sub print_group {
    my ($name, @entries) = @_;
    print "$name\n";
    print "  $_\n" for @entries;
}

my ($before, $after) = map { read_stock($_) } @ARGV;
my (@added, @removed, @changed);
for my $sku (sort keys %$after) {
    if (!exists $before->{$sku}) {
        push @added, "$sku — $after->{$sku}";
    } elsif ($before->{$sku} ne $after->{$sku}) {
        push @changed, "$sku — $before->{$sku} → $after->{$sku}";
    }
}
for my $sku (sort keys %$before) {
    push @removed, "$sku — $before->{$sku}" unless exists $after->{$sku};
}

print_group('Добавленные', @added);
print_group('Удалённые', @removed);
print_group('Изменившиеся', @changed);
