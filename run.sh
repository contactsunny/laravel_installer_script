#!/bin/bash

re='^[0-9]+$'

print_error() {
	echo "$(tput setab 1)$(tput setaf 7)$1$(tput sgr0)";
}

print_success() {
	echo "$(tput setab 2)$(tput setaf 0)$1$(tput sgr0)";
}

install_laravel() {
	printf "Select framework: \n1. Laravel \n2. Lumen \nEnter choice: "
	
	while true
	do
		read framework_choice
		if expr "$framework_choice" : '[0-9]\+$' && 
			[ $framework_choice -ge 1 ] && 
			[ $framework_choice -le 2 ]
			then
				break;
		fi
		printf "Wrong choice. Try again: "
	done

	framework=""
	if [ $framework_choice -eq 1 ]
		then
			framework="laravel"
	else
		framework="lumen"
	fi

	print_success "Install framework: ${framework}..."

	echo -n "Enter project directory: "
	read project_directory

	while [ "{$project_directory}" = "" ]
	do
		printf "Invalid directory. Try again: "
		read project_directory
	done

	print_success "Installing to ${project_directory}..."

	$(which composer) create-project laravel/$framework --prefer-dist $project_directory
}

update_composer() {
	print_success "Running composer self update";
	sudo $(which composer) self-update
	status=$?
	if [ $status -eq 0 ]
		then
			print_success "Updated composer."
			install_laravel
	else
		print_error "Something went wrong. Refer to log above for error message.";
	fi
}

echo 'Checking if php is installed';
php_location=$(which php)

if [ "${php_location}" = ""  ]
	then
		print_error "php is not installed. Instaling...";
		echo 'Updating apt...'
		sudo apt-get update
		echo 'Installing apache, php, mysql and dependencies...';
		sudo apt-get install -y apache2
		sudo apt-get install -y curl mysql-server
		sudo apt-get install -y php libapache2-mod-php php-mcrypt php-mysql php-cli
		sudo service apache2 restart
		print_success "Finishing installation..."
else
	print_success "php is installed";
fi

echo 'Checking if composer is installed';
composer_location=$(which composer)

if [ "${composer_location}" = "" ]
then
		print_error "composer not installed, installing...";
		curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
fi

update_composer