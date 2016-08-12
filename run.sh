#!/bin/bash

print_error() {

	echo "$(tput setab 1)$(tput setaf 7)$1$(tput sgr0)";
}

print_success() {

	echo "$(tput setab 2)$(tput setaf 0)$1$(tput sgr0)";
}

install_laravel() {
	echo -n "Enter project directory: "
	read project_directory
	$(which composer) create-project laravel/laravel --prefer-dist $project_directory
}

update_composer() {
	print_success "Running composer self update";
	sudo $composer_location self-update
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

if [ $php_location == ""  ]
	then
		print_error "php is not installed. Instaling...";
		echo 'Updating apt...'
		sudo apt-get update
		echo 'Installing apache, php, mysql and dependencies...';
		sudo apt-get install -y apache2
		sudo apt-get install -y curl mysql-server
		sudo mysql_secure_installation
		sudo apt-get install -y php libapache2-mod-php php-mcrypt php-mysql php-cli
		sudo service apache2 restart
		print_success "Finishing installation..."
else
	print_success "php is installed";
fi

echo 'Checking if composer is installed';
composer_location=$(which composer)

if [ "{$composer_location}" = "" ]
then
		print_error "composer not installed, installing...";
		curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
fi

update_composer