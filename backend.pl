#!/usr/bin/env perl

use strict;
use warnings;
use Mojolicious::Lite;

get '/home' => sub {
    my $self = shift;

    $self->render( 'home' );
};

get '/homejs' => sub {
    my $self = shift;

    $self->render( 'homejs' );
};

get '/team' => sub {
    my $self = shift;

    $self->render( 'team' );
};

get '/teamdb' => sub {
    use Team::Members;
    my $self     = shift;

    my $user     = Team::Members->new;
    my $all      = $self->param( 'all' );
    my $name     = $self->param( 'name' );
    my $position = $self->param( 'position' );
    my $grade    = $self->param( 'grade' );
    my ( @response, $profile );

    if ( $all eq "true" ) {
        @response = $user->get_member_list(all => 1);
        foreach my $stat ( @response ) {
            $profile .= $stat;
        }
    }

    elsif ( $all eq "false" ) {
        @response = $user->check_params(
            name     => $name,
            position => $position,
            grade    => $grade
        );
        foreach my $stat ( @response ) {
            $profile .= $stat;
        }
    }

    elsif ( $all eq "newmember" ) {
        $user->create_new_member(
            name     => $name,
            position => $position,
            grade    => $grade
        );
        $profile = "Account Created";
    }

    else {
        $profile = "bad request";
    }

    $self->render( text => $profile );
};

get '/teamjs' => sub {
    my $self = shift;

    $self->render( 'teamjs' );
};

get '/goal' => sub {
    my $self = shift;

    $self->render( 'goal' );
};

app->start;

__DATA__

@@ home.html.ep

<!DOCTYPE html>
<html>
<head>

<script src="http://code.jquery.com/jquery-1.8.2.min.js"></script>
<script src="/homejs"></script>

</head>
<body>

<h4 id="home_header">Computer Science Club Home</h4>

<a href="/team" target="_blank">The Team</a>
<a href="/goal" target="_blank">The Goal</a>
<a href="http://fairfaxhs.org" target="_blank">Our School</a></br>

<h5>Submit New Member</h5>

<input id="name" type="text"></input></br>
<select id="position">
    <option value="Programmer">Programmer</option>
    <option value="Designer">Designer</option>
</select>
<select id="grade">
    <option value="9">9</option>
    <option value="10">10</option>
    <option value="11">11</option>
    <option value="12">12</option>
</select>

<button id="submit_new_member" type="button">Submit</button>

</body>
</html>

@@ homejs.html.ep

$(document).ready(function() {
    $('#home_header').click(function() {
        window.location.reload();
    });
    $('#submit_new_member').click(function() {
        var name = $('#name').val();
        var position = $('#position').val();
        var grade = $('#grade').val();
        $.get('http://localhost:3000/teamdb?all=newmember&name='+name+'&position='+position+'&grade='+grade,
        function(status) {
            alert(status);
            $('#name').val('');
            //window.location.reload();
        });
    });
});

@@ goal.html.ep

<h5>Our Goal</h5>

<p><code>[paste goal here]</code></p>


@@ team.html.ep

<!DOCTYPE html>
<html>
<head>

<script src="http://code.jquery.com/jquery-1.8.2.min.js"></script>
<script src="/teamjs"></script>

</head>
<body>

<h4>Name, Position, Grade</h4>

</body>
</html>

@@ teamjs.html.ep

$(document).ready(function() {
    $.get('http://localhost:3000/teamdb?all=true',
    function(results) {
        var profiles = results.split(',');
        var list_length = profiles.length - 1;
        for (var i = 0;i < list_length;i++) {
            var full_file = profiles[i].split('.');
            $('body').append('<h5>'+full_file+'</h5>');
        }
    });
});
