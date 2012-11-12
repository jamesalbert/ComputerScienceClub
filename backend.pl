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

get '/getfilesfromsql' => sub {
    my $self = shift;
    use Team::Members;

    my ( @available_projects, $project );

    my $user = Team::Members->new;
    @available_projects = $user->get_files_from_sql;

    foreach my $item ( @available_projects ) {
        $project .= $item;
    }

    $self->render( text => $project );
};

get '/empty' => sub {
    my $self = shift;

    my $contents = $self->param( 'contents' );

    $self->render( text => $contents );
};

get '/list/of/competitions' => sub {
    my $self = shift;
    $self->render( text => 'no available competitions' );
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

<h3>Project Hosting</h3>

<h5>Upload A File</h5>
Select the folder: <input id="folder" type="text"></input></br>
Select the file: <input id="fakepath" type="file"></input></br>
<button id="dir" type="button">Upload File</button></br>

File's Full Directory: <input id="final_dir" type="text"></input>

<h5>Available Projects</h5>

</body>
</html>

@@ projecthostingjs.html.ep

$(document).ready(function() {
    $.get('http://localhost:3000/getfilesfromsql',
    function(available_projects) {
        var projects = available_projects.split('[NEWITEM]');
        var project_list_length = projects.length;
        for (var i = 0;i < project_list_length - 1;i++) {
            var file_to_contents = projects[i].split('[ITEMBREAK]');
            $('body').append(
                '<a href="/empty?contents='+file_to_contents[1]+'" class="project" target="_blank">'+file_to_contents[0]+'</a></br></br>'
            );
        }
    });
    $('h3').click(function() {
        window.location.replace('/home');
    });
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
