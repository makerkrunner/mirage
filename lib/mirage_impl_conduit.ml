open Functoria
open Mirage_impl_conduit_connector
open Mirage_impl_random

type conduit = Conduit

let conduit = Type Conduit

let conduit_with_connectors connectors =
  let packages = [ pkg ] in
  let extra_deps = abstract nocrypto :: List.map abstract connectors in
  let connect _ _ = function
    (* There is always at least the nocrypto device *)
    | _nocrypto :: connectors ->
        let pp_connector = Fmt.fmt "%s >>=@ " in
        let pp_connectors = Fmt.list ~sep:Fmt.nop pp_connector in
        Fmt.strf "Lwt.return Conduit_mirage.empty >>=@ %afun t -> Lwt.return t"
          pp_connectors connectors
    | [] -> failwith "The conduit with connectors expects at least one argument"
  in
  impl ~packages ~extra_deps ~connect "Conduit_mirage" conduit

let conduit_direct ?(tls = false) s =
  (* TCP must be before tls in the list. *)
  let connectors = [ tcp_conduit_connector $ s ] in
  let connectors =
    if tls then connectors @ [ tls_conduit_connector ] else connectors
  in
  conduit_with_connectors connectors
