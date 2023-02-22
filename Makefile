run: conv
	./conv


conv: conv.ml
	ocamlfind ocamlc -package fmt,camlp5.extprint,camlp5.extend,camlp5.pprintf,pcre,camlp5.quotations,camlp5.pa_o.link,camlp5.pr_o.link -linkpkg -linkall -syntax camlp5o conv.ml  -o conv

clean::
	rm -f conv *.cm* has_warning


.PHONY: run



# (libraries 
#   core base
#   compiler-libs.common 
#   camlp5 
#   )
