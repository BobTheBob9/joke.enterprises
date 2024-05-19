rm -r .build
mkdir .build

rm -r /web/*

function file {
    cp $1 /web/$1
}

file favicon.png
file badge88_31.png
file site.css

function build_page {
    gcc -E - < $1 > .build/$1.preprocessed
    sed '/^#/d' < .build/$1.preprocessed > /web/$1
}

build_page index.html
build_page whoami.html
build_page small-blog.html
build_page system.html
