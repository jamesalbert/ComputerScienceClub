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

    my ( @queries, $not_queried );

    foreach my $var ( keys %opts ) {
        if ( $opts{$var} ne '' ) {
            push @queries, $opts{$var};
        }
        else {
            $not_queried = $var;
        }
    }

    push @queries, $not_queried;

    return @queries;
}

1;
