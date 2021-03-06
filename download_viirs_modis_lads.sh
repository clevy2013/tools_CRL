#!/bin/bash
# Script to download MODIS or VIIRS data products from Terra (MOD), Aqua (MYD), combined Terra Aqua (MCD), or SNPP-VIIRS (VNP)
# Arthur Elmes
# Created 2019-05-01

# NOTE! Currently collection nubmers are hard-coded in as 006 for MODIS and 001 for VIIRS
# This will soon change. I don't think it is worth adding an argument for this; just change
# it when the collection 061 and 002 processing (et cetera) are done.

usage="Usage: ./download_modis.sh [-s start date (YYYY-MM-DD)] [-e end date (YYYY-MM-DD)] [-n product short name e.g. MCD43A3] [-t tile e.g. h12v04] [-d download dir]"
while getopts ":s:e:n:t:d:" arg; do
    case $arg in
	s) start_date=$OPTARG;;
	e) end_date=$OPTARG;;
	n) short_name=$OPTARG;;
	t) tile=$OPTARG;;
	d) dl_dir=$OPTARG;;
	\?) echo $usage
    esac
done

url_base=https://ladsweb.modaps.eosdis.nasa.gov/archive/allData/6/

if [ -z $start_date ] || [ -z $end_date ] || [ -z $short_name ] || [ -z $tile ] || \
       [ -z $dl_dir ]; then
    echo $usage
    exit
else
    echo "All args ok"
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
	    url_prod=${url_base}"/${short_name}.006/"
	    fmt="hdf";;
    "MYD"*) echo "Found Aqua Product"
	    url_prod=${url_base}"/${short_name}.006/"
	    fmt="hdf";;
    "MCD"*) echo "Found Combined Terra Aqua Product" 
	    url_prod=${url_base}"/${short_name}.006/"
	    fmt="hdf";;
    "VNP"*) echo "Found SNPP Product"
	    url_prod=${url_base}"/${short_name}.001/"
	    fmt="h5";;
esac

cur_date=${start_date}
end_date=$(date -I -d "$end_date+1 day")

# Loop through all dates in year, download with full url
while [[ "$cur_date" < "$end_date" ]]; do 
    dl_dir_out=$dl_dir
    cur_date_url=${cur_date:0:4}.${cur_date:5:2}.${cur_date:8:2}
    dl_url=${url_prod}${cur_date_url}/
    file="${short_name}*${tile}*.${fmt}"
    cur_date=$(date -I -d "$cur_date+1 day")
    year=`date --date="$cur_date" '+%Y'`
    dl_dir_out=${dl_dir_out}${short_name}/${fmt}/${year}/${tile}
    if [ ! -r $dl_dir_out ]; then
	mkdir -p $dl_dir_out
    fi
    echo "Downloading from:" ${dl_url}
    echo "File: " ${file}
    echo "Saving to: " ${dl_dir_out}
    wget --load-cookies ~/.urs_cookies --save-cookies ~/.urs_cookies --keep-session-cookies --no-check-certificate --auth-no-challenge=on \
	 -r --reject "index.html*" --accept "${file}" -l1 -np -e robots=off --no-directories --waitretry=300 -t 100 \
	 --directory-prefix=${dl_dir_out} --secure-protocol=TLSv1 ${dl_url}
done
