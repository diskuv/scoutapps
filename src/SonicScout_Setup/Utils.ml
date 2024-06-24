exception StopProvisioning

let step = ref 1
let rmsg = function Ok v -> v | Error (`Msg msg) -> failwith msg

let start_step s =
  let blue = Fmt.styled (`Fg (`Hi `Blue)) in
  let red = Fmt.styled (`Fg (`Hi `Red)) in
  let pp_arrow ~c ppf n =
    Fmt.array ~sep:(Fmt.any "")
      (fun ppf (even, c) ->
        if even then blue Fmt.char ppf c else red Fmt.char ppf c)
      ppf
      (Array.make n c |> Array.mapi (fun i c -> (i mod 10 < 5, c)))
  in
  Logs.info (fun l ->
      l "%a"
        (Fmt.styled `Bold (fun ppf v ->
             Fmt.pf ppf "%a Step %d - %s %a" (pp_arrow ~c:'>') 10 v s
               (pp_arrow ~c:'<') 10))
        !step);
  step := !step + 1
