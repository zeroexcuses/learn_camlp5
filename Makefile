run: conv
	./conv


conv:
	ocamlfind ocamlc -package fmt,camlp5.extprint,camlp5.extend,camlp5.pprintf,pcre -linkpkg -syntax camlp5o conv.ml  -o conv



.PHONY: run



# (libraries 
#   core base
#   compiler-libs.common 
#   camlp5 
#   )
