fake_dropbox
============

fake_dropbox is a simple fake implementation of the Dropbox API written in Ruby
using the Sinatra framework. It can be used for developing and testing
applications that use Dropbox. There are no real authentication and users (you
are always authenticated), the server stores files on the local machine.

Can be used either as a standalone app listening on a port or intercept calls to
the real Dropbox in Ruby apps.

It partially implements [version 0](https://www.dropbox.com/developers/reference/oldapi)
of the Dropbox API which should be compatible with [version 1](https://www.dropbox.com/developers/reference/api).
If you find it useful and want to add support for more features, go ahead ;)


Installation
------------

Using RubyGems:

    gem install fake_dropbox

To get the latest development version just clone the repository:

    git clone git://github.com/jgonera/fake_dropbox.git
    cd fake_dropbox
    gem install bundler
    bundle install

Then, if you want to install it as a gem:

    rake install


How to use
----------

### Running the server

If you installed fake_dropbox as a gem, you should be able to run:

    DROPBOX_DIR=/home/joe/somedir fake_dropbox [PORT]

You have to specify an environment variable `DROPBOX_DIR` which will point the
server to the directory on which the fake API should operate. Additionally, you
can specify a custom port (default is 4321).

### Intercepting requests in Ruby apps

You can also use this gem to intercept requests to Dropbox in your Ruby app,
without modifying any of its code or specifying a custom host or port. This
is achieved by using the [WebMock](https://github.com/bblimke/webmock) library.

The class responsible for this is `FakeDropbox::Glue`. To intercept requests to
the real Dropbox, just instantiate this class in your code:

    fake_dropbox = FakeDropbox::Glue.new

You can provide an optional argument to the constructor, pointing to the
directory you want to use for your fake Dropbox:

    fake_dropbox = FakeDropbox::Glue.new('/home/joe/somedir')

If you don't provide it, a temporary directory will be created in the system's
temporary path.

Moreover:

* `#dropbox_dir` returns the fake Dropbox directory.
* `#empty!` deletes everything in the `dropbox_dir` *recursively*.
Even though it should work only if the `dropbox_dir` resides inside the system's
temporary path, you should use it with caution.

A support file for Cucumber tests could look like this:

    require 'fake_dropbox'

    fake_dropbox = FakeDropbox::Glue.new

    After do
      fake_dropbox.empty!
    end

### Using without installing as a gem

If you cloned the repository and you don't want to install fake_dropbox as a
gem, you can run it using `rackup` while in the fake_dropbox directory:

    DROPBOX_DIR=/home/joe/somedir rackup


Copyright
---------

Copyright © 2011 Juliusz Gonera
fake_dropbox is released under the MIT license.

