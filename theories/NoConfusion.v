(**********************************************************************)
(* Equations                                                          *)
(* Copyright (c) 2009-2016 Matthieu Sozeau <matthieu.sozeau@inria.fr> *)
(**********************************************************************)
(* This file is distributed under the terms of the                    *)
(* GNU Lesser General Public License Version 2.1                      *)
(**********************************************************************)

(** Instances of [NoConfusion] for the standard datatypes. To be used by 
   [equations] when it needs applications of injectivity or discrimination
   on some equation. *)

(*Require Import Coq.Program.Program Bvector List.*)
Require Import Equations.Signature Equations.EqDec.
Require Export Equations.DepElim.

Ltac noconf H ::=
  blocked ltac:(noconf_ref H; simplify_dep_elim) ; auto 3.

(** Used by the [Derive NoConfusion] command. *)


Ltac destruct_sigma id :=
  match type of id with
    @sigma ?A ?P => let idx := fresh "idx" in
                   destruct id as [idx id];
                     repeat destruct_sigma idx; simpl in id
                                                         
  | _ => idtac
  end.

Ltac solve_noconf_prf := intros;
  on_last_hyp ltac:(fun id => destruct id) ; (* Subtitute a = b *)
  on_last_hyp ltac:(fun id =>
                      destruct_sigma id;
                      elim id) ; (* Destruct the inductive object a *)
  constructor.

Ltac destruct_tele_eq H :=
  match type of H with
    ?x = ?y =>
    let rhs := fresh in
    set (rhs := y) in *; pattern sigma rhs; clearbody rhs;
    destruct H; simpl
  end.

Ltac solve_noconf_inv := intros;
  match goal with
    |- ?R ?a ?b => destruct_sigma a; destruct_sigma b; 
                   destruct a ; destruct b; simpl in * |-;
                 on_last_hyp ltac:(fun id => destruct_tele_eq id || destruct id);
                 solve [constructor]
  end.

Ltac solve_noconf_inv_equiv :=
  intros;
  (* Subtitute a = b *)
  on_last_hyp ltac:(fun id => destruct id) ;
  (* Destruct the inductive object a *)
  on_last_hyp ltac:(fun id => destruct_sigma id; elim id) ;
  simpl; constructor.

Ltac solve_noconf := simpl; intros;
    match goal with
      [ H : @paths _ _ _ |- @paths _ _ _ ] => solve_noconf_inv_equiv
    | [ H : @paths _ _ _ |- _ ] => solve_noconf_prf
    | [ |- @paths _ _ _ ] => solve_noconf_inv
    end.

Derive NoConfusion for Unit.
Next Obligation. solve_noconf. Defined.
Next Obligation. solve_noconf. Defined.
Next Obligation. solve_noconf. Defined.

Derive NoConfusion for nat.
Next Obligation. solve_noconf. Defined.
Next Obligation. solve_noconf. Defined.
Next Obligation. solve_noconf. Defined.

Derive NoConfusion for option.
Next Obligation. solve_noconf. Defined.
Next Obligation. solve_noconf. Defined.
Next Obligation. solve_noconf. Defined.

Derive NoConfusion for list.
Next Obligation. solve_noconf. Defined.
Next Obligation. solve_noconf. Defined.
Next Obligation. solve_noconf. Defined.

Derive NoConfusion for sum.
Next Obligation. solve_noconf. Defined.
Next Obligation. solve_noconf. Defined.
Next Obligation. solve_noconf. Defined.

Require Import HoTT.Types.Bool.
Definition Bool_rect := Bool_ind.

Derive NoConfusion for Bool.
Next Obligation. solve_noconf. Defined.
Next Obligation. solve_noconf. Defined.
Next Obligation. solve_noconf. Defined.

(* FIXME. Problem with pattern matching on primitive record.
Error: Pattern-matching expression on an object of inductive type @sig
       has invalid information.
Derive NoConfusion for sig.
Next Obligation. Admitted.
Next Obligation. Admitted.
Next Obligation. Admitted.
*)
(* FIXME. Same problem as above.
Derive NoConfusion for prod.
Next Obligation. Admitted.
Next Obligation. Admitted.
Next Obligation. Admitted.
*)

(* TODO This should work. *)
(*Derive NoConfusion for Unit Bool nat option list sum prod sig.*)

(* FIXME should be done by the derive command *)
Extraction Inline noConfusion NoConfusionPackage_nat.
