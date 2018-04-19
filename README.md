# Rubybox
It's like a Dropbox, but with Ruby.

## Install
```
bundle install
```

## Run
You need to create the clients folders, for example:
```
mkdir clients_folders
mkdir clients_folders/pedro
mkdir clients_folders/paulo
```

Start the server
```
ruby server.rb
```

Start your clients (You need to fill in the username and the client folder. E.g.: clients_folders/paulo)
```
ruby client.rb
```
