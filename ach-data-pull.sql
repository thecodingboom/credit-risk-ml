select 
      t.transaction_public_id, --use this to hash for sampling/splitting
      t.transaction_id,
      t.transaction_created_datetime,
      te.transaction_error_code as LABEL_error_code, --label split
      cs.currency_symbol as send_currency_symbol,
      cr.currency_symbol as receive_currency_symbol,
      u.transaction_user_state_code as user_state,
      ps.payment_status_description as payment_state,
      --features below
      t.transaction_net_send / 100.0 as FEATURE_transaction_usd_send,
      t.transaction_net_payout / 100.0 as FEATURE_local_receive,
      ISNULL (t.transaction_kount_score, 0) as FEATURE_kount_score,
      t.transaction_kount_velocity as FEATURE_kount_velocity,
      t.transaction_sift_score as FEATURE_sift_score,
      t.transaction_days_since_first_completed as FEATURE_days_since_first_completed,
      cd.customer_limit_six_month_limit as FEATURE_six_month_send_limit,
      pp.payment_profile_type as FEATURE_account_type,
      SUBSTRING(pp.payment_profile_institution,0,5) as FEATURE_send_bank, 
      EXTRACT(DAY FROM t.transaction_created_datetime) as FEATURE_day_of_month,
      DATEDIFF (day, cd.customer_date_of_birth_datevalue, t.transaction_created_datetime) as FEATURE_customer_age,
      (select count(*) from transactions t2 
       where t2.transaction_customer_key = t.transaction_customer_key 
       and t2.transaction_created_datetime < t.transaction_created_datetime) 
       as FEATURE_previous_transactions --need to replace this with previous *succesful* transactions      
from transactions t
left join partner_dimension p on t.transaction_partner_key = p.partner_key
left join transaction_user_state_dimension u on t.transaction_user_state_key = u.transaction_user_state_key
left join transaction_error_dimension te on t.transaction_error_code_key = te.transaction_error_key
left join payment_status_dimension ps on t.transaction_payment_status_key = ps.payment_status_key
left join currency_dimension cs on t.transaction_sender_currency_key = cs.currency_key
left join currency_dimension cr on t.transaction_receiver_currency_key = cr.currency_key
left join payment_profile_dimension pp on t.transaction_payment_profile_key = pp.payment_profile_key
left join customer_dimension cd on t.transaction_customer_key = cd.customer_key

where t.transaction_created_datetime >= '2017-11-25'::DATE and t.transaction_created_datetime < '2017-12-01'::DATE
and receive_currency_symbol in ('INR')
and send_currency_symbol in ('USD')
and payment_profile_type in ('checking', 'savings')
and (te.transaction_error_code in ('ACH_INSUFFICIENT_FUNDS') 
  or (te.transaction_error_code in ('No Error') and user_state in ('TUS_COMPLETED'))) --both of these need to be true for goods
order by transaction_created_datetime

