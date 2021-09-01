# A Script that updates and start you're server (with aikar flags)
# This Script updates the server to the latest purpur build for the set version
# For the config and an info file, it creates a directory called "updater" and 2 files "config.txt" and "info.txt"
# In the "config.txt" you can set the minecraft version, the server should use
# The file "info.txt" contains some infos that are required by the script, DONT TOUCH IT, UNLESS YOU KNOW WHAT YOU ARE DOING!
# The Script takes 2 Arguments the first is the screenname to start the screen and the second how much ram to use

update_and_start()
{
  JAR=$( update )
  pre_agree_eula
  java -Xms"$1" -Xmx"$1" -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:InitiatingHeapOccupancyPercent=15 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -jar "$JAR" nogui
}

pre_agree_eula() 
{
  EULA="eula.txt"
  touch -a "$EULA"
  echo "eula=true" > "$EULA"
}

update() 
{
  CONFIG=updater/config.txt
  INFO=updater/info.txt
  VERSION=1.17.1
  
  mkdir -p updater
  if [ ! -f "$CONFIG" ]
  then
    touch "$CONFIG"
    echo "version=$VERSION" > "$CONFIG"
  else
    VERSION=`cut -d= -f2 "$CONFIG"`
  fi
  
  URL="https://api.pl3x.net/v2/purpur/$VERSION/latest"
  NEW_BUILD=`curl -s -X GET "$URL" | jq '.build' | sed 's/\"//g'`
  OLD_VERSION=$VERSION
  OLD_BUILD=-1
  
  if [ ! -f "$INFO" ]
  then
    touch "$INFO"
    echo -e "version=$VERSION\nbuild=-1" > "$INFO"
  else
    OLD_VERSION=`sed -n '1p' "$INFO" | cut -d= -f2`
    OLD_BUILD=`sed -n '2p' "$INFO" | cut -d= -f2`
  fi
  
  JAR_NAME="server-$VERSION-$NEW_BUILD.jar"

  if [ $VERSION != $OLD_VERSION ] || [ $OLD_BUILD != $NEW_BUILD ]
  then
    rm -f "server-$OLD_VERSION-$OLD_BUILD.jar"
    wget "$URL/download"
    mv download "$JAR_NAME"
  fi
  
  echo -e "version=$VERSION\nbuild=$NEW_BUILD" > "$INFO"
  echo $JAR_NAME
}

if [ ! -z "$1" ] && [ ! -z "$2" ]
then
  if [ "$1" == "startServer" ]
  then
    update_and_start "$2"
  else
    screen -dmS "$1" bash -c "./start.sh startServer $2"
  fi
else
  echo -e "Right useage: ./youFileName.sh screenname ram \nExample: ./start.sh lobby 1G"
fi
