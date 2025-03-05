shopt -s nullglob
shopt -s lastpipe

rm -r .build
mkdir .build

rm -r /web/*

ln -s /upload /web/upload

function file {
    cp $1 /web/$1
}

file favicon.png
file background-corner.svg
file badge88_31.png
file hack-regular-subset.woff2
file hack-bold-subset.woff2
file site.css

function build_page {
    gcc -w -E - < $1 | sed '/^#/d' > /web/$1
}

build_page index.html
build_page whoami.html
build_page system.html
build_page small-blog.html

# blog
mkdir /web/blog
blogincludes=""
find ./blog/ -type f | sort -k 1.12,1.16 -k 1.9,1.11 -k 1.6,1.8 -r | while read -r file; do
    page=$(basename "$file")

    day=${page:0:2}
    month=${page:3:2}
    year=${page:6:4}
    postName=$(echo ${page:11} | cut -d. -f1)
    summary="$(sed -e 's/<[^>]*>//g' "$file" | head -1)... (cont.)"

    # macro expected to be defined in file
    title="BLOG_TITLE( $day, $month, $year, $postName, \"/blog/$page\" )\n"
    
    if [[ $page != DEV* ]]; then
    	blogincludes+=$title
    	blogincludes+="#include \"blog/$page\"\n"
    fi	

    sed "s|BLOG_POST|$title\n#include \"blog/$page\"|" < blog-single-post-template.html | gcc -w -E "-DPOST_TITLE=\"$day/$month/$year - $postName\"" "-DPOST_SUMMARY=\"$summary\"" - | sed '/^#/d' > /web/blog/$page
done

# todo: not an actual define currently because can't #include from macro
sed "s|BLOG_PAGES|$blogincludes|" < blog.html | gcc -w -E - | sed '/^#/d' > /web/blog.html
