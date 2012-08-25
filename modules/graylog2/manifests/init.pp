class graylog2 {

    $version = "0.9.6p1"
    $graylog_folder = "/opt/graylog2"
    $graylog_web_folder = "$graylog_folder/graylog2-web-interface-$version"
    $graylog_server_folder = "$graylog_folder/graylog2-server-$version"
    $graylog2_web_file = "graylog2-web-interface-$version.tar.gz"
    $graylog2_server_file = "graylog2-server-$version.tar.gz"
    $graylog2_web_wget_link = "https://github.com/downloads/Graylog2/graylog2-web-interface/$graylog2_web_file"
    $graylog2_server_wget_link = "https://github.com/downloads/Graylog2/graylog2-server/$graylog2_server_file"
    $graylog_log_folder = "/var/log/graylog2"


    include elasticsearch

    Exec['apt-get update'] -> Package <| |>

    package {
        "mongodb":
            ensure => present;
        "make":
            ensure => present;
        "build-essential":
            ensure => present;
        "libcurl4-openssl-dev":
            ensure => present;
        "zlib1g-dev":
            ensure => present;
        "apache2-prefork-dev":
            ensure => present;
        "libaprutil1-dev":
            ensure => present;
    } ->
    user {
        "graylog" :
            shell => "/bin/bash",
            home => "/home/graylog",
            managehome => true,
            ensure => "present" ;
    } ->
    exec {
        'bundler':
            command => '/opt/vagrant_ruby/bin/gem install bundler',
            unless => "/opt/vagrant_ruby/bin/gem list | /bin/grep passenger";
        'passenger gem':
            command => '/opt/vagrant_ruby/bin/gem install --version "= 3.0.15" passenger',
            unless => "/opt/vagrant_ruby/bin/gem list | /bin/grep passenger",
            require => Package["apache2"];
        'passenger module':
            command => '/opt/vagrant_ruby/bin/rake apache2',
            cwd => "/opt/vagrant_ruby/lib/ruby/gems/1.8/gems/passenger-3.0.15",
            creates => "/etc/apache2/mods-enabled/passenger.load",
            require => Exec["passenger gem"];
    } ->
	file {
	    "/etc/apache2/mods-available/passenger.load":
	        ensure => present,
	        content => template("graylog2/passenger.load.erb");
	    "/etc/apache2/mods-enabled/passenger.load":
            ensure => link,
            notify => Service["apache2"],
            require => File["/etc/apache2/mods-available/passenger.load"],
            target => "/etc/apache2/mods-available/passenger.load";
        "/etc/apache2/sites-enabled/000-default":
            ensure => absent;
	    "/etc/apache2/sites-available/graylog2":
            ensure => present,
            content => template("graylog2/graylog2-vhost.erb");
        "/etc/apache2/sites-enabled/graylog2":
            ensure => link,
            notify => Service["apache2"],
            target => "/etc/apache2/sites-available/graylog2";
        "/etc/init/graylog2-server.conf":
            # the service is aware of this file. In case the service is not running puppet will
            # review the it's status.
            ensure => file,
            owner => "graylog",
            group => "graylog",
            mode => '0644',
            content => template("graylog2/init_graylog2-server.conf.erb");

        "/etc/init.d/graylog2-server":
            ensure => link,
            target => "/lib/init/upstart-job";

        "$graylog_folder":
            ensure => directory,
            owner => "graylog",
            group => "graylog",
            mode => '0755';

        "$graylog_log_folder":
            ensure => directory,
            owner => "graylog",
            group => "graylog",
            mode => '0755';

	} ->
	exec {
        "download graylog2 web":
            command => "/usr/bin/wget --no-check-certificate --output-document=$graylog_folder/$graylog2_web_file $graylog2_web_wget_link",
            unless => "/usr/bin/test -d $graylog_web_folder && /usr/bin/test -r $graylog_folder/$graylog2_web_file" ;

        "download graylog2 server":
            command => "/usr/bin/wget --no-check-certificate --output-document=$graylog_folder/$graylog2_server_file $graylog2_server_wget_link",
            unless => "/usr/bin/test -d $graylog_server_folder && /usr/bin/test -r $graylog_folder/$graylog2_server_file" ;
    } ->
    exec {
         "unzip graylog2 web":
            command => "/bin/tar --directory $graylog_folder -xzf $graylog_folder/$graylog2_web_file",
            unless => "/usr/bin/test -d $graylog_web_folder" ;

         "unzip graylog2 server":
            command => "/bin/tar --directory $graylog_folder -xzf $graylog_folder/$graylog2_server_file",
            unless => "/usr/bin/test -d $graylog_server_folder" ;
    } ->
    exec {
        "graylog web interface install bundler":
            command => "/opt/vagrant_ruby/bin/bundle install; /usr/bin/touch ${graylog_folder}/graylog_webinterface_install_bundler_${version}.lock",
            cwd => "$graylog_web_folder",
            user => "root",
            path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/opt/vagrant_ruby/bin",
            creates => "${graylog_folder}/graylog_webinterface_install_bundler_${version}.lock";
     } ->
     file {
        "$graylog_web_folder/config/email.yml":
            ensure => file,
            owner => "graylog",
            group => "graylog",
            mode => '0644',
            notify => Service["apache2"],
            content => template("graylog2/email.yml.erb");

        "$graylog_web_folder/config/general.yml":
            ensure => file,
            owner => "graylog",
            group => "graylog",
            mode => '0644',
            notify => Service["apache2"],
            content => template("graylog2/general.yml.erb");

        "$graylog_web_folder/config/mongoid.yml":
            ensure => file,
            owner => "graylog",
            group => "graylog",
            mode => '0644',
            notify => Service["apache2"],
            content => template("graylog2/mongoid.yml.erb");

        "$graylog_web_folder/config/newrelic.yml":
            ensure => file,
            owner => "graylog",
            group => "graylog",
            mode => '0644',
            notify => Service["apache2"],
            content => template("graylog2/newrelic.yml.erb");

        "$graylog_web_folder/config/indexer.yml":
            ensure => file,
            owner => "graylog",
            group => "graylog",
            mode => '0644',
            notify => Service["apache2"],
            content => template("graylog2/indexer.yml.erb");

        "$graylog_server_folder/graylog2.conf":
            ensure => file,
            owner => "graylog",
            group => "graylog",
            mode => '0644',
            notify => Service["graylog2-server"],
            content => template("graylog2/graylog2-server.conf.erb");

        "$graylog_folder/graylog2-web-interface" :
            ensure => link,
            notify => Service["apache2"],
            target => "$graylog_web_folder" ;

        "$graylog_folder/graylog2-server" :
            ensure => link,
            notify => Service["graylog2-server"],
            target => "$graylog_server_folder" ;

    	"$graylog_web_folder":
            ensure => directory,
            owner => "graylog",
            group => "graylog",
            recurse => true;

    	"$graylog_server_folder":
            ensure => directory,
            owner => "graylog",
            group => "graylog",
            recurse => true;
    } ->
    service {
        "graylog2-server":
        	ensure => running,
            require => File["/etc/init/graylog2-server.conf"],
            subscribe => File["$graylog_server_folder/graylog2.conf"],
            enable => true,
            provider => $::puppetversion ? {
            	"0.25.4" => "init",
            	default => "upstart"};
    }
}
