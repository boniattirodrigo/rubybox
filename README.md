# Rubybox
It's like a Dropbox, but with Ruby.

The goal here is to sync files between clients connected through sockets, once a client adds, updates, removes or renames a file all other clients will be notified.

## Install
```
bundle install
```

## Run (Example)
You need to create the clients folders:
```
mkdir clients_folders
mkdir clients_folders/pedro
mkdir clients_folders/paulo
```

Also you need to create a folder for your server keeps the files.
```
mkdir server_folder
```

Start the server
```
ruby server.rb
# Set up the directory where the server will save the synced files:
server_folder
```

Start your clients
```
ruby client.rb
# Enter your username:
Pedro
# Enter the directory where you will sync your files:
clients_folders/pedro
```
