(*
 *	Copyright (C) 2006-2009 Vincent Hanquez <vincent@snarc.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation; version 2.1 only. with the special
 * exception on linking described in file LICENSE.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * Dbus binding
 *)

exception Error of string * string

type bus
type message
type pending_call
type watch

type add_watch_fn = watch -> bool
type rm_watch_fn = watch -> unit
type toggle_watch_fn = watch -> unit
type watch_fns = add_watch_fn * rm_watch_fn * (toggle_watch_fn option)

type ty_sig =
	| SigByte
	| SigBool
	| SigInt16
	| SigUInt16
	| SigInt32
	| SigUInt32
	| SigInt64
	| SigUInt64
	| SigDouble
	| SigString
	| SigObjectPath
	| SigVariant
	| SigArray of ty_sig
	| SigStruct of ty_sig list
	| SigDict of ty_sig * ty_sig

type ty_array =
	| Unknowns
	| Bytes of char list
	| Bools of bool list
	| Int16s of int list
	| UInt16s of int list
	| Int32s of int32 list
	| UInt32s of int32 list
	| Int64s of int64 list
	| UInt64s of int64 list
	| Doubles of float list
	| Strings of string list
	| ObjectPaths of string list
	| Structs of ty_sig list * (ty list list)
	| Variants of ty list
	| Dicts of (ty_sig * ty_sig) * ((ty * ty) list)
and ty =
	| Unknown
	| Byte of char
	| Bool of bool
	| Int16 of int
	| UInt16 of int
	| Int32 of int32
	| UInt32 of int32
	| Int64 of int64
	| UInt64 of int64
	| Double of float
	| String of string
	| ObjectPath of string
	| Array of ty_array
	| Struct of ty list
	| Variant of ty

val string_of_ty : ty -> string

module Bus :
sig
	type ty = Session | System | Starter
	type flags = Replace_existing

	val get : ty -> bus
	val get_private : ty -> bus
	val register : bus -> unit
	val set_unique_name : bus -> string -> bool
	val get_unique_name : bus -> string
	val request_name : bus -> string -> int -> unit
	val release_name : bus -> string -> unit
	val has_owner : bus -> string -> bool
	val add_match : bus -> string -> bool -> unit
	val remove_match : bus -> string -> bool -> unit
end

module Message :
sig
	type message_type =
		| Invalid
		| Method_call
		| Method_return
		| Error
		| Signal
	val string_of_message_ty : message_type -> string
	val create : message_type -> message
	val new_method_call : string -> string -> string -> string -> message
	val new_method_return : message -> message
	val new_signal : string -> string -> string -> message
	val new_error : message -> string -> string -> message
	val append : message -> ty list -> unit
	val get_rev : message -> ty list
	val get : message -> ty list
	val marshal : message -> string
	val set_path : message -> string -> unit
	val set_interface : message -> string -> unit
	val set_member : message -> string -> unit
	val set_error_name : message -> string -> unit
	val set_destination : message -> string -> unit
	val set_sender : message -> string -> unit
	val set_reply_serial : message -> int32 -> unit
	val set_auto_start : message -> bool -> unit
	val has_path : message -> string -> bool
	val has_interface : message -> string -> bool
	val has_member : message -> string -> bool
	val has_destination : message -> string -> bool
	val has_sender : message -> string -> bool
	val has_signature : message -> string -> bool
	val get_type : message -> message_type
	val get_path : message -> string option
	val get_interface : message -> string option
	val get_member : message -> string option
	val get_error_name : message -> string option
	val get_destination : message -> string option
	val get_sender : message -> string option
	val get_signature : message -> string option
	val get_serial : message -> int32
	val get_reply_serial : message -> int32
	val get_auto_start : message -> bool
	val is_signal : message -> string -> string -> bool
	val is_method_call : message -> string -> string -> bool
	val is_error : message -> string -> bool
end

module Connection :
sig
	type dispatch_status = Data_remains | Complete | Need_memory
	val send : bus -> message -> int32
	val send_with_reply : bus -> message -> int -> pending_call
	val send_with_reply_and_block : bus -> message -> int -> message
	val add_filter : bus -> (bus -> message -> bool) -> unit
	val flush : bus -> unit
	val read_write : bus -> int -> bool
	val read_write_dispatch : bus -> int -> bool
	val pop_message : bus -> message option
	val get_dispatch_status : bus -> dispatch_status
	val dispatch : bus -> dispatch_status
	val get_fd : bus -> Unix.file_descr
	val set_watch_functions : bus -> watch_fns -> unit
	val get_max_message_size : bus -> int
	val set_max_message_size : bus -> int -> unit
	val get_max_received_size : bus -> int
	val set_max_received_size : bus -> int -> unit
	val get_outgoing_size : bus -> int
	val set_allow_anonymous : bus -> bool -> unit
end

module PendingCall :
sig
	val block : pending_call -> unit
	val cancel : pending_call -> unit
	val get_completed : pending_call -> bool
	val steal_reply : pending_call -> message
end

module Watch :
sig

	type flags = Readable | Writable

	val get_unix_fd : watch -> Unix.file_descr
	val get_enabled : watch -> bool
	val get_flags : watch -> flags list
	val handle : watch -> flags list -> unit

end
