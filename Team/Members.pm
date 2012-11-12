package Team::Members;

#Written by James Albert <james.albert72@gmail.com>

use strict;
use warnings;
use DBI;

sub new {
    my ( $class, %opts ) = @_;
    my $self = {};
    return bless $self, $class;
}

sub create_new_member {
    my ( $self, %opts ) = @_;

    my $dbh = DBI->connect(
        'dbi:SQLite:dbname=teamdb'
    );

    my $sth = $dbh->prepare(
        "insert into team values (
            null,
            \"$opts{name}\",
            \"$opts{position}\",
            \"$opts{grade}\"
        );"
    );

    $sth->execute;
    $dbh->disconnect;

    return $self;
}

sub delete_member {
    my ( $self, $name ) = @_;

    my $dbh = DBI->connect(
        'dbi:SQLite:dbname=teamdb'
    );

    my $sth = $dbh->prepare(
        "delete from team where name=\"$name\";"
    );
}

sub get_member_list {
    my ( $self, %opts ) = @_;

    my @name_list;

    my $dbh = DBI->connect(
        'dbi:SQLite:dbname=teamdb'
    );

    if ( $opts{all} == 1 ) {

        my $profiles = $dbh->selectall_arrayref(
            "select name, position, grade from team;", { Slice => {} }
        );

        $dbh->disconnect;

        foreach my $data ( @$profiles ) {
            push @name_list, $data->{name} . '.';
            push @name_list, $data->{position} . '.';
            push @name_list, $data->{grade} . ',' ;
        }

        return @name_list;
    }
}

sub check_params {
    my ( $self, %opts ) = @_;

    my ( @queries, $not_queried, $missing_link, @keys );

    my $dbh = DBI->connect(
        'dbi:SQLite:dbname=teamdb'
    );

    foreach my $var ( keys %opts ) {
        push @keys, $var;

        if ( $opts{$var} ne '' ) {
            push @queries, $opts{$var};
        }
        else {
            $not_queried = $var;
        }
    }

    push @queries, $not_queried;

    print "$queries[0]\n$queries[1]\n$queries[2]\n";
    print "$keys[0]\n$keys[1]\n$keys[2]\n";

    my $puzzle = $dbh->selectall_arrayref(
        "select $queries[2] as data from team
            where $keys[2]=\"$queries[0]\"
            and $keys[1]=\"$queries[1]\";", { Slice => {} }
    );

    #NOT WORKING, DON'T USE

    foreach my $piece ( @$puzzle ) {
        $missing_link = $piece->{data};
    }

    return $missing_link;
}

sub upload_file {
    my ( $self, $file_name, $folder ) = @_;
    use File::Find;

    our $prefix = $folder;
    our $suffix = $file_name;
    our $result;

    find( \&wanted, $ENV{HOME} );

    sub wanted {
        if ( $_ eq $suffix ) {

            my @folders = split(/\//, $File::Find::dir);

            my $containing_folder = pop(@folders);

            $result = $File::Find::name if $containing_folder eq $prefix;
        }
    }
    return $result;
}

sub read_from_upload {
    my ( $self, $directory ) = @_;
    use File::Slurp qw/read_file/;

    my $code = read_file( $directory );

    return $code;
}

sub write_file_to_sql {
    my ( $self, $file_name, $file_contents ) = @_;

    my $dbh = DBI->connect(
        'dbi:SQLite:dbname=teamdb'
    );

    my $sth = $dbh->prepare(
        "insert into files values( null, \"$file_name\", \"$file_contents\" );"
    );

    $sth->execute;
    $dbh->disconnect;

    return 'success';
}

1;
