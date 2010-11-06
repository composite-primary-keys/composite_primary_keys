= Composite Primary Keys - Testing Readme

== Testing an adapter

There are tests available for the following adapters:

* ibmdb
* mysql
* oracle
* postgresql
* sqlite

To run the tests for on of the adapters follow these steps (using mysql in the example):

* rake -T | grep mysql

    rake mysql:build_databases         # Build the MySQL test databases
    rake mysql:drop_databases          # Drop the MySQL test databases
    rake mysql:rebuild_databases       # Rebuild the MySQL test databases
    rake test_mysql                    # Run tests for test_mysql

* rake mysql:build_databases
* rake test_mysql
