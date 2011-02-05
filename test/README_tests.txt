= Composite Primary Keys - Testing Readme

== Testing an adapter

There are tests available for the following adapters:

* ibmdb
* mysql
* oracle
* oracle_enhanced
* postgresql
* sqlite

To run the tests for one of the adapters follow these steps (using mysql in the example):

* rake -T mysql

    rake mysql:build_databases         # Build the MySQL test databases
    rake mysql:drop_databases          # Drop the MySQL test databases
    rake mysql:rebuild_databases       # Rebuild the MySQL test databases
    rake mysql:test                    # Run tests using the mysql adapter

* rake mysql:build_databases
* rake mysql:test

== Running tests individually

You can specify which test you'd like to run on the command line:

* rake mysql:test TEST=test/test_equal.rb

If you want to run closer to the metal you can cd into the test/
directory and run the tests like so:

* ADAPTER=mysql ruby test_equal.rb
