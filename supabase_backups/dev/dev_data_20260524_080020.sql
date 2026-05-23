SET session_replication_role = replica;

--
-- PostgreSQL database dump
--

-- \restrict zRTfghehHK8A2XB5zZg3gswkLSkIOuXmb8hJ0KFrhDMqgneopy2j4sZqe1hqyS5

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

INSERT INTO "auth"."flow_state" ("id", "user_id", "auth_code", "code_challenge_method", "code_challenge", "provider_type", "provider_access_token", "provider_refresh_token", "created_at", "updated_at", "authentication_method", "auth_code_issued_at", "invite_token", "referrer", "oauth_client_state_id", "linking_target_id", "email_optional") VALUES
	('8bf30e23-2b82-478c-bd89-db31a27b87fe', 'c8b1becb-40c1-4802-9ff2-beac34a729e6', 'ffce3e4f-febb-420e-a5bc-afa69c4121b9', 's256', 'GpuZQL4kotqoA4SJNWfqAS7tMwWUP4vcgA305ygIdgM', 'email', '', '', '2026-05-21 12:31:30.806557+00', '2026-05-21 12:31:30.806557+00', 'email/signup', NULL, NULL, NULL, NULL, NULL, false),
	('355b8737-f863-43fd-968e-c0f2df706ba3', 'c8b1becb-40c1-4802-9ff2-beac34a729e6', 'd5c05b58-30d3-4e98-a27b-a91264b33320', 's256', 'FMcowFvGnlIgaZ58R_R3raoU1hqz6pSLeKidvCcVYMs', 'email', '', '', '2026-05-21 12:46:06.965613+00', '2026-05-21 12:46:06.965613+00', 'email/signup', NULL, NULL, NULL, NULL, NULL, false);


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."users" ("instance_id", "id", "aud", "role", "email", "encrypted_password", "email_confirmed_at", "invited_at", "confirmation_token", "confirmation_sent_at", "recovery_token", "recovery_sent_at", "email_change_token_new", "email_change", "email_change_sent_at", "last_sign_in_at", "raw_app_meta_data", "raw_user_meta_data", "is_super_admin", "created_at", "updated_at", "phone", "phone_confirmed_at", "phone_change", "phone_change_token", "phone_change_sent_at", "email_change_token_current", "email_change_confirm_status", "banned_until", "reauthentication_token", "reauthentication_sent_at", "is_sso_user", "deleted_at", "is_anonymous") VALUES
	('00000000-0000-0000-0000-000000000000', 'c8b1becb-40c1-4802-9ff2-beac34a729e6', 'authenticated', 'authenticated', 'onpa99@naver.com', '$2a$10$fiGEaHXnTz3r9fmRLTUrF.wdN2lveZXt5b9AIYidQdwX9EiQRe.tu', NULL, NULL, 'pkce_e0d4e760de552c914c0ab39386c46ef084c7aaff83ceb85b66fd184e', '2026-05-21 12:46:06.966786+00', '', NULL, '', '', NULL, NULL, '{"provider": "email", "providers": ["email"]}', '{"sub": "c8b1becb-40c1-4802-9ff2-beac34a729e6", "name": "김혜린", "email": "onpa99@naver.com", "phone": "", "email_verified": false, "phone_verified": false}', NULL, '2026-05-21 12:31:30.783437+00', '2026-05-21 12:46:08.496821+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '633906ea-b4b6-4d79-b559-ee3b11b8154c', 'authenticated', 'authenticated', 'onpa@naver.com', '$2a$10$J9xC1CgsmU8rdNWuEefxFOzr56ttsyyqja6cJjNSq4V3qgOlIXo.6', '2026-05-21 12:56:46.862803+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-05-21 22:19:39.314707+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "633906ea-b4b6-4d79-b559-ee3b11b8154c", "name": "김혜린", "email": "onpa@naver.com", "phone": "01087762855", "address": "서울시", "email_verified": true, "phone_verified": false}', NULL, '2026-05-21 12:56:46.855012+00', '2026-05-21 22:19:39.317688+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', 'authenticated', 'authenticated', 'dev.hr.kim@gmail.com', '$2a$10$pYrSKZ5hOPzuTxBVJYK3oO/cB7aQijysaa15zhDG2LDBiiCiozJ4u', '2026-04-27 11:53:06.309522+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-05-21 22:19:48.475944+00', '{"provider": "email", "providers": ["email"]}', '{"email_verified": true}', NULL, '2026-04-27 11:53:06.302568+00', '2026-05-21 22:19:48.478038+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', 'bee9b236-875b-4b03-84c2-483aa65ed9a7', 'authenticated', 'authenticated', 'onpa@nate.com', '$2a$10$dwoaNPxDaVWbQde/yQksEeD6LXYBAr4uTcLxolDRB2ORsqikVBoBS', '2026-05-21 22:25:16.652963+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-05-21 22:25:16.657853+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "bee9b236-875b-4b03-84c2-483aa65ed9a7", "name": "김혜린", "email": "onpa@nate.com", "phone": "01012345670", "address": "서울시 마포구", "email_verified": true, "phone_verified": false}', NULL, '2026-05-21 22:25:16.642039+00', '2026-05-23 16:56:55.847736+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false);


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."identities" ("provider_id", "user_id", "identity_data", "provider", "last_sign_in_at", "created_at", "updated_at", "id") VALUES
	('3c597199-32aa-4ab7-b383-dae3b8fdebf5', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', '{"sub": "3c597199-32aa-4ab7-b383-dae3b8fdebf5", "email": "dev.hr.kim@gmail.com", "email_verified": false, "phone_verified": false}', 'email', '2026-04-27 11:53:06.306775+00', '2026-04-27 11:53:06.306842+00', '2026-04-27 11:53:06.306842+00', 'c1dd3705-8a17-4d2d-a14d-ea4b258cb4e2'),
	('c8b1becb-40c1-4802-9ff2-beac34a729e6', 'c8b1becb-40c1-4802-9ff2-beac34a729e6', '{"sub": "c8b1becb-40c1-4802-9ff2-beac34a729e6", "name": "김혜린", "email": "onpa99@naver.com", "phone": "", "email_verified": false, "phone_verified": false}', 'email', '2026-05-21 12:31:30.799874+00', '2026-05-21 12:31:30.799947+00', '2026-05-21 12:31:30.799947+00', '38f942c8-505d-481c-9ef2-a256e1b0f05c'),
	('633906ea-b4b6-4d79-b559-ee3b11b8154c', '633906ea-b4b6-4d79-b559-ee3b11b8154c', '{"sub": "633906ea-b4b6-4d79-b559-ee3b11b8154c", "name": "김혜린", "email": "onpa@naver.com", "phone": "01087762855", "address": "서울시", "email_verified": false, "phone_verified": false}', 'email', '2026-05-21 12:56:46.859721+00', '2026-05-21 12:56:46.859767+00', '2026-05-21 12:56:46.859767+00', '9381c062-b839-4e2c-9388-0db97826e9d1'),
	('bee9b236-875b-4b03-84c2-483aa65ed9a7', 'bee9b236-875b-4b03-84c2-483aa65ed9a7', '{"sub": "bee9b236-875b-4b03-84c2-483aa65ed9a7", "name": "김혜린", "email": "onpa@nate.com", "phone": "01012345678", "address": "서울시 마포구", "email_verified": false, "phone_verified": false}', 'email', '2026-05-21 22:25:16.649703+00', '2026-05-21 22:25:16.649747+00', '2026-05-21 22:25:16.649747+00', '488cb24f-a9ef-45a6-a63d-6cec942dcdcd');


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
	('16736a35-95a7-431e-b422-33f9c512a690', '633906ea-b4b6-4d79-b559-ee3b11b8154c', '2026-05-21 18:22:21.342791+00', '2026-05-21 18:22:21.342791+00', NULL, 'aal1', NULL, NULL, 'Dart/3.12 (dart:io)', '58.140.56.37', NULL, NULL, NULL, NULL, NULL),
	('cdd9347b-6598-48d9-b27a-d73c5575c600', '633906ea-b4b6-4d79-b559-ee3b11b8154c', '2026-05-21 19:05:21.995583+00', '2026-05-21 19:05:21.995583+00', NULL, 'aal1', NULL, NULL, 'Dart/3.12 (dart:io)', '58.140.56.37', NULL, NULL, NULL, NULL, NULL),
	('b2b7e139-e641-4c41-9c52-f4ee5043714c', '633906ea-b4b6-4d79-b559-ee3b11b8154c', '2026-05-21 20:49:46.956125+00', '2026-05-21 20:49:46.956125+00', NULL, 'aal1', NULL, NULL, 'Dart/3.12 (dart:io)', '58.140.56.37', NULL, NULL, NULL, NULL, NULL),
	('31f7b6db-32e4-4e8a-b9c3-d731b18a51b1', '633906ea-b4b6-4d79-b559-ee3b11b8154c', '2026-05-21 22:19:39.314799+00', '2026-05-21 22:19:39.314799+00', NULL, 'aal1', NULL, NULL, 'Dart/3.12 (dart:io)', '58.140.56.37', NULL, NULL, NULL, NULL, NULL),
	('763ff524-fc5c-49f7-8d46-c48f63d29705', 'bee9b236-875b-4b03-84c2-483aa65ed9a7', '2026-05-21 22:25:16.657974+00', '2026-05-23 16:50:44.200462+00', NULL, 'aal1', NULL, '2026-05-23 16:50:44.200362', 'Dart/3.12 (dart:io)', '58.140.56.37', NULL, NULL, NULL, NULL, NULL);


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."mfa_amr_claims" ("session_id", "created_at", "updated_at", "authentication_method", "id") VALUES
	('16736a35-95a7-431e-b422-33f9c512a690', '2026-05-21 18:22:21.346368+00', '2026-05-21 18:22:21.346368+00', 'password', '29fb29ac-dec7-4a1c-acee-3d64091efb3d'),
	('cdd9347b-6598-48d9-b27a-d73c5575c600', '2026-05-21 19:05:21.999136+00', '2026-05-21 19:05:21.999136+00', 'password', '58fd7cfc-d046-4127-a857-6632904daf7e'),
	('b2b7e139-e641-4c41-9c52-f4ee5043714c', '2026-05-21 20:49:46.959574+00', '2026-05-21 20:49:46.959574+00', 'password', '15879c10-fa14-46f4-b76b-9653c9db5573'),
	('31f7b6db-32e4-4e8a-b9c3-d731b18a51b1', '2026-05-21 22:19:39.318536+00', '2026-05-21 22:19:39.318536+00', 'password', '3919aec5-3b7b-45cd-afe3-caa753607903'),
	('763ff524-fc5c-49f7-8d46-c48f63d29705', '2026-05-21 22:25:16.661233+00', '2026-05-21 22:25:16.661233+00', 'password', 'a7de0950-0d5a-4bf8-93f7-3ebd13198fc1');


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

INSERT INTO "auth"."one_time_tokens" ("id", "user_id", "token_type", "token_hash", "relates_to", "created_at", "updated_at") VALUES
	('853bdea9-e620-4faf-b6c6-327446cf07a5', 'c8b1becb-40c1-4802-9ff2-beac34a729e6', 'confirmation_token', 'pkce_e0d4e760de552c914c0ab39386c46ef084c7aaff83ceb85b66fd184e', 'onpa99@naver.com', '2026-05-21 12:46:08.49954', '2026-05-21 12:46:08.49954');


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."refresh_tokens" ("instance_id", "id", "token", "user_id", "revoked", "created_at", "updated_at", "parent", "session_id") VALUES
	('00000000-0000-0000-0000-000000000000', 21, 'xby5iy2bmncy', '633906ea-b4b6-4d79-b559-ee3b11b8154c', false, '2026-05-21 18:22:21.344252+00', '2026-05-21 18:22:21.344252+00', NULL, '16736a35-95a7-431e-b422-33f9c512a690'),
	('00000000-0000-0000-0000-000000000000', 24, 'jnisk6fjhfaf', '633906ea-b4b6-4d79-b559-ee3b11b8154c', false, '2026-05-21 19:05:21.997112+00', '2026-05-21 19:05:21.997112+00', NULL, 'cdd9347b-6598-48d9-b27a-d73c5575c600'),
	('00000000-0000-0000-0000-000000000000', 33, 'qqnkux2j66b2', '633906ea-b4b6-4d79-b559-ee3b11b8154c', false, '2026-05-21 20:49:46.957506+00', '2026-05-21 20:49:46.957506+00', NULL, 'b2b7e139-e641-4c41-9c52-f4ee5043714c'),
	('00000000-0000-0000-0000-000000000000', 38, 'locyjrqflswp', '633906ea-b4b6-4d79-b559-ee3b11b8154c', false, '2026-05-21 22:19:39.316361+00', '2026-05-21 22:19:39.316361+00', NULL, '31f7b6db-32e4-4e8a-b9c3-d731b18a51b1'),
	('00000000-0000-0000-0000-000000000000', 40, 'qjqyqkr7lcbw', 'bee9b236-875b-4b03-84c2-483aa65ed9a7', true, '2026-05-21 22:25:16.6593+00', '2026-05-23 16:50:44.195521+00', NULL, '763ff524-fc5c-49f7-8d46-c48f63d29705'),
	('00000000-0000-0000-0000-000000000000', 41, 'aih3dd3uft5f', 'bee9b236-875b-4b03-84c2-483aa65ed9a7', false, '2026-05-23 16:50:44.197213+00', '2026-05-23 16:50:44.197213+00', 'qjqyqkr7lcbw', '763ff524-fc5c-49f7-8d46-c48f63d29705');


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
	('3c597199-32aa-4ab7-b383-dae3b8fdebf5', '김혜린', 'admin');


--
-- Data for Name: chat_rooms; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."chat_rooms" ("id", "status", "created_at") VALUES
	('2808864e-cd7d-4492-9f89-3814f5cb5f3f', 'COMPLETED', '2026-05-21 17:51:38.339282+00'),
	('8018d441-cf7a-466d-bb27-15ddedce8e40', 'COMPLETED', '2026-05-21 17:59:41.0564+00'),
	('72dd3bb5-6f9a-410d-afd2-3fe4b90e2824', 'COMPLETED', '2026-05-21 18:02:30.885689+00'),
	('ae6cf2e6-7e6f-424b-8d50-e572a803465b', 'COMPLETED', '2026-05-21 18:11:57.297329+00'),
	('2fe645d3-137f-4a91-aad7-8c21295d8667', 'COMPLETED', '2026-05-21 18:32:12.85841+00'),
	('83d1f78a-cfa6-46b3-aa35-3cc747a8e68c', 'COMPLETED', '2026-05-21 18:38:53.833646+00');


--
-- Data for Name: chat_messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."chat_messages" ("id", "room_id", "sender_id", "message", "created_at", "image_url") VALUES
	('8e1284b2-9eb9-41c2-9435-8d4b40a058b3', '2808864e-cd7d-4492-9f89-3814f5cb5f3f', '633906ea-b4b6-4d79-b559-ee3b11b8154c', 'aa', '2026-05-21 17:59:22.660693+00', NULL),
	('e6fd2849-555b-4368-9434-5c80b0a593ee', '2808864e-cd7d-4492-9f89-3814f5cb5f3f', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', 'ddd', '2026-05-21 17:59:29.110501+00', NULL),
	('254011b5-8e0e-4a94-bf86-ee7b07b679da', '72dd3bb5-6f9a-410d-afd2-3fe4b90e2824', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', 'zxczxc', '2026-05-21 18:02:43.048953+00', NULL),
	('8094e8ed-0b03-4910-be96-3694facb404a', 'ae6cf2e6-7e6f-424b-8d50-e572a803465b', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', 'sdfsd', '2026-05-21 18:12:02.621575+00', NULL),
	('94a2e5b8-22c4-4ddc-9096-a2aad7ba97b9', 'ae6cf2e6-7e6f-424b-8d50-e572a803465b', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', 'sdfds', '2026-05-21 18:24:47.712052+00', NULL),
	('dc8bad4f-d937-438a-8f2f-01d7f3bf8b03', 'ae6cf2e6-7e6f-424b-8d50-e572a803465b', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', 'e', '2026-05-21 18:24:52.24807+00', NULL),
	('23aa5844-4e0e-42d2-ae7a-c2f58bf936dd', 'ae6cf2e6-7e6f-424b-8d50-e572a803465b', '633906ea-b4b6-4d79-b559-ee3b11b8154c', '', '2026-05-21 18:31:38.58809+00', 'https://zlumvgindinymplyvhsh.supabase.co/storage/v1/object/public/chat_images/ae6cf2e6-7e6f-424b-8d50-e572a803465b/633906ea-b4b6-4d79-b559-ee3b11b8154c_1779388297652.jpg'),
	('71137dbb-7b0b-4117-b364-f604a75a9a00', 'ae6cf2e6-7e6f-424b-8d50-e572a803465b', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', '', '2026-05-21 18:31:49.640874+00', 'https://zlumvgindinymplyvhsh.supabase.co/storage/v1/object/public/chat_images/ae6cf2e6-7e6f-424b-8d50-e572a803465b/3c597199-32aa-4ab7-b383-dae3b8fdebf5_1779388351244.jpg'),
	('cd8ce119-43f5-4ebc-8e84-680695a17cae', '83d1f78a-cfa6-46b3-aa35-3cc747a8e68c', '633906ea-b4b6-4d79-b559-ee3b11b8154c', 'ii', '2026-05-21 18:38:59.205639+00', NULL),
	('db962f05-c24a-41f6-87e0-f03309c70f87', '83d1f78a-cfa6-46b3-aa35-3cc747a8e68c', '633906ea-b4b6-4d79-b559-ee3b11b8154c', '1', '2026-05-21 18:38:59.776872+00', NULL),
	('60912ea9-1e82-4664-ae77-355a3106a420', '83d1f78a-cfa6-46b3-aa35-3cc747a8e68c', '633906ea-b4b6-4d79-b559-ee3b11b8154c', 's', '2026-05-21 18:39:00.668687+00', NULL),
	('f4463b53-5b79-4f4e-b0f1-c09ee493300d', '83d1f78a-cfa6-46b3-aa35-3cc747a8e68c', '633906ea-b4b6-4d79-b559-ee3b11b8154c', 'ee', '2026-05-21 18:39:14.221147+00', NULL);


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."users" ("id", "email", "name", "phone_number", "address", "created_at", "updated_at") VALUES
	('c8b1becb-40c1-4802-9ff2-beac34a729e6', 'onpa99@naver.com', '김혜린', '', NULL, '2026-05-21 12:51:41.645258+00', '2026-05-21 12:51:41.645258+00'),
	('633906ea-b4b6-4d79-b559-ee3b11b8154c', 'onpa@naver.com', '김혜린', '01087762855', '서울시', '2026-05-21 12:56:46.85468+00', '2026-05-21 12:56:46.85468+00'),
	('3c597199-32aa-4ab7-b383-dae3b8fdebf5', 'dev.hr.kim@gmail.com', '', '', NULL, '2026-05-21 12:51:41.645258+00', '2026-05-23 16:55:18.336494+00'),
	('bee9b236-875b-4b03-84c2-483aa65ed9a7', 'onpa@nate.com', '김혜린', '01012345670', NULL, '2026-05-21 22:25:16.64171+00', '2026-05-23 16:56:56.06244+00');


--
-- Data for Name: chat_room_members; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."chat_room_members" ("id", "room_id", "user_id", "role", "joined_at") VALUES
	('0493698e-c840-45b6-81d7-7f4eb70562a6', '2808864e-cd7d-4492-9f89-3814f5cb5f3f', '633906ea-b4b6-4d79-b559-ee3b11b8154c', 'CUSTOMER', '2026-05-21 17:51:38.339282+00'),
	('7d08d25d-ea98-4eb1-ae68-b216f5fea347', '2808864e-cd7d-4492-9f89-3814f5cb5f3f', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', 'ADMIN', '2026-05-21 17:59:16.502615+00'),
	('7e6cb558-4d1c-44d0-ba3a-ecad28416a04', '8018d441-cf7a-466d-bb27-15ddedce8e40', '633906ea-b4b6-4d79-b559-ee3b11b8154c', 'CUSTOMER', '2026-05-21 17:59:41.0564+00'),
	('cf2c276b-7ecc-4113-8986-d78cee768aa7', '8018d441-cf7a-466d-bb27-15ddedce8e40', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', 'ADMIN', '2026-05-21 18:02:11.057689+00'),
	('af08d5b5-a945-4998-8af2-649e11963531', '72dd3bb5-6f9a-410d-afd2-3fe4b90e2824', '633906ea-b4b6-4d79-b559-ee3b11b8154c', 'CUSTOMER', '2026-05-21 18:02:30.885689+00'),
	('7474f733-a34a-4e7e-8f67-28ca8b7f618f', '72dd3bb5-6f9a-410d-afd2-3fe4b90e2824', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', 'ADMIN', '2026-05-21 18:02:36.37167+00'),
	('ae0ab0b7-b1bb-4fb3-86a0-491b35e53de6', 'ae6cf2e6-7e6f-424b-8d50-e572a803465b', '633906ea-b4b6-4d79-b559-ee3b11b8154c', 'CUSTOMER', '2026-05-21 18:11:57.297329+00'),
	('591a615a-56ab-441d-bb77-3bb28a78155d', 'ae6cf2e6-7e6f-424b-8d50-e572a803465b', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', 'ADMIN', '2026-05-21 18:11:59.450021+00'),
	('1a6f9057-2ae9-4d73-9266-b0e5a581da28', '2fe645d3-137f-4a91-aad7-8c21295d8667', '633906ea-b4b6-4d79-b559-ee3b11b8154c', 'CUSTOMER', '2026-05-21 18:32:12.85841+00'),
	('5aae7a12-a431-4db6-a0fa-6d81a0eb73f6', '2fe645d3-137f-4a91-aad7-8c21295d8667', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', 'ADMIN', '2026-05-21 18:32:21.75712+00'),
	('35814edc-2fa7-44e3-b22a-d5e56e4e5ef7', '83d1f78a-cfa6-46b3-aa35-3cc747a8e68c', '633906ea-b4b6-4d79-b559-ee3b11b8154c', 'CUSTOMER', '2026-05-21 18:38:53.833646+00'),
	('16e29744-f589-4bea-b7c2-906c57a71238', '83d1f78a-cfa6-46b3-aa35-3cc747a8e68c', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', 'ADMIN', '2026-05-21 18:39:19.216201+00');


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."orders" ("id", "customer_name", "customer_phone", "shipping_address", "total_amount", "status", "created_at", "user_id") VALUES
	(2, '혜린김', '01098765432', '서울시 마포구, 서우, 31212', 10146, 'pending', '2026-05-21 20:07:44.354161+00', NULL),
	(1, '혜린김', '01087762855', '서울시 마포구, 서울, 04108', 84900, 'pending', '2026-05-21 14:06:36.847195+00', NULL);


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."products" ("id", "name", "price", "stock", "description", "created_at", "is_best_seller", "is_deleted") VALUES
	(4, 'test123', 123, 11, 'test', '2026-04-27 12:04:00.551715+00', false, false),
	(7, 'test5', 1, 13, 'test', '2026-04-27 12:13:25.800506+00', false, true),
	(9, '혼다 pcx 2019년식 윈도우 스크린', 75000, 1, '회사: 혼다
기종: pcx125
년식: 2019년식
제품명: 롱 윈도우 스크린', '2026-04-30 04:18:09.391768+00', false, false),
	(8, 'test6', 1, 14, 'test', '2026-04-27 12:13:54.683608+00', false, true),
	(6, 'test4', 111, 12, 'test', '2026-04-27 12:10:51.520722+00', false, true),
	(5, 'test123', 123, 11, 'test', '2026-04-27 12:08:47.293387+00', false, true),
	(10, 'test2', 123, 10, '', '2026-05-21 19:23:20.526125+00', false, false),
	(3, 'ssqq', 123, 3, 'test', '2026-04-27 12:03:04.907841+00', false, false);


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."order_items" ("id", "order_id", "product_id", "quantity", "unit_price") VALUES
	(1, 1, 9, 1, 75000),
	(2, 2, 10, 2, 123);


--
-- Data for Name: orders_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."orders_history" ("id", "order_id", "action", "old_data", "new_data", "changed_at") OVERRIDING SYSTEM VALUE VALUES
	(1, 1, 'UPDATE', '{"id": 1, "status": "pending", "user_id": null, "created_at": "2026-05-21T14:06:36.847195+00:00", "total_amount": 84900, "customer_name": "혜린김", "customer_phone": "01087762855", "shipping_address": "서울시 마포구, 서울, 04108"}', '{"id": 1, "status": "pending", "user_id": null, "created_at": "2026-05-21T14:06:36.847195+00:00", "total_amount": 84900, "customer_name": "혜린김", "customer_phone": "01087762855", "shipping_address": "서울시 마포구, 서울, 04108"}', '2026-05-23 16:58:32.108371+00');


--
-- Data for Name: product_images; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."product_images" ("id", "product_id", "image_url", "display_order", "is_main") VALUES
	(1, 5, 'https://zlumvgindinymplyvhsh.supabase.co/storage/v1/object/public/product_images/thumbnails/1777291773734_scaled_1000000034.jpg', 0, true),
	(2, 5, 'https://zlumvgindinymplyvhsh.supabase.co/storage/v1/object/public/product_images/details/1777291774197_scaled_1000000033.jpg', 1, false),
	(3, 6, 'https://zlumvgindinymplyvhsh.supabase.co/storage/v1/object/public/product_images/thumbnails/1777291897959_scaled_1000000033.jpg', 0, true),
	(4, 7, 'https://zlumvgindinymplyvhsh.supabase.co/storage/v1/object/public/product_images/thumbnails/1777292052257_scaled_1000000034.jpg', 0, true),
	(5, 7, 'https://zlumvgindinymplyvhsh.supabase.co/storage/v1/object/public/product_images/details/1777292052763_scaled_1000000034.jpg', 1, false),
	(6, 8, 'https://zlumvgindinymplyvhsh.supabase.co/storage/v1/object/public/product_images/thumbnails/1777292081121_scaled_1000000034.jpg', 0, true),
	(7, 8, 'https://zlumvgindinymplyvhsh.supabase.co/storage/v1/object/public/product_images/details/1777292081660_scaled_1000000034.jpg', 1, false),
	(8, 9, 'https://zlumvgindinymplyvhsh.supabase.co/storage/v1/object/public/product_images/thumbnails/1777522735564_scaled_1000000036.jpg', 0, true),
	(9, 9, 'https://zlumvgindinymplyvhsh.supabase.co/storage/v1/object/public/product_images/details/1777522736441_scaled_1000000035.jpg', 1, false),
	(10, 9, 'https://zlumvgindinymplyvhsh.supabase.co/storage/v1/object/public/product_images/details/1777522737308_scaled_1000000037.jpg', 2, false),
	(12, 10, 'https://zlumvgindinymplyvhsh.supabase.co/storage/v1/object/public/product_images/thumbnails/1779397215776_scaled_1000000034.jpg', 0, true);


--
-- Data for Name: products_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."products_history" ("id", "product_id", "action", "old_data", "new_data", "changed_at") OVERRIDING SYSTEM VALUE VALUES
	(1, 3, 'UPDATE', '{"id": 3, "name": "ssqq", "price": 123, "stock": 3, "created_at": "2026-04-27T12:03:04.907841+00:00", "is_deleted": false, "description": "test", "is_best_seller": false}', '{"id": 3, "name": "ssqq", "price": 123, "stock": 3, "created_at": "2026-04-27T12:03:04.907841+00:00", "is_deleted": false, "description": "test", "is_best_seller": false}', '2026-05-23 16:57:44.307761+00');


--
-- Data for Name: users_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."users_history" ("id", "user_id", "action", "old_data", "new_data", "changed_at") OVERRIDING SYSTEM VALUE VALUES
	(1, '3c597199-32aa-4ab7-b383-dae3b8fdebf5', 'UPDATE', '{"id": "3c597199-32aa-4ab7-b383-dae3b8fdebf5", "name": "", "email": "dev.hr.kim@gmail.com", "address": null, "created_at": "2026-05-21T12:51:41.645258+00:00", "updated_at": "2026-05-21T12:51:41.645258+00:00", "phone_number": ""}', '{"id": "3c597199-32aa-4ab7-b383-dae3b8fdebf5", "name": "", "email": "dev.hr.kim@gmail.com", "address": null, "created_at": "2026-05-21T12:51:41.645258+00:00", "updated_at": "2026-05-23T16:55:18.336494+00:00", "phone_number": ""}', '2026-05-23 16:55:18.336494+00'),
	(2, 'bee9b236-875b-4b03-84c2-483aa65ed9a7', 'UPDATE', '{"id": "bee9b236-875b-4b03-84c2-483aa65ed9a7", "name": "김혜린", "email": "onpa@nate.com", "address": "서울시 마포구", "created_at": "2026-05-21T22:25:16.64171+00:00", "updated_at": "2026-05-21T22:25:16.64171+00:00", "phone_number": "01012345678"}', '{"id": "bee9b236-875b-4b03-84c2-483aa65ed9a7", "name": "김혜린", "email": "onpa@nate.com", "address": null, "created_at": "2026-05-21T22:25:16.64171+00:00", "updated_at": "2026-05-23T16:56:56.06244+00:00", "phone_number": "01012345670"}', '2026-05-23 16:56:56.06244+00');


--
-- Data for Name: wishlists; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."wishlists" ("id", "user_id", "product_id", "created_at") OVERRIDING SYSTEM VALUE VALUES
	(1, '633906ea-b4b6-4d79-b559-ee3b11b8154c', 9, '2026-05-21 14:19:12.507827+00'),
	(3, '3c597199-32aa-4ab7-b383-dae3b8fdebf5', 9, '2026-05-21 19:53:16.938322+00'),
	(4, '633906ea-b4b6-4d79-b559-ee3b11b8154c', 6, '2026-05-21 20:36:49.568415+00');


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

INSERT INTO "storage"."buckets" ("id", "name", "owner", "created_at", "updated_at", "public", "avif_autodetection", "file_size_limit", "allowed_mime_types", "owner_id", "type") VALUES
	('product_images', 'product_images', NULL, '2026-04-27 12:01:54.767618+00', '2026-04-27 12:01:54.767618+00', true, false, NULL, NULL, NULL, 'STANDARD'),
	('chat_images', 'chat_images', NULL, '2026-05-21 18:23:20.505884+00', '2026-05-21 18:23:20.505884+00', true, false, 10485760, '{image/jpeg,image/png,image/webp,image/gif}', NULL, 'STANDARD');


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
	('12940492-c186-47f9-8479-b54e3f43638d', 'product_images', 'thumbnails/1777291773734_scaled_1000000034.jpg', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', '2026-04-27 12:08:47.569046+00', '2026-04-27 12:08:47.569046+00', '2026-04-27 12:08:47.569046+00', '{"eTag": "\"5efaa998ea3a10ec3da800384f8a2a11\"", "size": 18711, "mimetype": "image/jpg", "cacheControl": "max-age=3600", "lastModified": "2026-04-27T12:08:48.000Z", "contentLength": 18711, "httpStatusCode": 200}', '22357e48-16f9-4aca-8fa0-5ad2e086058c', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', '{}'),
	('ca392f11-fc23-4e6c-9733-a4aae87d3470', 'product_images', 'details/1777291774197_scaled_1000000033.jpg', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', '2026-04-27 12:08:48.125628+00', '2026-04-27 12:08:48.125628+00', '2026-04-27 12:08:48.125628+00', '{"eTag": "\"f2b9b0221e5e6774a44360669eb98980\"", "size": 36510, "mimetype": "image/jpg", "cacheControl": "max-age=3600", "lastModified": "2026-04-27T12:08:49.000Z", "contentLength": 36510, "httpStatusCode": 200}', '314d7b49-beca-4a14-857e-e09b7376940c', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', '{}'),
	('2ef19ec1-b2b9-4d68-a24a-f1d300e206b7', 'product_images', 'thumbnails/1777291897959_scaled_1000000033.jpg', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', '2026-04-27 12:10:51.933549+00', '2026-04-27 12:10:51.933549+00', '2026-04-27 12:10:51.933549+00', '{"eTag": "\"f2b9b0221e5e6774a44360669eb98980\"", "size": 36510, "mimetype": "image/jpg", "cacheControl": "max-age=3600", "lastModified": "2026-04-27T12:10:52.000Z", "contentLength": 36510, "httpStatusCode": 200}', '7f6ea19b-5b1c-4ac8-b2c1-9ec19f20923b', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', '{}'),
	('5cffa536-d0f6-4597-9f3a-31e2908d49b4', 'product_images', 'thumbnails/1777292052257_scaled_1000000034.jpg', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', '2026-04-27 12:13:26.146764+00', '2026-04-27 12:13:26.146764+00', '2026-04-27 12:13:26.146764+00', '{"eTag": "\"5efaa998ea3a10ec3da800384f8a2a11\"", "size": 18711, "mimetype": "image/jpg", "cacheControl": "max-age=3600", "lastModified": "2026-04-27T12:13:27.000Z", "contentLength": 18711, "httpStatusCode": 200}', '626ec612-959e-4664-803f-2a7ceb8c67b7', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', '{}'),
	('913293e2-1627-425b-b1ed-ad9fb25ce7eb', 'product_images', 'details/1777292052763_scaled_1000000034.jpg', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', '2026-04-27 12:13:26.691371+00', '2026-04-27 12:13:26.691371+00', '2026-04-27 12:13:26.691371+00', '{"eTag": "\"5efaa998ea3a10ec3da800384f8a2a11\"", "size": 18711, "mimetype": "image/jpg", "cacheControl": "max-age=3600", "lastModified": "2026-04-27T12:13:27.000Z", "contentLength": 18711, "httpStatusCode": 200}', '19bb4137-fb14-4b96-935f-a2f57911d11f', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', '{}'),
	('e6fea65a-7ffe-4938-85e0-e4e44c27726e', 'product_images', 'thumbnails/1777292081121_scaled_1000000034.jpg', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', '2026-04-27 12:13:54.997505+00', '2026-04-27 12:13:54.997505+00', '2026-04-27 12:13:54.997505+00', '{"eTag": "\"5efaa998ea3a10ec3da800384f8a2a11\"", "size": 18711, "mimetype": "image/jpg", "cacheControl": "max-age=3600", "lastModified": "2026-04-27T12:13:55.000Z", "contentLength": 18711, "httpStatusCode": 200}', '90063cbd-f6b9-4202-9099-7b2b845946ae', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', '{}'),
	('d305e3ed-6537-474e-bdc3-4d3de5c0a5e3', 'product_images', 'details/1777292081660_scaled_1000000034.jpg', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', '2026-04-27 12:13:55.519655+00', '2026-04-27 12:13:55.519655+00', '2026-04-27 12:13:55.519655+00', '{"eTag": "\"5efaa998ea3a10ec3da800384f8a2a11\"", "size": 18711, "mimetype": "image/jpg", "cacheControl": "max-age=3600", "lastModified": "2026-04-27T12:13:56.000Z", "contentLength": 18711, "httpStatusCode": 200}', 'ade3adea-6da6-4f8f-bdd1-b34e1e39cc44', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', '{}'),
	('6d648bce-dd2f-4ee0-8e8c-14e176032ed3', 'product_images', 'thumbnails/1777522735564_scaled_1000000036.jpg', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', '2026-04-30 04:18:10.051495+00', '2026-04-30 04:18:10.051495+00', '2026-04-30 04:18:10.051495+00', '{"eTag": "\"705a77526efa21e5e01c431f271ac727\"", "size": 113646, "mimetype": "image/jpg", "cacheControl": "max-age=3600", "lastModified": "2026-04-30T04:18:11.000Z", "contentLength": 113646, "httpStatusCode": 200}', 'c5b586a1-87b1-4363-8dab-2173cb1dc86e', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', '{}'),
	('285076ec-b95e-442f-92e1-4247214a73ec', 'product_images', 'details/1777522736441_scaled_1000000035.jpg', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', '2026-04-30 04:18:10.921387+00', '2026-04-30 04:18:10.921387+00', '2026-04-30 04:18:10.921387+00', '{"eTag": "\"f3ade6edc6b6680e5a76d6dd87cb676f\"", "size": 140530, "mimetype": "image/jpg", "cacheControl": "max-age=3600", "lastModified": "2026-04-30T04:18:11.000Z", "contentLength": 140530, "httpStatusCode": 200}', '8ba20978-f470-48e1-b4d0-3ee101d5a532', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', '{}'),
	('01153945-e87c-4268-ab14-fd0628374035', 'product_images', 'details/1777522737308_scaled_1000000037.jpg', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', '2026-04-30 04:18:11.838894+00', '2026-04-30 04:18:11.838894+00', '2026-04-30 04:18:11.838894+00', '{"eTag": "\"2fd04eaa114369175ad8e08b6e14aabe\"", "size": 135029, "mimetype": "image/jpg", "cacheControl": "max-age=3600", "lastModified": "2026-04-30T04:18:12.000Z", "contentLength": 135029, "httpStatusCode": 200}', '5b9fa63e-8c7d-45fa-adec-7c6bdae0913a', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', '{}'),
	('4e45bfea-fbff-41be-a26b-09c359c1b08a', 'chat_images', 'ae6cf2e6-7e6f-424b-8d50-e572a803465b/633906ea-b4b6-4d79-b559-ee3b11b8154c_1779388297652.jpg', '633906ea-b4b6-4d79-b559-ee3b11b8154c', '2026-05-21 18:31:38.454118+00', '2026-05-21 18:31:38.454118+00', '2026-05-21 18:31:38.454118+00', '{"eTag": "\"1e3c38d985ef44a7e86c177789436bbc\"", "size": 301536, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-05-21T18:31:39.000Z", "contentLength": 301536, "httpStatusCode": 200}', '5f59a94e-f259-4cfe-ac22-3382e811316a', '633906ea-b4b6-4d79-b559-ee3b11b8154c', '{}'),
	('8749f1d3-1ea9-4ec0-81ff-0d17228d11b7', 'chat_images', 'ae6cf2e6-7e6f-424b-8d50-e572a803465b/3c597199-32aa-4ab7-b383-dae3b8fdebf5_1779388351244.jpg', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', '2026-05-21 18:31:49.502754+00', '2026-05-21 18:31:49.502754+00', '2026-05-21 18:31:49.502754+00', '{"eTag": "\"f2b9b0221e5e6774a44360669eb98980\"", "size": 36510, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-05-21T18:31:50.000Z", "contentLength": 36510, "httpStatusCode": 200}', 'b6336a02-6dae-4153-95b4-ca0891c416cd', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', '{}'),
	('858f915f-661f-42f9-bafc-b76fddd61ce4', 'product_images', 'thumbnails/1779391442665_scaled_1000000033.jpg', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', '2026-05-21 19:23:21.206899+00', '2026-05-21 19:23:21.206899+00', '2026-05-21 19:23:21.206899+00', '{"eTag": "\"f2b9b0221e5e6774a44360669eb98980\"", "size": 36510, "mimetype": "image/jpg", "cacheControl": "max-age=3600", "lastModified": "2026-05-21T19:23:22.000Z", "contentLength": 36510, "httpStatusCode": 200}', '7fd1c6c3-ba7e-495c-897a-ef98be8cc7d1', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', '{}'),
	('237f0e2a-4856-4170-81f3-b614aaee56d9', 'product_images', 'thumbnails/1779397215776_scaled_1000000034.jpg', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', '2026-05-21 20:59:34.23653+00', '2026-05-21 20:59:34.23653+00', '2026-05-21 20:59:34.23653+00', '{"eTag": "\"5efaa998ea3a10ec3da800384f8a2a11\"", "size": 18711, "mimetype": "image/jpg", "cacheControl": "max-age=3600", "lastModified": "2026-05-21T20:59:35.000Z", "contentLength": 18711, "httpStatusCode": 200}', '8efd1b33-473c-455b-a521-90535f06af4e', '3c597199-32aa-4ab7-b383-dae3b8fdebf5', '{}');


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

SELECT pg_catalog.setval('"auth"."refresh_tokens_id_seq"', 41, true);


--
-- Name: order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."order_items_id_seq"', 2, true);


--
-- Name: orders_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."orders_history_id_seq"', 1, true);


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."orders_id_seq"', 2, true);


--
-- Name: product_images_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."product_images_id_seq"', 12, true);


--
-- Name: products_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."products_history_id_seq"', 1, true);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."products_id_seq"', 10, true);


--
-- Name: users_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."users_history_id_seq"', 2, true);


--
-- Name: wishlists_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."wishlists_id_seq"', 4, true);


--
-- PostgreSQL database dump complete
--

-- \unrestrict zRTfghehHK8A2XB5zZg3gswkLSkIOuXmb8hJ0KFrhDMqgneopy2j4sZqe1hqyS5

RESET ALL;
