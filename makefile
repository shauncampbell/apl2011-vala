all: 
	valac Apl/*.vala Collections/*.vala -o aplc -X -lm --pkg gee-1.0 --pkg gio-2.0 -D TS_BUILD=1

