PACKAGES=fmt,camlp5.extprint,camlp5.extend,camlp5.pprintf,pcre,camlp5.quotations,camlp5.pa_o.link,camlp5.pr_o.link

run: conv
	./conv


conv: conv.cmo
	ocamlfind ocamlc -package $(PACKAGES) -linkpkg -linkall conv.cmo  -o conv

conv.cmo: conv.ml
	not-ocamlfind preprocess -package $(PACKAGES),camlp5.pr_o -syntax camlp5o conv.ml > conv.ml.ppo
	ocamlfind ocamlc -package $(PACKAGES) -syntax camlp5o -c conv.ml

clean::
	rm -f conv *.cm* *ppo* has_warning


.PHONY: run
.SUFFIXES: .ml .cmo


# (libraries 
#   core base
#   compiler-libs.common 
#   camlp5 
#   )
