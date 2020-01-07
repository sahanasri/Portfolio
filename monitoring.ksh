#! /bin/ksh -e

#path of the directory that has the log files
path='/etl/data/prod/admin'

#path where the script is located
path2='/etl/opt/get_tracking'
email_list='sahana.srivatsan@optum.com'


cd $path

#Pulling date from transaction file and comparing with current date. Removes transaction file is dates don't match - this ensures transaction file keeps only current date log files

test=`awk -F_20 'NR==1 {print $2}' $path2/transaction_all3.txt`
file_date=`echo $test | cut -c1-8`
new_file_date="20"$file_date
curr_date=$(date +"%Y-%m-%d")
if [ "$new_file_date" != "$curr_date" ]; then
       rm $path2/transaction_all3.txt

fi

#Checks within the last hour, which files were updated and writes to new_logs file

find . -mtime -.04 -name '*.log' -exec grep -e 'Phase[ ][0-9]' {} + >> $path2/new_logs3.txt || true

#If transaction file isn't there, add it

if [ ! -f $path2/transaction_all3.txt ]; then
    touch $path2/transaction_all3.txt
fi

echo "end"

#Most jobs will show timings for every phase - this command only picks the largest and most recent timing from any group of jobs and writes to logs above

cat $path2/new_logs3.txt | awk '{gsub(/\(/,"",$7); if($7>=3600) seen[$1]=$7} END{for(i in seen) printf "%-15s\t%s\n", i, seen[i] }' | sort >> $path2/logs_above3.txt

#Compares most recent high running jobs with ones already written to transaction and removes any duplicates
diff $path2/logs_above3.txt $path2/transaction_all3.txt | grep "^<" | cut -d"<" -f2 | sed -e 's/^[ \t]*//' > $path2/nonduplicate3.txt

#Converts the timings to minutes and sends an email alert with high running job names
cat $path2/nonduplicate3.txt | while read line
do
        echo "$line" >> $path2/transaction_all3.txt
                test=`echo "$line" | awk -F' ' '{print $2}'`
                divisor="60"
                test2=`expr $test / $divisor`
                before="$line"
                after=${before//$test/$test2}

                echo " $after Minutes " >> $path2/email3.txt


done
    sort -nr -k 2 $path2/email3.txt >> $path2/email_sort3.txt
    mail -s "Data Warehouse AbInitio long running jobs" $email_list < $path2/email_sort3.txt

#Cleaning up all files
rm $path2/new_logs3.txt
rm $path2/logs_above3.txt
rm $path2/nonduplicate3.txt
rm $path2/email3.txt
rm $path2/email_sort3.txt
exit 0
