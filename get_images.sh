#!/bin/bash

######################
### Kacper Skelnik ###
######################

show_help() {
    echo ""
    echo "Help:"
    echo ""
    echo "This is program to download every images from website to folder named based on URL. If folder is already exist, program download only new images, and adds them to directory."
    echo ""
    echo "To run script type"
    echo "./get_images [OPTION (optional)] URL"
    echo ""
    echo "OPTIONS:"
    echo "--help : to show help site"
    echo "-u : to print links to all images on website"
    echo "-n : to print links to new images on website"
    echo ""
}

check_input() {
    # check if a $website is not empty
    if [ -z "$website" ]; then
        echo "Error: you did not give URL"
        show_help
        echo "work stopped"
        exit 0
    fi

    # check if user doesn't type some incorrect option
    if [ "${website:0:2}" == "--" ] || [ "${website:0:1}" == "-" ]; then
        echo "Error: you gave an incorrect option"
        show_help
        echo "work stopped"
        exit 0
    fi

    # check if you got a correct response from webside
    status=$(curl -s --head -w %{http_code} $website -o /dev/null)
    if [ $status -ne 200 ]; then
        echo "Error: you give an incorrect URL"
        echo "work stopped"
        exit 0
    fi
}

create_dir() {
    # create new dir for images base on webside URL
    name=$website
    name="${name#http://}"
    name="${name#https://}"
    name="${name#ftp://}"
    name="${name#scp://}"
    name="${name#scp://}"
    name="${name#sftp://}"
    name="${name%%/*}"
    name="$(echo $name | tr '.' '_')"
    mkdir -p $name
}

# initialization options
options=$(getopt -o un --long help -- "$@")
[ $? -eq 0 ] || {
    website=$1
}

# check if a option is correct once again. When there was no option given, then set first variable to website
if [ -z $1 ]; then 
    echo "Start work"
    show_help
    echo "work stopped"
    exit 0
elif [ $1 == "--help" ]; then 
    echo "Start work"
    website=$2
elif [ $1 == "-u" ]; then 
    echo "Start work"
    website=$2
elif [ $1 == "-n" ]; then 
    echo "Start work"
    website=$2
else
    echo "Start work"
    website=$1
fi

# start 
while true; do
    case "$1" in
    --help)
        show_help
        echo "work stopped"
        break
        ;;
    -u) 
        # function
        check_input

        # get page
        curl "$website" -o "website.html"

        # get all images src. Grep filter searches a file for a part starts from src=". then keeps stuff right of the to ". Then saves filtered line to file.
        cat website.html | grep img | grep -Po 'src="\K.*?(?=")' | sed 's/\?.*//' > urls.txt

        # Read file line by line, and echo them
        while read -r line; do
            echo "$line"
        done < urls.txt

        # Delete used file
        rm urls.txt
        rm website.html
        echo "Work done"
        break
        ;;
    -n)
        # function
        check_input

        # get page
        curl "$website" -o "website.html"

        # get all images src. Grep filter searches a file for a part starts from src=". then keeps stuff right of the to ". Then saves filtered line to file.
        cat website.html | grep img | grep -Po 'src="\K.*?(?=")' | sed 's/\?.*//' > urls.txt

        # function
        create_dir

        # Read file line by line, and if file exist in dir do nothing, else echo it.
        while read -r line; do
            file_name=$(basename $line)
    
            if test -f "$name/$file_name"; then
                :
            else 
                echo "$line"
            fi
        done < urls.txt

        if [[ -z $(ls -A $name) ]]; then
            rmdir $name
        else
            echo "/$name is not empty"
        fi

        # delete used file
        rm urls.txt
        rm website.html
        echo "Work done"
        break
        ;;
    *)
        # function
        check_input

        # get page
        curl "$website" -o "website.html"

        # get all images src. Grep filter searches a file for a part starts from src=". then keeps stuff right of the to ". Then saves filtered line to file.
        cat website.html | grep img | grep -Po 'src="\K.*?(?=")' | sed 's/\?.*//' > urls.txt

        # function
        create_dir

        # Read file line by line. When image dont exist in dir download it.
        while read -r line; do
            file_name=$(basename $line)
    
            if test -f "$name/$file_name"; then
                echo "$file_name already exist"
            else 
                wget -P ./$name $line
            fi
        done < urls.txt

        # delete used file
        rm urls.txt
        rm website.html
        echo ""
        echo "Images exist in: ${PWD}/$name"
        echo "Work done"
        break
        ;;
    esac
done

exit 0