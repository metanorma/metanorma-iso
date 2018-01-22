if [[ ! -d jing-trang ]]; then
  git clone https://github.com/relaxng/jing-trang.git
fi
cd jing-trang
./ant
cd ..
java -jar jing-trang/build/trang.jar -I rnc -O rng validate.rnc validate.rng

