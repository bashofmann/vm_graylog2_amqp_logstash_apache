class environment {
    exec {
        'apt-get update':
            command => '/usr/bin/apt-get update'
    } ->
    file {
        "/data":
            ensure => directory,
            mode => '0777';
    } ->
    package {
        "curl":
            ensure => present;
    }
    include apache
    include graylog2
    include rabbitmq
    include logstash::agent
    include logstash::listener
}

include environment

