all: ex

setenv:
	bash ./setenv.sh

ex: setenv
	emcc llvm-examples/ex.ll --js-library libraries/p5-wrap.js -s EXPORTED_FUNCTIONS="['_my_draw','_my_setup']" -o foo.js
	firefox index.html

mandelbrot: setenv
	emcc llvm-examples/mandelbrot.ll --js-library libraries/p5-wrap.js -s EXPORTED_FUNCTIONS="['_my_draw','_my_setup']" -o foo.js
	firefox index.html

.PHONY: clean

clean:
	rm -f foo.js *~
