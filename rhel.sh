
#Search only specific file types
grep -rn "keyword" --include="*.log" /path/to/directory

#Faster search (recommended for large systems)
find /path/to/directory -type f -exec grep -H "keyword" {} \;

#Basic Search
grep -r "keyword" /path/to/directory

#Process Check
ps -ef | grep process_name | grep -v grep

#Live with Scroll and Follow
tail -F file.log

#Read files
head -n 20 file.txt
tail -n 20 file.txt

#Zip Unzip List
zip -r file.zip folder_name/
unzip file.zip

#To list contents of a Zip file
unzip -l file.zip

#Ignore whitespace difference
diff -w old_file.txt new_file.txt
