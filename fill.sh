#!/bin/bash

# copyright Adrien Vetterli 2014
# author @adriennn
# gplv1.0
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 1.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston MA  02110-1301 USA.

# get one line of the database into an array at a time
while IFS=$'\t' read -r -a database; do

#assign array value to their own variable - easier to read
		fname="${database[0]}"
		lname="${database[1]}"
		email="${database[2]}"
		ref_number="${database[3]}"
		due_date="${database[5]}"
		ref_number_bc=$(printf "%023d" "$ref_number")
		member_type="${database[4]}"

		# Get the membership fee value from membership typ
		if [ "$member_type" == "member" ]; then
			total="5,00"
			elif [ "$member_type" == "associate" ]; then
			total="2,00"
			else
			total="25,00"
			fi
	inv_total=$(sed 's/[^0-9]*//g' <<< "$total")
	inv_total_bc=$(printf "%08d" "$inv_total")

#create a *.fdf file to fill the pdf form in $PWD/FDF/ subdirectory
	printf "%%FDF-1.2\n 1 0 obj<</FDF<< /Fields[\n<</T(fname)/V($fname)>>\n<</T(lname)/V($lname)>>\n<</T(email)/V("$email")>>\n<</T(ref_number)/V("$ref_number")>>\n<</T(member_type)/V("$member_type")>>\n<</T(total)/V("$total") >>\n] >> >>\n endobj\ntrailer<</Root 1 0 R >>\n%%%%EOF" > $PWD/FDF/"$fname"_"$lname".fdf

#use pdftk to merge both files which are then printed to the $PWD/PDF/ subdirectory
	pdftk $PWD/invoice_template.pdf fill_form $PWD/FDF/"$fname"_"$lname".fdf output $PWD/PDF/"$fname"_"$lname".pdf flatten

#Create the barcode- note that the barcode is placed at a custom location on an A4 sheet here
	barcode -b "49847300010288552$inv_total_bc$ref_number_bc$due_date" -e 128 -n -umm -t 1x1 -p20x30 -g+120+10 > $PWD/barcodes/PS/"$fname"_"$lname"_barcode.ps

#Convert the barcode file to pdf for stamping
	ps2pdf $PWD/barcodes/PS/"$fname"_"$lname"_barcode.ps $PWD/barcodes/PDF/"$fname"_"$lname"_barcode.pdf;

#Stamp the barcode to the form pdf
	pdftk $PWD/PDF/"$fname"_"$lname".pdf stamp $PWD/barcodes/PDF/"$fname"_"$lname"_barcode.pdf output $PWD/invoices/invoice_"$fname"_"$lname".pdf

    sendemail -f email.sender@mail.com -t "$email" -u "Association ABC Membership fee 20XX" -s smtp.mail.com -a $PWD/invoices/invoice_"$fname"_"$lname".pdf -xu SMTP_USERNAME -xp SMTP_PASSWORD -m "Dear member,\n please find the invoice for your membership to the Associationfor the year 20XX attached to this email.\n"
# Remove the sleep if your smtp server allows relentless sending
sleep 10
done < $PWD/database.txt
