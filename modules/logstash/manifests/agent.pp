class logstash::agent () {

   include logstash
   include grok

   file {
        "/opt/logstash/filters":
            ensure => directory,
            owner => "logstash",
            group => "logstash",
            mode => 755;

        "/opt/logstash/filters/rgjson.rb":
            ensure => file,
            owner => "logstash",
            group => "logstash",
            mode => 644,
            notify  => Service['logstash-agent'],
            source => "puppet:///modules/logstash/rgjson.rb";

        "/etc/logstash/logstash-agent.conf":
            ensure => file,
            owner => "logstash",
            group => "logstash",
            mode => 644,
            notify  => Service['logstash-agent'],
            content => template("logstash/logstash-agent.conf.erb");

        "/etc/init/logstash-agent.conf":
            # the service is aware of this file. In case the service is not running puppet will
            # review the it's status.
            ensure => file,
            owner => "logstash",
            group => "logstash",
            mode => 644,
            content => template("logstash/init_logstash-agent.conf.erb");

        "/etc/init.d/logstash-agent":
            ensure => link,
            target => "/lib/init/upstart-job";
    }

    service {
        "logstash-agent":
        	ensure => running,
            require => File["/etc/init/logstash-agent.conf"],
            subscribe => [File["$logstash::logstash_folder/logstash.jar"],File["/etc/logstash/logstash-agent.conf"]],
            enable => true,
            provider => $::puppetversion ? {
            	"0.25.4" => "init",
            	default => "upstart"};
    }
}