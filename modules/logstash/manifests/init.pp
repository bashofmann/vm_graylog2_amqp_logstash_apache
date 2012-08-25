class logstash {

    $logstash_file = "logstash-1.1.0-monolithic.jar"
    $logstash_folder = "/opt/logstash"
    $logstash_wget_link = "http://semicomplete.com/files/logstash/$logstash_file"
    $logstash_log_folder = "/var/log/logstash"
    $logstash_config_folder = "/etc/logstash"

    Exec['apt-get update'] -> Package <| |>

    user {
        "logstash" :
        	ensure => "present",
            shell => "/bin/bash",
            home => "/home/logstash",
            managehome => true;
    }

   file {
       "$logstash_folder":
           ensure => directory,
           owner => "logstash",
           group => "logstash",
           mode => '0755';

       "$logstash_config_folder":
           ensure => directory,
           owner => "logstash",
           group => "logstash",
           mode => '0755';

       "$logstash_log_folder":
           ensure => directory,
           owner => "logstash",
           group => "logstash",
           mode => '0755';
   } -> exec {
       "download logstash":
           command => "/usr/bin/wget --no-check-certificate --output-document=$logstash_folder/$logstash_file $logstash_wget_link",
           unless => "/usr/bin/test -r $logstash_folder/$logstash_file" ;
   } -> file {
       "$logstash_folder/$logstash_file":
            ensure => file,
            owner => "logstash",
            group => "logstash",
            recurse => true;
        "$logstash_folder/logstash.jar" :
            ensure => link,
            target => "$logstash_folder/$logstash_file" ;
   }
}
