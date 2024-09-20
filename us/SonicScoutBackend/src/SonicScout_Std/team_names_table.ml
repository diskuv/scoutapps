module type Fetchable_data = sig
  

  module Fetch : sig 
  val get_name_for_number : Sqlite3.db -> int -> string option
  val get_all_names : Sqlite3.db -> string list 
  val get_number_for_name : Sqlite3.db -> string -> int option 

  end 
end

module type Complete_table = sig
include Fetchable_data
include Db_utils.Generic_Table

end


module Table : Complete_table = struct

  let table_name = "team_names" 

  type colums = Number | Name 

  let primary_keys = [Number] 

  let colums_in_order = [Number; Name]

  
  let colum_name = function
  | Number -> "number"
  | Name -> "name"


  let colum_datatype = function
  | Number -> "INT"
  | Name -> "INT"

  module Fetch = struct
    
    let get_name_for_number db num =  
      let to_select = colum_name Name in 
      let where = [colum_name Number, Db_utils.Select.Int num] in 

      let result = Db_utils.Select.select_strings_where db ~table_name ~to_select ~where in 

      match result with 
      | x :: [] -> Some x  
      | _ -> None 


    let get_all_names db = 
      let to_select = colum_name Name in 
      
      Db_utils.Select.select_strings_where db ~table_name ~to_select ~where:[] 


    let get_number_for_name db name =
      let to_select = colum_name Number in 
      
      let where = [(colum_name Name, Db_utils.Select.String name)] in 

      let result = Db_utils.Select.select_ints_where db ~table_name ~to_select ~where in 

      match result with
      | x :: [] -> Some x 
      | _ -> None 
      
  end


  let create_table db = Db_utils.create_table db ~table_name ~colums:colums_in_order ~primary_keys:primary_keys ~to_name:colum_name ~to_datatype:colum_datatype 



  let drop_table (db:Sqlite3.db) = 
    let sql = "DROP TABLE " ^ table_name in 

    match Sqlite3.exec db sql with 
    | Sqlite3.Rc.OK -> Db_utils.Successful
    | r -> 
      let _ = Db_utils.formatted_error_message db r "failed to drop" in 
      Db_utils.Failed




  let insert_record db json = 
    let safe_yojson = Yojson.Safe.from_string json in 

    let basic_yojson = Yojson.Safe.to_basic safe_yojson in 

    let nums_and_names_type = Yojson.Basic.Util.member "names" basic_yojson in 


    let nums_and_names_list = match nums_and_names_type with
    | `List t -> t 
    | _ -> failwith "failed" in 


    let get_name_from_json json = 
      let name = Yojson.Basic.Util.member "name" json in   

      match name with
      | `String s -> s 
      | _ -> failwith "not string" in 

    let get_number_from_json json = 
      let num = Yojson.Basic.Util.member "number" json in 

      match num with
      | `Int n -> n
      | _ -> failwith "not num" in 

    let all_names_in_db = Fetch.get_all_names db in 

    let all_json_names = 
      let rec iter pos lst = 

        if pos = (List.length nums_and_names_list) then lst else  
        let field = List.nth nums_and_names_list pos in 

        let name = get_name_from_json field in 

        iter (pos+1) (name :: lst) in 

        iter 0 [] 

        in 


      let equal = 
        let rec check_missing_data l1 l2 pos acc = 
          if acc = true then true else 
            if pos = (List.length l1) then acc else 
              let name = List.nth l1 pos in 

              let exist_in_l2 = List.exists (fun s -> s = name) l2 in 

              (* print_endline ("pos = " ^ string_of_int pos );
              print_endline ("name = " ^ name);
              print_endline ("exists_in_l2 " ^ string_of_bool exist_in_l2); *)


              check_missing_data l1 l2 (pos+1) (not exist_in_l2) in 

              let check1 = check_missing_data all_names_in_db all_json_names 0 false in 
              let check2 = check_missing_data all_json_names all_names_in_db 0 false in 

              Printf.printf "CHECK1: %b" check1;
              Printf.printf "CHECK2: %b" check2;


              (not check1) && (not check2) in 


      if equal then Db_utils.Successful else 

        let _ = drop_table db in 
        let _ = create_table db in 

        let insert_indivisual_record num name = 

          let values = Printf.sprintf " VALUES(%d, \"%s\")" num name in  

          let sql = Printf.sprintf "INSERT INTO " ^ table_name ^ values in 

          match Sqlite3.exec db sql with 
          | Sqlite3.Rc.OK -> Printf.printf 
            "INSERTED INTO team_names 
             NUMBER: %d
             NAME: %s\n"
             num name 
             
          | r -> Db_utils.formatted_error_message db r "failed to insert into names table" in 


          List.iter 
            (fun a -> 
              let num = get_number_from_json a in 
              let name = get_name_from_json a in 

            insert_indivisual_record num name 
            ) nums_and_names_list; 

            Db_utils.Successful
          
          






      




  



end