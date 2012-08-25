class testapp {

    file {
        "/etc/apache2/sites-available/testapp":
            ensure => present,
            source => "puppet:///modules/testapp/vhost";
        "/etc/apache2/sites-enabled/testapp":
            ensure => link,
            target => "/etc/apache2/sites-available/testapp",
            notify => Service["apache2"];
        "/var/www/index.php":
            ensure => present,
            source => "puppet:///modules/testapp/app/index.php";
    }

    exec { "/bin/echo 'Listen 81' >> '/etc/apache2/ports.conf'":
        unless => "/bin/grep -qFx 'Listen 81' '/etc/apache2/ports.conf'",
        notify => Service["apache2"];
    }
}