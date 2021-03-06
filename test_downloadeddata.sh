#!/bin/bash
# Script to test downloaded MODIS or VIIRS data products from terra (MOD), Aqua (MYD), combined Terra Aqua (MCD), or SNPP-VIIRS (VNP)
# Charlotte Levy
# Created 2020-05-01


usage="Usage: ./test_downloadeddata.sh [-s start date (YYYY-MM-DD)] [-e end date (YYYY-MM-DD)] [-n product short name e.g. MCD43A3] [-t tile e.g. h12v04] [-d download dir] [-m file location]"
while getopts ":s:e:n:t:d:m:" arg; do
    case $arg in
	s) start_date=$OPTARG;;
	e) end_date=$OPTARG;;
	n) short_name=$OPTARG;;
	t) tile=$OPTARG;;
	d) dl_dir=$OPTARG;;
	m) multiple=$OPTARG;;
	\?) echo $usage
    esac
done

if [ -z $start_date ] || [ -z $end_date ] || [ -z $short_name ] || [ -z $tile ] || \
       [ -z $dl_dir ]; then
    echo $usage
    exit
else
    echo "All args ok"
fi

#Create alternate tile configuration for loop.
if [ -z $multiple ]; then
    echo "Single Tile Option"
    tile_list=$tile
else
    echo "Multiple Tile Option"
    tile_list="h00v08 h00v09 h00v10 h01v08 h01v09 h01v10 h01v11 h02v06 h02v08 h02v09 h02v10 h02v11 h03v06 h03v07 h03v09 h03v10 h03v11 h04v09 h04v10 h04v11 h05v10 h05v11 h05v13 h06v03 h06v11 h07v03 h07v05 h07v06 h07v07 h08v03 h08v04 h08v05 h08v06 h08v07 h08v08 h08v09 h09v02 h09v03 h09v04 h09v05 h09v06 h09v07 h09v08 h09v09 h10v02 h10v03 h10v04 h10v05 h10v06 h10v07 h10v08 h10v09 h10v10 h10v11 h11v02 h11v03 h11v04 h11v05 h11v06 h11v07 h11v08 h11v09 h11v10 h11v11 h11v12 h12v02 h12v03 h12v04 h12v05 h12v07 h12v08 h12v09 h12v10 h12v11 h12v12 h12v13 h13v02 h13v03 h13v04 h13v08 h13v09 h13v10 h13v11 h13v12 h13v13 h13v14 h14v02 h14v03 h14v04 h14v09 h14v10 h14v11 h14v14 h14v16 h14v17 h15v02 h15v03 h15v05 h15v07 h15v11 h15v14 h15v15 h15v16 h15v17 h16v02 h16v05 h16v06 h16v07 h16v08 h16v09 h16v12 h16v14 h16v16 h16v17 h17v02 h17v03 h17v04 h17v05 h17v06 h17v07 h17v08 h17v10 h17v12 h17v13 h17v15 h17v16 h17v17 h18v02 h18v03 h18v04 h18v05 h18v06 h18v07 h18v08 h18v09 h18v14 h18v15 h18v16 h18v17 h19v02 h19v03 h19v04 h19v05 h19v06 h19v07 h19v08 h19v09 h19v10 h19v11 h19v12 h19v15 h19v16 h19v17 h20v02 h20v03 h20v04 h20v05 h20v06 h20v07 h20v08 h20v09 h20v10 h20v11 h20v12 h20v13 h20v15 h20v16 h20v17 h21v02 h21v03 h21v04 h21v05 h21v06 h21v07 h21v08 h21v09 h21v10 h21v11 h21v13 h21v15 h21v16 h21v17 h22v02 h22v03 h22v04 h22v05 h22v06 h22v07 h22v08 h22v09 h22v10 h22v11 h22v13 h22v14 h22v15 h22v16 h23v02 h23v03 h23v04 h23v05 h23v06 h23v07 h23v08 h23v09 h23v10 h23v11 h23v15 h23v16 h24v02 h24v03 h24v04 h24v05 h24v06 h24v07 h24v12 h24v15 h25v02 h25v03 h25v04 h25v05 h25v06 h25v07 h25v08 h25v09 h26v02 h26v03 h26v04 h26v05 h26v06 h26v07 h26v08 h27v03 h27v04 h27v05 h27v06 h27v07 h27v08 h27v09 h27v10 h27v11 h27v12 h27v14 h28v03 h28v04 h28v05 h28v06 h28v07 h28v08 h28v09 h28v10 h28v11 h28v12 h28v13 h28v14 h29v03 h29v05 h29v06 h29v07 h29v08 h29v09 h29v10 h29v11 h29v12 h29v13 h30v05 h30v06 h30v07 h30v08 h30v09 h30v10 h30v11 h30v12 h30v13 h31v06 h31v07 h31v08 h31v09 h31v10 h31v11 h31v12 h31v13 h32v07 h32v08 h32v09 h32v10 h32v11 h32v12 h33v07 h33v08 h33v09 h33v10 h33v11 h34v07 h34v08 h34v09 h34v10 h35v08 h35v09 h35v10"
fi

# Check if the download dir has a trailing slash, add if not
case "$dl_dir" in
    */)
	echo
	;;
    *)
	echo "Adding trailing slash to dl_dir"
	dl_dir=${dl_dir}/
	;;
    esac

# Check which product was specified to select the right URL
case ${short_name} in
    "MOD"*) echo "Found Terra Product"
	    url_prod=${url_base}"MOLT/${short_name}.006/"
	    fmt="hdf";;
    "MYD"*) echo "Found Aqua Product"
	    url_prod=${url_base}"MOLA/${short_name}.006/"
	    fmt="hdf";;
    "MCD"*) echo "Found Combined Terra Aqua Product" 
	    url_prod=${url_base}"MOTA/${short_name}.006/"
	    fmt="hdf";;
    "VNP"*) echo "Found SNPP Product"
	    url_prod=${url_base}"VIIRS/${short_name}.001/"
	    fmt="h5";;
esac

nDNE=0
nEMPTY=0
nFILES=0

#Begin loop for tile list, if applicable
for newtile in $tile_list;
do

	echo "Now Beginning " ${newtile}
	dl_dir_simp=${dl_dir}${newtile}/${short_name}
        if [[ -d $dl_dir_simp ]]; then
		echo ${dl_dir_simp} " : folder exists"
	else
                echo ${dl_dir_simp} " : missing folder"
                nDNE=$((nDNE+1))
        fi

        if [[ "$(ls -A $dl_dir_simp)" ]]; then
		echo ${dl_dir_simp} " : folder has contents"
	else
                echo ${dl_dir_simp} " : empty folder"
                nEMPTY=$((nEMPTY+1))
        fi

	tFILES=0
	cur_date=${start_date}
	end_date=$(date -I -d "$end_date+1 day")

	# Loop through all dates in year, download with full url
	while [[ "$cur_date" < "$end_date" ]]; 
	do 

		#dl_dir_out=$dl_dir
		year=`date --date="$cur_date" '+%Y'`
		jday=`date --date="$cur_date" '+%j'`   
		file="${short_name}.A${year}${jday}.${newtile}*.${fmt}"
		cur_date=$(date -I -d "$cur_date+1 day")
		#dl_dir_out=${dl_dir_out}${short_name}/${fmt}/${year}/${newtile}
		dl_dir_out=${dl_dir_simp}/${year}
		dirfile=${dl_dir_out}/${file}
		if [[ ! -e "$dirfile" ]]; then
			echo ${dirfile} " : missing file"
			nFILES=$((nFILES+1))
			tFILES=$((tFILES+1))
		fi

	done

	echo ${tFILES} " : total # missing files"
done

echo "Number of Non-existent folders: " ${nDNE}
echo "Number of Empty folders: " ${nEMPTY}
echo "Number of Missing files: " ${nFILES} 
