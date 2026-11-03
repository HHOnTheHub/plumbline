-- Plumbline kit v0.1.1: a co-sign needs the risk area held, not reached. PRC-4, IAM-4.
--
-- In v0.1.0 cosign_procedure_version checked has_area, which is also true for a role with all_areas (the
-- System administrator). So the person who runs the systems could co-sign a regulated procedure, which
-- PRC-4 gives to the control function. A control function is held: the co-signer must hold a role
-- mapped to the co-sign area in role_areas. Rejecting a draft is unchanged.
--
--   holds_area(area)   true when one of the person's active roles is mapped to the area itself

create function public.holds_area(_area text) returns boolean
language sql stable security definer set search_path = '' as $$
  select public.mfa_ok() and exists (
    select 1 from public.role_assignments a
    join public.role_areas ra on ra.role_key = a.role_key and ra.area_key = _area
    where a.user_id = auth.uid() and public.assignment_active(a))
$$;

revoke all on function public.holds_area(text) from public, anon;
grant execute on function public.holds_area(text) to authenticated, service_role;

create or replace function public.cosign_procedure_version(_procedure_id text, _version integer)
returns text
language plpgsql security definer set search_path = '' as $$
declare
  v_proc public.procedures;
  v_ver public.procedure_versions;
  v_area text := coalesce(public.param_text('procedures.cosign_area'), 'risk_compliance');
begin
  if not public.holds_area(v_area) then
    raise exception 'Only the risk owner co-signs a regulated procedure (Plumbline PRC-4).';
  end if;
  select * into v_proc from public.procedures where id = _procedure_id;
  select * into v_ver from public.procedure_versions where procedure_id = _procedure_id and version = _version;
  if v_ver.procedure_id is null then raise exception 'There is no such procedure version.'; end if;
  if not v_proc.regulated then raise exception 'Only a regulated procedure needs a co-sign.'; end if;
  if v_ver.status <> 'draft' or v_ver.accepted_by is null then
    raise exception 'The job owner accepts first; then the co-sign.';
  end if;
  if auth.uid() in (v_ver.drafted_by, v_ver.accepted_by) then
    raise exception 'The co-signer must be someone other than the drafter and the accepter (Plumbline PRC-4).';
  end if;
  update public.procedure_versions set cosigned_by = auth.uid(), cosigned_at = now()
   where procedure_id = _procedure_id and version = _version;
  perform public.procedure_take_effect(_procedure_id, _version);
  perform public.log_evidence('procedure:cosigned', v_proc.job_id, 'procedure', null, null,
    jsonb_build_object('procedure_id', _procedure_id, 'version', _version), null, null, array['PRC-4']);
  return 'accepted';
end;
$$;
