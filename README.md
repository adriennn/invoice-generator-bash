
## Invoice generator

You will need the following software installed, most of which come by default on linux distributions : pdftk, sendemail, gnu barcode. The PDF template in the repo was made with LibreOffice.

The `fill.sh` script 	reads a simple flat text file. The database in the file must has the following format, one entry per line, tab separated without column headers (shown only for column identification below). if the script fails, make sure the file does not conta.in carriage return (\r). This script doesn't support UTF-8 characters (i.e. no É, È, Ö, Ä, Å, Ï etc...) so make sure you data doesn't container any else they will be removed.

		name	lname	email	refnumber	member_type
		Mo 	skidovsky	la@skyfalling.com	76762867	full
		boris	lagardere	boris.la@hotmail.com	49587798	full
		hubert	mauricette	hubert@gmail.com	87787778	full

### PDF form fields
If you need to know the names of the fields in the PDF template us ethe following command in a termainal `pdftk template.pdf`

- FieldName: fname
- FieldName: email
- FieldName: refnumber
- FieldName: due_date
- FieldName: member_last_name
- FieldName: total_invoice
