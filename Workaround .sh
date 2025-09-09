if ! diff -q <(tail -n +2 $properties_file) <(tail -n +2 $properties_template) >/dev/null; then
        touch file_$dd_stamp.log
        echo "$dd_stamp: The file has less than 7 lines. The workaround will be performed in 30 mins" >> file_$dd_stamp.log
        sleep 30m
        dd_stamp_now=`date +%Y%m%d-%H.%M.%S`
        echo "$dd_stamp_now: Workaround is starting" >> file_$dd_stamp.log

        first_line=$(head -n 1 $properties_file)

        sed -i '2,$d' $properties_file

        cat $properties_template >> $properties_file

        sed -i "1s/.*/$first_line/" $properties_file
        sed '2d' $properties_file >> temp.properties
        mv temp.properties $properties_file
        echo "Workaround is completed!" >> file_$dd_stamp.log

else
        echo "The file is ok."
fi
