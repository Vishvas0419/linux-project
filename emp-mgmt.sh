#!/bin/bash

# Check if sysvbanner is installed
if ! command -v banner &> /dev/null; then
    echo "Installing sysvbanner..."
    sudo apt update
    sudo apt install -y sysvbanner
fi

banner "Welcome"

# Create the database file if it doesn't exist
touch mydb

login() {
    clear
    echo "------------ LOGIN ------------"
    read -p "Username: " user
    read -s -p "Password: " pass
    echo

    if [[ "$user" == "group18" && "$pass" == "18" ]]; then
        echo "Login successful!"
        main_menu
    else
        echo "Invalid credentials!"
        exit 1
    fi
}

main_menu() {
    while true; do
        echo
        echo "----- Employee Management System -----"
        echo "1. Add Record"
        echo "2. Delete Record"
        echo "3. Modify Record"
        echo "4. Display Records"
        echo "5. Sort Records"
        echo "6. Search Record"
        echo "7. Count Records"
        echo "8. Exit"
        echo "--------------------------------------"
        read -p "Enter your choice: " choice

        case $choice in
            1) add_record ;;
            2) delete_record ;;
            3) edit_employee;;
            4) display_records ;;
            5) sort_records ;;
            6) search_record ;;
            7) count_records ;;
            8) echo "Exiting..."; exit 0 ;;
            *) echo "Invalid choice!" ;;
        esac
    done
}

add_record() {
    echo "--- Add Record ---"
    read -p "Employee ID: " id
    if grep -q "^$id\t" mydb; then
        echo "Record with ID $id already exists!"
        return
    fi

    read -p "Name: " name
    read -p "Age: " age
    read -p "Salary: " salary
    read -p "Designation: " desig

    echo -e "$id\t$name\t$age\t$salary\t$desig" >> mydb
    echo "Record added!"
}

delete_record() {
    echo "--- Delete Record ---"
    read -p "Enter Employee ID to delete: " id

    if grep -q "^$id\t" mydb; then
        grep -v "^$id\t" mydb > temp && mv temp mydb
        echo "Record deleted!"
    else
        echo "Record not found!"
    fi
}

edit_employee() {
    read -p "Enter the employee ID to edit: " id

    # Sanity check: Display contents of the database to ensure it's being read
    echo "Current database contents:"
    cat mydb
    echo

    # Search for the employee in the database
    employee=$(grep -P "^$id\t" "$mydb")

    if [ -z "$employee" ]; then
        echo "Employee with ID $id not found."
        return
    fi

    # Extract current employee data (ID, Name, Age, Salary, Designation)
    current_id=$(echo "$employee" | cut -f1)
    current_name=$(echo "$employee" | cut -f2)
    current_age=$(echo "$employee" | cut -f3)
    current_salary=$(echo "$employee" | cut -f4)
    current_designation=$(echo "$employee" | cut -f5)

    # Ask user if they want to change the name
    read -p "Current Name: $current_name. Enter new name (or press Enter to keep it): " new_name
    new_name=${new_name:-$current_name}  # If no input, keep current name

    # Ask user if they want to change the age
    read -p "Current Age: $current_age. Enter new age (or press Enter to keep it): " new_age
    new_age=${new_age:-$current_age}  # If no input, keep current age

    # Ask user if they want to change the salary
    read -p "Current Salary: $current_salary. Enter new salary (or press Enter to keep it): " new_salary
    new_salary=${new_salary:-$current_salary}  # If no input, keep current salary

    # Ask user if they want to change the designation
    read -p "Current Designation: $current_designation. Enter new designation (or press Enter to keep it): " new_designation
    new_designation=${new_designation:-$current_designation}  # If no input, keep current designation

    # Update the employee data in the mydb file
    temp_file=$(mktemp)
    awk -v id="$id" -v name="$new_name" -v age="$new_age" -v salary="$new_salary" -v designation="$new_designation" \
    -F'\t' 'BEGIN {OFS="\t"} {if ($1 == id) {$2 = name; $3 = age; $4 = salary; $5 = designation} print}' "$mydb" > "$temp_file" && mv "$temp_file" "$mydb"
    
    echo "Employee details updated successfully."
}



display_records() {
    echo "--- Employee Records ---"
    if [[ ! -s mydb ]]; then
        echo "No records found!"
        return
    fi

    echo -e "ID\tName\tAge\tSalary\tDesignation"
    echo "-----------------------------------------"
    column -t -s $'\t' mydb
}

sort_records() {
    echo "--- Sorted Records by ID ---"
    sort -n mydb | column -t -s $'\t'
}

search_record() {
    echo "--- Search Record ---"
    read -p "Enter Employee ID to search: " id

    # Sanity check: Display contents of the database to ensure it's being read
    echo "Current database contents:"
    cat mydb
    echo

    result=$(grep -P "^$id\t" mydb)

    if [[ -n $result ]]; then
        echo -e "ID\tName\tAge\tSalary\tDesignation"
        echo "$result" | column -t -s $'\t'
    else
        echo "Record not found!"
    fi
}

count_records() {
    echo "--- Total Records ---"
    count=$(wc -l < mydb)
    echo "Total number of records: $count"
}

# Start the program
login
