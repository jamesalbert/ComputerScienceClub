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
        $profile = $user->check_params(
            name     => $name,
            position => $position,
            grade    => $grade
        );
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

get '/projecthosting' => sub {
    my $self = shift;

    $self->render( 'projecthosting' );
};

get '/projecthostingjs' => sub {
    my $self = shift;

    $self->render( 'projecthostingjs' );
};

get '/uploadfile' => sub {
    use Team::Members;
    my $self = shift;

    my $user      = Team::Members->new;
    my $file_name = $self->param( 'filename' );
    my $folder    = $self->param( 'folder' );

    my $file = $user->upload_file( $file_name, $folder );

    $self->render( text => $file );
};

get '/getfiledata' => sub {
    my $self = shift;
    use Team::Members;

    my $user = Team::Members->new;
    my $directory = $self->param( 'directory' );

    my $feedback = $user->read_from_upload( $directory );

    $self->render( text => $feedback );
};

get '/writefiletosql' => sub {
    my $self = shift;
    use Team::Members;

    my $user = Team::Members->new;
    my $file_name = $self->param( 'filename' );
    my $file_contents = $self->param( 'filecontents' );

    my $status = $user->write_file_to_sql( $file_name, $file_contents );

    $self->render( text => $status );
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

Name: <input id="name" type="text"></input></br>
Position: <select id="position">
    <option value="Programmer">Programmer</option>
    <option value="Designer">Designer</option>
</select></br>
Grade: <select id="grade">
    <option value="9">9</option>
    <option value="10">10</option>
    <option value="11">11</option>
    <option value="12">12</option>
</select></br>

<button id="submit_new_member" type="button">Submit</button></br>

</br></br>

<a href="/list/of/competitions">Check the list of competitions</a>
<a href="/projecthosting">Try experimental project hosting</a>

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


@@ projecthosting.html.ep

<!DOCTYPE html>
<html>
<head>

<script src="http://code.jquery.com/jquery-1.8.2.min.js"></script>
<script src="/projecthostingjs"></script>

</head>
<body>

Select the folder: <input id="folder" type="text"></input></br>
Select the file: <input id="fakepath" type="file"></input></br>
<button id="dir" type="button">Get Value</button></br>

<input id="final_dir" type="text"></input>

</body>
</html>

@@ projecthostingjs.html.ep

$(document).ready(function() {
    $('#dir').click(function() {
        var folder = $('#folder').val();
        var fakepath = $('#fakepath').val();
        var dir_paths = fakepath.split('\\');
        var file = dir_paths.pop();
        $.get('http://localhost:3000/uploadfile?filename='+file+'&folder='+folder,
        function(response) {
            $('#folder').val('');
            $('#fakepath').val('');
            $('#final_dir').val(response);
            $('#final_dir').attr('disabled', 'disabled');
            $.get('http://localhost:3000/getfiledata?directory='+response,
            function(file_data) {
                var new_dir = $('#final_dir').val();
                $.get('http://localhost:3000/writefiletosql?filename='+new_dir+'&filecontents='+file_data,
                function(status) {
                    alert(status);
                });
            });
        });
    });
});

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
