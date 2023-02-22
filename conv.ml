


open Pcaml

let code = {code|
module MyRecord = struct
  type t = {
    a: int;
    b: string;
    c: int
  }
end

module MyVariant = struct
  type t =
    | Ok of string * int
    | Err of int * int
end

|code};;


let rec typekind_to_rs ~name pps = 
  let open MLast in
  function
    <:ctyp< int >> ->  Fmt.(pf pps "i32")
  | <:ctyp< string >> ->  Fmt.(pf pps "String")
  | <:ctyp< t >> ->  Fmt.(pf pps "%s" name)
  | <:ctyp< $lid:s$ >> ->  Fmt.(pf pps "%s" s)
  | <:ctyp< { $list:l$ } >> ->
     let members = l |> List.map (function (_,  mname, _,  ty, _) -> (mname, ty)) in
     Fmt.(pf pps "{ %a }"
            (list ~sep:(const string ", ") (pair ~sep:(const string ": ") string (typekind_to_rs ~name)))
            members)
  | <:ctyp< [ $list:l$ ] >> ->
     let members = l |> List.map (function
                         <:constructor< $uid:cname$ of $list:l$ >> -> (cname, l)) in
     let pp_branch pps (cname,l) =
       Fmt.(pf pps "%s(%a)" cname (list ~sep:(const string ", ") (typekind_to_rs ~name)) l) in
     Fmt.(pf pps "{ %a }" (list ~sep:(const string ", ") pp_branch) members)

let typedecl_to_rs ~name pps = 
  let open MLast in
  function
    <:type_decl< t = $tk$ >> ->
     match tk with
       <:ctyp< { $list:_$ } >> ->
      Fmt.(pf pps "struct %s %a" name (typekind_to_rs ~name) tk)
     | <:ctyp< [ $list:_$ ] >> ->
      Fmt.(pf pps "enum %s %a" name (typekind_to_rs ~name) tk)
;;


let parse_implem s = Grammar.Entry.parse implem (Stream.of_string s) ;;

let t: ((MLast.str_item * MLast.loc) list * status) = parse_implem code;;

let str_item_to_rs pps = MLast.(function
    <:str_item:< module $uid:mname$ = struct
                type t = $tk$ ;
                end >> ->
      Fmt.(pf pps "%a" (typedecl_to_rs ~name:mname) <:type_decl< t = $tk$ >>))
;;


let implem_to_rs pps sil = 
  let sil = List.map fst sil in
  Fmt.(pf pps "%a" (list ~sep:(const string "\n") str_item_to_rs) sil) ;;

let _ = implem_to_rs Fmt.stdout (fst t);; 



(*
let s = Stdio.In_channel.read_all "eg1.ml" ;;
s |> print_string;;
*)




(*


let loc = Ploc.dummy ;;
Fmt.(pf stdout "%a\n%!" (typekind_to_rs ~name:"Foo") <:ctyp< { a : int ; b : string ; c : t } >>);;
Fmt.(pf stdout "%a\n%!" (typedecl_to_rs ~name:"Foo") <:type_decl< t = { a : int ; b : string ; c : t } >>);;
Fmt.(pf stdout "%a\n%!" str_item_to_rs <:str_item< module MyRecord = struct
  type t = {
    a: int;
    b: string;
    c: int
  } ;
end >>) ;;
Fmt.(pf stdout "%a\n%!" str_item_to_rs <:str_item< module MyVariant = struct
  type t = [
     Ok of string and int
    | Err of int and int ] ;
end >>) ;;

Fmt.(pf stdout "================ Put it all together ================\n%!") ;;

  *)

(*
let file_contents f =
  f |> Fpath.v |> OS.File.read |> Result.get_ok;;
  *)


(*
s |> PAPR.Implem.pa1 |> PAPR.Implem.pr |> print_string ;;

s |> PAPR.Implem.pa1 |> implem_to_rs Fmt.stdout ;;
*)
