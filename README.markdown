R3PL4Y
======
This is the code project of replay.mikaellundin.name. Here main development of the website is done and contributions in form of pull requests are accepted. For contributing, see contribution section further on.

Getting Started
---------------
Fork the project and clone the repository to your local machine. If you intend to contribute, make sure you create a branch before making changes.

Run `bundle install` on project root to resolve all dependencies.

### Native dependencies
* Postgresql
* libxslt
* ImageMagick
* libpng

This project uses a postgresql database for persistance. Make sure that you have access to that database, or migrate the code to database of your choice. I give no assurance there's no postgresql specific code in this project.

As your development user, create a fresh database and set it up for development by running `rake db:setup`. Note the invite url at the bottom of the printout. That is how you're going to create your own user in the system.

Start the server with `rails server` and navigate to http://localhost:3000/.

### Service dependencies
In order to login you need to setup a login service, Twitter, Facebook or Steam. Twitter and Facebook is available for development, where as Steam can only be used in a production environment.

## Configure Twitter
Go to twitter.com and create a new application called r3pl4y_development. Add two environment variables to your system. (in Linux I add them to ~/.bashrc)
twitter_consumer_key: Your application identifier
twitter_consumer_secret: Your application secret

This is enough to let you login to R3PL4Y, and for publishing new reviews to Twitter stream.

