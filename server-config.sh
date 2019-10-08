#!/bin/bash
if [ $USER == 'root' ]
then
  passwd;
  echo "Creating new user... Enter username:\n";
  read username;
  adduser $username;
  usermod -aG sudo $username;
  echo "Logging out in 5 seconds. Use your username to login again";
  sleep 5;
  logout
fi
