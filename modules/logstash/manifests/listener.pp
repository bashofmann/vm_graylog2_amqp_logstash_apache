class logstash::listener {

    include logstash, rabbitmq

    file {

        "/opt/logstash/outputs":
            ensure => directory,
            owner => "logstash",
            group => "logstash",
            mode => 755;

        "/opt/logstash/outputs/rggelf.rb":
            ensure => file,
            owner => "logstash",
            group => "logstash",
            mode => 644,
            notify  => Service['logstash-listener'],
            source => "puppet:///modules/logstash/rggelf.rb";

        "/etc/logstash/logstash-listener.conf":
            ensure => file,
            owner => "logstash",
            group => "logstash",
            mode => 644,
            notify  => Service['logstash-listener'],
            content => template("logstash/logstash-listener.conf.erb");

        "/etc/init/logstash-listener.conf":
            # the service is aware of this file. In case the service is not running puppet will
            # review the it's status.
            ensure => file,
            owner => "logstash",
            group => "logstash",
            mode => 644,
            source => "puppet:///modules/logstash/init_logstash-listener.conf";


        "/etc/init.d/logstash-listener":
            ensure => link,
            target => "/lib/init/upstart-job";

    }

    service {
        "logstash-listener":
            ensure => running,
            require => File["/etc/init/logstash-listener.conf"],
            subscribe => [File["$logstash::logstash_folder/logstash.jar"],File["/etc/logstash/logstash-listener.conf"]],
            enable => true,
            provider => $::puppetversion ? {
            	"0.25.4" => "init",
            	default => "upstart"};
    }
}