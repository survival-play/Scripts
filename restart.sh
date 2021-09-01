# A Script that allows us to restart the entire network (or even a single server) with a single command
# If the arguments are empty, than all servers will restart, if an argument is given, then only the server with the same screenname will restart
# All servers must be registered in a file called "servers.txt" (in the same directory) according to these scheme: screenname:pathToStartFile:stopCommand:ram
# You are able to use "", Example: lobby:lobby/restart.sh:stop:1G or "lobby":"lobby/restart.sh":"stop":"1G"
# All Paths are relative to this file
# The specified startfile is sourced with the screenname as the first argument and the amount of ram as the second argument

restart()
{
  screen -S "$1" -X stuff "$2\n"
  await_terminate $1
  cd "$(dirname "$3")"
  
  source "$(basename "$3")" "$1" "$4"
  cd "$(dirname "$FILE_PATH")"
}

await_terminate()
{
  while screen -ls | grep -q "$1"
  do
    sleep 1
  done
}

SERVERS="servers.txt"
FILE_PATH=`realpath "$0"`

touch "$SERVERS"

while IFS= read -r line
do
  NAME=`echo "$line" | cut -d":" -f1 | sed 's/\"//g'`
  START_PATH=`echo "$line" | cut -d":" -f2 | sed 's/\"//g'`
  COMMAND=`echo "$line" | cut -d":" -f3 | sed 's/\"//g'`
  RAM=`echo "$line" | cut -d":" -f4 | sed 's/\"//g'`

  if [ ! -z "$1" ] && [ "$1" != "$NAME" ]; then continue; fi
  echo "restarting $NAME with $RAM Memory"
  restart $NAME $COMMAND $START_PATH $RAM
done < "$SERVERS"
