.. _userguide_server:

Bokeh Server
============

.. contents::
    :local:
    :depth: 2

.. program:: bokeh-server

.. _userguide_server_overview:

Overview
--------

The Bokeh server is an optional component that can be used to provide
additional capabilities, such as:

* hosting and publishing Bokeh plots for wider audiences
* streaming data to plots so that they automatically update
* interactively visualizing very large datasets by employing downsampling and abstract rendering
* building and deploying dashboards and apps with sophisticated user interactions

The Bokeh server is built on top of `Flask <http://flask.pocoo.org>`_. Bokeh
ships with a standalone executable ``bokeh-server`` that you can easily run,
and you can also embded the Bokeh server functionality inside another Flask
server using the Bokeh Server `Flask Blueprint <http://flask.pocoo.org/docs/0.10/blueprints/>`_.

The basic task of the Bokeh Server is to be a mediator between the original data
and plot models created by a user, and the reflected data and plot models in the
BokehJS client:

|

.. image:: /_images/bokeh_server.png
    :align: center
    :scale: 50 %

|

Here you can see illustrated the most useful and compelling of the Bokeh server:
**full two-way communication between the original code and the BokehJS plot.**
Plots are published by sending them to the server. The data for the plot can be
updated on the server, and the client will respond and update the plot. Users can
interact with the plot through tools and widgets in the browser, then the results of
these interactions can be pulled back to the original code to inform some further
query or analysis (possibly resulting in updates pushed back the plot).

We will explore the capabilities afforded by the Bokeh server in detail below.

.. _userguide_server_hosting:

Plot Hosting
------------



.. _userguide_server_streaming:

Streaming Data
--------------



.. _userguide_server_large:

Large Data
----------



.. _userguide_server_widgets:

Widgets and Dashboards
----------------------



.. _userguide_server_command_line:

Command Line Configuration
--------------------------

General Usage
~~~~~~~~~~~~~

The ``bokeh-server`` application has some command line options for
general usage, setting the server port and IP, for instance:

.. option:: -h, --help

    show this help message and exit

.. option:: --ip <IP>

    IP address that the bokeh server will listen on (default: 127.0.0.1)

.. option:: --port <PORT>

    port that the bokeh server will listen on (default: 5006)

.. option:: --url-prefix <URL_PREFIX>

    URL prefix for server. e.g. 'host:port/<prefix>/bokeh' (default: None)

Advanced Usage
~~~~~~~~~~~~~~

Additional configuration options for configuring server data sources,
multi-user operation, scripts, etc:

.. option:: -D <DATA_DIRECTORY>, --data-directory <DATA_DIRECTORY>

    location for server data sources

.. option:: -m, --multi-user

    start in multi-user configuration (default: False)

.. option:: --script <SCRIPT>

    script to load (for applets)

Storage Backends
~~~~~~~~~~~~~~~~

Bokeh server supports various different backends for data storage:

* In-Memory --- non-persistent, useful for testing
* `Shelve <https://docs.python.org/2/library/shelve.html>`_ --- lightweight, available on all platforms
* `Redis <http://redis.io>`_ --- recommended for production deployments

.. note::
    Redis can be more difficult to install on Windows, please consult
    :ref:`install_windows` for some additional notes.

Additional backends may be added in the future if need or demand arises, or
if they are contributed by the community.

You can specify the backend when starting the Bokeh server by supplying
the ``--backend`` command line argument:

.. option:: --backend <BACKEND>

    storage backend: [ redis | memory | shelve ] (default: shelve)

For example::

    $ bokeh-server --backend=memory

When using the ``redis`` backend there are some additional options
available:

.. option:: --redis-port <REDIS_PORT>

    port for redis server to listen on (default: 7001)

.. option:: --start-redis

    start redis automatically

.. option:: --no-start-redis

    do not start redis automatically

By default ``bokeh-server`` will start Redis automatically when the
``redis`` backend is chosen.

Websockets
~~~~~~~~~~

The Bokeh server uses websockets for communication between the server
and browser clients. There are several options for configuring the
use of websockets:

.. option:: --ws-conn-string <WS_CONN_STRING>

    connection string for websocket (unnecessary if auto-starting)

.. option:: --zmqaddr <ZMQADDR>

    ZeroMQ URL

.. option:: --no-ws-start

    don't automatically start a websocket worker

.. option:: --ws-port <WS_PORT>

    port for websocket worker to listen on

Typically these values do not require much attention. By default,
``bokeh-server`` automatically starts a ZeroMQ websocket worker.

Development Options
~~~~~~~~~~~~~~~~~~~

.. option:: -d, --debug

    use debug mode for Flask

.. option:: --dev

    run server in development mode: -js --backend=memory

.. option:: --filter-logs

    don't show 'GET /static/... 200 OK', useful with --splitjs

.. option:: -j, --debugjs

    serve BokehJS files from the bokehjs build directory in the source tree

.. option:: -s, --splitjs

    serve individual JS files instead of compiled bokeh.js, requires --debugjs

.. option:: --robust-reload

    protect debug server reloading from syntax errors

.. option:: -v, --verbose



