-- =====================================================================
-- PATCH UNTUK APLIKASI CUSTOMER
-- Jalankan SEKALI di Supabase > SQL Editor > New query > Run
-- (aman dijalankan ulang)
-- =====================================================================

-- 1) Kolom rating & ulasan pada order
alter table orders add column if not exists rating int check (rating between 1 and 5);
alter table orders add column if not exists review text;

-- 2) Satu pelanggan hanya boleh punya 1 order aktif
create unique index if not exists one_active_order_per_customer
  on orders(customer_id)
  where status in ('searching','accepted','arrived','ongoing');

-- 3) Pelanggan membatalkan order (aman: hanya status & alasan yang berubah)
create or replace function customer_cancel_order(p_order uuid, p_reason text)
returns jsonb language plpgsql security definer set search_path = public as $$
declare cnt int;
begin
  update orders
     set status = 'cancelled', cancelled_by = 'customer',
         cancel_reason = coalesce(nullif(trim(p_reason),''), 'Dibatalkan pelanggan')
   where id = p_order and customer_id = auth.uid()
     and status in ('searching','accepted','arrived');
  get diagnostics cnt = row_count;
  if cnt = 0 then
    return jsonb_build_object('ok', false, 'msg', 'Order tidak bisa dibatalkan (mungkin sudah berjalan)');
  end if;
  return jsonb_build_object('ok', true);
end $$;

-- 4) Pelanggan memberi rating setelah perjalanan selesai
create or replace function rate_order(p_order uuid, p_stars int, p_review text)
returns jsonb language plpgsql security definer set search_path = public as $$
declare did uuid;
begin
  if p_stars < 1 or p_stars > 5 then
    return jsonb_build_object('ok', false, 'msg', 'Rating harus 1-5');
  end if;
  update orders set rating = p_stars, review = left(coalesce(p_review,''), 300)
   where id = p_order and customer_id = auth.uid() and status = 'completed' and rating is null
   returning driver_id into did;
  if did is null then
    return jsonb_build_object('ok', false, 'msg', 'Order tidak ditemukan / sudah dinilai');
  end if;
  update drivers set rating = coalesce((
      select round(avg(rating)::numeric, 2) from orders where driver_id = did and rating is not null
    ), 5.00) where id = did;
  return jsonb_build_object('ok', true);
end $$;

grant execute on function customer_cancel_order(uuid, text) to authenticated;
grant execute on function rate_order(uuid, int, text) to authenticated;
