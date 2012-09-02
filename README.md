Vagrant VM to test out a graylog2 rabbitmq and logstash setup
=============================================================

Install
-------

You need vagrant to create and provision this VM, see http://vagrantup.com/ for installation details.

Once you installed vagrant just check out the git repo and run

    vagrant up

and wait some minutes. Vagrant will download a Ubuntu Precise 64bit base box image and will install
Graylog2, RabbitMQ, Logstash, Apache2 and PHP5 and configure them through Puppet.

Once vagrant finished setting everything up you can access these service at:

* Graylog2: http://localhost:8180/ (you have to add a user first)
* ElasticSearch Frontend: http://localhost:8192/_plugin/head/
* Small PHP test script that logs something to the error_log: http://localhost:8181/index.php
* RabbitMQ Frontend: http://localhost:8155/ (User: guest, Password: guest)

