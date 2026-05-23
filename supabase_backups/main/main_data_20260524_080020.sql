SET session_replication_role = replica;

--
-- PostgreSQL database dump
--

-- \restrict WNCVeoMWunbPabq3wqfbWAGgu9imR2XlxwJblMv1c3R2MBP88a2Ste68kR2BtYj

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: custom_oauth_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."users" ("instance_id", "id", "aud", "role", "email", "encrypted_password", "email_confirmed_at", "invited_at", "confirmation_token", "confirmation_sent_at", "recovery_token", "recovery_sent_at", "email_change_token_new", "email_change", "email_change_sent_at", "last_sign_in_at", "raw_app_meta_data", "raw_user_meta_data", "is_super_admin", "created_at", "updated_at", "phone", "phone_confirmed_at", "phone_change", "phone_change_token", "phone_change_sent_at", "email_change_token_current", "email_change_confirm_status", "banned_until", "reauthentication_token", "reauthentication_sent_at", "is_sso_user", "deleted_at", "is_anonymous") VALUES
	('00000000-0000-0000-0000-000000000000', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', 'authenticated', 'authenticated', 'dev.hr.kim@gmail.com', '$2a$10$9vYr9JJM9ha4hWEvLLGGr.28QXWEHrB8zFTIqTPzX5A7I.4gR/3KC', '2026-04-26 03:57:20.315125+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-05-06 06:21:21.998331+00', '{"provider": "email", "providers": ["email"]}', '{"email_verified": true}', NULL, '2026-04-26 03:57:20.302801+00', '2026-05-12 08:47:02.584226+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '33c19c5f-e963-48dc-af9b-8ce240f9ba5c', 'authenticated', 'authenticated', 'seokj0404@naver.com', '$2a$10$7y76oGT/.cdai15vI3HHsO46zDVvFf84Ty9XJHUyLQkMShfhPfC7W', '2026-04-26 03:57:32.354816+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-05-06 06:41:10.230422+00', '{"provider": "email", "providers": ["email"]}', '{"email_verified": true}', NULL, '2026-04-26 03:57:32.350288+00', '2026-05-18 03:00:04.043014+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false);


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."identities" ("provider_id", "user_id", "identity_data", "provider", "last_sign_in_at", "created_at", "updated_at", "id") VALUES
	('cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', '{"sub": "cf94da7c-15a6-4ef5-87e5-8605afe5fcdc", "email": "dev.hr.kim@gmail.com", "email_verified": false, "phone_verified": false}', 'email', '2026-04-26 03:57:20.313261+00', '2026-04-26 03:57:20.31334+00', '2026-04-26 03:57:20.31334+00', '8dd8c708-cc3f-4514-b8ac-71a5f4fd3594'),
	('33c19c5f-e963-48dc-af9b-8ce240f9ba5c', '33c19c5f-e963-48dc-af9b-8ce240f9ba5c', '{"sub": "33c19c5f-e963-48dc-af9b-8ce240f9ba5c", "email": "seokj0404@naver.com", "email_verified": false, "phone_verified": false}', 'email', '2026-04-26 03:57:32.352111+00', '2026-04-26 03:57:32.352158+00', '2026-04-26 03:57:32.352158+00', '78c27029-ae0e-4d5c-a38b-11399e39c627');


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."sessions" ("id", "user_id", "created_at", "updated_at", "factor_id", "aal", "not_after", "refreshed_at", "user_agent", "ip", "tag", "oauth_client_id", "refresh_token_hmac_key", "refresh_token_counter", "scopes") VALUES
	('3f9315ed-f83d-45c9-bfd8-aabeec0160cd', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', '2026-04-27 07:59:04.410159+00', '2026-04-27 09:28:56.282695+00', NULL, 'aal1', NULL, '2026-04-27 09:28:56.282581', 'Dart/3.5 (dart:io)', '58.140.56.37', NULL, NULL, NULL, NULL, NULL),
	('d207ca59-c4d2-4f40-8069-d6730cfd1166', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', '2026-04-27 10:23:34.867037+00', '2026-05-04 08:50:15.149034+00', NULL, 'aal1', NULL, '2026-05-04 08:50:15.148915', 'Dart/3.5 (dart:io)', '58.140.56.37', NULL, NULL, NULL, NULL, NULL),
	('59800dec-5fdb-4edf-bbe6-9cda7180ac0f', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', '2026-05-05 10:17:57.004392+00', '2026-05-05 11:18:25.558429+00', NULL, 'aal1', NULL, '2026-05-05 11:18:25.558319', 'Dart/3.5 (dart:io)', '58.140.56.37', NULL, NULL, NULL, NULL, NULL),
	('562469e6-678f-45d6-abc0-76400e4ef6a3', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', '2026-05-06 06:21:21.99947+00', '2026-05-12 08:47:02.602008+00', NULL, 'aal1', NULL, '2026-05-12 08:47:02.601875', 'Dart/3.5 (dart:io)', '58.140.56.37', NULL, NULL, NULL, NULL, NULL),
	('e9ca6439-afde-44c1-bf4b-5d680f27a09d', '33c19c5f-e963-48dc-af9b-8ce240f9ba5c', '2026-05-06 06:41:10.232391+00', '2026-05-15 11:00:29.499446+00', NULL, 'aal1', NULL, '2026-05-15 11:00:29.499327', 'Dart/3.5 (dart:io)', '59.7.120.186', NULL, NULL, NULL, NULL, NULL),
	('e77ee2be-99d4-404a-8db2-e0d6078f900e', '33c19c5f-e963-48dc-af9b-8ce240f9ba5c', '2026-05-06 06:37:26.47472+00', '2026-05-18 03:00:04.056748+00', NULL, 'aal1', NULL, '2026-05-18 03:00:04.056642', 'Dart/3.5 (dart:io)', '119.193.47.223', NULL, NULL, NULL, NULL, NULL);


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."mfa_amr_claims" ("session_id", "created_at", "updated_at", "authentication_method", "id") VALUES
	('3f9315ed-f83d-45c9-bfd8-aabeec0160cd', '2026-04-27 07:59:04.464848+00', '2026-04-27 07:59:04.464848+00', 'password', '5ffbfab3-3221-42d6-8541-8200c9359ca8'),
	('d207ca59-c4d2-4f40-8069-d6730cfd1166', '2026-04-27 10:23:34.909348+00', '2026-04-27 10:23:34.909348+00', 'password', 'c60357bd-a7f7-47df-b930-d8a00e948463'),
	('59800dec-5fdb-4edf-bbe6-9cda7180ac0f', '2026-05-05 10:17:57.062592+00', '2026-05-05 10:17:57.062592+00', 'password', '2b5a11ec-6648-4412-b570-2246f0d2c581'),
	('562469e6-678f-45d6-abc0-76400e4ef6a3', '2026-05-06 06:21:22.012585+00', '2026-05-06 06:21:22.012585+00', 'password', '095bbc82-31b5-4f5b-8c1e-8231162037f5'),
	('e77ee2be-99d4-404a-8db2-e0d6078f900e', '2026-05-06 06:37:26.481961+00', '2026-05-06 06:37:26.481961+00', 'password', 'de824a5c-3258-4187-a453-770b3a1bdbd5'),
	('e9ca6439-afde-44c1-bf4b-5d680f27a09d', '2026-05-06 06:41:10.246107+00', '2026-05-06 06:41:10.246107+00', 'password', 'cd26c47f-b9ce-494e-97f7-17a21ee46e61');


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_authorizations; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_client_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_consents; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."refresh_tokens" ("instance_id", "id", "token", "user_id", "revoked", "created_at", "updated_at", "parent", "session_id") VALUES
	('00000000-0000-0000-0000-000000000000', 7, 'zarxz7z6lpuq', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', true, '2026-04-27 07:59:04.434545+00', '2026-04-27 09:28:56.245904+00', NULL, '3f9315ed-f83d-45c9-bfd8-aabeec0160cd'),
	('00000000-0000-0000-0000-000000000000', 8, 'i2deq2liyro4', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', false, '2026-04-27 09:28:56.25952+00', '2026-04-27 09:28:56.25952+00', 'zarxz7z6lpuq', '3f9315ed-f83d-45c9-bfd8-aabeec0160cd'),
	('00000000-0000-0000-0000-000000000000', 9, 'vuqbm2szfipb', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', true, '2026-04-27 10:23:34.886998+00', '2026-04-27 11:22:09.207114+00', NULL, 'd207ca59-c4d2-4f40-8069-d6730cfd1166'),
	('00000000-0000-0000-0000-000000000000', 10, 'gokyr5yxuh3z', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', true, '2026-04-27 11:22:09.220182+00', '2026-04-27 12:21:03.127379+00', 'vuqbm2szfipb', 'd207ca59-c4d2-4f40-8069-d6730cfd1166'),
	('00000000-0000-0000-0000-000000000000', 11, 'rbinse5uzigx', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', true, '2026-04-27 12:21:03.139569+00', '2026-04-29 09:08:30.79737+00', 'gokyr5yxuh3z', 'd207ca59-c4d2-4f40-8069-d6730cfd1166'),
	('00000000-0000-0000-0000-000000000000', 12, 'fgxde2r5rvgv', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', true, '2026-04-29 09:08:30.81921+00', '2026-04-30 03:50:11.380239+00', 'rbinse5uzigx', 'd207ca59-c4d2-4f40-8069-d6730cfd1166'),
	('00000000-0000-0000-0000-000000000000', 13, 'bptcg4t337qk', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', true, '2026-04-30 03:50:11.398254+00', '2026-04-30 04:48:53.516866+00', 'fgxde2r5rvgv', 'd207ca59-c4d2-4f40-8069-d6730cfd1166'),
	('00000000-0000-0000-0000-000000000000', 14, 'z33zlfezo3vv', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', true, '2026-04-30 04:48:53.533059+00', '2026-05-04 06:52:58.092777+00', 'bptcg4t337qk', 'd207ca59-c4d2-4f40-8069-d6730cfd1166'),
	('00000000-0000-0000-0000-000000000000', 15, 'czdkozl4oae4', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', true, '2026-05-04 06:52:58.116822+00', '2026-05-04 07:51:35.398916+00', 'z33zlfezo3vv', 'd207ca59-c4d2-4f40-8069-d6730cfd1166'),
	('00000000-0000-0000-0000-000000000000', 16, '377ae72alx7j', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', true, '2026-05-04 07:51:35.417591+00', '2026-05-04 08:50:15.111933+00', 'czdkozl4oae4', 'd207ca59-c4d2-4f40-8069-d6730cfd1166'),
	('00000000-0000-0000-0000-000000000000', 17, '3dpisfnfv7l2', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', false, '2026-05-04 08:50:15.124693+00', '2026-05-04 08:50:15.124693+00', '377ae72alx7j', 'd207ca59-c4d2-4f40-8069-d6730cfd1166'),
	('00000000-0000-0000-0000-000000000000', 18, 'ubnaphkobuxh', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', true, '2026-05-05 10:17:57.039292+00', '2026-05-05 11:18:25.525663+00', NULL, '59800dec-5fdb-4edf-bbe6-9cda7180ac0f'),
	('00000000-0000-0000-0000-000000000000', 19, 'm33tgddub2sd', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', false, '2026-05-05 11:18:25.540215+00', '2026-05-05 11:18:25.540215+00', 'ubnaphkobuxh', '59800dec-5fdb-4edf-bbe6-9cda7180ac0f'),
	('00000000-0000-0000-0000-000000000000', 21, 'cu7ubd2db42g', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', true, '2026-05-06 06:21:22.009051+00', '2026-05-06 15:36:17.922284+00', NULL, '562469e6-678f-45d6-abc0-76400e4ef6a3'),
	('00000000-0000-0000-0000-000000000000', 24, '22jkubaqgjiu', '33c19c5f-e963-48dc-af9b-8ce240f9ba5c', true, '2026-05-06 06:37:26.478418+00', '2026-05-07 03:21:43.945859+00', NULL, 'e77ee2be-99d4-404a-8db2-e0d6078f900e'),
	('00000000-0000-0000-0000-000000000000', 26, 'tlcagi6oy5mv', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', true, '2026-05-06 15:36:17.940974+00', '2026-05-07 11:44:12.080306+00', 'cu7ubd2db42g', '562469e6-678f-45d6-abc0-76400e4ef6a3'),
	('00000000-0000-0000-0000-000000000000', 28, 'ktex7micpaad', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', true, '2026-05-07 11:44:12.091498+00', '2026-05-08 12:57:02.067235+00', 'tlcagi6oy5mv', '562469e6-678f-45d6-abc0-76400e4ef6a3'),
	('00000000-0000-0000-0000-000000000000', 29, 'ewzc7urqf5vh', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', true, '2026-05-08 12:57:02.084834+00', '2026-05-09 15:19:40.833059+00', 'ktex7micpaad', '562469e6-678f-45d6-abc0-76400e4ef6a3'),
	('00000000-0000-0000-0000-000000000000', 30, '6lnov5ad67gc', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', true, '2026-05-09 15:19:40.849468+00', '2026-05-10 06:48:35.488387+00', 'ewzc7urqf5vh', '562469e6-678f-45d6-abc0-76400e4ef6a3'),
	('00000000-0000-0000-0000-000000000000', 25, '32d7zjeinecs', '33c19c5f-e963-48dc-af9b-8ce240f9ba5c', true, '2026-05-06 06:41:10.242375+00', '2026-05-12 01:57:16.129631+00', NULL, 'e9ca6439-afde-44c1-bf4b-5d680f27a09d'),
	('00000000-0000-0000-0000-000000000000', 31, '5i7ixehxtwgp', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', true, '2026-05-10 06:48:35.498846+00', '2026-05-12 08:47:02.566021+00', '6lnov5ad67gc', '562469e6-678f-45d6-abc0-76400e4ef6a3'),
	('00000000-0000-0000-0000-000000000000', 33, 't2ac3l7jtuvr', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', false, '2026-05-12 08:47:02.577866+00', '2026-05-12 08:47:02.577866+00', '5i7ixehxtwgp', '562469e6-678f-45d6-abc0-76400e4ef6a3'),
	('00000000-0000-0000-0000-000000000000', 32, 'xmvltv2vght4', '33c19c5f-e963-48dc-af9b-8ce240f9ba5c', true, '2026-05-12 01:57:16.150933+00', '2026-05-13 12:27:12.887332+00', '32d7zjeinecs', 'e9ca6439-afde-44c1-bf4b-5d680f27a09d'),
	('00000000-0000-0000-0000-000000000000', 34, 'c42thffwocch', '33c19c5f-e963-48dc-af9b-8ce240f9ba5c', true, '2026-05-13 12:27:12.905177+00', '2026-05-15 11:00:29.454039+00', 'xmvltv2vght4', 'e9ca6439-afde-44c1-bf4b-5d680f27a09d'),
	('00000000-0000-0000-0000-000000000000', 35, 'tjrpbusbhfak', '33c19c5f-e963-48dc-af9b-8ce240f9ba5c', false, '2026-05-15 11:00:29.476711+00', '2026-05-15 11:00:29.476711+00', 'c42thffwocch', 'e9ca6439-afde-44c1-bf4b-5d680f27a09d'),
	('00000000-0000-0000-0000-000000000000', 27, 'oszbufwxzrze', '33c19c5f-e963-48dc-af9b-8ce240f9ba5c', true, '2026-05-07 03:21:43.958865+00', '2026-05-18 03:00:04.016221+00', '22jkubaqgjiu', 'e77ee2be-99d4-404a-8db2-e0d6078f900e'),
	('00000000-0000-0000-0000-000000000000', 36, 'cwbv4cw6k3nr', '33c19c5f-e963-48dc-af9b-8ce240f9ba5c', false, '2026-05-18 03:00:04.031809+00', '2026-05-18 03:00:04.031809+00', 'oszbufwxzrze', 'e77ee2be-99d4-404a-8db2-e0d6078f900e');


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: webauthn_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: webauthn_credentials; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: admins; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."admins" ("id", "name", "role") VALUES
	('cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', '김혜린', 'admin'),
	('33c19c5f-e963-48dc-af9b-8ce240f9ba5c', '서경진', 'admin');


--
-- Data for Name: chat_rooms; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: chat_messages; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."users" ("id", "email", "name", "phone_number", "created_at", "updated_at", "address") VALUES
	('cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', 'dev.hr.kim@gmail.com', '', '', '2026-05-21 12:37:29.125994+00', '2026-05-21 12:37:29.125994+00', NULL),
	('33c19c5f-e963-48dc-af9b-8ce240f9ba5c', 'seokj0404@naver.com', '', '', '2026-05-21 12:37:29.125994+00', '2026-05-21 12:37:29.125994+00', NULL);


--
-- Data for Name: chat_room_members; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."orders" ("id", "customer_name", "customer_phone", "shipping_address", "total_amount", "status", "created_at", "user_id") VALUES
	(1, '홍길동', '01012345678', '서울시 강남구 테헤란로 123, 서울, 06234', 84900, 'pending', '2026-05-04 08:18:41.585081+00', NULL),
	(2, '홍길동', '01012345678', '서울시 강남구 테헤란로 123, 서울, 06234', 84900, 'pending', '2026-05-04 08:19:02.800893+00', NULL);


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."products" ("id", "name", "price", "stock", "description", "created_at", "is_best_seller", "is_deleted") VALUES
	(1, '혼다 pcx 2019년식 윈도우 스크린', 75000, 10, '회사: 혼다
기종: pcx125
년식: 2019년식
제품명: 롱 윈도우 스크린', '2026-04-30 04:15:34.598393+00', false, false);


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."order_items" ("id", "order_id", "product_id", "quantity", "unit_price") VALUES
	(1, 1, 1, 1, 75000),
	(2, 2, 1, 1, 75000);


--
-- Data for Name: orders_history; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: product_images; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."product_images" ("id", "product_id", "image_url", "display_order", "is_main") VALUES
	(1, 1, 'https://utifuxaezkhfeuwetfti.supabase.co/storage/v1/object/public/product_images/thumbnails/1777522580828_scaled_1000000036.jpg', 0, true),
	(2, 1, 'https://utifuxaezkhfeuwetfti.supabase.co/storage/v1/object/public/product_images/details/1777522581747_scaled_1000000035.jpg', 1, false),
	(3, 1, 'https://utifuxaezkhfeuwetfti.supabase.co/storage/v1/object/public/product_images/details/1777522582982_scaled_1000000037.jpg', 2, false);


--
-- Data for Name: products_history; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: users_history; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: wishlists; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

INSERT INTO "storage"."buckets" ("id", "name", "owner", "created_at", "updated_at", "public", "avif_autodetection", "file_size_limit", "allowed_mime_types", "owner_id", "type") VALUES
	('product_images', 'product_images', NULL, '2026-04-26 05:07:36.770443+00', '2026-04-26 05:07:36.770443+00', true, false, NULL, NULL, NULL, 'STANDARD'),
	('chat_images', 'chat_images', NULL, '2026-05-21 18:27:52.995808+00', '2026-05-21 18:27:52.995808+00', true, false, 10485760, '{image/jpeg,image/png,image/webp,image/gif}', NULL, 'STANDARD');


--
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: buckets_vectors; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

INSERT INTO "storage"."objects" ("id", "bucket_id", "name", "owner", "created_at", "updated_at", "last_accessed_at", "metadata", "version", "owner_id", "user_metadata") VALUES
	('8217b3d6-f187-478d-aafb-22c217dfbdbb', 'product_images', 'thumbnails/1777181016971_scaled_1000000033.jpg', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', '2026-04-26 05:22:51.808332+00', '2026-04-26 05:22:51.808332+00', '2026-04-26 05:22:51.808332+00', '{"eTag": "\"f2b9b0221e5e6774a44360669eb98980\"", "size": 36510, "mimetype": "image/jpg", "cacheControl": "max-age=3600", "lastModified": "2026-04-26T05:22:52.000Z", "contentLength": 36510, "httpStatusCode": 200}', 'dba8a11e-76b3-4113-9423-3bc11591b746', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', '{}'),
	('c1eb181a-6c7c-4228-8f30-2d3b649583f1', 'product_images', 'details/1777181017604_scaled_1000000034.jpg', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', '2026-04-26 05:22:52.367158+00', '2026-04-26 05:22:52.367158+00', '2026-04-26 05:22:52.367158+00', '{"eTag": "\"5efaa998ea3a10ec3da800384f8a2a11\"", "size": 18711, "mimetype": "image/jpg", "cacheControl": "max-age=3600", "lastModified": "2026-04-26T05:22:53.000Z", "contentLength": 18711, "httpStatusCode": 200}', '4f947d87-999a-4d26-ab8b-fb90e1fb3d00', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', '{}'),
	('22175559-2e44-4a84-a823-49af68d5f106', 'product_images', 'details/1777284670953_scaled_1000000034.jpg', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', '2026-04-27 10:10:24.777531+00', '2026-04-27 10:10:24.777531+00', '2026-04-27 10:10:24.777531+00', '{"eTag": "\"5efaa998ea3a10ec3da800384f8a2a11\"", "size": 18711, "mimetype": "image/jpg", "cacheControl": "max-age=3600", "lastModified": "2026-04-27T10:10:25.000Z", "contentLength": 18711, "httpStatusCode": 200}', 'd3d553ca-6ada-4a1c-b37d-14e72375b2ef', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', '{}'),
	('10f6b39a-2240-458e-b1d6-de9c4e0ce691', 'product_images', 'thumbnails/1777284860639_scaled_1000000034.jpg', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', '2026-04-27 10:13:34.448858+00', '2026-04-27 10:13:34.448858+00', '2026-04-27 10:13:34.448858+00', '{"eTag": "\"5efaa998ea3a10ec3da800384f8a2a11\"", "size": 18711, "mimetype": "image/jpg", "cacheControl": "max-age=3600", "lastModified": "2026-04-27T10:13:35.000Z", "contentLength": 18711, "httpStatusCode": 200}', '6b5c0c0c-f07f-4862-8eb2-10fac010210a', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', '{}'),
	('1b9bbc2c-6e40-4658-9eeb-e4ae23a1c8b4', 'product_images', 'thumbnails/1777284991848_scaled_1000000034.jpg', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', '2026-04-27 10:15:45.613306+00', '2026-04-27 10:15:45.613306+00', '2026-04-27 10:15:45.613306+00', '{"eTag": "\"5efaa998ea3a10ec3da800384f8a2a11\"", "size": 18711, "mimetype": "image/jpg", "cacheControl": "max-age=3600", "lastModified": "2026-04-27T10:15:46.000Z", "contentLength": 18711, "httpStatusCode": 200}', '1cf7d8d4-528b-40bc-96ec-5674c96dce5c', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', '{}'),
	('a1fa23ac-1f66-4a1a-a9dd-3f720b511701', 'product_images', 'thumbnails/1777285809573_scaled_1000000033.jpg', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', '2026-04-27 10:29:23.384178+00', '2026-04-27 10:29:23.384178+00', '2026-04-27 10:29:23.384178+00', '{"eTag": "\"f2b9b0221e5e6774a44360669eb98980\"", "size": 36510, "mimetype": "image/jpg", "cacheControl": "max-age=3600", "lastModified": "2026-04-27T10:29:24.000Z", "contentLength": 36510, "httpStatusCode": 200}', 'bf678a30-c0b7-406c-903b-f2334c8a8810', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', '{}'),
	('1204fd26-ae83-46a4-8ccb-d7b82f642465', 'product_images', 'thumbnails/1777522580828_scaled_1000000036.jpg', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', '2026-04-30 04:15:35.370621+00', '2026-04-30 04:15:35.370621+00', '2026-04-30 04:15:35.370621+00', '{"eTag": "\"705a77526efa21e5e01c431f271ac727\"", "size": 113646, "mimetype": "image/jpg", "cacheControl": "max-age=3600", "lastModified": "2026-04-30T04:15:36.000Z", "contentLength": 113646, "httpStatusCode": 200}', 'd70567a1-3596-4c3a-840f-6a2b3f6325d8', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', '{}'),
	('cc0255a6-bdc0-46e0-8a38-28e375b4c8f9', 'product_images', 'details/1777522581747_scaled_1000000035.jpg', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', '2026-04-30 04:15:36.556923+00', '2026-04-30 04:15:36.556923+00', '2026-04-30 04:15:36.556923+00', '{"eTag": "\"f3ade6edc6b6680e5a76d6dd87cb676f\"", "size": 140530, "mimetype": "image/jpg", "cacheControl": "max-age=3600", "lastModified": "2026-04-30T04:15:37.000Z", "contentLength": 140530, "httpStatusCode": 200}', 'b32cd36e-f31c-4afe-b6a8-89173195fd7f', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', '{}'),
	('10bf2586-28db-4ae7-b417-8705dcbf2596', 'product_images', 'details/1777522582982_scaled_1000000037.jpg', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', '2026-04-30 04:15:37.415294+00', '2026-04-30 04:15:37.415294+00', '2026-04-30 04:15:37.415294+00', '{"eTag": "\"2fd04eaa114369175ad8e08b6e14aabe\"", "size": 135029, "mimetype": "image/jpg", "cacheControl": "max-age=3600", "lastModified": "2026-04-30T04:15:38.000Z", "contentLength": 135029, "httpStatusCode": 200}', '0960c0a5-ddff-49d8-a00d-6cb598932fb4', 'cf94da7c-15a6-4ef5-87e5-8605afe5fcdc', '{}');


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: vector_indexes; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: supabase_auth_admin
--

SELECT pg_catalog.setval('"auth"."refresh_tokens_id_seq"', 36, true);


--
-- Name: order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."order_items_id_seq"', 2, true);


--
-- Name: orders_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."orders_history_id_seq"', 1, false);


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."orders_id_seq"', 2, true);


--
-- Name: product_images_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."product_images_id_seq"', 3, true);


--
-- Name: products_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."products_history_id_seq"', 1, false);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."products_id_seq"', 1, true);


--
-- Name: users_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."users_history_id_seq"', 1, false);


--
-- Name: wishlists_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."wishlists_id_seq"', 1, false);


--
-- PostgreSQL database dump complete
--

-- \unrestrict WNCVeoMWunbPabq3wqfbWAGgu9imR2XlxwJblMv1c3R2MBP88a2Ste68kR2BtYj

RESET ALL;
