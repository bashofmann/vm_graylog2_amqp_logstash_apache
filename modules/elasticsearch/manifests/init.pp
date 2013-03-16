 class elasticsearch {

    $version = "0.19.8"
    $elasticsearch_folder = "/opt/elasticsearch"
    $elasticsearch_data_folder = "/data/elasticsearch"
    $elasticsearch_log_folder = "/var/log/elasticsearch"
    $elasticsearch_file = "elasticsearch-$version.tar.gz"
    $elasticsearch_install_folder = "$elasticsearch_folder/elasticsearch-$version"
    $elasticsearch_wget_link = "https://download.elasticsearch.org/elasticsearch/elasticsearch/\/$elasticsearch_file"
    $elasticsearch_user = "elasticsearch"
    $cluster = "log_cluster"

    Exec['apt-get update'] -> Package <| |>

    package {
        "openjdk-7-jdk":
            ensure => "present";
    } ->
    user {
        "$elasticsearch_user" :
            shell => "/bin/bash",
            home => "/home/$elasticsearch_user",
            managehome => true,
            ensure => "present" ;
    } ->
	file {
        "/etc/init.d/elasticsearch":
            # the service is aware of this file. In case the service is not running puppet will
            # review the it's status.
            ensure => file,
            owner => "root",
            group => "root",
            mode => '0755',
            content => template("elasticsearch/eventd_elasticsearch.erb");

        "$elasticsearch_log_folder":
            ensure => directory,
            owner => "$elasticsearch_user",
            group => "$elasticsearch_user",
            mode => '0755';

        "$elasticsearch_folder":
            ensure => directory,
            owner => "$elasticsearch_user",
            group => "$elasticsearch_user",
            mode => '0755';

        "$elasticsearch_data_folder":
            ensure => directory,
            owner => "$elasticsearch_user",
            group => "$elasticsearch_user",
            mode => '0755';

         "/var/run/elasticsearch":
       		ensure => directory,
            owner => "$elasticsearch_user",
            group => "$elasticsearch_user",
            mode => '0755';

	} ->
	exec {
        "download elasticsearch":
            command => "/usr/bin/wget --no-check-certificate --output-document=$elasticsearch_folder/$elasticsearch_file $elasticsearch_wget_link",
            unless => "/usr/bin/test -d $elasticsearch_install_folder && /usr/bin/test -r $elasticsearch_folder/$elasticsearch_file" ;

    } ->
    exec {
         "unzip elasticsearch":
            command => "/bin/tar --directory $elasticsearch_folder -xvzf $elasticsearch_folder/$elasticsearch_file",
            unless => "/usr/bin/test -d $elasticsearch_install_folder" ;

    } ->
    file {
        "$elasticsearch_install_folder/config/elasticsearch.yml":
            ensure => file,
            owner => "$elasticsearch_user",
            group => "$elasticsearch_user",
            mode => '0644',
            notify => Service["elasticsearch"],
            content => template("elasticsearch/elasticsearch.yml.erb");

        "$elasticsearch_folder/elasticsearch" :
            ensure => link,
            notify => Service["elasticsearch"],
            target => "$elasticsearch_install_folder" ;

        "$elasticsearch_install_folder":
             ensure => directory,
             owner => "$elasticsearch_user",
             group => "$elasticsearch_user",
             recurse => true;
    } ->
    exec {
        "install elasticsearch management plugin":
            command => "$elasticsearch_install_folder/bin/plugin -install mobz/elasticsearch-head",
            user => "$elasticsearch_user",
            unless => "/usr/bin/test -d $elasticsearch_install_folder/plugins/head";
    } ->
    service {
        "elasticsearch":
            ensure => running,
            require => File["/etc/init.d/elasticsearch"],
            enable => true,
            hasstatus => false;
    }
}
