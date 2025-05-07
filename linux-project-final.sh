\#!/bin/bash
mydb="mydb"

# EMPLOYEE MANAGEMENT SYSTEM

# Check and install sysvbanner if missing

if ! command -v banner &> /dev/null; then
echo "Installing sysvbanner..."
sudo apt update
sudo apt install -y sysvbanner
fi

banner "Welcome"

# Create database if it doesn't exist

touch "\$mydb"

login() {
clear
user=\$(whiptail --inputbox "Enter Username:" 8 40 --title "LOGIN" 3>&1 1>&2 2>&3)
\[ \$? -ne 0 ] && exit 1

```
pass=$(whiptail --passwordbox "Enter Password:" 8 40 --title "LOGIN" 3>&1 1>&2 2>&3)
[ $? -ne 0 ] && exit 1

if [[ "$user" == "vishvas" && "$pass" == "1082" ]]; then
    whiptail --msgbox "Login successful!" 8 40
    main_menu
else
    whiptail --msgbox "Invalid credentials!" 8 40
    exit 1
fi
```

}

main\_menu() {
while true; do
choice=\$(whiptail --title "Employee Management System" --menu "Choose an option" 20 50 10&#x20;
"1" "Add Record"&#x20;
"2" "Delete Record"&#x20;
"3" "Modify Record"&#x20;
"4" "Display Records"&#x20;
"5" "Sort Records"&#x20;
"6" "Search Record"&#x20;
"7" "Count Records"&#x20;
"8" "Exit" 3>&1 1>&2 2>&3)

```
    [ $? -ne 0 ] && continue

    case $choice in
        1) add_record ;;
        2) delete_record ;;
        3) edit_record ;;
        4) display_records ;;
        5) sort_records ;;
        6) search_record ;;
        7) count_records ;;
        8) exit ;;
    esac
done
```

}

add\_record() {
id=\$(whiptail --inputbox "Enter Employee ID:" 8 40 --title "Add Record" 3>&1 1>&2 2>&3)
\[ \$? -ne 0 ] && return

```
if grep -q "^$id\t" "$mydb"; then
    whiptail --msgbox "Record with ID $id already exists!" 8 40
    return
fi

name=$(whiptail --inputbox "Enter Name:" 8 40 --title "Add Record" 3>&1 1>&2 2>&3)
[ $? -ne 0 ] && return
age=$(whiptail --inputbox "Enter Age:" 8 40 --title "Add Record" 3>&1 1>&2 2>&3)
[ $? -ne 0 ] && return
salary=$(whiptail --inputbox "Enter Salary:" 8 40 --title "Add Record" 3>&1 1>&2 2>&3)
[ $? -ne 0 ] && return
desig=$(whiptail --inputbox "Enter Designation:" 8 40 --title "Add Record" 3>&1 1>&2 2>&3)
[ $? -ne 0 ] && return

echo -e "$id\t$name\t$age\t$salary\t$desig" >> "$mydb"
whiptail --msgbox "Record added successfully!" 8 40
```

}

delete\_record() {
id=\$(whiptail --inputbox "Enter Employee ID to delete:" 8 40 --title "Delete Record" 3>&1 1>&2 2>&3)
\[ \$? -ne 0 ] && return
if grep -q "^\$id\[\[:space:]]" "\$mydb"; then
grep -v "^\$id\[\[:space:]]" "\$mydb" > temp && mv temp "\$mydb"
whiptail --msgbox "Record deleted successfully!" 8 40
else
whiptail --msgbox "Record not found!" 8 40
fi

}

edit\_record() {
id=\$(whiptail --inputbox "Enter Employee ID to edit:" 8 40 --title "Edit Record" 3>&1 1>&2 2>&3)

```
# Get the record
record=$(grep "^$id[[:space:]]" "$mydb")

if [ -z "$record" ]; then
    whiptail --msgbox "Record not found!" 8 40
    return
fi

# Split the fields
old_name=$(echo "$record" | awk -F'\t' '{print $2}')
old_age=$(echo "$record" | awk -F'\t' '{print $3}')
old_salary=$(echo "$record" | awk -F'\t' '{print $4}')
old_desig=$(echo "$record" | awk -F'\t' '{print $5}')

# Ask for new values, allow skipping
name=$(whiptail --inputbox "Enter Name [$old_name]:" 8 40 --title "Edit Record" 3>&1 1>&2 2>&3)
age=$(whiptail --inputbox "Enter Age [$old_age]:" 8 40 --title "Edit Record" 3>&1 1>&2 2>&3)
salary=$(whiptail --inputbox "Enter Salary [$old_salary]:" 8 40 --title "Edit Record" 3>&1 1>&2 2>&3)
desig=$(whiptail --inputbox "Enter Designation [$old_desig]:" 8 40 --title "Edit Record" 3>&1 1>&2 2>&3)

# Use old values if new input is empty
[ -z "$name" ] && name=$old_name
[ -z "$age" ] && age=$old_age
[ -z "$salary" ] && salary=$old_salary
[ -z "$desig" ] && desig=$old_desig

# Update record
grep -v "^$id[[:space:]]" "$mydb" > temp && mv temp "$mydb"
echo -e "$id\t$name\t$age\t$salary\t$desig" >> "$mydb"

whiptail --msgbox "Record updated successfully!" 8 40
```

}

search\_record() {
id=\$(whiptail --inputbox "Enter Employee ID to search:" 8 40 --title "Search Record" 3>&1 1>&2 2>&3)
\[ \$? -ne 0 ] && return

```
result=$(grep -P "^$id\t" "$mydb")
if [[ -n $result ]]; then
    echo -e "ID\tName\tAge\tSalary\tDesignation\n$result" | column -t -s $'\t' > /tmp/employeetmp
    whiptail --textbox /tmp/employeetmp 15 60 --title "Search Result"
else
    whiptail --msgbox "Record not found!" 8 40
fi
```

}

display\_records() {
if \[\[ ! -s "\$mydb" ]]; then
whiptail --msgbox "No records found!" 8 40
return
fi
echo -e "ID\tName\tAge\tSalary\tDesignation" > /tmp/employeetmp
cat "\$mydb" >> /tmp/employeetmp
column -t -s \$'\t' /tmp/employeetmp > /tmp/employeetmp2
whiptail --textbox /tmp/employeetmp2 20 60 --title "All Employee Records"
}

sort\_records() {
if \[\[ ! -s "\$mydb" ]]; then
whiptail --msgbox "No records found!" 8 40
return
fi
echo -e "ID\tName\tAge\tSalary\tDesignation" > /tmp/sortedtmp
sort -n "\$mydb" >> /tmp/sortedtmp
column -t -s \$'\t' /tmp/sortedtmp > /tmp/sortedtmp2
whiptail --textbox /tmp/sortedtmp2 20 60 --title "Sorted Records"
}

count\_records() {
count=\$(wc -l < "\$mydb")
whiptail --msgbox "Total number of records: \$count" 8 40
}

# Start program

login
