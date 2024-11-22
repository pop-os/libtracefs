#!/bin/bash

# The samples are pulled out of the examples used in the man pages
# that are located in the Documentation directory.

EXAMPLES="dynevents kprobes eprobes uprobes synth error filter function-filter \
	  hist hist-cont tracer stream instances-affinity cpu sql"

for f in $EXAMPLES; do
	# Extract the code examples from the .txt files that generate the manpages
	sed -ne '/^EXAMPLE/,/FILES/ { /EXAMPLE/,+2d ; /^FILES/d ;  /^--/d ; p}' \
		Documentation/libtracefs-$f.txt > $AUTOPKGTEST_TMP/$f.c
	echo "[I] Extracted code for example $f"
done

for f in $(ls $AUTOPKGTEST_TMP/*.c); do
	name=$(basename $f .c)
	flags=$(pkg-config --libs libtracefs)
	cflags=$(pkg-config --cflags libtracefs)

	# stream.c and instances-affinity.c make use of macros which require
	# the definition of _GNU_SOURCE to be used. Take a look at the
	# splice(2) for stream.c and CPU_SET(3) for instances-affinity.c.
	if [[ "$f" == *"stream.c" ]] || [[ "$f" = *"instances-affinity.c" ]]; then
		sed -i '1i #define _GNU_SOURCE' $f
		echo "[I] Defined _GNU_SOURCE in $f"
	fi

	cc -o $AUTOPKGTEST_TMP/$name $f $flags $cflags
	echo "[I] Built example $f"
done
