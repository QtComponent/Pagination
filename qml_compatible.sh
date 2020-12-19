#!/bin/sh

cd `dirname $0` > /dev/null

regexp="QtQuick\s+[0-9]\.[0-9]+"
target_dir=QtQuick_1_0
major=1

if (( $#==1 ))
then
    major=$1
fi

cp QtQuick_2_0/* QtQuick_1_0/ -rfd
sed -i "s/2.0/1.0/g" QtQuick_1_0/qmldir

grep -rlE "$regexp" $target_dir | xargs sed -i "s/QtQuick\\s\+[0-9]\.[0-9]\+/QtQuick $major.0/g"

targetFileName=MyTemplate
currentDirName=`pwd | awk -F "/" '{print $NF}'`
find . -name qmldir -or -name *.qml -or -name *Demo.qml | xargs sed -i "s/MyTemplate/$currentDirName/g"

for file in `find . -name $targetFileName*`
do
    newfile=`echo $file | sed "s/$targetFileName/$currentDirName/g"`
    mv $file $newfile
done
