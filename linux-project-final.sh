#!/bin/bash
mydb="mydb"

# Check and install sysvbanner if missing
if ! command -v banner &> /dev/null; then
    echo "Installing sysvbanner..."
    sudo apt update
    sudo apt install -y sysvbanner
fi

banner "Welcome"

# Create database if it doesn't exist
touch "$mydb"

login() {
    clear
    user=$(whiptail --inputbox "Enter Username:" 8 40 --title "LOGIN" 3>&1 1>&2 2>&3)
    [ $? -ne 0 ] && exit 1

    pass=$(whiptail --passwordbox "Enter Password:" 8 40 --title "LOGIN" 3>&1 1>&2 2>&3)
    [ $? -ne 0 ] && exit 1

    if [[ "$user" == "group18" && "$pass" == "18" ]]; then
        whiptail --msgbox "Login successful!" 8 40
        main_menu
    else
        whiptail --msgbox "Invalid credentials!" 8 40
        exit 1
    fi
}

main_menu() {
    while true; do
        choice=$(whiptail --title "Employee Management System" --menu "Choose an option" 20 50 10 \
        "1" "Add Record" \
        "2" "Delete Record" \
        "3" "Modify Record" \
        "4" "Display Records" \
        "5" "Sort Records" \
        "6" "Search Record" \
        "7" "Count Records" \
        "8" "Exit" 3>&1 1>&2 2>&3)

        [ $? -ne 0 ] && continue

        case $choice in
            1) add_record ;;
            2) delete_record ;;
            3) edit_employee ;;
            4) display_records ;;
            5) sort_records ;;
            6) search_record ;;
            7) count_records ;;
            8) exit ;;
        esac
    done
}

add_record() {
    id=$(whiptail --inputbox "Enter Employee ID:" 8 40 --title "Add Record" 3>&1 1>&2 2>&3)
    [ $? -ne 0 ] && return

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
}

delete_record() {
    id=$(whiptail --inputbox "Enter Employee ID to delete:" 8 40 --title "Delete Record" 3>&1 1>&2 2>&3)
    [ $? -ne 0 ] && return

    if grep -q "^$id\t" "$mydb"; then
        grep -v "^$id\t" "$mydb" > temp && mv temp "$mydb"
        whiptail --msgbox "Record deleted successfully!" 8 40
    else
        whiptail --msgbox "Record not found!" 8 40
    fi
}

edit_employee() {
    id=$(whiptail --inputbox "Enter Employee ID to modify:" 8 40 --title "Modify Record" 3>&1 1>&2 2>&3)
    [ $? -ne 0 ] && return

    employee=$(grep -P "^$id\t" "$mydb")
    if [ -z "$employee" ]; then
        whiptail --msgbox "Record not found!" 8 40
        return
    fi

    current_name=$(echo "$employee" | cut -f2)
    current_age=$(echo "$employee" | cut -f3)
    current_salary=$(echo "$employee" | cut -f4)
    current_designation=$(echo "$employee" | cut -f5)

    new_name=$(whiptail --inputbox "Name: [$current_name]" 8 40 --title "Modify" 3>&1 1>&2 2>&3)
    [ $? -ne 0 ] && return
    new_age=$(whiptail --inputbox "Age: [$current_age]" 8 40 --title "Modify" 3>&1 1>&2 2>&3)
    [ $? -ne 0 ] && return
    new_salary=$(whiptail --inputbox "Salary: [$current_salary]" 8 40 --title "Modify" 3>&1 1>&2 2>&3)
    [ $? -ne 0 ] && return
    new_designation=$(whiptail --inputbox "Designation: [$current_designation]" 8 40 --title "Modify" 3>&1 1>&2 2>&3)
    [ $? -ne 0 ] && return

    temp_file=$(mktemp)
    awk -v id="$id" -v name="$new_name" -v age="$new_age" -v salary="$new_salary" -v designation="$new_designation" \
    -F'\t' 'BEGIN {OFS="\t"} {if ($1 == id) {$2 = name; $3 = age; $4 = salary; $5 = designation} print}' "$mydb" > "$temp_file" && mv "$temp_file" "$mydb"

    whiptail --msgbox "Record updated successfully!" 8 40
}

search_record() {
    id=$(whiptail --inputbox "Enter Employee ID to search:" 8 40 --title "Search Record" 3>&1 1>&2 2>&3)
    [ $? -ne 0 ] && return

    result=$(grep -P "^$id\t" "$mydb")
    if [[ -n $result ]]; then
        echo -e "ID\tName\tAge\tSalary\tDesignation\n$result" | column -t -s $'\t' > /tmp/employeetmp
        whiptail --textbox /tmp/employeetmp 15 60 --title "Search Result"
    else
        whiptail --msgbox "Record not found!" 8 40
    fi
}

display_records() {
    if [[ ! -s "$mydb" ]]; then
        whiptail --msgbox "No records found!" 8 40
        return
    fi
    echo -e "ID\tName\tAge\tSalary\tDesignation" > /tmp/employeetmp
    cat "$mydb" >> /tmp/employeetmp
    column -t -s $'\t' /tmp/employeetmp > /tmp/employeetmp2
    whiptail --textbox /tmp/employeetmp2 20 60 --title "All Employee Records"
}

sort_records() {
    if [[ ! -s "$mydb" ]]; then
        whiptail --msgbox "No records found!" 8 40
        return
    fi
    echo -e "ID\tName\tAge\tSalary\tDesignation" > /tmp/sortedtmp
    sort -n "$mydb" >> /tmp/sortedtmp
    column -t -s $'\t' /tmp/sortedtmp > /tmp/sortedtmp2
    whiptail --textbox /tmp/sortedtmp2 20 60 --title "Sorted Records"
}

count_records() {
    count=$(wc -l < "$mydb")
    whiptail --msgbox "Total number of records: $count" 8 40
}

# Start program
login
