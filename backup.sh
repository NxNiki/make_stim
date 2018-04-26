#!bin/sh

dstr=$(date +"%Y%m%d%H%M")
file_name='stim_maker_'$dstr

if [[ ! -d file_name ]];then
	mkdir $file_name
fi

cp *.m $file_name
zip -r $file_name.zip $file_name
mv $file_name.zip ../
exit 0
