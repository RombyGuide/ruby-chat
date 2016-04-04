#--------------------------------------------------------------------#
# This is a simple GUI chat client written using Ruby/Tk             #
#                                                                    #
# For now, the server will be hard coded into the program            #
#                                                                    #
# This will create a window with the list of users, the chat window, #
# and the text input box.                                            #
#                                                                    #
# Created by The Scholars, March 25, 2015                            #
# The Scholars:                                                      #
#   Dan Cannan                                                       #
#   Jeff Ding                                                        #
#   Josh Braaten                                                     #
#   Jake Richardson                                                  #
#   Jesus Carrillo                                                   #
#--------------------------------------------------------------------#

# This program needs the Tk gem, and the socket as well
require 'tk'
require 'socket'

# Option for the menus, without this, there is a line that shows
TkOption.add '*tearOff', 0

#--------------------------------------------------------#
# Class for the Root Window, the main chat window that   #
# the user will see after connecting and logging in.     #
# I'm making this a class to have better access to the   #
# elements of the window.                                #
#--------------------------------------------------------#
class RootWindow
	def initialize
		@chat_window = chat_window_scrollbar = nil
		
		@root_window = TkRoot.new { title "Chat Client" ; geometry '815x900+5+5' }
		
		# Create the menu bar on the root window
		@menu_bar = TkMenu.new(@root)
		@root_window['menu'] = @menu_bar

		# Spacer label
		@spacer = TkLabel.new(@root_window) {
			text ' '
			grid('row'=>0, 'column'=>0)
		}
		
		# Label for the User window
		@user_label = TkLabel.new(@root_window) {
			text 'Users'
			font TkFont.new('courier 14 bold')
			grid('row'=>1, 'column'=>1)
		}
		
		@user_list = TkText.new(@root_window) {
			width 25
			height 50
			grid('row'=>2, 'column'=>1, 'rowspan'=>3)
		}
		
		# Another spacer label
		@spacer = TkLabel.new(@root_window) {
			text ' '
			grid('row'=>0, 'column'=>2)
		}
		
		# Label for the chat window
		@chat_window_label = TkLabel.new(@root_window) {
			text 'Chat Window'
			font TkFont.new('courier 14 bold')
			grid('row'=>1, 'column'=>3)
		}
		
		# Chat window scrollbar
		@chat_window_scrollbar = TkScrollbar.new(@root_window) {
			orient 'vertical'
			grid('row'=>2, 'column'=>4, 'sticky'=>'ns')
		}

		# Window where the messages from the server will appear
		@chat_window = TkText.new(@root_window) {
			width 70
			height 35
			wrap 'word'
			grid('row'=>2, 'column'=>3, 'sticky'=>'ns')
		}
		
		# attach the chat window scrollbar to the chat window
		@chat_window.yscrollbar(@chat_window_scrollbar)
		
		# label for the entry window
		@entry_label = TkLabel.new(@root_window) {
			text 'Enter Message'
			font TkFont.new('courier 14 bold')
			grid('row'=>3, 'column'=>3, 'sticky'=>'nw')
		}
		
		@to_label = TkLabel.new(@root_window) {
			text 'To:'
			font TkFont.new('courier 12 bold')
			grid('row'=>3, 'column'=>3, 'sticky'=>'sw')
		}
		
		@to_entry = TkEntry.new(@root_window) {
			width 87
			grid('row'=>3, 'column'=>3, 'sticky'=>'se')
		}
		
		# User's text entry window
		@entry_window = TkText.new(@root_window) {
			width 70
			height 5
			wrap 'word'
			grid('row'=>4, 'column'=>3, 'sticky'=>'n')
		}
		
		# Submit button, to send the text from the entry box to the server
		@submit_button = TkButton.new(@root_window) {
			text 'Submit'
			grid('row'=>3, 'column'=>3, 'sticky'=>'e')
		}
	end
	
	attr_accessor :root_window, :menu_bar, :user_list, :chat_window, :entry_window, :submit_button, :to_entry
end #End of RootWindow class

#-----------------------------------------------#
# Method to confirm that the user wants to quit #
# the application                               #
#-----------------------------------------------#
def confirm_quit
	confirmExit = Tk::messageBox :type => 'yesno',
		:message => "Are you sure you want to quit?",
		:icon => "question", :title => 'Exit'
	if confirmExit == 'yes'
		exit
	end
end

#-----------------------------------------------#
# Method to let the user switch the view mode   #
# to show just names, or names with the host and#
# port.                                         #
#-----------------------------------------------#
def toggle_view(root_obj, socket)

	# Send the message to the server to set the option
	socket.puts "toggle_full_names"
	
	# Get the return message from the server
	message = socket.gets
	
	# Display the return message in a message box, so the user knows what it is set to now.
	show_name_change = Tk::messageBox :type => 'ok',
		:message => message,
		:icon => "info", :title => 'Name View'
end

#-----------------------------------------------#
# Method to display a simple About screen       #
# showing basic program information             #
#-----------------------------------------------#
def about(root_obj)

	# create the about window
	about_window = TkToplevel.new(root_obj.root_window) { title "About" }
	
	# create the text box where the text is displayed, the wrap word option will make sure words aren't seperated onto different lines
	about_text = TkText.new(about_window) {
		height 18
		width 50
		wrap "word"
		grid("row"=>0, "column"=>0)
	}
	
	# Create an OK button to close the about window
	ok_button = TkButton.new(about_window) {
		text "OK"
		command { about_window.destroy }
		grid("row"=>1, "column"=>0, "sticky"=>'e')
	}
	
	# Create some tags to make certain text more visible to the user.
	about_text.tag_add('heading', 0.0, 1.0)
	about_text.tag_add('heading2', 9.0, 10.0)
	about_text.tag_configure('heading', :font=>'helvetica 16 bold')
	about_text.tag_configure('heading2', :font=>'helvetica 14 bold')
	
	# Create and insert the text to display to the user.
	about_text.insert("end", "\t\tRubyChat\n", 'heading')
	about = "RubyChat is a GUI chat client written in Ruby/Tk.\nPaired with ChatServer.rb this program allows users to connect to a server, and send messages, either "
	about2 = "to all users, or private messages to a specific user."
	about3 = "Written by: The Scholars"
	about4 = "Team Scholars:\n"
	scholars = "Dan Cannan\nJake Richardon\nJosh Braaten\nJeff Ding\nJesus Carrillo"
	about_text.insert("end", about + about2 + "\n\n" + about3 + "\n\n")
	about_text.insert("end", about4, 'heading2')
	about_text.insert("end", scholars)
end


#-----------------------------------------------#
# Method to show a help menu for users          #
# the help window is seperated into different   #
# tabs.  The default tab displayed depends on   #
# which screen the user was on when they hit    #
# help from the menu.                           #
#-----------------------------------------------#
def help(root_obj, tab)

	# Create the help top level window
	help_window = TkToplevel.new(root_obj.root_window) { title "Help" }
	
	# Create a notebook tile, which gives us the option of having different tabs
	help_notebook = Tk::Tile::Notebook.new(help_window) {
		# specify the options for the notebook, and place it
		height 501
		width 500
		grid("row"=>0, "column"=>0)
	}
	
	# create the frames that will be the different tabs in the notebook.  We have 3, one for connection, one for logging in, and one for the chat window
	connect = TkFrame.new(help_notebook)
	login = TkFrame.new(help_notebook)
	chat = TkFrame.new(help_notebook)
	
	# Create the text boxes to show the help information.  The Wrap Word option will wrap words in the text boxes, so that words aren't broken up on different lines

	# text box for the connection help frame
	connect_help = TkText.new(connect) {
		height 31
		width 62
		wrap "word"
		grid("row"=>0, "column"=>0)
	}
	
	# text box for the login help frame
	login_help = TkText.new(login) {
		height 31
		width 62
		wrap "word"
		grid("row"=>0, "column"=>0)
	}
	
	# text box for the chat window help frame
	chat_help = TkText.new(chat) {
		height 31
		width 62
		wrap "word"
		grid("row"=>0, "column"=>0)
	}
		
	# Add the frames to the notebook
	help_notebook.add connect, :text=>"Connect"
	help_notebook.add login, :text=>"Login"
	help_notebook.add chat, :text=>"Chat"
	
	# Add an OK button, that will close the help window
	ok_button = TkButton.new(help_window) {
		text "OK"
		command { help_window.destroy }
		grid("row"=>1, "column"=>0, "sticky"=>'e')
	}
	
	# Insert text into the text boxes.  This is the help information the user sees when the click Help
	connect_help.insert("end", "Connection Window:\n\nThe connection window has two entry boxes:\nHostname wants the name of the host to connect to, with localhost being the default\nPort wants the port address, 5535 being the default\n")
	connection_help = "\nConnecting:\n\nTo connect, type in the host's name and the port the server is listening on, and press the connect button.  If the server is not running, you will get an error saying that the connection was refused\n"
	connection_help2 = "\nOnce connected, you will get a message response back from the server saying that you are connect, and that you need to authenticate.  Pressing OK on this window will bring up the screen to login.\n\nFor help logging in, press the login help tab."
	connect_help.insert("end", connection_help)
	connect_help.insert("end", connection_help2)
	
	login_help_text = "Login Window:\n\nThe login window asks you for the username and password you are using to log in.  The window has two boxes:\nUsername is your username\nPassword is the password you use to log in to the server"
	login_help_text2 = "\n\nLogging in:\n\nTo log in, put in your username and password, and press the login button.  If there is a problem with the username or the password, you will get an error message from the server, indicating the problem\n\n"
	login_help_text3 = "Once you are successfully logged in, the login window will close, and the chat window will open up, and there will be a message in the main chat window indicating that your login was successful."
	login_help.insert("end", login_help_text)
	login_help.insert("end", login_help_text2)
	login_help.insert("end", login_help_text3)
	
	chat_help_text = "Chat window:\n\nThe chat window is seperated into a number of different boxes:\nUser List is the list of users logged in, this will update as users log in and out\nThe Chat Window is the window where messages from the server and users are displayed\nThe Entry Window has two components, the To box is where you type in who to send messages to, and the main entry window is where you type the text to send\n\n"
	chat_help_text2 = "Sending Messages:\n\nTo send a private, or unicast message, type the name of a user logged in into the 'To' box, and type a message to send into the entry window, and press submit.  The message will be sent only to the user you specified.\n\nSending a broadcast message: To send a message to all users, leave the 'To' box empty, and just type in a message and press submit, and the message will be sent to all users\n\n"
	chat_help_text3 = "Receiving Messages:\n\nIn the chat window, if you see a user's name, followed by ':', that means that the message is visible to all users.  If you see a message with a user's name and 'To you' after it, that means that the message was a private message sent only to you.\n\n"
	chat_help_text4 = "Message Window Options:\n\nIf you click the View menu on the top menu, you have the option to show full names.  Showing full names means that messages from other users will list their name followed by their host and port numbers.  If you turn this off, you will only see the user's name when messages are sent."
	chat_help.insert("end", chat_help_text)
	chat_help.insert("end", chat_help_text2)
	chat_help.insert("end", chat_help_text3)
	chat_help.insert("end", chat_help_text4)
	
	# Select the tab to display to the user, this is sent from the program, depending on where they clicked help (0 for connection help, 1 for login help, and 2 for chat window help)
	help_notebook.select tab
end

#-----------------------------------------------#
# Method to connect to the server.  This will   #
# take the host and port the user entered, and  #
# and create the socket, and then send the user #
# to the authenticate method, which will allow  #
# the user to send the username/password        #
#-----------------------------------------------#
def connect(host, port, window, root)
	# create the socket
	socket = TCPSocket.new(host, port)
	
	# get the message that the server sent us
	message = socket.gets
	
	# split the message and check the first word
	server_message = message.split
	
	# if the first word is 100, then that is a message that we are connected
	if server_message.first == "100"
		# The next message sent is asking us to log in
		login_message = socket.gets
		
		# This message is asking for the password.  We are going to ignore it for this GUI client
		password_message = socket.gets
		
		# Take the 2 100 messages from the server, and put them together, and display them in a message box
		message += login_message
		connection_accepted = Tk::messageBox :type => 'ok',
			:message=>message, :icon=>'info', :title=>'Connected'
			
		# destroy the connection window, and create a login window
		window.destroy
		
		# create the authentication window
		authentication_window = TkToplevel.new(root.root_window) { title 'Login' }
		
		# Create a label asking the user to log in.
		login_label = TkLabel.new(authentication_window) {
			text 'Please login to continue'
			grid('row'=>0, 'column'=>1, 'columnspan'=>2)
		}
		
		# label for the user name entry box
		username_label = TkLabel.new(authentication_window) {
			text 'Username'
			grid('row'=>1, 'column'=>0)
		}

		# the username entry box
		username_entry = TkEntry.new(authentication_window) {
			grid('row'=>1, 'column'=>1)
		}

		# password entry box label
		password_label = TkLabel.new(authentication_window) {
			text 'Password'
			grid('row'=>2, 'column'=>0)
		}

		# password entry box
		password_entry = TkEntry.new(authentication_window) {
			show '*'
			grid('row'=>2, 'column'=>1)
		}
		
		# button to send the username and password to the server
		login_button = TkButton.new(authentication_window) {
			text 'Login'
			command { authenticate(password_message, username_entry.get.to_s, password_entry.get.to_s, socket, authentication_window, root) }
			grid('row'=>3, 'column'=>1, 'sticky'=>'e')
		}
		
		login_menu = TkMenu.new(authentication_window)
			authentication_window['menu'] = login_menu
			login_help = TkMenu.new(login_menu)
			login_menu.add :cascade, :menu=>login_help, :label=>'Help'
			login_help.add :command, :label=>'About', :underline=>0, :command=>proc{ about(root) }
			login_help.add :command, :label=>'Help', :underline=>0, :command=>proc{ help(root, 1) }
	
		# bind the authentication window to the return key, so the user doesn't have to click the login button
		authentication_window.bind("Return") { authenticate(password_message, username_entry.get.to_s, password_entry.get.to_s, socket, authentication_window, root) }
	end
# Rescue code if the server is not running
rescue SocketError => details
	connection_error = Tk::messageBox :type=>'ok',
		:message=>"Connection Error, invalid host name or port",
		:icon=>"error", :title=>"Connection Error"
	connection_window.focus
end

#-----------------------------------------------#
# Method to send the username/password to the   #
# server.  This will ignore some of the messages#
# that the server is sending, and only focus    #
# on the messages that the username/password is #
# correct                                       #
#-----------------------------------------------#
def authenticate (pass_message, user, pass, socket, window, root)
	# send the username
	socket.puts user
	
	# get the message from the server
	message = socket.gets.chomp!
	
	# split the message, and look at the first word
	server_message = message.split
	
	# if the username is correct, then get send the password
	if server_message.first == "310"
		
		# message from the server asking for the password, we will ignore it because we already have it
		pass_message = socket.gets
		
		# send the password
		socket.puts pass
		
		# Get the message from the server, and split it to look at the first word
		message = socket.gets
		server_message = message.split
		
		# if the password is correct, then get the successful authentication message from the server, get the list of users, and load the root window
		if server_message.first == "320"
			message = socket.gets
			user_list = Array.new
			user_list = get_user_list(socket)
			chat(socket, window, root, message, user_list)
			
		# if the password is not correct, then eat the message from the server asking for the username again
		else
			pass_message = socket.gets
			
			# put up a message box letting the user know the password was invalid
			password_error = Tk::messageBox :type=>'ok',
				:message=>message, :icon=>"error", :title=>"Invalid Password"
		end # end password check
	
	# if the username is incorrect, then display a message box to the user letting them know what the problem is
	else
		pass_message = socket.gets
		invalid_username = Tk::messageBox :type=>'ok',
			:message=>message, :icon=>"error", :title=>"Invalid Username"
	end # end username check
end # end authenticate method

#-----------------------------------------------#
# Method to get the list of users from the      #
# server.  This will store the list in a local  #
# array that we can update as users login/logoff#
#-----------------------------------------------#
def get_user_list(socket)
	# create a new empty local array
	list = Array.new
	
	# send "list" to the server, which will make the server send the user list
	socket.puts "list"
	message = socket.gets
	
	# parse the string of users the server sent us
	user_string = socket.gets.chomp!
	user_list_raw = user_string.split
	
	# for each user we were sent, add it to a new user hash, and push it into our local user list
	user_list_raw.each do |i|
		user_list_hash = Hash.new
		user_list_hash["name"] = i
		list << user_list_hash
	end # end user_list_raw processing
	
	# return the list
	return list
end

#-----------------------------------------------#
# Method to get send text to the server.        #
# This will take in whatever is in the entry box#
# and send it to the server as a unicast or     #
# broadcast message.  For all messages, this    #
# will check the list of users in the to field, #
# if empty, it will be a broadcast, but if there#
# is a user in the box, it will be a unicast.   #
#-----------------------------------------------#
def textEntry(socket, root_obj, users, code)

	to = root_obj.to_entry.get
	text = root_obj.entry_window.get('0.0', 'end')
	
	if code == 0
		text = text.chomp!
	end
	
	if to == ""
		# Text to prepend to the local chat client
		you_say = "You said: " + text
		
		# Text to prepend to the message sent to the server
		send_text = "broadcast " + text
		
		# send the text to the server
		socket.send(send_text, 0)
		socket.flush
		
	else
		
		# Boolean variable, set to false to start
		connected_user = false
		
		# Go through the connected users, and set the connected user variable to true if they are found
		users.each do |find_user|
			if find_user["name"] == to
				connected_user = true
				break
			end
		end
		
		# Check if the user is connected, and if they are, send them the message
		if connected_user
			you_say = "You said to " + to + ": " + text
			send_text = "unicast " + to + " " + text
			socket.puts send_text
			
			# Get the notification from the server, but don't do anything with it
			notification = socket.gets
		else
			
			# Display a message if the username entered is not found
			unicast_error = Tk::messageBox :type=>'ok',
				:message=>"User not found", :icon=>"error", :title=>"Unicast Send Error"
		end
		
	end
	
	# insert the text into the chat window
	root_obj.chat_window.insert('end', you_say)
	
	# delete the text from the entry text box, and the to entry box
	root_obj.entry_window.delete('0.0', 'end')
	root_obj.to_entry.delete('0', 'end')
	
	# make sure that the chat window is always showing the bottom message, and will autoscroll
	root_obj.chat_window.see('end')
end

#-----------------------------------------------#
# Method to process text sent from the server.  #
# This will allow us to do things like add users#
# or remove users from the user list, and       #
# to format text as it is displayed in the      #
# chat window.                                  #
#-----------------------------------------------#
def process_message(notification, raw_text, socket, root_obj, list)
	from = notification[3]
	
	# split the raw text sent from the server
	server_message = raw_text.split
	
	# switch on the code that was sent
	case server_message.first
	
		# 140 means a user connected.  Get the username, and add them to the list of connected users
		when "140"
			# Create a new hash
			user_hash = Hash.new
			
			message = server_message[3]
			
			# get the username
			user=message.split('@')
			user_hash["name"] = user[0]
			
			# push it into our local user list
			list << user_hash
			
			# add the user to the user_list window
			root_obj.user_list.insert("end", list[list.length - 1]["name"] + "\n")
			
			root_obj.chat_window.insert("end", raw_text)
			
		# 150 means that the message is a unicast, so construct the message to look a bit different from broadcasts
		when "150"
			from = notification[2]
			code = server_message.shift
			message = server_message.join " "
			unicast_message = "Message to you from " + from + " " + message + "\n"
			root_obj.chat_window.insert("end", unicast_message)
			
		# 190 means a user disconnected
		when "190"
			# variable to use for the index
			ind = 0
			
			message = server_message[1]
			
			# get the username that just disconnected
			user_raw=message.split('@')
			user=user_raw.shift
			
			# find the user in our local list of users
			list.each_with_index do |item, index|
				if item["name"] == user
					ind = index
				end
			end
			
			# delete the user from our local array
			list.delete_at(ind)
			
			# clear and re-populate the user list window
			root_obj.user_list.delete('0.0', 'end')
			list.each do |item|
				root_obj.user_list.insert('end', item["name"] + "\n")
			end
			
			root_obj.chat_window.insert("end", raw_text)
			
		else
			root_obj.chat_window.insert("end", from + ": " + raw_text)
	end # end case
end

#-----------------------------------------------#
# Method for the main chat feature.  This runs  #
# in a new thread, as the ruby/tk main loop     #
# causes issues.  This will get server messages #
# which we will send to other messages to       #
# process.                                      #
#-----------------------------------------------#
def chat(socket, window, root, message, users)

	view = TkMenu.new(root.menu_bar)
	root.menu_bar.add :cascade, :menu=>view, :label=>'View'
	view.add :command, :label=>'Full Names', :underline=>0, :command=>proc{ toggle_view(root, socket) }
	root_help = TkMenu.new(root.menu_bar)
	root.menu_bar.add :cascade, :menu=>root_help, :label=>'Help'
	root_help.add :command, :label=>'About', :underline=>0, :command=>proc{ about(root) }
	root_help.add :command, :label=>'Help', :underline=>0, :command=>proc{ help(root, 2) }

	# add the current user list to the user list window
	users.each do |user|
		root.user_list.insert("end", user["name"] + "\n")
	end
	
	# maximize the root window
	root.root_window.deiconify
	
	# destroy the login window
	window.destroy
	
	# insert the last message we received from the login process, which is that we are successfully authenticated
	root.chat_window.insert('end', message)
	
	# bind the submit button to the text entry method
	root.root_window.bind("Return") {textEntry(socket, root, users, 0)}
	root.submit_button.command { textEntry(socket, root, users, 1) }
	
	# create a new thread so we can run the main chat loop
	Thread.new {
		while true do			
			io_ready 	= IO.select([socket, $stdin], nil, nil, nil)
			ready2read	= io_ready[0]

			next if not ready2read

			ready2read.each do |source|
			
				if not source.eof? then
				
					# there is a message to read
					message = source.gets
					
				else #source.eof? then
				
					# either the socket was closed or the user signaled end of input
					case source
					
						when socket
							root.chat_window.insert('end', "Server disconnected!, exiting\n")
							socket.close
							exit(1)
					
						when $stdin
							root.chat_window.insert('end', "End of input detected, exiting\n")
							socket.close
							exit(0)
					
						else
							root.chat_window.insert('end', "pigs are flying!\n") #should never get here
							exit(2)
					end
				end
				
				# where to write the message
				case source
					when $stdin
						root.textEntry(socket, root)
						# write to the socket
						#message = entry_window.get('0.0', 'end')
						#chat_window.insert('end', message)
						#puts message.length
						#socket.send(message, 0) unless message.nil?
						#socket.flush
						
					when socket
						# process the server message
						message_words = message.split
						notification = message_words.shift
						case notification
							when "150"
								unicast = socket.gets
								process_message(message_words, unicast, source, root, users)
								
							when "160"
								broadcast = socket.gets
								process_message(message_words, broadcast, source, root, users)
							
						end
						#root.chat_window.insert('end', message)
						
					else
						$stderr.puts "pigs are flying!\n" #should never get here
						exit(2)
				end
				
			end
		end
	}
end

#-----------------------#
#	Main program start	#
#-----------------------#

# Create a new RootWindow object
root = RootWindow.new

# Add the menu bar for the root window
file = TkMenu.new(root.menu_bar)
root.menu_bar.add :cascade, :menu=>file, :label=>'File'
file.add :command, :label=>'Quit', :underline=>0, :command=>proc{ confirm_quit }

# Create the connection window
connect_window = TkToplevel.new(root.root_window) { title "Connect" }

# Add the menu bar for the connection window
connect_menu = TkMenu.new(connect_window)
	connect_window['menu'] = connect_menu
	file = TkMenu.new(connect_menu)
	connect_menu.add :cascade, :menu=>file, :label=>'File'
	file.add :command, :label=>'Quit', :underline=>0, :command=>proc{confirm_quit}
	connect_help = TkMenu.new(connect_menu)
	connect_menu.add :cascade, :menu=>connect_help, :label=>'Help'
	connect_help.add :command, :label=>'About', :underline=>0, :command=>proc{ about(root) }
	connect_help.add :command, :label=>'Help', :underline=>0, :command=>proc{ help(root, 0) }

# label for the host name entry window
hostname_label = TkLabel.new(connect_window) {
	text 'Hostname'
	grid('row'=>1, 'column'=>0)
}

# label for the port entry window
port_label = TkLabel.new(connect_window) {
	text 'Port'
	grid('row'=>2, 'column'=>0)
}

# entry box for the host name
hostname_entry = TkEntry.new(connect_window) {
	grid('row'=>1, 'column'=>1)
}

# entry box for the port
port_entry = TkEntry.new(connect_window) {
	grid('row'=>2, 'column'=>1)
}

# TkVariable to store the host and port
host = TkVariable.new
port = TkVariable.new

# assign the TkVariables to the host and port entry boxes
hostname_entry.textvariable = host
port_entry.textvariable = port

# default values for the host and port
host.value = "localhost"
port.value = 5535

# Connect button
connect_button = TkButton.new(connect_window) {
	text 'Connect'
	grid('row'=>5, 'column'=>1, 'sticky'=>'e')
	command { connect(hostname_entry.get.to_s, port_entry.get.to_i, connect_window, root) }
}

# Bind the return key to the connection window, and set the connect method to it
connect_window.bind("Return") { connect(hostname_entry.get.to_s, port_entry.get.to_i, connect_window, root) }

# Minimize the root window
root.root_window.lower.iconify

connect_window.raise.focus

connect_button.focus

# start the Tk main loop
Tk.mainloop