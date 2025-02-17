shopt -s nullglob

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
smallblogincludes=""
for page in `ls ./blog/ | sort -k 1.7,1.11 -k 1.4,1.6 -k 1.1,1.2 -r`; do
    # macro expected to be defined in file
    title="BLOG_TITLE( ${page:0:2}, ${page:3:2}, ${page:6:4}, $(echo ${page:11} | cut -d. -f1), /blog/$page )\n"
    smallblogincludes+=$title
    smallblogincludes+="#include \"blog/$page\"\n"

    sed "s|BLOG_POST|$title\n#include \"blog/$page\"|" < blog-single-post-template.html | gcc -w -E - | sed '/^#/d' > /web/blog/$page 
done

# todo: not an actual define currently because can't #include from macro
sed "s|BLOG_PAGES|$smallblogincludes|" < blog.html | gcc -w -E - | sed '/^#/d' > /web/blog.html
