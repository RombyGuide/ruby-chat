#-------------------------------------------------------------------------------
# Class ChatServer
#
# Usage:
# ruby [-d] ChatServer.rb <ipaddress or hostname> <portnumber e.g. 5535>
#
# -d invokes all lines of code with if $DEBUG
#
# ipaddress is the address of the server itself. Can be 127.0.0.1 unless you
# want to connect from another host. You can use myhost.com or 192.168.X.X
# as appropriate. 
#
# To discover your ip address run the command 
# "ifconfig -a"   on a terminal on a Mac
# "ipconfig /all" on a command shell for a PC. 
#
# Use server with the chat_client.rb program using the same IP address and port
# 
# Template by Dan Mazzola, 4/7/2015, CIS 430
#===============================================================================
# YOUR GROUP NAME AND TEAM MEMBERS NAMES BELOW:
# The Scholars: 4/11/2015, CIS 430, TTH/4:30
# Dan Cannan
# Jesus Carrillo
# Jeff Ding
# Jake Richardson
# Josh Braaten
#-------------------------------------------------------------------------------

require "socket"

USERNAME=0					
PASSWORD=1

#------------------------------------------------------------------------------
# global multi-dimensional array of userames and passwords
# This code assumes all usernames are lowercase (e.g. string.downcase!)
# passwords can be any case. 
#------------------------------------------------------------------------------

$users_and_passwords = 
[
	[ "katy", 	"katypw" ], 
	[ "pink", 	"pinkpw" ],
	[ "bono", 	"bonopw" ],
	[ "dan",	"danpw"  ],
	[ "jesus",	"jesuspw"  ],
	[ "jake",	"jakepw"  ],
	[ "josh",	"joshpw"  ],
	[ "jeff",	"jeffpw"  ]
]

class Connection

	#--------------------------------------------------------------------------
	# initialize a new Connection with the socket and default values
	#--------------------------------------------------------------------------
	def initialize(socket)	
		@socket 			= socket 			
		@host 				= socket.peeraddr[2]
		@port 				= socket.peeraddr[1]
		@username 			= nil				
		@authenticated 		= false
		@show_full_names 	= false
		@groups				= nil
	end

	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	attr_reader 	:socket, :host, :port, :username, :authenticated
	attr_accessor 	:show_full_names

	#--------------------------------------------------------------------------
	# to_s() Produces a string representation of our Connection Class:
	# #Class:id........ = Connection:3ff39dc2fcb0,
	#  @socket......... = #<TCPSocket:fd 9>,
	#  @host........... = "216.58.217.206", 
	#  @port........... = 80, 
	#  @username....... = nil, 
	#  @authenticated.. = false,
	#  @show_full_names = false
	#--------------------------------------------------------------------------
	def to_s
		conn_str = 
			sprintf("#%s%s:%x\n%s%s\n%s%s\n%s%s\n%s%s\n%s%s\n%s%s\n%s%s\n",
				"Class:id.......... = ", self.class, self.object_id, 
				" @socket.......... = ", @socket.inspect, 
				" @host............ = ", @host.inspect, 
				" @port............ = ", @port.inspect, 
				" @username........ = ", @username.inspect,
				" @authenticated... = ", @authenticated.inspect,
				" @show_full_names. = ", @show_full_names.inspect,
				" @groups.......... = ", @groups.inspect)
		return conn_str
	end

	#--------------------------------------------------------------------------
	# valid_username?() method tests if name is a valid username. 
	# if found in the global list of $users_and_passwords, set the value of 
	# @username to name, and return true, else return false
	#--------------------------------------------------------------------------
	def valid_username?(name)
		$users_and_passwords.each do |element|
			if element[USERNAME] == name
				@username=name
				return true
			end
		end			
		return false
	end

	#--------------------------------------------------------------------------
	# valid_password?() method tests if password is valid for the current 
	# Connection username. If it matches the valid password for @username
	# set @authenticated to true, and return true, else return false
	#--------------------------------------------------------------------------
	def valid_password?(password)
		$users_and_passwords.each do |element|
			if element[USERNAME] == @username
				if element[PASSWORD] == password
					@authenticated=true
					return true
				end
			end
		end			

		return false
	end

	#--------------------------------------------------------------------------
	# puts() writes a message the current Connections socket
	#--------------------------------------------------------------------------
	def puts(message)
		@socket.puts(message)
	end

	#--------------------------------------------------------------------------
	# gets() reads a message from the current Connections socket
	#--------------------------------------------------------------------------
	def gets
		@socket.gets
	end

end # class Connection


class ChatServer

	#--------------------------------------------------------------------------
	# initialize() This initializes and sets up our ChatServer object
	#--------------------------------------------------------------------------
	def initialize(host, port)
		
		# keep an array of client Connections		
		@connection_array 	= Array.new
		
		# Create the server socket listening on the host and port		
		@server_socket = TCPServer.new(host, port)
		
		# Set a special option for our socket, it says, "for our socket, 
		# at the SOcket Level, ReUse addresses is set to true. 
		# Useful for multiple clients to prevent address already in use error.	
		@server_socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1)
		
		# Print a log on the server we have created the socket		
		printf("<log>: ChatServer started at %s\n", Time.now())
		printf("<log>: Running on host: '%s', listening on port '%d'\n", 
			host, port)
		
		log_socket_info
		
	end
	
	#--------------------------------------------------------------------------
	# name_display(type) method checks status of @show_full_names 
	# and displays username in appropriate setting. using the type to
	# determine if it's a destination or source display 
	#--------------------------------------------------------------------------
	def name_display(conn, source)
		
		if conn.show_full_names == true
			return sprintf("%s@%s:%s", source.username, 
							source.host, source.port)
		else 
			return sprintf("%s", source.username)
		end
		
	end	
	
	#--------------------------------------------------------------------------
	# create an array of all client sockets 
	#--------------------------------------------------------------------------
	def get_client_sockets
		client_sockets = []
		@connection_array.each do |conn| 
			client_sockets << conn.socket
		end
		return client_sockets
	end

	#--------------------------------------------------------------------------
	# Given a socket, find the connection object. Return connection object
	# if found, else nil.
	#--------------------------------------------------------------------------
	def get_connection_by_socket(socket)
		@connection_array.each do |conn|
			if conn.socket == socket
				return conn
			end
		end
		return nil
	end

	#--------------------------------------------------------------------------
	# Given a username, search the connection array and find the connection
	# object with that name, return the connection if found, else nil.
	#--------------------------------------------------------------------------
	def get_connection_by_username(username)
		@connection_array.each do |conn|
			if conn.username == username
				return conn
			end
		end
		return nil
	end

	#--------------------------------------------------------------------------
	# log_socket_info() print log to server console
	#--------------------------------------------------------------------------
	def log_socket_info
		printf("<log>: Client Connections = %d\n", @connection_array.length)
	end

	#--------------------------------------------------------------------------
	# broadcast_message() send a message to each client connection and log the
	# message on the server console. Do not set the message to source, send 
	# acknowlegement of sending the message instead	
	#--------------------------------------------------------------------------
	def broadcast_message(message, source_conn)
		
		broadcast_message 	= message
		notification = ""

		@connection_array.each do |conn|
			if conn.socket == source_conn.socket
				# skip the source connection
				next
			else
			
				# Format the source username based on whether the client is set to show full names
				source_username 	= name_display(conn, source_conn)
				notification 		= "160 Broadcast message from #{source_username}"
				
				# send notification & message to client
				conn.puts(notification)
				conn.puts(broadcast_message)

				# send acknowldgement to source
				#dest_username = sprintf("%s@%s:%s", conn.username, 
				#				conn.host, conn.port)
				#source_conn.puts("360 Broadcast sent to #{dest_username}")
			end
		end
		
		# log notification and broadcast_message to server console
		log_message(notification)
		log_message(broadcast_message)
	end
	
	#--------------------------------------------------------------------------
	# accept_new_connection() Accept new client connection, get valid username
	# and password. When correct, create new Connection object and add to the
	# list of current connections
	#--------------------------------------------------------------------------
	def accept_new_connection

		# Make a new Connection object
		client_socket = @server_socket.accept
		conn=Connection.new(client_socket)

		# Send connection acknowldgement to source
		conn.puts("100 Your connection has been accepted by the server!\n")
		conn.puts("100 Please login and authenticate.\n")

		# Start loop for getting valid username and password.  Modified for the GUI client:
		loop do
			conn.puts "110 Enter a valid username:"
			response=conn.gets.chomp!
			if conn.valid_username?(response)
				conn.puts "310 Username valid, need password."
				conn.puts "120 Enter a valid password for #{conn.username}:"
				response = conn.gets.chomp!
				if conn.valid_password?(response)
					conn.puts "320 Valid password entered! for #{conn.username}"
				else
					conn.puts "220 Invalid password."
				end
			else
				conn.puts "210 Invalid username."
			end
			
			# loop until valid password for username
			break if conn.valid_password?(response)
		end
		
		# acknowldge valid username and password and log to server
		message = sprintf("320 Successful Login, welcome %s@%s:%s\n", 
			conn.username, conn.host, conn.port)
		conn.puts "#{message}"
		log_message("<Debug>\n #{conn}") if $DEBUG

		# add new validated Connection to the array of current connections
		@connection_array.push(conn)

		# broadcast to all clients a new client has joined and log to server
		message = sprintf("140 Client Joined: %s@%s:%s\n", 
			conn.username, conn.host, conn.port)		
		broadcast_message(message, conn)
		log_socket_info
	end
	
	#--------------------------------------------------------------------------
	# sockets_ready_for_reading() returns an array of sockets that have a 
	# message ready to be read
	#--------------------------------------------------------------------------
	def sockets_ready_for_reading
	
		# Start by creating an array of sockets. The array is composed
		# of the @server_socket and appending the array of client sockets. 
		# To get the array of client sockets, we call get_client_sockets()

		socket_array = []					# make a new empty array
		socket_array << @server_socket		# append the @server_socket
		socket_array << get_client_sockets	# append an array of clients
		socket_array.flatten!				# flatten! the array

		# Here is a tutorial of how to create the socket array, only with
		# integers instead of sockets:
		# irb(main):001:0> a=[]        		# make a new empty array
		# => []
		# irb(main):002:0> a << 1			# append a digit to the array	
		# => [1]
		# irb(main):004:0> a << [2,3,4]		# append an array to the array
		# => [1, [2, 3, 4]]
		# irb(main):005:0> a.flatten!		# flatten! does just that
		# => [1, 2, 3, 4]

		# IO.select monitors IO objects and returns a proper subset
		# that have something pending. Take four arguments, a array of of 
		# objects to scan for reads, writes, errors, and timeouts. We 
		# are only concerned with sockets ready to read, so we pass nil
		# for the rest. IO.select returns four arrays of arrays, we 
		# pluck of first array which is the array of sockets ready to be
		# read from.

		io_ready 	= IO.select(socket_array, nil, nil, nil)
		ready2read	= io_ready[0]

		return ready2read
	end

	#--------------------------------------------------------------------------
	# log_message() Write a message to the server console for logging purposes
	#--------------------------------------------------------------------------
	def log_message(message)
		puts(message)
	end

	#--------------------------------------------------------------------------
	# Parse and process each client message
	#--------------------------------------------------------------------------
	def process_message(raw_message, conn)

		puts "<Debug> processing_message: #{raw_message.inspect} from "\
			"#{conn.username}@#{conn.host}:#{conn.port}" if $DEBUG

		message_words = raw_message.split
		cmd = message_words.shift.downcase

		# irb(main):02> raw_cmd="Unicast Katy I used to bite my tongue too"
		# => "Unicast Katy I used to bite my tongue too"
		# irb(main):03> message_words=raw_cmd.split
		# => ["Unicast", "Katy", "I", "used", "to", "bite", "my", "tongue", "too"]
		# irb(main):04> cmd=message_words.shift.downcase
		# => "unicast"
		# irb(main):05> message_words
		# => ["Katy", "I", "used", "to", "bite", "my", "tongue", "too"]
		# irb(main):06> dest_username=message_words.shift.downcase
		# => "katy"
		# irb(main):07> message=message_words.join(" ")
		# => "I used to bite my tongue too"

		case cmd

		when 'broadcast'

			broadcast_message(message_words.join(' '), conn)

		when 'unicast'

			source_conn 	= conn
			dest_username 	= message_words.shift
			dest_username.downcase! unless dest_username.nil?
			message 		= message_words.join(" ")
			dest_conn		= get_connection_by_username(dest_username)
			
			# Set the source username based on whether the client wants full names shown
			source_username = name_display(dest_conn, source_conn)

			if not dest_conn 
				source_conn.puts("250 Invalid username: "\
								 "#{dest_username.inspect} for unicast")
			else
				dest_conn.puts("150 Message from #{source_username}:")
				dest_conn.puts("150 #{message}")
				dest_username 	= sprintf("%s@%s:%s", dest_conn.username, 
									dest_conn.host, dest_conn.port)
				source_conn.puts("350 message sent to #{dest_username}")
			end

		when 'list'
			
			connection_list = ""
			@connection_array.each do |connection|
				connection_list << connection.username
				connection_list << " "
			end
			conn.puts("370 List of connected users shown below:")
			conn.puts connection_list

		when 'show_full_names'

			conn.puts "130 Show Full Username set to #{conn.show_full_names}"

		when 'toggle_full_names'

			if conn.show_full_names == false

				conn.show_full_names = true
				conn.puts "330 Show Full Usernames now #{conn.show_full_names}"

			else

				conn.show_full_names = false
				conn.puts "331 Show Full Usernames now #{conn.show_full_names}"

			end
			
		when 'help'

			help_subcommand=message_words.first
			help_subcommand.downcase! unless help_subcommand.nil?

			case help_subcommand

			when nil
				conn.puts("390 Successful help command:")
				conn.puts("")
				conn.puts("190 Usage: help <command>, where <command> is:")
				conn.puts("190  broadcast   unicast   list  help")
				conn.puts("190  show_full_names  toggle_full_names")
				conn.puts("")

			when 'unicast'
				conn.puts("390 Successful help command:")
				conn.puts("")
				conn.puts("190 unicast <username> message_text")
				conn.puts("190 sends message_text to <username>")
				conn.puts("")

			when 'broadcast'
				conn.puts("390 Successful help command:")
				conn.puts("")
				conn.puts("190 broadcast message_text")
				conn.puts("190 sends message_text to all connected users")
				conn.puts("")

			when 'list'
				conn.puts("390 Successful help command:")
				conn.puts("")
				conn.puts("190 list")
				conn.puts("190 shows a list of currently connected users")
				conn.puts("")

			when 'show_full_names'
				conn.puts("390 Successful help command:")
				conn.puts("")
				conn.puts("190 show_full_names")
				conn.puts("190 displays the current show_full_names value")
				conn.puts("190 used to control the format of usernames")
				conn.puts("190 when 'true' uses username@host:port format")
				conn.puts("190 when 'false' uses username format")
				conn.puts("190 use help toggle_full_names for more information")
				conn.puts("")

			when 'toggle_full_names'
				conn.puts("390 Successful help command:")
				conn.puts("")
				conn.puts("190 toggle_full_names")
				conn.puts("190 switches the value of show_full_names")
				conn.puts("190 use help show_full_names for more information")
				conn.puts("")

			else
				conn.puts("290 Invalid help subcommand")

			end
		else
			conn.puts("200 Invalid command: #{cmd.inspect}")
		end
		

	end
	
	#--------------------------------------------------------------------------
	# run() The server loop
	#--------------------------------------------------------------------------
	def run
	
		while true  						# run forever
		
			ready2read = sockets_ready_for_reading()
			
			next if not ready2read 			# if nil, loop again
	
			puts "<Debug> ready2read=#{ready2read.inspect}" if $DEBUG

			ready2read.each do |socket|		
			
				if socket == @server_socket then	# we have a new client

					accept_new_connection

				else       							# a client has a message

					conn = get_connection_by_socket(socket)

					if socket.eof? then 	# the socket was closed

						message = sprintf("190 %s@%s:%s now disconnected\n", 
							conn.username, conn.host, conn.port)
						log_message(message)
						broadcast_message(message, conn)
						socket.close
						@connection_array.delete(conn)
						log_socket_info

					else					# we have a message to process
					
						message = socket.gets.chomp!
						log_string = sprintf("<log>:Message From: %s@%s:%s %s", 
						   conn.username, conn.host, conn.port, message.inspect)
						log_message(log_string)
						process_message(message, conn)

					end
				end
			end 
		end
	end
end # class definition


#--------------------------------------------------------------------------
# Start of program is here, process command line arguments, make a new 
# server object and run it
#--------------------------------------------------------------------------

puts "<Debug> ARGV=#{ARGV.inspect}" if $DEBUG

if ARGV.length != 2 then
	$stderr.puts "Error: Usage #$0 host port"
	exit(1)
else	
	host = ARGV[0]
	port = ARGV[1].to_i
end

puts "<Debug> host=#{host.inspect}" if $DEBUG
puts "<Debug> port=#{port.inspect}" if $DEBUG

#--------------------------------------------------------------------------
# make a new ChatServer on host and port, then enter the server run loop
#--------------------------------------------------------------------------

myChatServer = ChatServer.new(host, port)
myChatServer.run
