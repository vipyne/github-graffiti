#!/usr/bin/env bash

# automate a bunch of bogus commits and backdate them to turn all the squares green...

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

GRAFITTI_DESIGN=$(ruby -e " string_w_newlines = '
1111191119111118111181888881888881811111111181111111
1111999199911118111181118111118111811111111888111111
1111999999911118111181118111118111811118888888888811
1111999999911118111181118111118111811111188888881111
1111199999111118111181118111118111811111118818811111
1111119991111118111181118111118111811111188111881111
1111111911111118888181118111118111888811811111118111
'
height = 7 # days
width = 52 # weeks
in_string = string_w_newlines.gsub(/\n/, '')
out_string = in_string.clone
width.times do |ww|
  height.times do |hh|
    out_string[height * ww + hh] = in_string[width * hh + ww]
  end
end
puts out_string += '1111111' # add a couple extra days for in progress week
")

if [[ "${#@}" -lt 2 ]]; then
  echo " ##"
  echo " #  Please add at least 2 args"
  echo " # 1 github username"
  echo " # 2 repo name"
  echo " # 3 (optional) dryrun - DON'T create repo and push to github "
  echo " # "
  echo " #  usage:"
  echo " #   $ ./green_squares.sh <github username> <repo name> [dryrun]"
  echo " ##"
  exit
fi

USERNAME="$1"
REPONAME="$2"
DRYRUN="$3"

if [[ "$DRYRUN" ]]; then
  echo "dryrun -- NOT creating repo on github"
  UNIXTIME=1487739600 # Feb 22, 2018 I think; no particular reason for this default
else
  echo "creating repo on github"
  # create repo on github
  DATA_OPTS="{ \"name\":\"$REPONAME\" }"
  curl -i -X POST -u "$USERNAME" -d "$DATA_OPTS" https://api.github.com/user/repos > /dev/null

  # scrape the date of last green square
  ayearago=$(curl https://github.com/"$USERNAME" |grep -m1 data-date= |sed -e 's/^.*date="//p')

  year="${ayearago:0:4}"
  day="${ayearago:8:2}"
  month="${ayearago:5:2}"

  case $month in
  01)
    monthstr="Jan"
    ;;
  02)
    monthstr="Feb"
    ;;
  03)
    monthstr="Mar"
    ;;
  04)
    monthstr="Apr"
    ;;
  05)
    monthstr="May"
    ;;
  06)
    monthstr="Jun"
    ;;
  07)
    monthstr="Jul"
    ;;
  08)
    monthstr="Aug"
    ;;
  09)
    monthstr="Sep"
    ;;
  10)
    monthstr="Oct"
    ;;
  11)
    monthstr="Nov"
    ;;
  12)
    monthstr="Dec"
    ;;
  esac

  UNIXTIMEAYEARAGO=$(date -j -f "%b %d %Y %T" "${monthstr} ${day} ${year} 12:00:00" "+%s")
  # #UNIXTIMERIGHTNOW=$(date -j -f "%a %b %d %T %Z %Y" "`date`" "+%s")
  # #                   $ date -j -f "%b %d %Y %T" "Apr 05 2016 00:00:00" "+%s"
  UNIXTIME=$UNIXTIMEAYEARAGO
  echo "$UNIXTIMEAYEARAGO"
fi

mkdir ../"$REPONAME" || exit
cd ../"$REPONAME"

rm -rf unixtime
rm -rf .git

git init
git add .
git commit -m "initial commit of the script responsible for drawing pictures with green squares"

rewriteHistory() {
  WORKING=true
  for i in $(seq 1 ${#GRAFITTI_DESIGN}); do
    INNERLOOP="${GRAFITTI_DESIGN:i-1:1}"
    for j in $( seq 1 $(($INNERLOOP * 4)) ); do
      # # github is *not* liking how many files this produces:
      touch "$i-$j-unixtime" # sorry github
      git add .
      git commit -m "commit number $i : $j"
      COMMITTIME=$(($UNIXTIME + $j * 10))
      git commit --amend --no-edit --date "$COMMITTIME"
      wait
    done
    wait
  # 86400 seconds in a day
    UNIXTIME=$(($UNIXTIME + 86400))
  done > /dev/null
  WORKING=false
}

# whistleWhileYouWork() {
#   WORKCOUNT=1
#   echo
#   while $WORKING; do
#     seq -s~ $WORKCOUNT|tr -d '[:digit:]'
#     echo -ne "|\r"
#     sleep 1
#     ((WORKCOUNT+=1))
#   done
# }

mkdir unixtime
cd unixtime || exit

touch something

rewriteHistory # & TODO: get the background process of this to work so that we can whistle while we work!
# whistleWhileYouWork

if [[   "$DRYRUN" ]]; then
  git remote add origin git@github.com:"$USERNAME"/"$REPONAME".git
  git push -u origin master
  wait
  open "https://github.com/$USERNAME"
fi

echo 'done'

# http://vipyne.tumblr.com/post/155636272150/insert-back-to-the-future-joke-here

