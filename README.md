# ruby-chat
A simple ruby chat client and server

This was developed for a networking class, so this is just a simple chat client/server using ruby.

The server has authentication, but to keep things simple, the valid users/passwords are stored in the server file.

The client is a GUI client using Ruby/TK, and will allow any logged in users to send messages to each other.

Before running this program, make sure you have ruby set up on your system, and that you can run .rb files from a terminal.

To run: download all files to a folder on your system.  In your terminal program, navigate to the folder where you saved your files,
and run the ChatServer.rb first, by typing: ruby ChatServer.rb [hostname] [port].  If running on the same system where you will be running
the client, use: ruby ChatServer.rb localhost 5535.

When the server is up and running, you can then run the chat.rb file, which will then prompt you for a hostname and port.  Put in
localhost for the hostname, and 5535 for the port.  After it connects to the server, you will then be prompted for a login.

Valid usernames/passwords are listed below:
katy/katypw
pink/pinkpw
bono/bonopw
dan/danpw
jesus/jesuspw
jake/jakepw
josh/joshpw
jeff/jeffpw

You can add more users by modifying the ChatServer.rb file.
