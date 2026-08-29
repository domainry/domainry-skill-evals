-- MySQL dump 10.13  Distrib 9.5.0, for macos15.7 (arm64)
--
-- Host: localhost    Database: domainry_m2_fieldservice_e235a3d6e4fb_mysql_opt12_canary01
-- ------------------------------------------------------
-- Server version	9.5.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `_audit_events`
--

DROP TABLE IF EXISTS `_audit_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `_audit_events` (
  `id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `event` varchar(191) NOT NULL,
  `object_key` varchar(191) DEFAULT NULL,
  `record_id` varchar(191) DEFAULT NULL,
  `actor_id` varchar(191) DEFAULT NULL,
  `role_key` varchar(191) DEFAULT NULL,
  `summary` text,
  `metadata_json` text NOT NULL,
  `before_json` text NOT NULL,
  `after_json` text NOT NULL,
  `created_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  UNIQUE KEY `uniq_audit_events_workspace_identity` (`workspace_id`,`id`),
  KEY `idx_audit_event_actor_cursor` (`workspace_id`,`actor_id`,`created_at`,`id`),
  KEY `idx_audit_event_record_cursor` (`workspace_id`,`object_key`,`record_id`,`created_at`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `_audit_events`
--

LOCK TABLES `_audit_events` WRITE;
/*!40000 ALTER TABLE `_audit_events` DISABLE KEYS */;
INSERT INTO `_audit_events` VALUES ('audit_1787337948512864000_1','default','internal_record_mutation','scheduler_cursor','weekday_overdue_reminders','system','system','Internal record mutation','{\"actor_id\":\"system\",\"operation\":\"create\",\"policy\":\"scheduler_runtime\",\"reason\":\"provision published scheduler definition\",\"role_key\":\"system\",\"workspace_id\":\"default\"}','null','null','2026-08-21T18:45:48Z'),('platform_seed_audit_bootstrap','default','platform_seed_initialized','platform','global_capability_seed','system','admin','Initialized global platform capability seed data.','{\"capability\":\"global_system\",\"source\":\"runtime_bootstrap\"}','null','null','2026-08-21T18:43:47Z'),('platform_seed_audit_permissions','default','platform_permissions_initialized','identity_permission','admin','system','admin','Initialized global admin permissions and menu assignments.','{\"capability\":\"identity\",\"source\":\"runtime_bootstrap\"}','null','null','2026-08-21T18:44:47Z');
/*!40000 ALTER TABLE `_audit_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `_business_seed_provenance`
--

DROP TABLE IF EXISTS `_business_seed_provenance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `_business_seed_provenance` (
  `seed_key` varchar(191) NOT NULL,
  `object_key` varchar(191) NOT NULL,
  `record_id` varchar(191) NOT NULL,
  `source_kind` varchar(191) NOT NULL,
  `source_id` varchar(191) DEFAULT NULL,
  `template_id` varchar(191) DEFAULT NULL,
  `template_version` varchar(191) DEFAULT NULL,
  `content_hash` varchar(191) NOT NULL,
  `materialized_at` varchar(191) NOT NULL,
  PRIMARY KEY (`seed_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `_business_seed_provenance`
--

LOCK TABLES `_business_seed_provenance` WRITE;
/*!40000 ALTER TABLE `_business_seed_provenance` DISABLE KEYS */;
INSERT INTO `_business_seed_provenance` VALUES ('customer_qin_profile','customer_profile','customer_profile_customer_qin_profile','template','domain_m2_field_service','domain_m2_field_service','0.1.0','e90fc4ab96dfb06ebbb81772f14378f97a06bbbba2e3842a6192e796b8bdd891','2026-08-21T18:45:47Z'),('customer_sun_profile','customer_profile','customer_profile_customer_sun_profile','template','domain_m2_field_service','domain_m2_field_service','0.1.0','fbc920b549632691ceb86e0f97d9f1ab62539cabf5c27d97b37d9b6b27383a02','2026-08-21T18:45:47Z'),('device_qin_press','device','device_device_qin_press','template','domain_m2_field_service','domain_m2_field_service','0.1.0','a619f75aaf8c9ded6b3f59a1225e8096cf3b7f0a723824da11297590883eafe2','2026-08-21T18:45:47Z'),('device_sun_lathe','device','device_device_sun_lathe','template','domain_m2_field_service','domain_m2_field_service','0.1.0','200faefaaa6141e7a029f3067a086f2887288f14c79194d0f72a5bdbd9db1ba1','2026-08-21T18:45:47Z'),('export_audit_seed','report_export_audit','report_export_audit_export_audit_seed','template','domain_m2_field_service','domain_m2_field_service','0.1.0','494f31fedec73c48a16b069003306f7d082a4e2f01440d258e92723c5cd3848b','2026-08-21T18:45:47Z'),('export_download_seed','report_export_download','report_export_download_export_download_seed','template','domain_m2_field_service','domain_m2_field_service','0.1.0','7ed5d2fc228c86f18de4a58a2a781972177a64a689be9a6a75313f22d0e058ba','2026-08-21T18:45:47Z'),('ledger_qin_charge','fee_ledger','fee_ledger_ledger_qin_charge','template','domain_m2_field_service','domain_m2_field_service','0.1.0','2ef84f2bfc855b079d158b70ad0ace4e559b0d1e2ee8fc31aa503712991bf2c3','2026-08-21T18:45:47Z'),('ledger_qin_waiver','fee_ledger','fee_ledger_ledger_qin_waiver','template','domain_m2_field_service','domain_m2_field_service','0.1.0','9c46f58c60d40e133075b05b96ce8220e5e381cfe6796dd78cb5976151b37f7b','2026-08-21T18:45:47Z'),('part_bearing','spare_part','spare_part_part_bearing','template','domain_m2_field_service','domain_m2_field_service','0.1.0','3efdd09c306b1c0c356611f04aef879e021d19ba248706c33c908327f648a6a0','2026-08-21T18:45:47Z'),('part_controller','spare_part','spare_part_part_controller','template','domain_m2_field_service','domain_m2_field_service','0.1.0','d8e59c783f52622a822e88fbd7d1ad6b3a4a3e3f26c5a8c752880f963347b575','2026-08-21T18:45:47Z'),('part_filter','spare_part','spare_part_part_filter','template','domain_m2_field_service','domain_m2_field_service','0.1.0','c5f3e7d60d781fa9d4797b52e5b9905ba61cfaf6364633eb6d9bef95947ec95f','2026-08-21T18:45:47Z'),('reminder_qin_overdue','overdue_reminder','overdue_reminder_reminder_qin_overdue','template','domain_m2_field_service','domain_m2_field_service','0.1.0','8755cc7de36461639f627764e78b8ebaa2e16f947afb73bd7cc8c44c71ff3248','2026-08-21T18:45:47Z'),('request_qin_completed_direct','service_request','service_request_request_qin_completed_direct','template','domain_m2_field_service','domain_m2_field_service','0.1.0','f4bf5478076a98ef0048064f1377eb65d286270244679822e5e02e1303c8a91c','2026-08-21T18:45:47Z'),('request_qin_completed_no_waiver','service_request','service_request_request_qin_completed_no_waiver','template','domain_m2_field_service','domain_m2_field_service','0.1.0','4a5fd679513be6dbc17f9162ca632b126c0019c8d99f9e7b484c1552a1f8aeee','2026-08-21T18:45:47Z'),('request_qin_dispatched','service_request','service_request_request_qin_dispatched','template','domain_m2_field_service','domain_m2_field_service','0.1.0','3730b46a8921335362592ddc5f37e1d8c32256a6f982beafc2d53ac4c59f0780','2026-08-21T18:45:47Z'),('request_qin_dispatched_fresh','service_request','service_request_request_qin_dispatched_fresh','template','domain_m2_field_service','domain_m2_field_service','0.1.0','625cb250c921b44d17573c5d48c415c01c8c51df3d7f918431296791c180e6a7','2026-08-21T18:45:47Z'),('request_qin_submitted','service_request','service_request_request_qin_submitted','template','domain_m2_field_service','domain_m2_field_service','0.1.0','f229710b833605793a9274ff42375d2467e50b37e811278a0b5379436663949d','2026-08-21T18:45:47Z'),('request_sun_completed_pending','service_request','service_request_request_sun_completed_pending','template','domain_m2_field_service','domain_m2_field_service','0.1.0','801991713f384f7b9d2028a2741bba90297d247716bd8bceed4a72d96141380f','2026-08-21T18:45:47Z'),('request_sun_in_repair','service_request','service_request_request_sun_in_repair','template','domain_m2_field_service','domain_m2_field_service','0.1.0','7b6cdbca04ccff6bf58d7e551aa600c647acbb4f58b678ee3590e4bc885ee266','2026-08-21T18:45:47Z'),('usage_qin_filter','part_usage','part_usage_usage_qin_filter','template','domain_m2_field_service','domain_m2_field_service','0.1.0','dfeb34ae845e0d77ae51f5ea0311c14183f033669caee6c35f62413c53e4f67e','2026-08-21T18:45:47Z'),('waiver_qin_direct','warranty_waiver','warranty_waiver_waiver_qin_direct','template','domain_m2_field_service','domain_m2_field_service','0.1.0','b4a62766f3aa376826ac1ca9f822e2c56857122df21f7fc73d3dd057ed198fe3','2026-08-21T18:45:47Z'),('waiver_sun_pending','warranty_waiver','warranty_waiver_waiver_sun_pending','template','domain_m2_field_service','domain_m2_field_service','0.1.0','4d680a54e74c2bfe6d39b1edf3d3f57500a4d7237678cadd88508832fab4db73','2026-08-21T18:45:47Z');
/*!40000 ALTER TABLE `_business_seed_provenance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `_runtime_schema_migrations`
--

DROP TABLE IF EXISTS `_runtime_schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `_runtime_schema_migrations` (
  `version` varchar(191) NOT NULL,
  `name` varchar(191) NOT NULL DEFAULT '',
  `kind` varchar(191) NOT NULL DEFAULT 'runtime_schema_data',
  `checksum` varchar(191) NOT NULL DEFAULT '',
  `dirty` tinyint(1) NOT NULL DEFAULT '0',
  `applied_at` varchar(191) NOT NULL,
  `runtime_version` varchar(191) NOT NULL DEFAULT '',
  `duration_ms` bigint NOT NULL DEFAULT '0',
  `operator` varchar(191) NOT NULL DEFAULT '',
  `instance_id` varchar(191) NOT NULL DEFAULT '',
  `backup_id` varchar(191) NOT NULL DEFAULT '',
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `_runtime_schema_migrations`
--

LOCK TABLES `_runtime_schema_migrations` WRITE;
/*!40000 ALTER TABLE `_runtime_schema_migrations` DISABLE KEYS */;
INSERT INTO `_runtime_schema_migrations` VALUES ('008_identity_account_directory','runtime_release_cohort','runtime_schema_data','c6a3378790a17e3f233013184e36a19771605c8e287ab1d43748246df0da3214',0,'2026-08-21T18:45:46Z','v0.0.0-source-318b0a23fff4fee2',1120,'runtime','Maclan.local:59334','bootstrap-empty');
/*!40000 ALTER TABLE `_runtime_schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `_schema_migrations`
--

DROP TABLE IF EXISTS `_schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `_schema_migrations` (
  `path` varchar(255) NOT NULL,
  `version` varchar(255) NOT NULL DEFAULT '',
  `name` varchar(255) NOT NULL DEFAULT '',
  `kind` varchar(255) NOT NULL DEFAULT 'schema',
  `checksum` varchar(255) NOT NULL DEFAULT '',
  `dirty` tinyint(1) NOT NULL DEFAULT '0',
  `applied_at` varchar(64) NOT NULL,
  `runtime_version` varchar(255) NOT NULL DEFAULT '',
  `duration_ms` bigint NOT NULL DEFAULT '0',
  `operator` varchar(255) NOT NULL DEFAULT '',
  `instance_id` varchar(255) NOT NULL DEFAULT '',
  `backup_id` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`path`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `_schema_migrations`
--

LOCK TABLES `_schema_migrations` WRITE;
/*!40000 ALTER TABLE `_schema_migrations` DISABLE KEYS */;
/*!40000 ALTER TABLE `_schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `_workflow_executions`
--

DROP TABLE IF EXISTS `_workflow_executions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `_workflow_executions` (
  `workspace_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `id` varchar(191) NOT NULL,
  `workflow_key` varchar(191) NOT NULL,
  `name` text NOT NULL,
  `trigger` varchar(191) NOT NULL,
  `status` varchar(191) NOT NULL,
  `action_type` varchar(191) DEFAULT NULL,
  `action_json` text NOT NULL,
  `payload_json` text NOT NULL,
  `result_json` text NOT NULL,
  `process_id` varchar(191) DEFAULT NULL,
  `node_id` varchar(191) DEFAULT NULL,
  `object_key` varchar(191) DEFAULT NULL,
  `record_id` varchar(191) DEFAULT NULL,
  `actor_id` varchar(191) DEFAULT NULL,
  `run_as` varchar(191) DEFAULT NULL,
  `idempotency_key` varchar(191) DEFAULT NULL,
  `attempt` int NOT NULL DEFAULT '0',
  `max_attempts` int NOT NULL DEFAULT '0',
  `next_run_at` varchar(191) DEFAULT NULL,
  `last_error` text,
  `lease_owner` varchar(191) NOT NULL DEFAULT '',
  `lease_expires_at` varchar(191) NOT NULL DEFAULT '',
  `fencing_token` bigint NOT NULL DEFAULT '0',
  `message` text,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_workflow_execution_workspace_id` (`workspace_id`,`id`),
  KEY `idx_workflow_execution_process` (`workspace_id`,`process_id`,`node_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `_workflow_executions`
--

LOCK TABLES `_workflow_executions` WRITE;
/*!40000 ALTER TABLE `_workflow_executions` DISABLE KEYS */;
INSERT INTO `_workflow_executions` VALUES ('default','platform_seed_workflow_execution_completed','platform.metadata_health_check','Metadata health check','manual','completed','emit_audit','{\"event\":\"platform_metadata_health_checked\",\"type\":\"emit_audit\"}','{\"source\":\"runtime_bootstrap\"}','{\"checked\":true,\"warnings\":0}','','','','','system','admin','platform-seed-metadata-health-check',1,3,NULL,'','','',0,'Seeded metadata health check completed.','2026-08-21T18:45:02Z','2026-08-21T18:45:02Z'),('default','platform_seed_workflow_execution_warning','platform.audit_retention_check','Audit retention check','manual','failed','emit_audit','{\"event\":\"platform_audit_retention_checked\",\"type\":\"emit_audit\"}','{\"source\":\"runtime_bootstrap\"}','{\"checked\":true,\"needs_review\":true}','','','','','system','admin','platform-seed-audit-retention-check',1,3,NULL,'Seeded example failure for retry visibility.','','',0,'Seeded audit retention check needs review.','2026-08-21T18:45:17Z','2026-08-21T18:45:17Z');
/*!40000 ALTER TABLE `_workflow_executions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `action_assurance_grants`
--

DROP TABLE IF EXISTS `action_assurance_grants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `action_assurance_grants` (
  `id` varchar(191) NOT NULL,
  `token_hash` varchar(191) NOT NULL,
  `workspace_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `user_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `action_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `object_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `record_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '',
  `payload_digest` varchar(191) NOT NULL,
  `methods_json` text NOT NULL,
  `approval_version` varchar(191) NOT NULL DEFAULT '',
  `approval_hash` varchar(191) NOT NULL DEFAULT '',
  `issued_at` varchar(191) NOT NULL,
  `expires_at` varchar(191) NOT NULL,
  `consumed_at` varchar(191) NOT NULL DEFAULT '',
  UNIQUE KEY `uniq_action_assurance_grants_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_action_assurance_token_hash` (`token_hash`),
  KEY `idx_action_assurance_binding` (`workspace_id`,`user_id`,`action_key`,`object_key`,`record_id`),
  KEY `idx_action_assurance_expiry` (`expires_at`,`consumed_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `action_assurance_grants`
--

LOCK TABLES `action_assurance_grants` WRITE;
/*!40000 ALTER TABLE `action_assurance_grants` DISABLE KEYS */;
/*!40000 ALTER TABLE `action_assurance_grants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `action_definitions`
--

DROP TABLE IF EXISTS `action_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `action_definitions` (
  `id` varchar(191) NOT NULL,
  `resource_key` varchar(191) NOT NULL,
  `object_key` varchar(191) NOT NULL,
  `name` text NOT NULL,
  `payload_json` longtext NOT NULL,
  `schema_version` varchar(191) NOT NULL,
  `schema_hash` varchar(191) NOT NULL,
  `source_kind` varchar(191) NOT NULL,
  `source_id` varchar(191) NOT NULL,
  `disabled_at` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `resource_key` (`resource_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `action_definitions`
--

LOCK TABLES `action_definitions` WRITE;
/*!40000 ALTER TABLE `action_definitions` DISABLE KEYS */;
INSERT INTO `action_definitions` VALUES ('action:report_export_audit.request_work_order_export','report_export_audit.request_work_order_export','report_export_audit','Request work-order export','{\"key\":\"report_export_audit.request_work_order_export\",\"object_key\":\"report_export_audit\",\"label\":\"Request work-order export\",\"kind\":\"object_create\",\"requires_permission\":\"report_export_audit.create\",\"preconditions\":[],\"audit_event\":\"report_export.requested\",\"payload_fields\":[{\"key\":\"purpose\",\"name\":\"Purpose\",\"type\":\"long_text\",\"required\":true},{\"key\":\"report_key\",\"name\":\"Report key\",\"type\":\"text\",\"required\":true},{\"key\":\"requested_at\",\"name\":\"Requested at\",\"type\":\"datetime\",\"required\":true},{\"key\":\"status\",\"name\":\"Status\",\"type\":\"select\",\"options\":[\"requested\"],\"required\":true}],\"idempotency_keys\":[\"report_key\",\"requested_at\"]}','0.1.0','9e186d588348e617ee22c9d3eb5a718343819e613ff6d652901d66aa6cb76141','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('action:service_request.complete_repair','service_request.complete_repair','service_request','Complete repair','{\"key\":\"service_request.complete_repair\",\"object_key\":\"service_request\",\"label\":\"Complete repair\",\"kind\":\"record_operation\",\"requires_permission\":\"service_request.complete_repair\",\"preconditions\":[],\"audit_event\":\"service_request.completed\",\"input_type\":\"example.com/m2-fieldservice/generated/capabilities.CompleteRepairInput\",\"output_type\":\"example.com/m2-fieldservice/generated/capabilities.CompleteRepairOutput\",\"input_contract_sha256\":\"f65d274f74496892258e1008f6dcc347915ed6cb5ef3968199023f058ca4640e\",\"output_contract_sha256\":\"a80255047c1d82383db63a1b81e0d31b9cf28fdf0d65e28ad74afb58f06104cb\",\"payload_fields\":[{\"key\":\"completed_at\",\"name\":\"Completed at\",\"type\":\"datetime\",\"required\":true},{\"key\":\"quote_amount\",\"name\":\"Quoted fee\",\"type\":\"currency\",\"required\":true,\"source_object_key\":\"service_request\",\"source_field_key\":\"quote_amount\"},{\"key\":\"request_id\",\"name\":\"Request ID\",\"type\":\"text\",\"required\":true},{\"key\":\"usage_lines_json\",\"name\":\"Usage lines JSON\",\"type\":\"long_text\",\"required\":true}],\"output_fields\":[{\"key\":\"service_request_id\",\"type\":\"object_id\",\"required\":true},{\"key\":\"usage_count\",\"type\":\"integer\",\"required\":true},{\"key\":\"fee_ledger_id\",\"type\":\"object_id\",\"required\":true}],\"idempotency_keys\":[\"request_id\"]}','0.1.0','19e53b8e97aefbce708f2ea0c1935397941b187d7c14cbaf3f0873955b450165','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('action:service_request.dispatch_service_request','service_request.dispatch_service_request','service_request','Dispatch service request','{\"key\":\"service_request.dispatch_service_request\",\"object_key\":\"service_request\",\"label\":\"Dispatch service request\",\"kind\":\"record_operation\",\"requires_permission\":\"service_request.dispatch_service_request\",\"preconditions\":[],\"audit_event\":\"service_request.dispatched\",\"input_type\":\"example.com/m2-fieldservice/generated/capabilities.DispatchServiceRequestInput\",\"output_type\":\"example.com/m2-fieldservice/generated/capabilities.DispatchServiceRequestOutput\",\"input_contract_sha256\":\"002f51a6a133f4604caef3ae206a629fe88c48a5199b8accd976d2f1d77716fa\",\"output_contract_sha256\":\"716793298e843434a2b287bc8dfe05043293500f90f2858cda3d235f3e55880b\",\"payload_fields\":[{\"key\":\"assigned_user_id\",\"name\":\"Assigned technician\",\"type\":\"user\",\"required\":true},{\"key\":\"dispatched_at\",\"name\":\"Dispatched at\",\"type\":\"datetime\",\"required\":true},{\"key\":\"organization_unit_id\",\"name\":\"Station ID\",\"type\":\"text\",\"required\":true},{\"key\":\"request_id\",\"name\":\"Request ID\",\"type\":\"text\",\"required\":true}],\"output_fields\":[{\"key\":\"service_request_id\",\"type\":\"object_id\",\"required\":true},{\"key\":\"status\",\"type\":\"value_domain\",\"required\":true}],\"idempotency_keys\":[\"request_id\"]}','0.1.0','6834b060272c9fb97839800539609dd2a89ff55ca7e895bda6f00d4bb19e8355','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('action:service_request.request_warranty_waiver','service_request.request_warranty_waiver','service_request','Request warranty waiver','{\"key\":\"service_request.request_warranty_waiver\",\"object_key\":\"service_request\",\"label\":\"Request warranty waiver\",\"kind\":\"record_operation\",\"requires_permission\":\"service_request.request_warranty_waiver\",\"preconditions\":[],\"audit_event\":\"warranty_waiver.requested\",\"input_type\":\"example.com/m2-fieldservice/generated/capabilities.RequestWarrantyWaiverInput\",\"output_type\":\"example.com/m2-fieldservice/generated/capabilities.RequestWarrantyWaiverOutput\",\"input_contract_sha256\":\"ca1ef7f04eb05d14ffe5c939cdddc640ee791819e06c22c4978deba5e6ed09e5\",\"output_contract_sha256\":\"6e4ae117866e0e94ab75ad51db849dbf91ce72ca981258aae11bd5fb1b00137e\",\"payload_fields\":[{\"key\":\"request_id\",\"name\":\"Request ID\",\"type\":\"text\",\"required\":true},{\"key\":\"requested_amount\",\"name\":\"Requested waiver\",\"type\":\"currency\",\"required\":true,\"source_object_key\":\"warranty_waiver\",\"source_field_key\":\"requested_amount\"},{\"key\":\"requested_at\",\"name\":\"Requested at\",\"type\":\"datetime\",\"required\":true},{\"key\":\"warranty_asserted\",\"name\":\"Warranty eligibility asserted\",\"type\":\"boolean\",\"required\":true}],\"output_fields\":[{\"key\":\"warranty_waiver_id\",\"type\":\"object_id\",\"required\":true},{\"key\":\"status\",\"type\":\"value_domain\",\"required\":true}],\"idempotency_keys\":[\"request_id\"]}','0.1.0','30e41857ed6c82030f7d2421821d339b934cb6871b04caa68377526b48c3c654','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('action:service_request.send_overdue_reminder','service_request.send_overdue_reminder','service_request','Send overdue reminder','{\"key\":\"service_request.send_overdue_reminder\",\"object_key\":\"service_request\",\"label\":\"Send overdue reminder\",\"kind\":\"record_operation\",\"requires_permission\":\"service_request.send_overdue_reminder\",\"preconditions\":[],\"audit_event\":\"service_request.overdue_reminder_sent\",\"input_type\":\"example.com/m2-fieldservice/generated/capabilities.SendOverdueReminderInput\",\"output_type\":\"example.com/m2-fieldservice/generated/capabilities.SendOverdueReminderOutput\",\"input_contract_sha256\":\"19ded76f4f0a61b35947544b48af3eed3f0d53bd28e9797d6875db23ba2308fc\",\"output_contract_sha256\":\"d80d06c14240ffab8e40605df4476213f81ffca8c9807104257b6f4c3ebb5032\",\"payload_fields\":[{\"key\":\"scheduled_at\",\"name\":\"Scheduled at\",\"type\":\"datetime\",\"required\":true}],\"output_fields\":[{\"key\":\"created\",\"type\":\"boolean\",\"required\":true},{\"key\":\"overdue_reminder_id\",\"type\":\"object_id\"}],\"idempotency_keys\":[\"scheduled_at\"]}','0.1.0','eb498e98656e6fee9c9ac9aeb030ea7ebb33e0778b68f631db8a20c4e504beb2','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('action:service_request.start_assigned_repair','service_request.start_assigned_repair','service_request','Start assigned repair','{\"key\":\"service_request.start_assigned_repair\",\"object_key\":\"service_request\",\"label\":\"Start assigned repair\",\"kind\":\"record_operation\",\"requires_permission\":\"service_request.start_assigned_repair\",\"preconditions\":[],\"audit_event\":\"service_request.repair_started\",\"input_type\":\"example.com/m2-fieldservice/generated/capabilities.StartAssignedRepairInput\",\"output_type\":\"example.com/m2-fieldservice/generated/capabilities.StartAssignedRepairOutput\",\"input_contract_sha256\":\"c457c8219a487fa92f83d7e20fa7f62604372d2b682577a3bfbd9c5d10c8378d\",\"output_contract_sha256\":\"0140168d9454cdf60a710c2aca48d85eb5776faa8f1b26e23a1a7547d843b4ec\",\"payload_fields\":[{\"key\":\"request_id\",\"name\":\"Request ID\",\"type\":\"text\",\"required\":true},{\"key\":\"started_at\",\"name\":\"Started at\",\"type\":\"datetime\",\"required\":true}],\"output_fields\":[{\"key\":\"service_request_id\",\"type\":\"object_id\",\"required\":true},{\"key\":\"status\",\"type\":\"value_domain\",\"required\":true}],\"idempotency_keys\":[\"request_id\"]}','0.1.0','286769698f63a26f656479af0933831feba615c15c78ad1792da004945f352d0','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('action:service_request.submit_service_request','service_request.submit_service_request','service_request','Submit service request','{\"key\":\"service_request.submit_service_request\",\"object_key\":\"service_request\",\"label\":\"Submit service request\",\"kind\":\"object_operation\",\"requires_permission\":\"service_request.submit_service_request\",\"preconditions\":[],\"audit_event\":\"service_request.submitted\",\"input_type\":\"example.com/m2-fieldservice/generated/capabilities.SubmitServiceRequestInput\",\"output_type\":\"example.com/m2-fieldservice/generated/capabilities.SubmitServiceRequestOutput\",\"input_contract_sha256\":\"ac80cff74c4c63086d60f972eb25276b71c9efef27d8e5576bb5e4a888cf82c6\",\"output_contract_sha256\":\"82c2c286fa64ff6039cb40e7d97d43d2f1f5de972eba6b0ae79a356280bb0fc4\",\"payload_fields\":[{\"key\":\"device_id\",\"name\":\"Device\",\"type\":\"relation\",\"required\":true,\"target_object_key\":\"device\"},{\"key\":\"fault_description\",\"name\":\"Fault description\",\"type\":\"long_text\",\"required\":true},{\"key\":\"preferred_visit_at\",\"name\":\"Preferred visit time\",\"type\":\"datetime\",\"required\":true},{\"key\":\"request_id\",\"name\":\"Request ID\",\"type\":\"text\",\"required\":true},{\"key\":\"submitted_at\",\"name\":\"Submitted at\",\"type\":\"datetime\",\"required\":true}],\"output_fields\":[{\"key\":\"service_request_id\",\"type\":\"object_id\",\"required\":true},{\"key\":\"status\",\"type\":\"value_domain\",\"required\":true}],\"idempotency_keys\":[\"request_id\"]}','0.1.0','03131c9104cb0f7c5b1fd6b090a4e7e0fa7fe45c5c617badade5cf08589d3a09','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('action:service_request.unassign_service_request','service_request.unassign_service_request','service_request','Unassign service request','{\"key\":\"service_request.unassign_service_request\",\"object_key\":\"service_request\",\"label\":\"Unassign service request\",\"kind\":\"record_operation\",\"requires_permission\":\"service_request.unassign_service_request\",\"preconditions\":[],\"audit_event\":\"service_request.unassigned\",\"input_type\":\"example.com/m2-fieldservice/generated/capabilities.UnassignServiceRequestInput\",\"output_type\":\"example.com/m2-fieldservice/generated/capabilities.UnassignServiceRequestOutput\",\"input_contract_sha256\":\"ca25d84356bae2994ad1ef2e826d1cf3f9b460c6c2b8c6b7ad63e6ccae67a70e\",\"output_contract_sha256\":\"bfe26b4fcdf61461a59c8305bf5c727916dc38f81ff4b3dbc0c3fc0e4d2e6907\",\"payload_fields\":[{\"key\":\"request_id\",\"name\":\"Request ID\",\"type\":\"text\",\"required\":true}],\"output_fields\":[{\"key\":\"service_request_id\",\"type\":\"object_id\",\"required\":true},{\"key\":\"status\",\"type\":\"value_domain\",\"required\":true}],\"idempotency_keys\":[\"request_id\"]}','0.1.0','8acf2f896e3ac269d4a069d049b31394ef42c0265796e53617ecc0233c1dd8a0','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('action:warranty_waiver.decide_warranty_waiver','warranty_waiver.decide_warranty_waiver','warranty_waiver','Decide warranty waiver','{\"key\":\"warranty_waiver.decide_warranty_waiver\",\"object_key\":\"warranty_waiver\",\"label\":\"Decide warranty waiver\",\"kind\":\"record_operation\",\"requires_permission\":\"warranty_waiver.decide_warranty_waiver\",\"preconditions\":[],\"audit_event\":\"warranty_waiver.decided\",\"input_type\":\"example.com/m2-fieldservice/generated/capabilities.DecideWarrantyWaiverInput\",\"output_type\":\"example.com/m2-fieldservice/generated/capabilities.DecideWarrantyWaiverOutput\",\"input_contract_sha256\":\"d47de7fb02b4bb4be529c3fdc2579692946f44360698fbb29b18dd53467b4a16\",\"output_contract_sha256\":\"cdf72e574945b2ef7be5e086c84d748948fc15d279fb1477df330ad6fea97edf\",\"payload_fields\":[{\"key\":\"decided_at\",\"name\":\"Decided at\",\"type\":\"datetime\",\"required\":true},{\"key\":\"decision\",\"name\":\"Decision\",\"type\":\"select\",\"options\":[\"approved\",\"rejected\"],\"required\":true},{\"key\":\"rejection_reason\",\"name\":\"Rejection reason\",\"type\":\"long_text\"}],\"output_fields\":[{\"key\":\"warranty_waiver_id\",\"type\":\"object_id\",\"required\":true},{\"key\":\"status\",\"type\":\"value_domain\",\"required\":true}],\"idempotency_keys\":[\"decision\"]}','0.1.0','297a63d306fbdf7fc67515ad785b8d8d83fa3115be4ff8d001827d728e52ec0f','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z');
/*!40000 ALTER TABLE `action_definitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `agent_definitions`
--

DROP TABLE IF EXISTS `agent_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `agent_definitions` (
  `id` varchar(191) NOT NULL,
  `resource_key` varchar(191) NOT NULL,
  `object_key` varchar(191) NOT NULL,
  `name` text NOT NULL,
  `payload_json` longtext NOT NULL,
  `schema_version` varchar(191) NOT NULL,
  `schema_hash` varchar(191) NOT NULL,
  `source_kind` varchar(191) NOT NULL,
  `source_id` varchar(191) NOT NULL,
  `disabled_at` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `resource_key` (`resource_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agent_definitions`
--

LOCK TABLES `agent_definitions` WRITE;
/*!40000 ALTER TABLE `agent_definitions` DISABLE KEYS */;
/*!40000 ALTER TABLE `agent_definitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `agent_entrypoint_definitions`
--

DROP TABLE IF EXISTS `agent_entrypoint_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `agent_entrypoint_definitions` (
  `id` varchar(191) NOT NULL,
  `resource_key` varchar(191) NOT NULL,
  `object_key` varchar(191) NOT NULL,
  `name` text NOT NULL,
  `payload_json` longtext NOT NULL,
  `schema_version` varchar(191) NOT NULL,
  `schema_hash` varchar(191) NOT NULL,
  `source_kind` varchar(191) NOT NULL,
  `source_id` varchar(191) NOT NULL,
  `disabled_at` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `resource_key` (`resource_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agent_entrypoint_definitions`
--

LOCK TABLES `agent_entrypoint_definitions` WRITE;
/*!40000 ALTER TABLE `agent_entrypoint_definitions` DISABLE KEYS */;
/*!40000 ALTER TABLE `agent_entrypoint_definitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `agent_runtime_state`
--

DROP TABLE IF EXISTS `agent_runtime_state`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `agent_runtime_state` (
  `kind` varchar(255) NOT NULL,
  `state_key` varchar(255) NOT NULL,
  `workspace_id` varchar(255) NOT NULL,
  `user_id` varchar(255) NOT NULL,
  `role_key` varchar(255) NOT NULL,
  `payload_json` text NOT NULL,
  `updated_at` bigint NOT NULL,
  PRIMARY KEY (`workspace_id`,`kind`,`state_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agent_runtime_state`
--

LOCK TABLES `agent_runtime_state` WRITE;
/*!40000 ALTER TABLE `agent_runtime_state` DISABLE KEYS */;
/*!40000 ALTER TABLE `agent_runtime_state` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `agent_service_principal_definitions`
--

DROP TABLE IF EXISTS `agent_service_principal_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `agent_service_principal_definitions` (
  `id` varchar(191) NOT NULL,
  `resource_key` varchar(191) NOT NULL,
  `object_key` varchar(191) NOT NULL,
  `name` text NOT NULL,
  `payload_json` longtext NOT NULL,
  `schema_version` varchar(191) NOT NULL,
  `schema_hash` varchar(191) NOT NULL,
  `source_kind` varchar(191) NOT NULL,
  `source_id` varchar(191) NOT NULL,
  `disabled_at` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `resource_key` (`resource_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agent_service_principal_definitions`
--

LOCK TABLES `agent_service_principal_definitions` WRITE;
/*!40000 ALTER TABLE `agent_service_principal_definitions` DISABLE KEYS */;
/*!40000 ALTER TABLE `agent_service_principal_definitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `agent_task_definitions`
--

DROP TABLE IF EXISTS `agent_task_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `agent_task_definitions` (
  `id` varchar(191) NOT NULL,
  `resource_key` varchar(191) NOT NULL,
  `object_key` varchar(191) NOT NULL,
  `name` text NOT NULL,
  `payload_json` longtext NOT NULL,
  `schema_version` varchar(191) NOT NULL,
  `schema_hash` varchar(191) NOT NULL,
  `source_kind` varchar(191) NOT NULL,
  `source_id` varchar(191) NOT NULL,
  `disabled_at` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `resource_key` (`resource_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agent_task_definitions`
--

LOCK TABLES `agent_task_definitions` WRITE;
/*!40000 ALTER TABLE `agent_task_definitions` DISABLE KEYS */;
/*!40000 ALTER TABLE `agent_task_definitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `agent_task_runs`
--

DROP TABLE IF EXISTS `agent_task_runs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `agent_task_runs` (
  `workspace_id` varchar(255) NOT NULL,
  `run_id` varchar(255) NOT NULL,
  `idempotency_key` varchar(255) NOT NULL,
  `task_key` varchar(255) NOT NULL,
  `process_id` varchar(255) NOT NULL,
  `status` varchar(255) NOT NULL,
  `lease_owner` varchar(255) NOT NULL,
  `fencing_token` bigint NOT NULL,
  `lease_expires_at` bigint NOT NULL,
  `next_attempt_at` bigint NOT NULL,
  `payload_json` text NOT NULL,
  `created_at` bigint NOT NULL,
  `updated_at` bigint NOT NULL,
  PRIMARY KEY (`workspace_id`,`run_id`),
  UNIQUE KEY `workspace_id` (`workspace_id`,`idempotency_key`),
  KEY `idx_agent_task_claim` (`workspace_id`,`status`,`next_attempt_at`,`lease_expires_at`,`created_at`),
  KEY `idx_agent_task_process` (`workspace_id`,`process_id`,`status`),
  KEY `idx_agent_task_key` (`workspace_id`,`task_key`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agent_task_runs`
--

LOCK TABLES `agent_task_runs` WRITE;
/*!40000 ALTER TABLE `agent_task_runs` DISABLE KEYS */;
/*!40000 ALTER TABLE `agent_task_runs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_mutation_receipts`
--

DROP TABLE IF EXISTS `auth_mutation_receipts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_mutation_receipts` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `use_case` varchar(191) NOT NULL,
  `target_id` varchar(191) NOT NULL,
  `idempotency_key` varchar(191) NOT NULL,
  `request_fingerprint` varchar(191) NOT NULL,
  `status` varchar(191) NOT NULL,
  `result_json` text NOT NULL,
  `lease_owner` varchar(191) NOT NULL,
  `lease_expires_at` varchar(191) NOT NULL,
  `fencing_token` bigint NOT NULL,
  `error_code` varchar(191) NOT NULL,
  `expires_at` varchar(191) NOT NULL,
  `actor_id` varchar(191) NOT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_auth_mutation_receipts_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_auth_mutation_receipt_scope` (`workspace_id`,`use_case`,`target_id`,`idempotency_key`),
  KEY `idx_auth_mutation_receipt_lease` (`status`,`lease_expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_mutation_receipts`
--

LOCK TABLES `auth_mutation_receipts` WRITE;
/*!40000 ALTER TABLE `auth_mutation_receipts` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_mutation_receipts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_provider_credentials`
--

DROP TABLE IF EXISTS `auth_provider_credentials`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_provider_credentials` (
  `id` varchar(255) NOT NULL,
  `provider_key` varchar(255) NOT NULL,
  `connection_key` varchar(255) NOT NULL DEFAULT '',
  `workspace_id` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL,
  `client_id` text,
  `client_secret` text,
  `redirect_url` text,
  `otp_provider` varchar(255) DEFAULT NULL,
  `access_token` text,
  `phone_number_id` varchar(255) DEFAULT NULL,
  `auto_create_users` tinyint(1) NOT NULL DEFAULT '1',
  `default_role_key` varchar(255) DEFAULT NULL,
  `role_mappings_json` text,
  `updated_by` varchar(255) NOT NULL,
  `created_at` varchar(255) NOT NULL,
  `updated_at` varchar(255) NOT NULL,
  UNIQUE KEY `uniq_auth_provider_credentials_workspace_identity` (`workspace_id`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_provider_credentials`
--

LOCK TABLES `auth_provider_credentials` WRITE;
/*!40000 ALTER TABLE `auth_provider_credentials` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_provider_credentials` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_refresh_tokens`
--

DROP TABLE IF EXISTS `auth_refresh_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_refresh_tokens` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `user_id` varchar(191) NOT NULL,
  `session_id` varchar(191) NOT NULL,
  `token_hash` text NOT NULL,
  `expires_at` varchar(191) NOT NULL,
  `revoked_at` varchar(191) DEFAULT NULL,
  `replaced_by_id` varchar(191) DEFAULT NULL,
  `last_used_at` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_auth_refresh_tokens_workspace_identity` (`workspace_id`,`id`),
  KEY `idx_auth_refresh_tokens_user` (`workspace_id`,`user_id`),
  KEY `idx_auth_refresh_tokens_replaced_by` (`workspace_id`,`replaced_by_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_refresh_tokens`
--

LOCK TABLES `auth_refresh_tokens` WRITE;
/*!40000 ALTER TABLE `auth_refresh_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_refresh_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `automation_instruction_executions`
--

DROP TABLE IF EXISTS `automation_instruction_executions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `automation_instruction_executions` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `idempotency_key` varchar(191) NOT NULL,
  `rule_key` varchar(191) NOT NULL,
  `object_key` varchar(191) NOT NULL,
  `record_id` varchar(191) NOT NULL,
  `record_version` varchar(191) NOT NULL,
  `operation` varchar(191) NOT NULL,
  `instruction_key` varchar(191) NOT NULL,
  `status` varchar(191) NOT NULL,
  `result_json` text NOT NULL,
  `error_code` varchar(191) DEFAULT NULL,
  `lease_owner` varchar(191) NOT NULL DEFAULT '',
  `lease_expires_at` varchar(191) DEFAULT NULL,
  `fencing_token` bigint NOT NULL DEFAULT '1',
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_automation_instruction_executions_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `idx_automation_instruction_idempotency` (`workspace_id`,`idempotency_key`),
  KEY `idx_automation_instruction_status` (`workspace_id`,`status`,`lease_expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `automation_instruction_executions`
--

LOCK TABLES `automation_instruction_executions` WRITE;
/*!40000 ALTER TABLE `automation_instruction_executions` DISABLE KEYS */;
/*!40000 ALTER TABLE `automation_instruction_executions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `automation_rule_definitions`
--

DROP TABLE IF EXISTS `automation_rule_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `automation_rule_definitions` (
  `id` varchar(191) NOT NULL,
  `resource_key` varchar(191) NOT NULL,
  `object_key` varchar(191) NOT NULL,
  `name` text NOT NULL,
  `payload_json` longtext NOT NULL,
  `schema_version` varchar(191) NOT NULL,
  `schema_hash` varchar(191) NOT NULL,
  `source_kind` varchar(191) NOT NULL,
  `source_id` varchar(191) NOT NULL,
  `disabled_at` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `resource_key` (`resource_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `automation_rule_definitions`
--

LOCK TABLES `automation_rule_definitions` WRITE;
/*!40000 ALTER TABLE `automation_rule_definitions` DISABLE KEYS */;
/*!40000 ALTER TABLE `automation_rule_definitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `automation_rule_executions`
--

DROP TABLE IF EXISTS `automation_rule_executions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `automation_rule_executions` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `rule_key` varchar(191) NOT NULL,
  `object_key` varchar(191) NOT NULL,
  `record_id` varchar(191) DEFAULT NULL,
  `phase` varchar(191) NOT NULL,
  `operation` varchar(191) NOT NULL,
  `status` varchar(191) NOT NULL,
  `actor_id` varchar(191) DEFAULT NULL,
  `role_key` varchar(191) DEFAULT NULL,
  `request_id` varchar(191) DEFAULT NULL,
  `correlation_id` varchar(191) DEFAULT NULL,
  `event_id` varchar(191) DEFAULT NULL,
  `duration_ms` int NOT NULL DEFAULT '0',
  `error_code` varchar(191) DEFAULT NULL,
  `candidate_json` text NOT NULL,
  `trace_json` text NOT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_automation_rule_executions_workspace_identity` (`workspace_id`,`id`),
  KEY `idx_automation_execution_rule` (`workspace_id`,`rule_key`,`created_at`),
  KEY `idx_automation_execution_record` (`workspace_id`,`object_key`,`record_id`,`created_at`),
  KEY `idx_automation_execution_status` (`workspace_id`,`status`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `automation_rule_executions`
--

LOCK TABLES `automation_rule_executions` WRITE;
/*!40000 ALTER TABLE `automation_rule_executions` DISABLE KEYS */;
/*!40000 ALTER TABLE `automation_rule_executions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `business_action_executions`
--

DROP TABLE IF EXISTS `business_action_executions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `business_action_executions` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `object_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `record_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin DEFAULT NULL,
  `action_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `idempotency_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `request_fingerprint` varchar(191) NOT NULL DEFAULT '',
  `status` varchar(191) NOT NULL,
  `result_json` text NOT NULL,
  `lease_owner` varchar(191) NOT NULL DEFAULT '',
  `lease_expires_at` varchar(191) NOT NULL DEFAULT '',
  `fencing_token` bigint NOT NULL DEFAULT '0',
  `response_status` int NOT NULL DEFAULT '0',
  `error_code` varchar(191) NOT NULL DEFAULT '',
  `expires_at` varchar(191) NOT NULL DEFAULT '',
  `actor_id` varchar(191) DEFAULT NULL,
  `role_key` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_business_action_executions_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_business_action_execution_scope` (`workspace_id`,`object_key`,`record_id`,`action_key`,`idempotency_key`),
  KEY `idx_business_action_execution_lease` (`status`,`lease_expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `business_action_executions`
--

LOCK TABLES `business_action_executions` WRITE;
/*!40000 ALTER TABLE `business_action_executions` DISABLE KEYS */;
/*!40000 ALTER TABLE `business_action_executions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `business_audit_export_artifacts`
--

DROP TABLE IF EXISTS `business_audit_export_artifacts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `business_audit_export_artifacts` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `requester_user_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `role_key` varchar(191) NOT NULL,
  `idempotency_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `filters_json` text NOT NULL,
  `scope_sha256` varchar(191) NOT NULL,
  `authorization_scope_sha256` varchar(191) NOT NULL,
  `token_sha256` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `filename` text NOT NULL,
  `content_sha256` varchar(191) NOT NULL,
  `row_count` bigint NOT NULL,
  `content_base64` text NOT NULL,
  `audit_identity` varchar(191) NOT NULL,
  `status` varchar(191) NOT NULL,
  `created_at` varchar(191) NOT NULL,
  `expires_at` varchar(191) NOT NULL,
  `download_count` bigint NOT NULL DEFAULT '0',
  `last_downloaded_at` varchar(191) NOT NULL DEFAULT '',
  UNIQUE KEY `uniq_business_audit_export_artifacts_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_business_audit_export_idempotency` (`workspace_id`,`requester_user_id`,`idempotency_key`),
  UNIQUE KEY `uniq_business_audit_export_token_hash` (`workspace_id`,`token_sha256`),
  KEY `idx_business_audit_export_expiry` (`workspace_id`,`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `business_audit_export_artifacts`
--

LOCK TABLES `business_audit_export_artifacts` WRITE;
/*!40000 ALTER TABLE `business_audit_export_artifacts` DISABLE KEYS */;
/*!40000 ALTER TABLE `business_audit_export_artifacts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `business_change_plan_drafts`
--

DROP TABLE IF EXISTS `business_change_plan_drafts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `business_change_plan_drafts` (
  `workspace_id` varchar(191) NOT NULL,
  `plan_id` varchar(191) NOT NULL,
  `revision` int NOT NULL,
  `status` varchar(191) NOT NULL,
  `payload_json` longtext NOT NULL,
  `created_by` varchar(191) NOT NULL,
  `updated_by` varchar(191) NOT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`workspace_id`,`plan_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `business_change_plan_drafts`
--

LOCK TABLES `business_change_plan_drafts` WRITE;
/*!40000 ALTER TABLE `business_change_plan_drafts` DISABLE KEYS */;
/*!40000 ALTER TABLE `business_change_plan_drafts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `business_change_plan_operations`
--

DROP TABLE IF EXISTS `business_change_plan_operations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `business_change_plan_operations` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `plan_id` varchar(191) NOT NULL,
  `plan_revision` int NOT NULL,
  `operation` varchar(191) NOT NULL,
  `idempotency_key` varchar(191) NOT NULL,
  `request_fingerprint` varchar(191) NOT NULL,
  `status` varchar(191) NOT NULL,
  `result_json` longtext NOT NULL,
  `lease_owner` varchar(191) NOT NULL,
  `lease_expires_at` varchar(191) NOT NULL,
  `fencing_token` bigint NOT NULL,
  `error_code` varchar(191) NOT NULL,
  `expires_at` varchar(191) NOT NULL,
  `actor_id` varchar(191) NOT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_change_plan_operation_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_change_plan_operation_scope` (`workspace_id`,`plan_id`,`plan_revision`,`operation`,`idempotency_key`),
  KEY `idx_change_plan_operation_lease` (`status`,`lease_expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `business_change_plan_operations`
--

LOCK TABLES `business_change_plan_operations` WRITE;
/*!40000 ALTER TABLE `business_change_plan_operations` DISABLE KEYS */;
/*!40000 ALTER TABLE `business_change_plan_operations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `business_localized_text`
--

DROP TABLE IF EXISTS `business_localized_text`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `business_localized_text` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(128) NOT NULL,
  `entity_type` varchar(128) NOT NULL,
  `entity_key` varchar(128) NOT NULL,
  `property` varchar(128) NOT NULL,
  `locale` varchar(128) NOT NULL,
  `text` text NOT NULL,
  `source_kind` varchar(191) NOT NULL,
  `source_id` varchar(191) NOT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_business_localized_text_key` (`workspace_id`,`entity_type`,`entity_key`,`property`,`locale`),
  UNIQUE KEY `uniq_business_localized_text_workspace_identity` (`workspace_id`,`id`),
  KEY `idx_business_localized_text_entity` (`entity_type`,`entity_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `business_localized_text`
--

LOCK TABLES `business_localized_text` WRITE;
/*!40000 ALTER TABLE `business_localized_text` DISABLE KEYS */;
INSERT INTO `business_localized_text` VALUES ('default:action:report_export_audit.request_work_order_export:label:en-US','default','action','report_export_audit.request_work_order_export','label','en-US','Request work-order export','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action:service_request.complete_repair:label:en-US','default','action','service_request.complete_repair','label','en-US','Complete repair','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action:service_request.dispatch_service_request:label:en-US','default','action','service_request.dispatch_service_request','label','en-US','Dispatch service request','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action:service_request.request_warranty_waiver:label:en-US','default','action','service_request.request_warranty_waiver','label','en-US','Request warranty waiver','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action:service_request.send_overdue_reminder:label:en-US','default','action','service_request.send_overdue_reminder','label','en-US','Send overdue reminder','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action:service_request.start_assigned_repair:label:en-US','default','action','service_request.start_assigned_repair','label','en-US','Start assigned repair','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action:service_request.submit_service_request:label:en-US','default','action','service_request.submit_service_request','label','en-US','Submit service request','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action:service_request.unassign_service_request:label:en-US','default','action','service_request.unassign_service_request','label','en-US','Unassign service request','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action:warranty_waiver.decide_warranty_waiver:label:en-US','default','action','warranty_waiver.decide_warranty_waiver','label','en-US','Decide warranty waiver','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action_payload_field:report_export_audit.request_work_order_export.purpose:name:en-US','default','action_payload_field','report_export_audit.request_work_order_export.purpose','name','en-US','Purpose','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action_payload_field:report_export_audit.request_work_order_export.report_key:name:en-US','default','action_payload_field','report_export_audit.request_work_order_export.report_key','name','en-US','Report key','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action_payload_field:report_export_audit.request_work_order_export.requested_at:name:en-US','default','action_payload_field','report_export_audit.request_work_order_export.requested_at','name','en-US','Requested at','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action_payload_field:report_export_audit.request_work_order_export.status:name:en-US','default','action_payload_field','report_export_audit.request_work_order_export.status','name','en-US','Status','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action_payload_field:service_request.complete_repair.completed_at:name:en-US','default','action_payload_field','service_request.complete_repair.completed_at','name','en-US','Completed at','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action_payload_field:service_request.complete_repair.quote_amount:name:en-US','default','action_payload_field','service_request.complete_repair.quote_amount','name','en-US','Quoted fee','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action_payload_field:service_request.complete_repair.request_id:name:en-US','default','action_payload_field','service_request.complete_repair.request_id','name','en-US','Request ID','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action_payload_field:service_request.complete_repair.usage_lines_json:name:en-US','default','action_payload_field','service_request.complete_repair.usage_lines_json','name','en-US','Usage lines JSON','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action_payload_field:service_request.dispatch_service_request.assigned_user_id:name:en-US','default','action_payload_field','service_request.dispatch_service_request.assigned_user_id','name','en-US','Assigned technician','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action_payload_field:service_request.dispatch_service_request.dispatched_at:name:en-US','default','action_payload_field','service_request.dispatch_service_request.dispatched_at','name','en-US','Dispatched at','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action_payload_field:service_request.dispatch_service_request.organization_unit_id:name:en-US','default','action_payload_field','service_request.dispatch_service_request.organization_unit_id','name','en-US','Station ID','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action_payload_field:service_request.dispatch_service_request.request_id:name:en-US','default','action_payload_field','service_request.dispatch_service_request.request_id','name','en-US','Request ID','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action_payload_field:service_request.request_warranty_waiver.request_id:name:en-US','default','action_payload_field','service_request.request_warranty_waiver.request_id','name','en-US','Request ID','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action_payload_field:service_request.request_warranty_waiver.requested_amount:name:en-US','default','action_payload_field','service_request.request_warranty_waiver.requested_amount','name','en-US','Requested waiver','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action_payload_field:service_request.request_warranty_waiver.requested_at:name:en-US','default','action_payload_field','service_request.request_warranty_waiver.requested_at','name','en-US','Requested at','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action_payload_field:service_request.request_warranty_waiver.warranty_asserted:name:en-US','default','action_payload_field','service_request.request_warranty_waiver.warranty_asserted','name','en-US','Warranty eligibility asserted','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action_payload_field:service_request.send_overdue_reminder.scheduled_at:name:en-US','default','action_payload_field','service_request.send_overdue_reminder.scheduled_at','name','en-US','Scheduled at','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action_payload_field:service_request.start_assigned_repair.request_id:name:en-US','default','action_payload_field','service_request.start_assigned_repair.request_id','name','en-US','Request ID','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action_payload_field:service_request.start_assigned_repair.started_at:name:en-US','default','action_payload_field','service_request.start_assigned_repair.started_at','name','en-US','Started at','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action_payload_field:service_request.submit_service_request.device_id:name:en-US','default','action_payload_field','service_request.submit_service_request.device_id','name','en-US','Device','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action_payload_field:service_request.submit_service_request.fault_description:name:en-US','default','action_payload_field','service_request.submit_service_request.fault_description','name','en-US','Fault description','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action_payload_field:service_request.submit_service_request.preferred_visit_at:name:en-US','default','action_payload_field','service_request.submit_service_request.preferred_visit_at','name','en-US','Preferred visit time','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action_payload_field:service_request.submit_service_request.request_id:name:en-US','default','action_payload_field','service_request.submit_service_request.request_id','name','en-US','Request ID','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action_payload_field:service_request.submit_service_request.submitted_at:name:en-US','default','action_payload_field','service_request.submit_service_request.submitted_at','name','en-US','Submitted at','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action_payload_field:service_request.unassign_service_request.request_id:name:en-US','default','action_payload_field','service_request.unassign_service_request.request_id','name','en-US','Request ID','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action_payload_field:warranty_waiver.decide_warranty_waiver.decided_at:name:en-US','default','action_payload_field','warranty_waiver.decide_warranty_waiver.decided_at','name','en-US','Decided at','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action_payload_field:warranty_waiver.decide_warranty_waiver.decision:name:en-US','default','action_payload_field','warranty_waiver.decide_warranty_waiver.decision','name','en-US','Decision','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:action_payload_field:warranty_waiver.decide_warranty_waiver.rejection_reason:name:en-US','default','action_payload_field','warranty_waiver.decide_warranty_waiver.rejection_reason','name','en-US','Rejection reason','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:app:app:description:en-US','default','app','app','description','en-US','Dual-Surface equipment maintenance operations with scoped dispatch, transactional repair completion, warranty-waiver approval, reminders, reporting, and governed export.','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:app:app:name:en-US','default','app','app','name','en-US','M2 Equipment Field Service','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:dictionary:audit_event_category:description:en-US','default','dictionary','audit_event_category','description','en-US','Default categories shown by audit and operations surfaces.','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:dictionary:audit_event_category:name:en-US','default','dictionary','audit_event_category','name','en-US','Audit event category','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:dictionary:platform_operation_status:description:en-US','default','dictionary','platform_operation_status','description','en-US','Default status values used by global system capability pages.','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:dictionary:platform_operation_status:name:en-US','default','dictionary','platform_operation_status','name','en-US','Platform operation status','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:dictionary:workflow_execution_status:description:en-US','default','dictionary','workflow_execution_status','description','en-US','Default workflow execution lifecycle values for the global workflow console.','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:dictionary:workflow_execution_status:name:en-US','default','dictionary','workflow_execution_status','name','en-US','Workflow execution status','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:dictionary_item:audit_event_category.access:label:en-US','default','dictionary_item','audit_event_category.access','label','en-US','Access','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:dictionary_item:audit_event_category.import_export:label:en-US','default','dictionary_item','audit_event_category.import_export','label','en-US','Import / export','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:dictionary_item:audit_event_category.metadata:label:en-US','default','dictionary_item','audit_event_category.metadata','label','en-US','Metadata','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:dictionary_item:audit_event_category.operations:label:en-US','default','dictionary_item','audit_event_category.operations','label','en-US','Operations','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:dictionary_item:audit_event_category.workflow:label:en-US','default','dictionary_item','audit_event_category.workflow','label','en-US','Workflow','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:dictionary_item:platform_operation_status.disabled:label:en-US','default','dictionary_item','platform_operation_status.disabled','label','en-US','Disabled','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:dictionary_item:platform_operation_status.enabled:label:en-US','default','dictionary_item','platform_operation_status.enabled','label','en-US','Enabled','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:dictionary_item:platform_operation_status.failed:label:en-US','default','dictionary_item','platform_operation_status.failed','label','en-US','Failed','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:dictionary_item:platform_operation_status.warning:label:en-US','default','dictionary_item','platform_operation_status.warning','label','en-US','Warning','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:dictionary_item:workflow_execution_status.completed:label:en-US','default','dictionary_item','workflow_execution_status.completed','label','en-US','Completed','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:dictionary_item:workflow_execution_status.dead_lettered:label:en-US','default','dictionary_item','workflow_execution_status.dead_lettered','label','en-US','Dead lettered','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:dictionary_item:workflow_execution_status.failed:label:en-US','default','dictionary_item','workflow_execution_status.failed','label','en-US','Failed','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:dictionary_item:workflow_execution_status.queued:label:en-US','default','dictionary_item','workflow_execution_status.queued','label','en-US','Queued','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:dictionary_item:workflow_execution_status.running:label:en-US','default','dictionary_item','workflow_execution_status.running','label','en-US','Running','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:entrypoint:fieldservice_business:description:en-US','default','entrypoint','fieldservice_business','description','en-US','Focused operational workspace for internal roles.','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:entrypoint:fieldservice_business:name:en-US','default','entrypoint','fieldservice_business','name','en-US','Field Service Business Workspace','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:entrypoint:fieldservice_portal:description:en-US','default','entrypoint','fieldservice_portal','description','en-US','Self-service domain entrypoint for external customers.','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:entrypoint:fieldservice_portal:name:en-US','default','entrypoint','fieldservice_portal','name','en-US','Field Service Customer Portal','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:customer_profile.display_name:name:en-US','default','field','customer_profile.display_name','name','en-US','Display name','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:customer_profile.identity_user_id:name:en-US','default','field','customer_profile.identity_user_id','name','en-US','Identity user','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:customer_profile.status:name:en-US','default','field','customer_profile.status','name','en-US','Status','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:device.customer_profile_id:name:en-US','default','field','device.customer_profile_id','name','en-US','Customer','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:device.name:name:en-US','default','field','device.name','name','en-US','Name','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:device.purchase_date:name:en-US','default','field','device.purchase_date','name','en-US','Purchase date','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:device.serial_number:name:en-US','default','field','device.serial_number','name','en-US','Serial number','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:fee_ledger.amount:name:en-US','default','field','fee_ledger.amount','name','en-US','Amount','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:fee_ledger.calculation_trace:name:en-US','default','field','fee_ledger.calculation_trace','name','en-US','Calculation trace','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:fee_ledger.input_snapshot:name:en-US','default','field','fee_ledger.input_snapshot','name','en-US','Input snapshot','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:fee_ledger.kind:name:en-US','default','field','fee_ledger.kind','name','en-US','Entry kind','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:fee_ledger.lineage_key:name:en-US','default','field','fee_ledger.lineage_key','name','en-US','Lineage key','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:fee_ledger.occurred_at:name:en-US','default','field','fee_ledger.occurred_at','name','en-US','Occurred at','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:fee_ledger.policy_snapshot:name:en-US','default','field','fee_ledger.policy_snapshot','name','en-US','Policy snapshot','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:fee_ledger.service_request_id:name:en-US','default','field','fee_ledger.service_request_id','name','en-US','Service request','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:fee_ledger.warranty_waiver_id:name:en-US','default','field','fee_ledger.warranty_waiver_id','name','en-US','Warranty waiver','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_dead_letter.failed_at:name:en-US','default','field','job_dead_letter.failed_at','name','en-US','Failed At','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_dead_letter.job_run_id:name:en-US','default','field','job_dead_letter.job_run_id','name','en-US','Job Run','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_dead_letter.last_error:name:en-US','default','field','job_dead_letter.last_error','name','en-US','Last Error','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_dead_letter.reason:name:en-US','default','field','job_dead_letter.reason','name','en-US','Reason','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_dead_letter.resolution_idempotency_key:name:en-US','default','field','job_dead_letter.resolution_idempotency_key','name','en-US','Resolution Idempotency Key','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_dead_letter.resolution_note:name:en-US','default','field','job_dead_letter.resolution_note','name','en-US','Resolution Note','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_dead_letter.resolved_at:name:en-US','default','field','job_dead_letter.resolved_at','name','en-US','Resolved At','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_dead_letter.resolved_by:name:en-US','default','field','job_dead_letter.resolved_by','name','en-US','Resolved By','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_dead_letter.scheduler_definition_key:name:en-US','default','field','job_dead_letter.scheduler_definition_key','name','en-US','Scheduler Definition Key','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_dead_letter.status:name:en-US','default','field','job_dead_letter.status','name','en-US','Status','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run_event.created_at:name:en-US','default','field','job_run_event.created_at','name','en-US','Created At','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run_event.event_type:name:en-US','default','field','job_run_event.event_type','name','en-US','Event Type','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run_event.job_run_id:name:en-US','default','field','job_run_event.job_run_id','name','en-US','Job Run','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run_event.message:name:en-US','default','field','job_run_event.message','name','en-US','Message','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run_event.metadata_json:name:en-US','default','field','job_run_event.metadata_json','name','en-US','Metadata JSON','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run.attempt:name:en-US','default','field','job_run.attempt','name','en-US','Attempt','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run.error_category:name:en-US','default','field','job_run.error_category','name','en-US','Error Category','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run.error_message:name:en-US','default','field','job_run.error_message','name','en-US','Error Message','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run.fencing_token:name:en-US','default','field','job_run.fencing_token','name','en-US','Fencing Token','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run.finished_at:name:en-US','default','field','job_run.finished_at','name','en-US','Finished At','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run.idempotency_key:name:en-US','default','field','job_run.idempotency_key','name','en-US','Idempotency Key','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run.idempotency_scope:name:en-US','default','field','job_run.idempotency_scope','name','en-US','Idempotency Scope','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run.last_command_key:name:en-US','default','field','job_run.last_command_key','name','en-US','Last Command Key','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run.last_command_scope:name:en-US','default','field','job_run.last_command_scope','name','en-US','Last Command Scope','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run.lease_expires_at:name:en-US','default','field','job_run.lease_expires_at','name','en-US','Lease Expires At','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run.lease_owner:name:en-US','default','field','job_run.lease_owner','name','en-US','Lease Owner','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run.max_attempts:name:en-US','default','field','job_run.max_attempts','name','en-US','Max Attempts','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run.next_retry_at:name:en-US','default','field','job_run.next_retry_at','name','en-US','Next Retry At','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run.payload_json:name:en-US','default','field','job_run.payload_json','name','en-US','Payload JSON','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run.recoverability:name:en-US','default','field','job_run.recoverability','name','en-US','Recoverability','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run.result_json:name:en-US','default','field','job_run.result_json','name','en-US','Result JSON','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run.retry_backoff:name:en-US','default','field','job_run.retry_backoff','name','en-US','Retry Backoff','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run.retry_backoff_seconds:name:en-US','default','field','job_run.retry_backoff_seconds','name','en-US','Retry Backoff Seconds','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run.retry_delay_seconds:name:en-US','default','field','job_run.retry_delay_seconds','name','en-US','Retry Delay Seconds','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run.retry_max_delay_seconds:name:en-US','default','field','job_run.retry_max_delay_seconds','name','en-US','Max Retry Delay Seconds','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run.scheduled_for:name:en-US','default','field','job_run.scheduled_for','name','en-US','Scheduled For','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run.scheduler_definition_key:name:en-US','default','field','job_run.scheduler_definition_key','name','en-US','Scheduler Definition Key','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run.started_at:name:en-US','default','field','job_run.started_at','name','en-US','Started At','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run.status:name:en-US','default','field','job_run.status','name','en-US','Status','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run.target_object:name:en-US','default','field','job_run.target_object','name','en-US','Target Object','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run.target_record_id:name:en-US','default','field','job_run.target_record_id','name','en-US','Target Record ID','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run.timeout_seconds:name:en-US','default','field','job_run.timeout_seconds','name','en-US','Timeout Seconds','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run.triggered_by:name:en-US','default','field','job_run.triggered_by','name','en-US','Triggered By','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run.workflow_execution_id:name:en-US','default','field','job_run.workflow_execution_id','name','en-US','Workflow Execution ID','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:job_run.workflow_key:name:en-US','default','field','job_run.workflow_key','name','en-US','Workflow Key','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:overdue_reminder.business_date:name:en-US','default','field','overdue_reminder.business_date','name','en-US','Business date','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:overdue_reminder.dedupe_key:name:en-US','default','field','overdue_reminder.dedupe_key','name','en-US','Dedupe key','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:overdue_reminder.owner_department_id:name:en-US','default','field','overdue_reminder.owner_department_id','name','en-US','Owner department ID','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:overdue_reminder.owner_department_path:name:en-US','default','field','overdue_reminder.owner_department_path','name','en-US','Owner department path','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:overdue_reminder.recipient_user_id:name:en-US','default','field','overdue_reminder.recipient_user_id','name','en-US','Recipient','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:overdue_reminder.sent_at:name:en-US','default','field','overdue_reminder.sent_at','name','en-US','Sent at','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:overdue_reminder.service_request_id:name:en-US','default','field','overdue_reminder.service_request_id','name','en-US','Service request','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:part_usage.amount:name:en-US','default','field','part_usage.amount','name','en-US','Usage amount','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:part_usage.calculation_trace:name:en-US','default','field','part_usage.calculation_trace','name','en-US','Calculation trace','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:part_usage.occurred_at:name:en-US','default','field','part_usage.occurred_at','name','en-US','Occurred at','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:part_usage.owner_department_id:name:en-US','default','field','part_usage.owner_department_id','name','en-US','Owner department ID','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:part_usage.owner_department_path:name:en-US','default','field','part_usage.owner_department_path','name','en-US','Owner department path','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:part_usage.performed_by_user_id:name:en-US','default','field','part_usage.performed_by_user_id','name','en-US','Performed by','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:part_usage.quantity:name:en-US','default','field','part_usage.quantity','name','en-US','Quantity','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:part_usage.service_request_id:name:en-US','default','field','part_usage.service_request_id','name','en-US','Service request','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:part_usage.spare_part_id:name:en-US','default','field','part_usage.spare_part_id','name','en-US','Spare part','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:part_usage.unit_price_snapshot:name:en-US','default','field','part_usage.unit_price_snapshot','name','en-US','Unit price snapshot','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:record_timer.attempt:name:en-US','default','field','record_timer.attempt','name','en-US','Attempt','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:record_timer.business_calendar_key:name:en-US','default','field','record_timer.business_calendar_key','name','en-US','Business Calendar Key','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:record_timer.cancelled_at:name:en-US','default','field','record_timer.cancelled_at','name','en-US','Cancelled At','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:record_timer.due_at:name:en-US','default','field','record_timer.due_at','name','en-US','Due At','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:record_timer.failed_at:name:en-US','default','field','record_timer.failed_at','name','en-US','Failed At','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:record_timer.fencing_token:name:en-US','default','field','record_timer.fencing_token','name','en-US','Fencing Token','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:record_timer.fired_at:name:en-US','default','field','record_timer.fired_at','name','en-US','Fired At','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:record_timer.last_error:name:en-US','default','field','record_timer.last_error','name','en-US','Last Error','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:record_timer.lease_expires_at:name:en-US','default','field','record_timer.lease_expires_at','name','en-US','Lease Expires At','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:record_timer.lease_owner:name:en-US','default','field','record_timer.lease_owner','name','en-US','Lease Owner','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:record_timer.max_attempts:name:en-US','default','field','record_timer.max_attempts','name','en-US','Max Attempts','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:record_timer.object_key:name:en-US','default','field','record_timer.object_key','name','en-US','Object Key','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:record_timer.offset_seconds:name:en-US','default','field','record_timer.offset_seconds','name','en-US','Offset Seconds','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:record_timer.payload_json:name:en-US','default','field','record_timer.payload_json','name','en-US','Payload JSON','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:record_timer.priority:name:en-US','default','field','record_timer.priority','name','en-US','Priority','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:record_timer.purpose:name:en-US','default','field','record_timer.purpose','name','en-US','Purpose','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:record_timer.record_id:name:en-US','default','field','record_timer.record_id','name','en-US','Record ID','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:record_timer.retry_delay_seconds:name:en-US','default','field','record_timer.retry_delay_seconds','name','en-US','Retry Delay Seconds','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:record_timer.retry_max_delay_seconds:name:en-US','default','field','record_timer.retry_max_delay_seconds','name','en-US','Retry Max Delay Seconds','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:record_timer.schedule_mode:name:en-US','default','field','record_timer.schedule_mode','name','en-US','Schedule Mode','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:record_timer.sequence:name:en-US','default','field','record_timer.sequence','name','en-US','Sequence','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:record_timer.source_field:name:en-US','default','field','record_timer.source_field','name','en-US','Source Field','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:record_timer.status:name:en-US','default','field','record_timer.status','name','en-US','Status','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:record_timer.supersedes_timer_id:name:en-US','default','field','record_timer.supersedes_timer_id','name','en-US','Supersedes Timer','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:record_timer.target_key:name:en-US','default','field','record_timer.target_key','name','en-US','Target Key','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:record_timer.target_type:name:en-US','default','field','record_timer.target_type','name','en-US','Target Type','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:record_timer.timer_key:name:en-US','default','field','record_timer.timer_key','name','en-US','Timer Key','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:record_timer.timezone:name:en-US','default','field','record_timer.timezone','name','en-US','Timezone','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:report_export_audit.owner_department_id:name:en-US','default','field','report_export_audit.owner_department_id','name','en-US','Owner department ID','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:report_export_audit.owner_department_path:name:en-US','default','field','report_export_audit.owner_department_path','name','en-US','Owner department path','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:report_export_audit.purpose:name:en-US','default','field','report_export_audit.purpose','name','en-US','Purpose','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:report_export_audit.report_key:name:en-US','default','field','report_export_audit.report_key','name','en-US','Report key','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:report_export_audit.requested_at:name:en-US','default','field','report_export_audit.requested_at','name','en-US','Requested at','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:report_export_audit.requester_user_id:name:en-US','default','field','report_export_audit.requester_user_id','name','en-US','Requester','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:report_export_audit.row_count:name:en-US','default','field','report_export_audit.row_count','name','en-US','Row count','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:report_export_audit.scope_hash:name:en-US','default','field','report_export_audit.scope_hash','name','en-US','Scope hash','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:report_export_audit.status:name:en-US','default','field','report_export_audit.status','name','en-US','Status','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:report_export_download.audit_id:name:en-US','default','field','report_export_download.audit_id','name','en-US','Audit request','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:report_export_download.content_hash:name:en-US','default','field','report_export_download.content_hash','name','en-US','Content hash','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:report_export_download.expires_at:name:en-US','default','field','report_export_download.expires_at','name','en-US','Expires at','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:report_export_download.filename:name:en-US','default','field','report_export_download.filename','name','en-US','Filename','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:report_export_download.owner:name:en-US','default','field','report_export_download.owner','name','en-US','Owner','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:scheduler_cursor.last_run_at:name:en-US','default','field','scheduler_cursor.last_run_at','name','en-US','Last Run At','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:scheduler_cursor.last_run_status:name:en-US','default','field','scheduler_cursor.last_run_status','name','en-US','Last Run Status','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:scheduler_cursor.next_run_at:name:en-US','default','field','scheduler_cursor.next_run_at','name','en-US','Next Run At','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:scheduler_cursor.scheduler_definition_key:name:en-US','default','field','scheduler_cursor.scheduler_definition_key','name','en-US','Scheduler Definition Key','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:service_request.assigned_user_id:name:en-US','default','field','service_request.assigned_user_id','name','en-US','Assigned technician','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:service_request.completed_at:name:en-US','default','field','service_request.completed_at','name','en-US','Completed at','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:service_request.customer_profile_id:name:en-US','default','field','service_request.customer_profile_id','name','en-US','Customer','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:service_request.device_id:name:en-US','default','field','service_request.device_id','name','en-US','Device','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:service_request.dispatched_at:name:en-US','default','field','service_request.dispatched_at','name','en-US','Dispatched at','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:service_request.fault_description:name:en-US','default','field','service_request.fault_description','name','en-US','Fault description','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:service_request.organization_unit_id:name:en-US','default','field','service_request.organization_unit_id','name','en-US','Station','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:service_request.owner_department_id:name:en-US','default','field','service_request.owner_department_id','name','en-US','Owner department ID','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:service_request.owner_department_path:name:en-US','default','field','service_request.owner_department_path','name','en-US','Owner department path','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:service_request.preferred_visit_at:name:en-US','default','field','service_request.preferred_visit_at','name','en-US','Preferred visit time','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:service_request.quote_amount:name:en-US','default','field','service_request.quote_amount','name','en-US','Quoted fee','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:service_request.started_at:name:en-US','default','field','service_request.started_at','name','en-US','Repair started at','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:service_request.status:name:en-US','default','field','service_request.status','name','en-US','Status','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:service_request.submitted_at:name:en-US','default','field','service_request.submitted_at','name','en-US','Submitted at','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:spare_part.code:name:en-US','default','field','spare_part.code','name','en-US','Code','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:spare_part.name:name:en-US','default','field','spare_part.name','name','en-US','Name','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:spare_part.stock_quantity:name:en-US','default','field','spare_part.stock_quantity','name','en-US','Stock quantity','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:spare_part.unit_price:name:en-US','default','field','spare_part.unit_price','name','en-US','Unit price','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:warranty_waiver.calculation_trace:name:en-US','default','field','warranty_waiver.calculation_trace','name','en-US','Calculation trace','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:warranty_waiver.decided_at:name:en-US','default','field','warranty_waiver.decided_at','name','en-US','Decided at','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:warranty_waiver.decided_by_user_id:name:en-US','default','field','warranty_waiver.decided_by_user_id','name','en-US','Decided by','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:warranty_waiver.owner_department_id:name:en-US','default','field','warranty_waiver.owner_department_id','name','en-US','Owner department ID','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:warranty_waiver.owner_department_path:name:en-US','default','field','warranty_waiver.owner_department_path','name','en-US','Owner department path','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:warranty_waiver.policy_snapshot:name:en-US','default','field','warranty_waiver.policy_snapshot','name','en-US','Policy snapshot','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:warranty_waiver.rejection_reason:name:en-US','default','field','warranty_waiver.rejection_reason','name','en-US','Rejection reason','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:warranty_waiver.requested_amount:name:en-US','default','field','warranty_waiver.requested_amount','name','en-US','Requested waiver','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:warranty_waiver.requested_at:name:en-US','default','field','warranty_waiver.requested_at','name','en-US','Requested at','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:warranty_waiver.requester_user_id:name:en-US','default','field','warranty_waiver.requester_user_id','name','en-US','Requesting technician','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:warranty_waiver.service_request_id:name:en-US','default','field','warranty_waiver.service_request_id','name','en-US','Service request','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:warranty_waiver.status:name:en-US','default','field','warranty_waiver.status','name','en-US','Status','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:warranty_waiver.threshold_snapshot:name:en-US','default','field','warranty_waiver.threshold_snapshot','name','en-US','Approval threshold snapshot','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field:warranty_waiver.warranty_asserted:name:en-US','default','field','warranty_waiver.warranty_asserted','name','en-US','Warranty eligibility asserted','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field_option:customer_profile.status.active:label:en-US','default','field_option','customer_profile.status.active','label','en-US','Active','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field_option:customer_profile.status.inactive:label:en-US','default','field_option','customer_profile.status.inactive','label','en-US','Inactive','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field_option:fee_ledger.kind.adjustment:label:en-US','default','field_option','fee_ledger.kind.adjustment','label','en-US','Adjustment','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field_option:fee_ledger.kind.charge:label:en-US','default','field_option','fee_ledger.kind.charge','label','en-US','Charge','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field_option:fee_ledger.kind.reversal:label:en-US','default','field_option','fee_ledger.kind.reversal','label','en-US','Reversal','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field_option:fee_ledger.kind.waiver:label:en-US','default','field_option','fee_ledger.kind.waiver','label','en-US','Waiver','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field_option:report_export_audit.status.denied:label:en-US','default','field_option','report_export_audit.status.denied','label','en-US','Denied','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field_option:report_export_audit.status.downloaded:label:en-US','default','field_option','report_export_audit.status.downloaded','label','en-US','Downloaded','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field_option:report_export_audit.status.expired:label:en-US','default','field_option','report_export_audit.status.expired','label','en-US','Expired','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field_option:report_export_audit.status.prepared:label:en-US','default','field_option','report_export_audit.status.prepared','label','en-US','Prepared','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field_option:report_export_audit.status.requested:label:en-US','default','field_option','report_export_audit.status.requested','label','en-US','Requested','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field_option:service_request.status.completed:label:en-US','default','field_option','service_request.status.completed','label','en-US','Completed','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field_option:service_request.status.dispatched:label:en-US','default','field_option','service_request.status.dispatched','label','en-US','Dispatched','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field_option:service_request.status.in_repair:label:en-US','default','field_option','service_request.status.in_repair','label','en-US','In repair','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field_option:service_request.status.submitted:label:en-US','default','field_option','service_request.status.submitted','label','en-US','Submitted','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field_option:warranty_waiver.status.applied:label:en-US','default','field_option','warranty_waiver.status.applied','label','en-US','Applied','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field_option:warranty_waiver.status.approved:label:en-US','default','field_option','warranty_waiver.status.approved','label','en-US','Approved','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field_option:warranty_waiver.status.pending:label:en-US','default','field_option','warranty_waiver.status.pending','label','en-US','Pending approval','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:field_option:warranty_waiver.status.rejected:label:en-US','default','field_option','warranty_waiver.status.rejected','label','en-US','Rejected','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:object:customer_profile:description:en-US','default','object','customer_profile','description','en-US','Business customer profile bound one-to-one to a Runtime identity account.','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:object:customer_profile:name:en-US','default','object','customer_profile','name','en-US','Customer profile','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:object:device:description:en-US','default','object','device','description','en-US','Customer-owned equipment eligible for maintenance service.','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:object:device:name:en-US','default','object','device','name','en-US','Device','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:object:fee_ledger:description:en-US','default','object','fee_ledger','description','en-US','Append-only charge and waiver facts used to derive final customer fee without historical drift.','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:object:fee_ledger:name:en-US','default','object','fee_ledger','name','en-US','Fee ledger','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:object:job_dead_letter:description:en-US','default','object','job_dead_letter','description','en-US','Runtime-owned exhausted scheduler runs.','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:object:job_dead_letter:name:en-US','default','object','job_dead_letter','name','en-US','Job Dead Letter','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:object:job_run:description:en-US','default','object','job_run','description','en-US','Runtime-owned scheduler executions.','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:object:job_run:name:en-US','default','object','job_run','name','en-US','Job Run','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:object:job_run_event:description:en-US','default','object','job_run_event','description','en-US','Runtime-owned scheduler audit events.','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:object:job_run_event:name:en-US','default','object','job_run_event','name','en-US','Job Run Event','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:object:overdue_reminder:description:en-US','default','object','overdue_reminder','description','en-US','Natural-key reminder fact enforcing at most one notification per request and business date.','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:object:overdue_reminder:name:en-US','default','object','overdue_reminder','name','en-US','Overdue reminder','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:object:part_usage:description:en-US','default','object','part_usage','description','en-US','Immutable event-time part consumption fact created during repair completion.','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:object:part_usage:name:en-US','default','object','part_usage','name','en-US','Part usage','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:object:record_timer:description:en-US','default','object','record_timer','description','en-US','Durable record-scoped action and workflow timers.','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:object:record_timer:name:en-US','default','object','record_timer','name','en-US','Record Timer','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:object:report_export_audit:description:en-US','default','object','report_export_audit','description','en-US','Governed work-order export request and terminal audit linkage.','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:object:report_export_audit:name:en-US','default','object','report_export_audit','name','en-US','Report export audit','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:object:report_export_download:description:en-US','default','object','report_export_download','description','en-US','Governed export artifact metadata linked to its audit request.','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:object:report_export_download:name:en-US','default','object','report_export_download','name','en-US','Report export download','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:object:scheduler_cursor:description:en-US','default','object','scheduler_cursor','description','en-US','Runtime-owned cursor for one published scheduler definition.','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:object:scheduler_cursor:name:en-US','default','object','scheduler_cursor','name','en-US','Scheduler Cursor','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:object:service_request:description:en-US','default','object','service_request','description','en-US','Customer repair request and governed internal work-order lifecycle.','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:object:service_request:name:en-US','default','object','service_request','name','en-US','Service request','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:object:spare_part:description:en-US','default','object','spare_part','description','en-US','Maintainable part catalog with exact unit price and non-negative current stock.','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:object:spare_part:name:en-US','default','object','spare_part','name','en-US','Spare part','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:object:warranty_waiver:description:en-US','default','object','warranty_waiver','description','en-US','Single immutable waiver request with a conditional terminal approval decision.','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:object:warranty_waiver:name:en-US','default','object','warranty_waiver','name','en-US','Warranty waiver','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:report:part_usage_summary:name:en-US','default','report','part_usage_summary','name','en-US','Part usage summary','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:report:work_order_detail_export:name:en-US','default','report','work_order_detail_export','name','en-US','Work-order detail export','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:report:work_order_throughput:name:en-US','default','report','work_order_throughput','name','en-US','Work-order throughput','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:report_export_control:work_order_detail_export_control:name:en-US','default','report_export_control','work_order_detail_export_control','name','en-US','Work-order detail governed export','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:role:admin:name:en-US','default','role','admin','name','en-US','Admin','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:role:customer:name:en-US','default','role','customer','name','en-US','Customer','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:role:ops_manager:name:en-US','default','role','ops_manager','name','en-US','Operations manager','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:role:organization_administrator:name:en-US','default','role','organization_administrator','name','en-US','Organization administrator','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:role:scheduler_service:name:en-US','default','role','scheduler_service','name','en-US','Scheduler service','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:role:system_administrator:name:en-US','default','role','system_administrator','name','en-US','System administrator','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:role:technician:name:en-US','default','role','technician','name','en-US','Technician','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:validation:service_request_lifecycle:message:en-US','default','validation','service_request_lifecycle','message','en-US','Service request lifecycle','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:view:customer_profile_detail:name:en-US','default','view','customer_profile_detail','name','en-US','Customer profile Detail','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:view:customer_profile_list:name:en-US','default','view','customer_profile_list','name','en-US','Customer profile','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:view:device_detail:name:en-US','default','view','device_detail','name','en-US','Device Detail','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:view:device_list:name:en-US','default','view','device_list','name','en-US','Device','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:view:fee_ledger_detail:name:en-US','default','view','fee_ledger_detail','name','en-US','Fee ledger Detail','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:view:fee_ledger_list:name:en-US','default','view','fee_ledger_list','name','en-US','Fee ledger','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:view:overdue_reminder_detail:name:en-US','default','view','overdue_reminder_detail','name','en-US','Overdue reminder Detail','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:view:overdue_reminder_list:name:en-US','default','view','overdue_reminder_list','name','en-US','Overdue reminder','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:view:part_usage_detail:name:en-US','default','view','part_usage_detail','name','en-US','Part usage Detail','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:view:part_usage_list:name:en-US','default','view','part_usage_list','name','en-US','Part usage','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:view:report_export_audit_detail:name:en-US','default','view','report_export_audit_detail','name','en-US','Report export audit Detail','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:view:report_export_audit_list:name:en-US','default','view','report_export_audit_list','name','en-US','Report export audit','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:view:report_export_download_detail:name:en-US','default','view','report_export_download_detail','name','en-US','Report export download Detail','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:view:report_export_download_list:name:en-US','default','view','report_export_download_list','name','en-US','Report export download','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:view:service_request_detail:name:en-US','default','view','service_request_detail','name','en-US','Service request Detail','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:view:service_request_list:name:en-US','default','view','service_request_list','name','en-US','Service request list','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:view:spare_part_detail:name:en-US','default','view','spare_part_detail','name','en-US','Spare part Detail','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:view:spare_part_list:name:en-US','default','view','spare_part_list','name','en-US','Spare part list','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:view:warranty_waiver_detail:name:en-US','default','view','warranty_waiver_detail','name','en-US','Warranty waiver Detail','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:view:warranty_waiver_list:name:en-US','default','view','warranty_waiver_list','name','en-US','Warranty waiver','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:workflow:overdue_service_request_scan:name:en-US','default','workflow','overdue_service_request_scan','name','en-US','Overdue service request scan','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:workflow:platform.audit_retention_check:name:en-US','default','workflow','platform.audit_retention_check','name','en-US','Audit retention check','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:workflow:platform.metadata_health_check:name:en-US','default','workflow','platform.metadata_health_check','name','en-US','Metadata health check','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('default:workflow:warranty_waiver_approval:name:en-US','default','workflow','warranty_waiver_approval','name','en-US','Warranty waiver approval','generated','domain_m2_field_service','2026-08-21T18:45:46Z','2026-08-21T18:45:46Z');
/*!40000 ALTER TABLE `business_localized_text` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `business_record_localized_value`
--

DROP TABLE IF EXISTS `business_record_localized_value`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `business_record_localized_value` (
  `workspace_id` varchar(128) NOT NULL,
  `object_key` varchar(128) NOT NULL,
  `record_id` varchar(128) NOT NULL,
  `field_key` varchar(128) NOT NULL,
  `locale` varchar(128) NOT NULL,
  `text_value` text NOT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_business_record_localized_value` (`workspace_id`,`object_key`,`record_id`,`field_key`,`locale`),
  KEY `idx_business_record_localized_search` (`workspace_id`,`object_key`,`locale`,`field_key`,`record_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `business_record_localized_value`
--

LOCK TABLES `business_record_localized_value` WRITE;
/*!40000 ALTER TABLE `business_record_localized_value` DISABLE KEYS */;
/*!40000 ALTER TABLE `business_record_localized_value` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `component_definitions`
--

DROP TABLE IF EXISTS `component_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `component_definitions` (
  `id` varchar(191) NOT NULL,
  `resource_key` varchar(191) NOT NULL,
  `object_key` varchar(191) NOT NULL,
  `name` text NOT NULL,
  `payload_json` longtext NOT NULL,
  `schema_version` varchar(191) NOT NULL,
  `schema_hash` varchar(191) NOT NULL,
  `source_kind` varchar(191) NOT NULL,
  `source_id` varchar(191) NOT NULL,
  `disabled_at` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `resource_key` (`resource_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `component_definitions`
--

LOCK TABLES `component_definitions` WRITE;
/*!40000 ALTER TABLE `component_definitions` DISABLE KEYS */;
/*!40000 ALTER TABLE `component_definitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `connector_definitions`
--

DROP TABLE IF EXISTS `connector_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `connector_definitions` (
  `id` varchar(191) NOT NULL,
  `resource_key` varchar(191) NOT NULL,
  `object_key` varchar(191) NOT NULL,
  `name` text NOT NULL,
  `payload_json` longtext NOT NULL,
  `schema_version` varchar(191) NOT NULL,
  `schema_hash` varchar(191) NOT NULL,
  `source_kind` varchar(191) NOT NULL,
  `source_id` varchar(191) NOT NULL,
  `disabled_at` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `resource_key` (`resource_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `connector_definitions`
--

LOCK TABLES `connector_definitions` WRITE;
/*!40000 ALTER TABLE `connector_definitions` DISABLE KEYS */;
/*!40000 ALTER TABLE `connector_definitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customer_profile`
--

DROP TABLE IF EXISTS `customer_profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer_profile` (
  `workspace_id` varchar(191) NOT NULL,
  `id` varchar(191) NOT NULL,
  `created_at` text NOT NULL,
  `updated_at` text NOT NULL,
  `display_name` varchar(191) DEFAULT NULL,
  `identity_user_id` varchar(191) DEFAULT NULL,
  `status` varchar(191) DEFAULT NULL,
  UNIQUE KEY `uidx_field_b55c082f40c09de2` (`workspace_id`,`id`),
  UNIQUE KEY `uidx_field_15687c9223c07061` (`workspace_id`,`identity_user_id`),
  KEY `idx_field_3a5f04916805a6ed` (`display_name`),
  KEY `idx_field_c5849ffd3bdabcb0` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer_profile`
--

LOCK TABLES `customer_profile` WRITE;
/*!40000 ALTER TABLE `customer_profile` DISABLE KEYS */;
INSERT INTO `customer_profile` VALUES ('default','customer_profile_customer_qin_profile','2026-08-21T18:45:47Z','2026-08-21T18:45:47.907977Z','Qin Industrial','customer_qin','active'),('default','customer_profile_customer_sun_profile','2026-08-21T18:45:47Z','2026-08-21T18:45:47.908979Z','Sun Manufacturing','customer_sun','active');
/*!40000 ALTER TABLE `customer_profile` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `device`
--

DROP TABLE IF EXISTS `device`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `device` (
  `workspace_id` varchar(191) NOT NULL,
  `id` varchar(191) NOT NULL,
  `created_at` text NOT NULL,
  `updated_at` text NOT NULL,
  `customer_profile_id` varchar(191) DEFAULT NULL,
  `name` varchar(191) DEFAULT NULL,
  `purchase_date` text,
  `serial_number` varchar(191) DEFAULT NULL,
  UNIQUE KEY `uidx_field_acfca298b045897f` (`workspace_id`,`id`),
  UNIQUE KEY `uidx_field_a7d588162fb90196` (`workspace_id`,`serial_number`),
  KEY `idx_field_b9d8a9122ed785fa` (`customer_profile_id`),
  KEY `idx_field_3589ebeab74ac2f1` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `device`
--

LOCK TABLES `device` WRITE;
/*!40000 ALTER TABLE `device` DISABLE KEYS */;
INSERT INTO `device` VALUES ('default','device_device_qin_press','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z','customer_profile_customer_qin_profile','Qin Hydraulic Press','2025-01-15','QIN-PRESS-2026-001'),('default','device_device_sun_lathe','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z','customer_profile_customer_sun_profile','Sun CNC Lathe','2024-06-20','SUN-LATHE-2026-001');
/*!40000 ALTER TABLE `device` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dictionary_definitions`
--

DROP TABLE IF EXISTS `dictionary_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dictionary_definitions` (
  `id` varchar(191) NOT NULL,
  `resource_key` varchar(191) NOT NULL,
  `object_key` varchar(191) NOT NULL,
  `name` text NOT NULL,
  `payload_json` longtext NOT NULL,
  `schema_version` varchar(191) NOT NULL,
  `schema_hash` varchar(191) NOT NULL,
  `source_kind` varchar(191) NOT NULL,
  `source_id` varchar(191) NOT NULL,
  `disabled_at` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `resource_key` (`resource_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dictionary_definitions`
--

LOCK TABLES `dictionary_definitions` WRITE;
/*!40000 ALTER TABLE `dictionary_definitions` DISABLE KEYS */;
INSERT INTO `dictionary_definitions` VALUES ('dictionary:audit_event_category','audit_event_category','','Audit event category','{\"key\":\"audit_event_category\",\"name\":\"Audit event category\",\"description\":\"Default categories shown by audit and operations surfaces.\",\"source\":\"platform\",\"items\":[{\"key\":\"access\",\"label\":\"Access\",\"value\":\"access\",\"sort_order\":10,\"status\":\"active\"},{\"key\":\"metadata\",\"label\":\"Metadata\",\"value\":\"metadata\",\"sort_order\":20,\"status\":\"active\"},{\"key\":\"workflow\",\"label\":\"Workflow\",\"value\":\"workflow\",\"sort_order\":30,\"status\":\"active\"},{\"key\":\"import_export\",\"label\":\"Import / export\",\"value\":\"import_export\",\"sort_order\":40,\"status\":\"active\"},{\"key\":\"operations\",\"label\":\"Operations\",\"value\":\"operations\",\"sort_order\":50,\"status\":\"active\"}]}','0.1.0','61cbfefe652cd4c3c89eecbe89c5bb006588ea40cb876690b9d14d0c2dd649a4','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('dictionary:platform_operation_status','platform_operation_status','','Platform operation status','{\"key\":\"platform_operation_status\",\"name\":\"Platform operation status\",\"description\":\"Default status values used by global system capability pages.\",\"source\":\"platform\",\"items\":[{\"key\":\"enabled\",\"label\":\"Enabled\",\"value\":\"enabled\",\"sort_order\":10,\"status\":\"active\",\"color\":\"green\"},{\"key\":\"disabled\",\"label\":\"Disabled\",\"value\":\"disabled\",\"sort_order\":20,\"status\":\"active\",\"color\":\"slate\"},{\"key\":\"warning\",\"label\":\"Warning\",\"value\":\"warning\",\"sort_order\":30,\"status\":\"active\",\"color\":\"amber\"},{\"key\":\"failed\",\"label\":\"Failed\",\"value\":\"failed\",\"sort_order\":40,\"status\":\"active\",\"color\":\"red\"}]}','0.1.0','5ca97464ea7f3fdbb5d27b05c81d53aede9f2d0c3c47d231a50c0947fb176aab','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('dictionary:workflow_execution_status','workflow_execution_status','','Workflow execution status','{\"key\":\"workflow_execution_status\",\"name\":\"Workflow execution status\",\"description\":\"Default workflow execution lifecycle values for the global workflow console.\",\"source\":\"platform\",\"items\":[{\"key\":\"queued\",\"label\":\"Queued\",\"value\":\"queued\",\"sort_order\":10,\"status\":\"active\"},{\"key\":\"running\",\"label\":\"Running\",\"value\":\"running\",\"sort_order\":20,\"status\":\"active\"},{\"key\":\"completed\",\"label\":\"Completed\",\"value\":\"completed\",\"sort_order\":30,\"status\":\"active\"},{\"key\":\"failed\",\"label\":\"Failed\",\"value\":\"failed\",\"sort_order\":40,\"status\":\"active\"},{\"key\":\"dead_lettered\",\"label\":\"Dead lettered\",\"value\":\"dead_lettered\",\"sort_order\":50,\"status\":\"active\"}]}','0.1.0','b26e16ec1bbe98f255331de9176fdab117deb5f169c8a2501a42df724a584343','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z');
/*!40000 ALTER TABLE `dictionary_definitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `entrypoint_definitions`
--

DROP TABLE IF EXISTS `entrypoint_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `entrypoint_definitions` (
  `id` varchar(191) NOT NULL,
  `resource_key` varchar(191) NOT NULL,
  `object_key` varchar(191) NOT NULL,
  `name` text NOT NULL,
  `payload_json` longtext NOT NULL,
  `schema_version` varchar(191) NOT NULL,
  `schema_hash` varchar(191) NOT NULL,
  `source_kind` varchar(191) NOT NULL,
  `source_id` varchar(191) NOT NULL,
  `disabled_at` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `resource_key` (`resource_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `entrypoint_definitions`
--

LOCK TABLES `entrypoint_definitions` WRITE;
/*!40000 ALTER TABLE `entrypoint_definitions` DISABLE KEYS */;
INSERT INTO `entrypoint_definitions` VALUES ('entrypoint:fieldservice_business','fieldservice_business','','Field Service Business Workspace','{\"key\":\"fieldservice_business\",\"name\":\"Field Service Business Workspace\",\"description\":\"Focused operational workspace for internal roles.\",\"audience\":\"internal\",\"roles\":[\"ops_manager\"],\"default\":true,\"config\":{\"create_objects\":[],\"journeys\":[],\"kind\":\"operator_console\",\"primary_object\":\"service_request\",\"read_objects\":[\"service_request\",\"spare_part\",\"part_usage\",\"warranty_waiver\",\"fee_ledger\"],\"update_objects\":[]}}','0.1.0','62197f7d05835f163c18f300f363b274d978685a666f34d97fe60b58325836df','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('entrypoint:fieldservice_portal','fieldservice_portal','','Field Service Customer Portal','{\"key\":\"fieldservice_portal\",\"name\":\"Field Service Customer Portal\",\"description\":\"Self-service domain entrypoint for external customers.\",\"audience\":\"consumer\",\"roles\":[\"customer\"],\"config\":{\"create_objects\":[],\"journeys\":[],\"kind\":\"customer_portal\",\"primary_object\":\"service_request\",\"read_objects\":[\"customer_profile\",\"device\",\"service_request\",\"warranty_waiver\",\"fee_ledger\"],\"update_objects\":[]}}','0.1.0','1e1ecd6ea097fcd8367d42250736b83345a43d49cf1b8ba173703bebe54f69ec','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z');
/*!40000 ALTER TABLE `entrypoint_definitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fee_ledger`
--

DROP TABLE IF EXISTS `fee_ledger`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fee_ledger` (
  `workspace_id` varchar(191) NOT NULL,
  `id` varchar(191) NOT NULL,
  `created_at` text NOT NULL,
  `updated_at` text NOT NULL,
  `amount` decimal(19,2) DEFAULT NULL,
  `calculation_trace` text,
  `input_snapshot` text,
  `kind` varchar(191) DEFAULT NULL,
  `lineage_key` varchar(191) DEFAULT NULL,
  `occurred_at` varchar(191) DEFAULT NULL,
  `policy_snapshot` text,
  `service_request_id` varchar(191) DEFAULT NULL,
  `warranty_waiver_id` varchar(191) DEFAULT NULL,
  UNIQUE KEY `uidx_field_9e2c71fe75286187` (`workspace_id`,`id`),
  UNIQUE KEY `uidx_field_3abdb10697618f6f` (`workspace_id`,`lineage_key`),
  KEY `idx_field_2f38162e8b817b22` (`kind`),
  KEY `idx_field_a1349cb4ee426115` (`occurred_at`),
  KEY `idx_field_823e28d374c6f500` (`service_request_id`),
  KEY `idx_field_078ac658a64c0ae0` (`warranty_waiver_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fee_ledger`
--

LOCK TABLES `fee_ledger` WRITE;
/*!40000 ALTER TABLE `fee_ledger` DISABLE KEYS */;
INSERT INTO `fee_ledger` VALUES ('default','fee_ledger_ledger_qin_charge','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z',800.00,'Persisted quoted fee','quote_amount=CNY 800.00','charge','request_qin_completed_direct:charge','2026-08-15T03:00:00Z','Completion quote ledger v1','service_request_request_qin_completed_direct',NULL),('default','fee_ledger_ledger_qin_waiver','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z',300.00,'final=CNY 800.00-CNY 300.00=CNY 500.00','quote=CNY 800.00; requested=CNY 300.00','waiver','waiver_qin_direct:applied','2026-08-15T03:05:00Z','Direct waiver threshold CNY 500.00','service_request_request_qin_completed_direct','warranty_waiver_waiver_qin_direct');
/*!40000 ALTER TABLE `fee_ledger` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `field_definitions`
--

DROP TABLE IF EXISTS `field_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `field_definitions` (
  `id` varchar(191) NOT NULL,
  `resource_key` varchar(191) NOT NULL,
  `object_key` varchar(191) NOT NULL,
  `name` text NOT NULL,
  `payload_json` longtext NOT NULL,
  `schema_version` varchar(191) NOT NULL,
  `schema_hash` varchar(191) NOT NULL,
  `source_kind` varchar(191) NOT NULL,
  `source_id` varchar(191) NOT NULL,
  `disabled_at` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `resource_key` (`resource_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `field_definitions`
--

LOCK TABLES `field_definitions` WRITE;
/*!40000 ALTER TABLE `field_definitions` DISABLE KEYS */;
INSERT INTO `field_definitions` VALUES ('field:customer_profile.display_name','customer_profile.display_name','customer_profile','Display name','{\"key\":\"display_name\",\"name\":\"Display name\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"customer_profile\",\"indexed\":true},\"validation\":{},\"required\":true}','0.1.0','7b3469b43023126b1d016de417ce35c3dc069311bb9beea824281ef5812e56cc','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:customer_profile.identity_user_id','customer_profile.identity_user_id','customer_profile','Identity user','{\"key\":\"identity_user_id\",\"name\":\"Identity user\",\"type\":\"relation\",\"config\":{\"_definition_object_key\":\"customer_profile\",\"object_key\":\"identity_user\",\"target\":\"identity_user\"},\"validation\":{\"target\":\"identity_user\"},\"required\":false,\"unique\":true}','0.1.0','5e98691b5eae2bf77d63386b26e94f556117f518610f33d6257c3a19df440204','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:customer_profile.status','customer_profile.status','customer_profile','Status','{\"key\":\"status\",\"name\":\"Status\",\"type\":\"select\",\"config\":{\"_definition_object_key\":\"customer_profile\",\"indexed\":true},\"validation\":{},\"options\":[{\"label\":\"Active\",\"value\":\"active\"},{\"label\":\"Inactive\",\"value\":\"inactive\"}],\"required\":true}','0.1.0','e52f93b6f31cc99f20de20b7a6719015611874c83842af3f375f796ed19af2f9','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:device.customer_profile_id','device.customer_profile_id','device','Customer','{\"key\":\"customer_profile_id\",\"name\":\"Customer\",\"type\":\"relation\",\"config\":{\"_definition_object_key\":\"device\",\"indexed\":true,\"object_key\":\"customer_profile\",\"target\":\"customer_profile\"},\"validation\":{\"target\":\"customer_profile\"},\"required\":true}','0.1.0','6adde0fce4e852ffc0bb9b3e058072be687b8461799bb8ae1d987eaa0e0b2bce','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:device.name','device.name','device','Name','{\"key\":\"name\",\"name\":\"Name\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"device\",\"indexed\":true},\"validation\":{},\"required\":true}','0.1.0','032e5e3975963cb6fd5d478f18a16ac71aabe4f9f9c3447858f8653155739396','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:device.purchase_date','device.purchase_date','device','Purchase date','{\"key\":\"purchase_date\",\"name\":\"Purchase date\",\"type\":\"date\",\"config\":{\"_definition_object_key\":\"device\"},\"validation\":{},\"required\":true}','0.1.0','5cc3698f2018fb467c89b6b06d31c10f1645d63bb6161181bfbdc2d0f3a57e9f','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:device.serial_number','device.serial_number','device','Serial number','{\"key\":\"serial_number\",\"name\":\"Serial number\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"device\",\"indexed\":true},\"validation\":{},\"required\":true,\"unique\":true}','0.1.0','8f171e612d56ea49d78a58d842667dafaa161a70de329009f6e9de6f605f5d66','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:fee_ledger.amount','fee_ledger.amount','fee_ledger','Amount','{\"key\":\"amount\",\"name\":\"Amount\",\"type\":\"currency\",\"config\":{\"_definition_object_key\":\"fee_ledger\",\"currency_code\":\"CNY\",\"precision\":19,\"rounding_mode\":\"half_even\",\"scale\":2},\"validation\":{},\"required\":true}','0.1.0','c65413eeddc5e80ecf5fd85114f1d18a1e9cd81f86e5c38e8260d3da6d23e0e9','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:fee_ledger.calculation_trace','fee_ledger.calculation_trace','fee_ledger','Calculation trace','{\"key\":\"calculation_trace\",\"name\":\"Calculation trace\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"fee_ledger\"},\"validation\":{},\"required\":true}','0.1.0','c7abd7759934f1d4932ae2df67c9a95b159bebc644b6c1d0f00e8089689d60a7','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:fee_ledger.input_snapshot','fee_ledger.input_snapshot','fee_ledger','Input snapshot','{\"key\":\"input_snapshot\",\"name\":\"Input snapshot\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"fee_ledger\"},\"validation\":{},\"required\":true}','0.1.0','85862dbba1d1117b8728aed770124e0e566523c95ba3b89055d208c1abbfde18','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:fee_ledger.kind','fee_ledger.kind','fee_ledger','Entry kind','{\"key\":\"kind\",\"name\":\"Entry kind\",\"type\":\"select\",\"config\":{\"_definition_object_key\":\"fee_ledger\",\"indexed\":true},\"validation\":{},\"options\":[{\"label\":\"Charge\",\"value\":\"charge\"},{\"label\":\"Waiver\",\"value\":\"waiver\"},{\"label\":\"Reversal\",\"value\":\"reversal\"},{\"label\":\"Adjustment\",\"value\":\"adjustment\"}],\"required\":true}','0.1.0','55d97621710a019ca2df95063a448203e9daa6e923318163b197d07a97b4da85','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:fee_ledger.lineage_key','fee_ledger.lineage_key','fee_ledger','Lineage key','{\"key\":\"lineage_key\",\"name\":\"Lineage key\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"fee_ledger\",\"indexed\":true},\"validation\":{},\"required\":true,\"unique\":true}','0.1.0','7430b8ef4f24fe45bd1e90467faaf29962e5f1ed695a040273924c6912a7262f','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:fee_ledger.occurred_at','fee_ledger.occurred_at','fee_ledger','Occurred at','{\"key\":\"occurred_at\",\"name\":\"Occurred at\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"fee_ledger\",\"indexed\":true},\"validation\":{},\"required\":true}','0.1.0','10885d4819b991ee9619cb6e8cb73fbc968e3f679cc5ec97205666c082933ff3','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:fee_ledger.policy_snapshot','fee_ledger.policy_snapshot','fee_ledger','Policy snapshot','{\"key\":\"policy_snapshot\",\"name\":\"Policy snapshot\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"fee_ledger\"},\"validation\":{},\"required\":true}','0.1.0','0ca1d74530161d15c52ad1150b4faffd9a136d2d975bb741110aec7098723ec2','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:fee_ledger.service_request_id','fee_ledger.service_request_id','fee_ledger','Service request','{\"key\":\"service_request_id\",\"name\":\"Service request\",\"type\":\"relation\",\"config\":{\"_definition_object_key\":\"fee_ledger\",\"indexed\":true,\"object_key\":\"service_request\",\"target\":\"service_request\"},\"validation\":{\"target\":\"service_request\"},\"required\":true}','0.1.0','ffe79c055232c8fd4351e1f015354685242d15cc534a3257a14dcc4aab79d1f6','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:fee_ledger.warranty_waiver_id','fee_ledger.warranty_waiver_id','fee_ledger','Warranty waiver','{\"key\":\"warranty_waiver_id\",\"name\":\"Warranty waiver\",\"type\":\"relation\",\"config\":{\"_definition_object_key\":\"fee_ledger\",\"indexed\":true,\"object_key\":\"warranty_waiver\",\"target\":\"warranty_waiver\"},\"validation\":{\"target\":\"warranty_waiver\"},\"required\":false}','0.1.0','034006fcc9d2ba806521102a0e1bd03ba9ba281881a0ba8c0ab446ac41e4974e','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_dead_letter.failed_at','job_dead_letter.failed_at','job_dead_letter','Failed At','{\"key\":\"failed_at\",\"name\":\"Failed At\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"job_dead_letter\"},\"validation\":{},\"required\":true}','0.1.0','533c211c80431b32eb73d704dd2cbcae216385304806aeac049afa630b28cdbe','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_dead_letter.job_run_id','job_dead_letter.job_run_id','job_dead_letter','Job Run','{\"key\":\"job_run_id\",\"name\":\"Job Run\",\"type\":\"relation\",\"config\":{\"_definition_object_key\":\"job_dead_letter\"},\"validation\":{\"target\":\"job_run\"},\"required\":true}','0.1.0','ba73ac27afb961f39d3edf16cc3ba3dcc7e14dabcc9183bc5a899927c913674d','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_dead_letter.last_error','job_dead_letter.last_error','job_dead_letter','Last Error','{\"key\":\"last_error\",\"name\":\"Last Error\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"job_dead_letter\"},\"validation\":{},\"required\":false}','0.1.0','b7605e9dd82a0bff4f5580b8854d0c261946a885d566ab3c8a8326ada3eb09da','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_dead_letter.reason','job_dead_letter.reason','job_dead_letter','Reason','{\"key\":\"reason\",\"name\":\"Reason\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"job_dead_letter\"},\"validation\":{},\"required\":true}','0.1.0','0fc155458eda270e1aa914b196b8bee660fa8a87c6251b8505b3499e587eeeae','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_dead_letter.resolution_idempotency_key','job_dead_letter.resolution_idempotency_key','job_dead_letter','Resolution Idempotency Key','{\"key\":\"resolution_idempotency_key\",\"name\":\"Resolution Idempotency Key\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"job_dead_letter\"},\"validation\":{},\"required\":false}','0.1.0','fbb5219fdd943347dd8b4d26dd978ec65ff7ef6e5df3145edde73b2d89a50be4','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_dead_letter.resolution_note','job_dead_letter.resolution_note','job_dead_letter','Resolution Note','{\"key\":\"resolution_note\",\"name\":\"Resolution Note\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"job_dead_letter\"},\"validation\":{},\"required\":false}','0.1.0','671b386f4b079b477f9b7e2a40bde86fe5fb572d48e794153fde751bdce7aefe','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_dead_letter.resolved_at','job_dead_letter.resolved_at','job_dead_letter','Resolved At','{\"key\":\"resolved_at\",\"name\":\"Resolved At\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"job_dead_letter\"},\"validation\":{},\"required\":false}','0.1.0','22856093a7c990fe699e32fbd214c2081f482b0ba2346dcabacb8a4a80445d09','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_dead_letter.resolved_by','job_dead_letter.resolved_by','job_dead_letter','Resolved By','{\"key\":\"resolved_by\",\"name\":\"Resolved By\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"job_dead_letter\"},\"validation\":{},\"required\":false}','0.1.0','d2e9f60b53363d7820f7ec80423c9f22cfdd1760c2613db7083c2f6835712b48','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_dead_letter.scheduler_definition_key','job_dead_letter.scheduler_definition_key','job_dead_letter','Scheduler Definition Key','{\"key\":\"scheduler_definition_key\",\"name\":\"Scheduler Definition Key\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"job_dead_letter\"},\"validation\":{},\"required\":true}','0.1.0','f72c3c484f6a6ecd8ab06e1898c2c47bd8db6ebc6319127eeaa18968a1512997','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_dead_letter.status','job_dead_letter.status','job_dead_letter','Status','{\"key\":\"status\",\"name\":\"Status\",\"type\":\"select\",\"config\":{\"_definition_object_key\":\"job_dead_letter\"},\"validation\":{\"options\":[\"open\",\"retrying\",\"resolved\",\"ignored\"]},\"required\":true}','0.1.0','2a91d59e7f20a63a177ecf7276eb0a40f48ddf0bbdafe123f9356e41a2f272c6','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run_event.created_at','job_run_event.created_at','job_run_event','Created At','{\"key\":\"created_at\",\"name\":\"Created At\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"job_run_event\"},\"validation\":{},\"required\":true}','0.1.0','0c01c85e6a783865d847099c7dccafdafb0b7f4abc869a230a7acccacd0cf18a','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run_event.event_type','job_run_event.event_type','job_run_event','Event Type','{\"key\":\"event_type\",\"name\":\"Event Type\",\"type\":\"select\",\"config\":{\"_definition_object_key\":\"job_run_event\"},\"validation\":{\"options\":[\"created\",\"lease_acquired\",\"definition_cursor_advanced\",\"state_changed\",\"simulated\",\"workflow_triggered\",\"action_triggered\",\"report_query_run_created\",\"report_export_audit_created\",\"download_task_created\",\"retry_scheduled\",\"dead_lettered\",\"dead_letter_resolved\",\"cancelled\"]},\"required\":true}','0.1.0','48149bc6ba4321dd95c14f1112055208bf5c5faabcb78588c27d024a9ab48044','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run_event.job_run_id','job_run_event.job_run_id','job_run_event','Job Run','{\"key\":\"job_run_id\",\"name\":\"Job Run\",\"type\":\"relation\",\"config\":{\"_definition_object_key\":\"job_run_event\"},\"validation\":{\"target\":\"job_run\"},\"required\":true}','0.1.0','48602d82b8587c996e56c6ef1cd6375fd4887c4d2e5c8d7c668db2a4a4b0c106','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run_event.message','job_run_event.message','job_run_event','Message','{\"key\":\"message\",\"name\":\"Message\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"job_run_event\"},\"validation\":{},\"required\":false}','0.1.0','1f7197220820ddcfd167d71536a72063fb630b265eda131c3e215f8b86c2a04a','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run_event.metadata_json','job_run_event.metadata_json','job_run_event','Metadata JSON','{\"key\":\"metadata_json\",\"name\":\"Metadata JSON\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"job_run_event\"},\"validation\":{},\"required\":false}','0.1.0','6e5e7ee84a02e035c027f5e34fadfd741ba3b794f7c3ac143e57e9c909252d88','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run.attempt','job_run.attempt','job_run','Attempt','{\"key\":\"attempt\",\"name\":\"Attempt\",\"type\":\"number\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":true}','0.1.0','e1baa994127f6dd506be9c8a9b8d4c4783c04f7f8037f1746a4332c7262a3727','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run.error_category','job_run.error_category','job_run','Error Category','{\"key\":\"error_category\",\"name\":\"Error Category\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','0.1.0','e0b8dd1d51425694c70f9bdbc7cebb279f9f9fa84de6707991440d79a641b087','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run.error_message','job_run.error_message','job_run','Error Message','{\"key\":\"error_message\",\"name\":\"Error Message\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','0.1.0','5d04ed0b00a29b4d6424b462dbf5653889e639154931d39ecca48726c9ec7ab3','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run.fencing_token','job_run.fencing_token','job_run','Fencing Token','{\"key\":\"fencing_token\",\"name\":\"Fencing Token\",\"type\":\"number\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','0.1.0','1300f2f29e218e49f14381c13ee137ff062d45606ee6a577a327903929e08a33','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run.finished_at','job_run.finished_at','job_run','Finished At','{\"key\":\"finished_at\",\"name\":\"Finished At\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','0.1.0','d684cb3f7453d9a6cfd7c492fe0e317ae54a5ede7c7b05334e09611c6339b49b','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run.idempotency_key','job_run.idempotency_key','job_run','Idempotency Key','{\"key\":\"idempotency_key\",\"name\":\"Idempotency Key\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','0.1.0','7635107e21facb0daec32d48bae7ac7a510612ad3295f12001a4b6c297c7ced0','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run.idempotency_scope','job_run.idempotency_scope','job_run','Idempotency Scope','{\"key\":\"idempotency_scope\",\"name\":\"Idempotency Scope\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','0.1.0','ff16b81bb06e972cc47c4daf5c70787591971bf07525291a658a781301490681','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run.last_command_key','job_run.last_command_key','job_run','Last Command Key','{\"key\":\"last_command_key\",\"name\":\"Last Command Key\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','0.1.0','64f8f9a1b246dc66ad127e041f6a762768c19927f1896e8c1faf615b1b6e392f','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run.last_command_scope','job_run.last_command_scope','job_run','Last Command Scope','{\"key\":\"last_command_scope\",\"name\":\"Last Command Scope\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','0.1.0','329f2208e6da7d0ba06760e1661155faa4047058f86627ae4b842d2a14279da4','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run.lease_expires_at','job_run.lease_expires_at','job_run','Lease Expires At','{\"key\":\"lease_expires_at\",\"name\":\"Lease Expires At\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','0.1.0','a3b31ee3c15cb479639667c3352b2d259e87d7ad98e6f7a22dbb11cd3c34103c','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run.lease_owner','job_run.lease_owner','job_run','Lease Owner','{\"key\":\"lease_owner\",\"name\":\"Lease Owner\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','0.1.0','a55c687793469c72a04853891486d2514f002fac3234812f9aa9ae9739274846','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run.max_attempts','job_run.max_attempts','job_run','Max Attempts','{\"key\":\"max_attempts\",\"name\":\"Max Attempts\",\"type\":\"number\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":true}','0.1.0','b85f419a839b8268d831309b3b49bb45bd981d76d35e9fc4dc36f6a0c523c3b2','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run.next_retry_at','job_run.next_retry_at','job_run','Next Retry At','{\"key\":\"next_retry_at\",\"name\":\"Next Retry At\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','0.1.0','5b6652a772a819f0618a17c445a794ac755d1b4acda90308d472ee857adc728f','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run.payload_json','job_run.payload_json','job_run','Payload JSON','{\"key\":\"payload_json\",\"name\":\"Payload JSON\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','0.1.0','f9a7e0bbe9c68c80bfce0d5b0121d085166de3d617e530355a0387989ea434e4','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run.recoverability','job_run.recoverability','job_run','Recoverability','{\"key\":\"recoverability\",\"name\":\"Recoverability\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','0.1.0','23de1460dbcd8c21309937dc23742b554e81c12616ed1783b15e38fdb0892b82','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run.result_json','job_run.result_json','job_run','Result JSON','{\"key\":\"result_json\",\"name\":\"Result JSON\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','0.1.0','f125034d83157952313069ba86fb8d786b1d7f8239fba4a395213591f69f5242','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run.retry_backoff','job_run.retry_backoff','job_run','Retry Backoff','{\"key\":\"retry_backoff\",\"name\":\"Retry Backoff\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','0.1.0','8076580110d09275a6dec2297776054270246c5be61cd20b1f42ca54dfe95713','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run.retry_backoff_seconds','job_run.retry_backoff_seconds','job_run','Retry Backoff Seconds','{\"key\":\"retry_backoff_seconds\",\"name\":\"Retry Backoff Seconds\",\"type\":\"number\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','0.1.0','1d7128177c96363b74275bbebfde71a6d6bf12af5ef378b8fb56f803840a5bf1','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run.retry_delay_seconds','job_run.retry_delay_seconds','job_run','Retry Delay Seconds','{\"key\":\"retry_delay_seconds\",\"name\":\"Retry Delay Seconds\",\"type\":\"number\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','0.1.0','12ba2625cf87bb8bdb354a8304fcb8dd0ceeae33a3e95b7e881998ab4b4bc8d2','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run.retry_max_delay_seconds','job_run.retry_max_delay_seconds','job_run','Max Retry Delay Seconds','{\"key\":\"retry_max_delay_seconds\",\"name\":\"Max Retry Delay Seconds\",\"type\":\"number\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','0.1.0','9be8761a5c54df3057ece2defd0d5a0e975520e4f6cf493bfc42dd45d17b42a8','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run.scheduled_for','job_run.scheduled_for','job_run','Scheduled For','{\"key\":\"scheduled_for\",\"name\":\"Scheduled For\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":true}','0.1.0','04da55d41d8f24e81baca3158adeb3abebaf7eec9a0046502eb4c71bba462ab9','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run.scheduler_definition_key','job_run.scheduler_definition_key','job_run','Scheduler Definition Key','{\"key\":\"scheduler_definition_key\",\"name\":\"Scheduler Definition Key\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":true}','0.1.0','55ec4a6781fc727a85576d6440e9971a2dbc7b355aa4063d9365e77d7840e9f8','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run.started_at','job_run.started_at','job_run','Started At','{\"key\":\"started_at\",\"name\":\"Started At\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','0.1.0','a3832805526ef6b44ec1d11d17add54fa0e6acdbe086ff3fda983f46d61fd7e5','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run.status','job_run.status','job_run','Status','{\"key\":\"status\",\"name\":\"Status\",\"type\":\"select\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{\"options\":[\"queued\",\"leased\",\"running\",\"succeeded\",\"failed\",\"retrying\",\"cancelled\",\"dead_letter\"]},\"required\":true}','0.1.0','e6a94e396921eab3b01b25798ea078c74ae5f79cc5e1e4518ffe9dbddf919e7b','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run.target_object','job_run.target_object','job_run','Target Object','{\"key\":\"target_object\",\"name\":\"Target Object\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','0.1.0','9a95e2caaa2bfb6752af08c63726f70213d8f437c2b92abaca866308f8e6cfad','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run.target_record_id','job_run.target_record_id','job_run','Target Record ID','{\"key\":\"target_record_id\",\"name\":\"Target Record ID\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','0.1.0','24b29441b7dc78230ade570eb7d218f073a67225189d70a9087a504280251f96','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run.timeout_seconds','job_run.timeout_seconds','job_run','Timeout Seconds','{\"key\":\"timeout_seconds\",\"name\":\"Timeout Seconds\",\"type\":\"number\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','0.1.0','0e9cb26f99f52153b9233d62965b73e49a18c1869d7a89acc4deee98d38c5031','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run.triggered_by','job_run.triggered_by','job_run','Triggered By','{\"key\":\"triggered_by\",\"name\":\"Triggered By\",\"type\":\"select\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{\"options\":[\"scheduler\",\"manual\",\"api\",\"workflow\",\"retry\"]},\"required\":true}','0.1.0','9316b34bbd8f0e97b41102dd8f28bef728f97738e157f5b65c28187463bd7198','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run.workflow_execution_id','job_run.workflow_execution_id','job_run','Workflow Execution ID','{\"key\":\"workflow_execution_id\",\"name\":\"Workflow Execution ID\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','0.1.0','4321bf7a7f9d4eb65005d0a39b860603f59e78422f0fc72905b6f993b7798b26','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:job_run.workflow_key','job_run.workflow_key','job_run','Workflow Key','{\"key\":\"workflow_key\",\"name\":\"Workflow Key\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','0.1.0','403fc1c3dd3c703eccdbce472aa1e16ce75a68847d4ad5bf32fdd711b8888be2','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:overdue_reminder.business_date','overdue_reminder.business_date','overdue_reminder','Business date','{\"key\":\"business_date\",\"name\":\"Business date\",\"type\":\"date\",\"config\":{\"_definition_object_key\":\"overdue_reminder\",\"indexed\":true},\"validation\":{},\"required\":true}','0.1.0','e9391ad69e9b36ddbb36865ad8012c8719613bbeadc1aa587757c92750a584ba','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:overdue_reminder.dedupe_key','overdue_reminder.dedupe_key','overdue_reminder','Dedupe key','{\"key\":\"dedupe_key\",\"name\":\"Dedupe key\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"overdue_reminder\",\"indexed\":true},\"validation\":{},\"required\":true,\"unique\":true}','0.1.0','055c4dfcb854546e54acbc17f3214d512dada0932a80d0735bd07427d1529f78','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:overdue_reminder.owner_department_id','overdue_reminder.owner_department_id','overdue_reminder','Owner department ID','{\"key\":\"owner_department_id\",\"name\":\"Owner department ID\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"overdue_reminder\",\"indexed\":true},\"validation\":{},\"required\":false}','0.1.0','913e75f285a8958d61667ecbab6ed2b72e5fc67722245bef849ea9b873b7ccc6','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:overdue_reminder.owner_department_path','overdue_reminder.owner_department_path','overdue_reminder','Owner department path','{\"key\":\"owner_department_path\",\"name\":\"Owner department path\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"overdue_reminder\",\"indexed\":true},\"validation\":{},\"required\":false}','0.1.0','88fcf7b37a576a6b6b29d65275e696d88b2320c7e687f9fa823f57a6bb010c61','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:overdue_reminder.recipient_user_id','overdue_reminder.recipient_user_id','overdue_reminder','Recipient','{\"key\":\"recipient_user_id\",\"name\":\"Recipient\",\"type\":\"relation\",\"config\":{\"_definition_object_key\":\"overdue_reminder\",\"object_key\":\"identity_user\",\"scope_owner\":true,\"target\":\"identity_user\"},\"validation\":{\"target\":\"identity_user\"},\"required\":false}','0.1.0','af332200d3eae1257b3b70c5e332dff54dcae84221919d0e2d27ea164cf7fa57','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:overdue_reminder.sent_at','overdue_reminder.sent_at','overdue_reminder','Sent at','{\"key\":\"sent_at\",\"name\":\"Sent at\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"overdue_reminder\"},\"validation\":{},\"required\":true}','0.1.0','aba1a457c5ba05530184866f16030c774fe83f189be2754136e81a16df785201','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:overdue_reminder.service_request_id','overdue_reminder.service_request_id','overdue_reminder','Service request','{\"key\":\"service_request_id\",\"name\":\"Service request\",\"type\":\"relation\",\"config\":{\"_definition_object_key\":\"overdue_reminder\",\"indexed\":true,\"object_key\":\"service_request\",\"target\":\"service_request\"},\"validation\":{\"target\":\"service_request\"},\"required\":true}','0.1.0','a78adaa0f921983fa644b8889dd4f36971780fe1e58c39622259396c432b3d98','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:part_usage.amount','part_usage.amount','part_usage','Usage amount','{\"key\":\"amount\",\"name\":\"Usage amount\",\"type\":\"currency\",\"config\":{\"_definition_object_key\":\"part_usage\",\"currency_code\":\"CNY\",\"precision\":19,\"rounding_mode\":\"half_even\",\"scale\":2},\"validation\":{},\"required\":true}','0.1.0','962606a84182ae22b43f332b3abfa592ff7671b96a5798bfd91a9b4431068ca4','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:part_usage.calculation_trace','part_usage.calculation_trace','part_usage','Calculation trace','{\"key\":\"calculation_trace\",\"name\":\"Calculation trace\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"part_usage\"},\"validation\":{},\"required\":true}','0.1.0','586ad0d3d264020dd8ede69d1e75f65785e64b8b4e04380c0e2831250e572fee','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:part_usage.occurred_at','part_usage.occurred_at','part_usage','Occurred at','{\"key\":\"occurred_at\",\"name\":\"Occurred at\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"part_usage\",\"indexed\":true},\"validation\":{},\"required\":true}','0.1.0','26b6717590152f2e0cb38d9fccd1f2cf91802c698cc6eb331e42d00eb75cd45c','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:part_usage.owner_department_id','part_usage.owner_department_id','part_usage','Owner department ID','{\"key\":\"owner_department_id\",\"name\":\"Owner department ID\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"part_usage\",\"indexed\":true},\"validation\":{},\"required\":false}','0.1.0','e40fcd50e3e9f27de8643ec849a3c0cc23e6c68032266d858f2d6d027665da15','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:part_usage.owner_department_path','part_usage.owner_department_path','part_usage','Owner department path','{\"key\":\"owner_department_path\",\"name\":\"Owner department path\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"part_usage\",\"indexed\":true},\"validation\":{},\"required\":false}','0.1.0','009ddd6926e4a072470f3cac8d720c72f80b5eb49839944fd38fd3560ff775fd','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:part_usage.performed_by_user_id','part_usage.performed_by_user_id','part_usage','Performed by','{\"key\":\"performed_by_user_id\",\"name\":\"Performed by\",\"type\":\"user\",\"config\":{\"_definition_object_key\":\"part_usage\",\"auto_assign_current_user\":true,\"scope_owner\":true},\"validation\":{},\"required\":false}','0.1.0','aa1b7c739f67df872866b721fc903a28dda3897734dba240d92298f9daf97108','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:part_usage.quantity','part_usage.quantity','part_usage','Quantity','{\"key\":\"quantity\",\"name\":\"Quantity\",\"type\":\"integer\",\"config\":{\"_definition_object_key\":\"part_usage\"},\"validation\":{},\"required\":true}','0.1.0','20d2e56d465c7560d6c45cc07ef25899d20204645560e4dd14f173c9d658d026','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:part_usage.service_request_id','part_usage.service_request_id','part_usage','Service request','{\"key\":\"service_request_id\",\"name\":\"Service request\",\"type\":\"relation\",\"config\":{\"_definition_object_key\":\"part_usage\",\"indexed\":true,\"object_key\":\"service_request\",\"target\":\"service_request\"},\"validation\":{\"target\":\"service_request\"},\"required\":true}','0.1.0','60edee7eef53799d1ec0867f89934b7ab9eae9ed9e58a90b14afb334c8f84e7c','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:part_usage.spare_part_id','part_usage.spare_part_id','part_usage','Spare part','{\"key\":\"spare_part_id\",\"name\":\"Spare part\",\"type\":\"relation\",\"config\":{\"_definition_object_key\":\"part_usage\",\"indexed\":true,\"object_key\":\"spare_part\",\"target\":\"spare_part\"},\"validation\":{\"target\":\"spare_part\"},\"required\":true}','0.1.0','7ae52386d38d6eda6b6f24c38321fb2d730e5d4535085519654803a961f8e270','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:part_usage.unit_price_snapshot','part_usage.unit_price_snapshot','part_usage','Unit price snapshot','{\"key\":\"unit_price_snapshot\",\"name\":\"Unit price snapshot\",\"type\":\"currency\",\"config\":{\"_definition_object_key\":\"part_usage\",\"currency_code\":\"CNY\",\"precision\":19,\"rounding_mode\":\"half_even\",\"scale\":2},\"validation\":{},\"required\":true}','0.1.0','84166fd7a02e46b44723551b0d126fe6c6da1930548e2998944930ee3eecae29','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:record_timer.attempt','record_timer.attempt','record_timer','Attempt','{\"key\":\"attempt\",\"name\":\"Attempt\",\"type\":\"number\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":true}','0.1.0','3a976ea32daf117389f780dd4fbbf54bd9fda1775fa4fb1d313f77a4fd33b8cc','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:record_timer.business_calendar_key','record_timer.business_calendar_key','record_timer','Business Calendar Key','{\"key\":\"business_calendar_key\",\"name\":\"Business Calendar Key\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":false}','0.1.0','0afebd6a8d1efb190d4faeb2a6f30e82af9ccb7ee55b203719a56a0dc3b08154','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:record_timer.cancelled_at','record_timer.cancelled_at','record_timer','Cancelled At','{\"key\":\"cancelled_at\",\"name\":\"Cancelled At\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":false}','0.1.0','a921b8714d36ce8076bd7fd43907b4fb8f0530cc7a67722ad5c7bb9ce7933d93','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:record_timer.due_at','record_timer.due_at','record_timer','Due At','{\"key\":\"due_at\",\"name\":\"Due At\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"record_timer\",\"indexed\":true},\"validation\":{},\"required\":true}','0.1.0','36dbfcd092f5cadfff1d8ea2d90e180503fa372c008b9669f40bcbf72feec240','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:record_timer.failed_at','record_timer.failed_at','record_timer','Failed At','{\"key\":\"failed_at\",\"name\":\"Failed At\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":false}','0.1.0','dc2d0d1d872a11c3e6b6cce127618e8188418b548f65507da8255faecfea0043','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:record_timer.fencing_token','record_timer.fencing_token','record_timer','Fencing Token','{\"key\":\"fencing_token\",\"name\":\"Fencing Token\",\"type\":\"number\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":true}','0.1.0','88fff3f7ee1d2343138589797c658e2449aa4c6b67ffa95edbaa241357ae3d8a','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:record_timer.fired_at','record_timer.fired_at','record_timer','Fired At','{\"key\":\"fired_at\",\"name\":\"Fired At\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":false}','0.1.0','b08b5b5a71cbf22179832eb8e7556f030780f354f112dd40e30254d24925165a','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:record_timer.last_error','record_timer.last_error','record_timer','Last Error','{\"key\":\"last_error\",\"name\":\"Last Error\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":false}','0.1.0','0012e68896d47a3b00f9d0059a14c24add5085a3d1c631c6fd7e427834303678','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:record_timer.lease_expires_at','record_timer.lease_expires_at','record_timer','Lease Expires At','{\"key\":\"lease_expires_at\",\"name\":\"Lease Expires At\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":false}','0.1.0','2691896e8e158be8809178b7539cff6a8549ed9727c3783c74be106f3ba7d4c3','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:record_timer.lease_owner','record_timer.lease_owner','record_timer','Lease Owner','{\"key\":\"lease_owner\",\"name\":\"Lease Owner\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":false}','0.1.0','b0c46c87fd82da748d6b52ff0a5ab72694e3f247a96b9295c7dd7cafce963840','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:record_timer.max_attempts','record_timer.max_attempts','record_timer','Max Attempts','{\"key\":\"max_attempts\",\"name\":\"Max Attempts\",\"type\":\"number\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":true}','0.1.0','12adfd0c74ff318305e541c0ca49626b775c8795af671f21e5e18fda5f40434a','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:record_timer.object_key','record_timer.object_key','record_timer','Object Key','{\"key\":\"object_key\",\"name\":\"Object Key\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"record_timer\",\"indexed\":true,\"max_length\":128},\"validation\":{},\"required\":true}','0.1.0','b7502a90d51b51a40e19269a70c8dfffeadaecd76f023879b1534c03231293c3','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:record_timer.offset_seconds','record_timer.offset_seconds','record_timer','Offset Seconds','{\"key\":\"offset_seconds\",\"name\":\"Offset Seconds\",\"type\":\"number\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":false}','0.1.0','48cf7e8df977741ad70dee6c9da5ab5ad85038c71962f71f612c198335e3cb43','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:record_timer.payload_json','record_timer.payload_json','record_timer','Payload JSON','{\"key\":\"payload_json\",\"name\":\"Payload JSON\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":false}','0.1.0','99bbfae13d245f2f5d414ac37ac900a8cf110586e38e08a70b6cdd7f1927fa31','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:record_timer.priority','record_timer.priority','record_timer','Priority','{\"key\":\"priority\",\"name\":\"Priority\",\"type\":\"number\",\"config\":{\"_definition_object_key\":\"record_timer\",\"indexed\":true},\"validation\":{},\"required\":true}','0.1.0','e947132e87424b020aab03eb9008e1676243ae831c3c08fd7d28fea8ae5f8462','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:record_timer.purpose','record_timer.purpose','record_timer','Purpose','{\"key\":\"purpose\",\"name\":\"Purpose\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"record_timer\",\"max_length\":128},\"validation\":{},\"required\":true}','0.1.0','7b4c6429c4f55a80abf00eaf475d50ebb6c544e2fc33d4b5d9a0fa6e13837536','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:record_timer.record_id','record_timer.record_id','record_timer','Record ID','{\"key\":\"record_id\",\"name\":\"Record ID\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"record_timer\",\"indexed\":true,\"max_length\":128},\"validation\":{},\"required\":true}','0.1.0','9f231649d01851288597dbe7049a661e935d79920afdca7fe76a7eb983fe074f','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:record_timer.retry_delay_seconds','record_timer.retry_delay_seconds','record_timer','Retry Delay Seconds','{\"key\":\"retry_delay_seconds\",\"name\":\"Retry Delay Seconds\",\"type\":\"number\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":true}','0.1.0','49e5380f03c23e6694db9bd27e02bbdfa3917db068c8b26ebd02e0bfb8d9239a','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:record_timer.retry_max_delay_seconds','record_timer.retry_max_delay_seconds','record_timer','Retry Max Delay Seconds','{\"key\":\"retry_max_delay_seconds\",\"name\":\"Retry Max Delay Seconds\",\"type\":\"number\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":true}','0.1.0','af64c4b4921b09e78755ac41014617742de11d5582dc9ec9a0b4ee52f7649053','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:record_timer.schedule_mode','record_timer.schedule_mode','record_timer','Schedule Mode','{\"key\":\"schedule_mode\",\"name\":\"Schedule Mode\",\"type\":\"select\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{\"options\":[\"absolute\",\"relative_field\",\"business_calendar\"]},\"required\":true}','0.1.0','ea50e1a6939f2fdc653e375314aab188f30418316fcf506fad7d2a5c8ff6c2de','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:record_timer.sequence','record_timer.sequence','record_timer','Sequence','{\"key\":\"sequence\",\"name\":\"Sequence\",\"type\":\"number\",\"config\":{\"_definition_object_key\":\"record_timer\",\"indexed\":true},\"validation\":{},\"required\":true}','0.1.0','d1c09ae28c21f51429231a602e0e580f9813e160264f652fb9ad16f51148cc8c','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:record_timer.source_field','record_timer.source_field','record_timer','Source Field','{\"key\":\"source_field\",\"name\":\"Source Field\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":false}','0.1.0','07b0368add24bed4219a9e7f998ed8f14e07c245ef17ff4a30166799a42972db','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:record_timer.status','record_timer.status','record_timer','Status','{\"key\":\"status\",\"name\":\"Status\",\"type\":\"select\",\"config\":{\"_definition_object_key\":\"record_timer\",\"indexed\":true},\"validation\":{\"options\":[\"scheduled\",\"leased\",\"fired\",\"cancelled\",\"superseded\",\"failed\"]},\"required\":true}','0.1.0','4be5f313402700d0e71189521596911084d1e632e5302ea7b9a34be7481fd510','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:record_timer.supersedes_timer_id','record_timer.supersedes_timer_id','record_timer','Supersedes Timer','{\"key\":\"supersedes_timer_id\",\"name\":\"Supersedes Timer\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":false}','0.1.0','d721a145701453b2dab3fe547cf9ea3e9767a03733f0708ecf05693ef2a306d5','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:record_timer.target_key','record_timer.target_key','record_timer','Target Key','{\"key\":\"target_key\",\"name\":\"Target Key\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":true}','0.1.0','bfc8ced3efc6c9eb93739ca994611df291ff1696e269beef5f929030cd56ce87','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:record_timer.target_type','record_timer.target_type','record_timer','Target Type','{\"key\":\"target_type\",\"name\":\"Target Type\",\"type\":\"select\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{\"options\":[\"action\",\"workflow\"]},\"required\":true}','0.1.0','34286dced554da8cd5921e55324e4c182c86945cc40631e34bb53c36faf0db5e','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:record_timer.timer_key','record_timer.timer_key','record_timer','Timer Key','{\"key\":\"timer_key\",\"name\":\"Timer Key\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"record_timer\",\"max_length\":128},\"validation\":{},\"required\":true}','0.1.0','080ce7fd69fbf529a82ae0a3545a17ef458acf455be6a152c0f5a6ff40b00224','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:record_timer.timezone','record_timer.timezone','record_timer','Timezone','{\"key\":\"timezone\",\"name\":\"Timezone\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":true}','0.1.0','faa3400081342cd5ef6985378a9060ffb851b3ffdfbcc9d1c0232b460dac896a','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:report_export_audit.owner_department_id','report_export_audit.owner_department_id','report_export_audit','Owner department ID','{\"key\":\"owner_department_id\",\"name\":\"Owner department ID\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"report_export_audit\",\"indexed\":true},\"validation\":{},\"required\":false}','0.1.0','0ae728cd5b31138c7d6165d8a3ec4d32e768633c6bbf2c981d0149fe200bbf2f','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:report_export_audit.owner_department_path','report_export_audit.owner_department_path','report_export_audit','Owner department path','{\"key\":\"owner_department_path\",\"name\":\"Owner department path\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"report_export_audit\",\"indexed\":true},\"validation\":{},\"required\":false}','0.1.0','fed8404a319a0466f09c5a38a059f41591dcffad29f468ff5dd0ae609761e99c','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:report_export_audit.purpose','report_export_audit.purpose','report_export_audit','Purpose','{\"key\":\"purpose\",\"name\":\"Purpose\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"report_export_audit\"},\"validation\":{},\"required\":true}','0.1.0','67e5a2152f442e908cf5454498938709e8959ea6ef22d972f78ca31620a49c14','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:report_export_audit.report_key','report_export_audit.report_key','report_export_audit','Report key','{\"key\":\"report_key\",\"name\":\"Report key\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"report_export_audit\",\"indexed\":true},\"validation\":{},\"required\":true}','0.1.0','9956ba1ffe44c9e84465b809e97ade52fff02e80b2eabd017208acfd145e4526','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:report_export_audit.requested_at','report_export_audit.requested_at','report_export_audit','Requested at','{\"key\":\"requested_at\",\"name\":\"Requested at\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"report_export_audit\",\"indexed\":true},\"validation\":{},\"required\":true}','0.1.0','28c6847c035d48fe2604894954d53d14f7dc778ff9f25bf8f9a102a277df0ab4','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:report_export_audit.requester_user_id','report_export_audit.requester_user_id','report_export_audit','Requester','{\"key\":\"requester_user_id\",\"name\":\"Requester\",\"type\":\"user\",\"config\":{\"_definition_object_key\":\"report_export_audit\",\"auto_assign_current_user\":true,\"scope_owner\":true},\"validation\":{},\"required\":false}','0.1.0','d693732cabfe490858c803f0a1b83bd173fb26d50916b4f75383f9e8cea757e8','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:report_export_audit.row_count','report_export_audit.row_count','report_export_audit','Row count','{\"key\":\"row_count\",\"name\":\"Row count\",\"type\":\"integer\",\"config\":{\"_definition_object_key\":\"report_export_audit\"},\"validation\":{},\"required\":false}','0.1.0','80544441c382e55bee7e88aa5b5e2c97fdb8de0e7210dd80ce2b6648accc9f48','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:report_export_audit.scope_hash','report_export_audit.scope_hash','report_export_audit','Scope hash','{\"key\":\"scope_hash\",\"name\":\"Scope hash\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"report_export_audit\"},\"validation\":{},\"required\":false}','0.1.0','de0b49d0e8df328b64c5d3b1625f824747cb1a311aaf8f920008c76d4fd7ea8d','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:report_export_audit.status','report_export_audit.status','report_export_audit','Status','{\"key\":\"status\",\"name\":\"Status\",\"type\":\"select\",\"config\":{\"_definition_object_key\":\"report_export_audit\",\"indexed\":true},\"validation\":{},\"options\":[{\"label\":\"Requested\",\"value\":\"requested\"},{\"label\":\"Prepared\",\"value\":\"prepared\"},{\"label\":\"Downloaded\",\"value\":\"downloaded\"},{\"label\":\"Denied\",\"value\":\"denied\"},{\"label\":\"Expired\",\"value\":\"expired\"}],\"required\":true}','0.1.0','72b85f0bbc4c6a9187c0a528b44827ecb1bb78ff66849b65e3296c7149cc2343','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:report_export_download.audit_id','report_export_download.audit_id','report_export_download','Audit request','{\"key\":\"audit_id\",\"name\":\"Audit request\",\"type\":\"relation\",\"config\":{\"_definition_object_key\":\"report_export_download\",\"indexed\":true,\"object_key\":\"report_export_audit\",\"target\":\"report_export_audit\"},\"validation\":{\"target\":\"report_export_audit\"},\"required\":true}','0.1.0','df85843d0489a743e797f413b50d6e9432100d7855cdf40c55d3c4ee77415ea6','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:report_export_download.content_hash','report_export_download.content_hash','report_export_download','Content hash','{\"key\":\"content_hash\",\"name\":\"Content hash\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"report_export_download\"},\"validation\":{},\"required\":true}','0.1.0','7423f18850a449a716b0a756280e5a28855a012433c10a68d59cdf2b7af34d48','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:report_export_download.expires_at','report_export_download.expires_at','report_export_download','Expires at','{\"key\":\"expires_at\",\"name\":\"Expires at\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"report_export_download\",\"indexed\":true},\"validation\":{},\"required\":true}','0.1.0','1d9f4bfa9b6c0bd55aa33d95c65dd81faaa2c98604a05bdd6d73a89da4a52c6f','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:report_export_download.filename','report_export_download.filename','report_export_download','Filename','{\"key\":\"filename\",\"name\":\"Filename\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"report_export_download\"},\"validation\":{},\"required\":true}','0.1.0','a0f32e86ee941af23f1c18a0b2a58fbe091e5e7ca7ce60f451af5417538343df','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:report_export_download.owner','report_export_download.owner','report_export_download','Owner','{\"key\":\"owner\",\"name\":\"Owner\",\"type\":\"user\",\"config\":{\"_definition_object_key\":\"report_export_download\",\"auto_assign_current_user\":true},\"validation\":{},\"required\":false}','0.1.0','50666b02bcdb1cb08eb73f95f90a4a6512854f96e441c317d73f290ec61fa650','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:scheduler_cursor.last_run_at','scheduler_cursor.last_run_at','scheduler_cursor','Last Run At','{\"key\":\"last_run_at\",\"name\":\"Last Run At\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"scheduler_cursor\"},\"validation\":{},\"required\":false}','0.1.0','ff86bcacc98b659fade71b2269090877f6363aa423df4407b2f02dbff0f4e487','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:scheduler_cursor.last_run_status','scheduler_cursor.last_run_status','scheduler_cursor','Last Run Status','{\"key\":\"last_run_status\",\"name\":\"Last Run Status\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"scheduler_cursor\"},\"validation\":{},\"required\":false}','0.1.0','90b348150a3f2a13166fb2b874220160cef7a83783053dbb2242ed197f2f6bc2','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:scheduler_cursor.next_run_at','scheduler_cursor.next_run_at','scheduler_cursor','Next Run At','{\"key\":\"next_run_at\",\"name\":\"Next Run At\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"scheduler_cursor\"},\"validation\":{},\"required\":false}','0.1.0','2fbe476eaabaefd26183a456d1c4de43af33e4cd42465a5f2d7ac5c8b3ad306b','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:scheduler_cursor.scheduler_definition_key','scheduler_cursor.scheduler_definition_key','scheduler_cursor','Scheduler Definition Key','{\"key\":\"scheduler_definition_key\",\"name\":\"Scheduler Definition Key\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"scheduler_cursor\"},\"validation\":{},\"required\":true}','0.1.0','914c3a0b8c4292737822bf5267bb2caa7a6d1f623f26633ec3f5463afebc5d43','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:service_request.assigned_user_id','service_request.assigned_user_id','service_request','Assigned technician','{\"key\":\"assigned_user_id\",\"name\":\"Assigned technician\",\"type\":\"relation\",\"config\":{\"_definition_object_key\":\"service_request\",\"object_key\":\"identity_user\",\"scope_owner\":true,\"target\":\"identity_user\"},\"validation\":{\"target\":\"identity_user\"},\"required\":false}','0.1.0','f3f8838c5f042e3eae48d5112dcc7e7eea2c48773fe8d421f51338361f32f437','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:service_request.completed_at','service_request.completed_at','service_request','Completed at','{\"key\":\"completed_at\",\"name\":\"Completed at\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"service_request\",\"indexed\":true},\"validation\":{},\"required\":false}','0.1.0','4849d361c1c7dc79921990c0e56fd05e62b5be72abe11e95c60cd27e7919f9a0','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:service_request.customer_profile_id','service_request.customer_profile_id','service_request','Customer','{\"key\":\"customer_profile_id\",\"name\":\"Customer\",\"type\":\"relation\",\"config\":{\"_definition_object_key\":\"service_request\",\"indexed\":true,\"object_key\":\"customer_profile\",\"target\":\"customer_profile\"},\"validation\":{\"target\":\"customer_profile\"},\"required\":true}','0.1.0','855c3914fe9cc82d8ba3b3645e421d0923f9ee8c390eaf16e89e4c7c17c52c1e','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:service_request.device_id','service_request.device_id','service_request','Device','{\"key\":\"device_id\",\"name\":\"Device\",\"type\":\"relation\",\"config\":{\"_definition_object_key\":\"service_request\",\"indexed\":true,\"object_key\":\"device\",\"target\":\"device\"},\"validation\":{\"target\":\"device\"},\"required\":true}','0.1.0','159206d11cf1d027ced968fcd3cd35c8d6d5c3e8fbebaaac5fb7f2f741d47bdf','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:service_request.dispatched_at','service_request.dispatched_at','service_request','Dispatched at','{\"key\":\"dispatched_at\",\"name\":\"Dispatched at\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"service_request\",\"indexed\":true},\"validation\":{},\"required\":false}','0.1.0','e14fdf994e65a3e7cf6504bbdf014baadd59383d3dd3b129cef5cbfe99dd67a8','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:service_request.fault_description','service_request.fault_description','service_request','Fault description','{\"key\":\"fault_description\",\"name\":\"Fault description\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"service_request\"},\"validation\":{},\"required\":true}','0.1.0','cf96d21b76f5451a882dbdc057f0ad06364050c19132a124dd4032e35b2d235d','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:service_request.organization_unit_id','service_request.organization_unit_id','service_request','Station','{\"key\":\"organization_unit_id\",\"name\":\"Station\",\"type\":\"relation\",\"config\":{\"_definition_object_key\":\"service_request\",\"object_key\":\"identity_organization_unit\",\"target\":\"identity_organization_unit\"},\"validation\":{\"target\":\"identity_organization_unit\"},\"required\":false}','0.1.0','3d3872f055a46c4fdaf3329c7db5083d8fe5b07bb7fcefa948f4e645f13c3798','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:service_request.owner_department_id','service_request.owner_department_id','service_request','Owner department ID','{\"key\":\"owner_department_id\",\"name\":\"Owner department ID\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"service_request\",\"indexed\":true},\"validation\":{},\"required\":false}','0.1.0','a17a32f1c1604126beb0bbe1175b019e25e960559d51e54e34bd440648cd4b37','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:service_request.owner_department_path','service_request.owner_department_path','service_request','Owner department path','{\"key\":\"owner_department_path\",\"name\":\"Owner department path\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"service_request\",\"indexed\":true},\"validation\":{},\"required\":false}','0.1.0','98b97f2569956ebc16d5da7c0a28003b26bf01ce265011995e0b7952b100d7a2','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:service_request.preferred_visit_at','service_request.preferred_visit_at','service_request','Preferred visit time','{\"key\":\"preferred_visit_at\",\"name\":\"Preferred visit time\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"service_request\",\"indexed\":true},\"validation\":{},\"required\":true}','0.1.0','4d71bec0d12631dc4f157d2d1c1e7eaca54fca342babd00d49cc98e9cc2d6a92','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:service_request.quote_amount','service_request.quote_amount','service_request','Quoted fee','{\"key\":\"quote_amount\",\"name\":\"Quoted fee\",\"type\":\"currency\",\"config\":{\"_definition_object_key\":\"service_request\",\"currency_code\":\"CNY\",\"precision\":19,\"rounding_mode\":\"half_even\",\"scale\":2},\"validation\":{},\"required\":false}','0.1.0','c2b35cf274b31c8382a19dfbca3d0eaca92902e39c662d88f600456f71396a0c','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:service_request.started_at','service_request.started_at','service_request','Repair started at','{\"key\":\"started_at\",\"name\":\"Repair started at\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"service_request\"},\"validation\":{},\"required\":false}','0.1.0','5d1b5f15b33517c7c7362e9000a2d14ad70bd3eb0ae603465312a84fe8d8ff97','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:service_request.status','service_request.status','service_request','Status','{\"key\":\"status\",\"name\":\"Status\",\"type\":\"select\",\"config\":{\"_definition_object_key\":\"service_request\",\"indexed\":true},\"validation\":{},\"options\":[{\"label\":\"Submitted\",\"value\":\"submitted\"},{\"label\":\"Dispatched\",\"value\":\"dispatched\"},{\"label\":\"In repair\",\"value\":\"in_repair\"},{\"label\":\"Completed\",\"value\":\"completed\"}],\"required\":true}','0.1.0','a08dddd2dcb072c3539e71d045350eebca4ae4414d30c967856e1f415400e7df','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:service_request.submitted_at','service_request.submitted_at','service_request','Submitted at','{\"key\":\"submitted_at\",\"name\":\"Submitted at\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"service_request\",\"indexed\":true},\"validation\":{},\"required\":true}','0.1.0','8d99ab2b26c523626a876dc7280659b01b7183d834514b8d1543a99ce4f5868d','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:spare_part.code','spare_part.code','spare_part','Code','{\"key\":\"code\",\"name\":\"Code\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"spare_part\",\"indexed\":true},\"validation\":{},\"required\":true,\"unique\":true}','0.1.0','a44bdc7f52422ffc34b448e93d1a91968c657d3e960d1a6f21f4c27c7f73822b','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:spare_part.name','spare_part.name','spare_part','Name','{\"key\":\"name\",\"name\":\"Name\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"spare_part\",\"indexed\":true},\"validation\":{},\"required\":true}','0.1.0','d49a4c64fa473126ffc142efbc02c27fcd2d8831d99101d3cd7693eb21eec63c','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:spare_part.stock_quantity','spare_part.stock_quantity','spare_part','Stock quantity','{\"key\":\"stock_quantity\",\"name\":\"Stock quantity\",\"type\":\"integer\",\"config\":{\"_definition_object_key\":\"spare_part\"},\"validation\":{},\"required\":true}','0.1.0','f80f30ecc8ff1b305d9627d087424626da1ce263d25eda81b92475d6ba038d0b','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:spare_part.unit_price','spare_part.unit_price','spare_part','Unit price','{\"key\":\"unit_price\",\"name\":\"Unit price\",\"type\":\"currency\",\"config\":{\"_definition_object_key\":\"spare_part\",\"currency_code\":\"CNY\",\"precision\":19,\"rounding_mode\":\"half_even\",\"scale\":2},\"validation\":{},\"required\":true}','0.1.0','8d967075d948c92e1724bffc87bf360890a50182acc939f017b246268c151a33','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:warranty_waiver.calculation_trace','warranty_waiver.calculation_trace','warranty_waiver','Calculation trace','{\"key\":\"calculation_trace\",\"name\":\"Calculation trace\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"warranty_waiver\"},\"validation\":{},\"required\":true}','0.1.0','0b783e98c09d78c5e7dd3d59eea03a135a146079337c7648b33a5bda70f9185f','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:warranty_waiver.decided_at','warranty_waiver.decided_at','warranty_waiver','Decided at','{\"key\":\"decided_at\",\"name\":\"Decided at\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"warranty_waiver\"},\"validation\":{},\"required\":false}','0.1.0','ac464fd91eddf48d0043b30be1e1f5202d57e19d0b7f43c9349f8c0ccec7734b','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:warranty_waiver.decided_by_user_id','warranty_waiver.decided_by_user_id','warranty_waiver','Decided by','{\"key\":\"decided_by_user_id\",\"name\":\"Decided by\",\"type\":\"user\",\"config\":{\"_definition_object_key\":\"warranty_waiver\"},\"validation\":{},\"required\":false}','0.1.0','cc779983857bfc84ca4d3e27944ba05af2b3269724c66f1937de62db58f7b28f','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:warranty_waiver.owner_department_id','warranty_waiver.owner_department_id','warranty_waiver','Owner department ID','{\"key\":\"owner_department_id\",\"name\":\"Owner department ID\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"warranty_waiver\",\"indexed\":true},\"validation\":{},\"required\":false}','0.1.0','747515894b3f41c8aabdd8a407b9108c84fb23d5059e0a1786baa9b67834034b','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:warranty_waiver.owner_department_path','warranty_waiver.owner_department_path','warranty_waiver','Owner department path','{\"key\":\"owner_department_path\",\"name\":\"Owner department path\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"warranty_waiver\",\"indexed\":true},\"validation\":{},\"required\":false}','0.1.0','5d49407a8be938de032b83e319e64149b4825279b9c633b26e4d12a8635d14fe','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:warranty_waiver.policy_snapshot','warranty_waiver.policy_snapshot','warranty_waiver','Policy snapshot','{\"key\":\"policy_snapshot\",\"name\":\"Policy snapshot\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"warranty_waiver\"},\"validation\":{},\"required\":true}','0.1.0','697250825ec47806d3d8009c0722b7c2a2b947a971dc731ef73434441eea7b38','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:warranty_waiver.rejection_reason','warranty_waiver.rejection_reason','warranty_waiver','Rejection reason','{\"key\":\"rejection_reason\",\"name\":\"Rejection reason\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"warranty_waiver\"},\"validation\":{},\"required\":false}','0.1.0','d6637db6051fd8ace5c4f87787ab25b3fba96c89d39b40e0ebb3990bf917f177','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:warranty_waiver.requested_amount','warranty_waiver.requested_amount','warranty_waiver','Requested waiver','{\"key\":\"requested_amount\",\"name\":\"Requested waiver\",\"type\":\"currency\",\"config\":{\"_definition_object_key\":\"warranty_waiver\",\"currency_code\":\"CNY\",\"precision\":19,\"rounding_mode\":\"half_even\",\"scale\":2},\"validation\":{},\"required\":true}','0.1.0','cad546c1f5623259d2a69e1e580a717bace61dba91c4e98b0aefa648bb4a8a2e','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:warranty_waiver.requested_at','warranty_waiver.requested_at','warranty_waiver','Requested at','{\"key\":\"requested_at\",\"name\":\"Requested at\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"warranty_waiver\",\"indexed\":true},\"validation\":{},\"required\":true}','0.1.0','bde47b4d715fc1d5cfcfff074d247010c92118030550900bb20e7ca328d512e0','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:warranty_waiver.requester_user_id','warranty_waiver.requester_user_id','warranty_waiver','Requesting technician','{\"key\":\"requester_user_id\",\"name\":\"Requesting technician\",\"type\":\"user\",\"config\":{\"_definition_object_key\":\"warranty_waiver\",\"auto_assign_current_user\":true,\"scope_owner\":true},\"validation\":{},\"required\":false}','0.1.0','8fdd83bfdbb2076c8697721cb84c397033e56c1f54ac25d0c14bd57459f7a153','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:warranty_waiver.service_request_id','warranty_waiver.service_request_id','warranty_waiver','Service request','{\"key\":\"service_request_id\",\"name\":\"Service request\",\"type\":\"relation\",\"config\":{\"_definition_object_key\":\"warranty_waiver\",\"indexed\":true,\"object_key\":\"service_request\",\"target\":\"service_request\"},\"validation\":{\"target\":\"service_request\"},\"required\":true,\"unique\":true}','0.1.0','09644578404a9056190614cb599c41fc9dcaf108491bd3c45621fb49a282f409','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:warranty_waiver.status','warranty_waiver.status','warranty_waiver','Status','{\"key\":\"status\",\"name\":\"Status\",\"type\":\"select\",\"config\":{\"_definition_object_key\":\"warranty_waiver\",\"indexed\":true},\"validation\":{},\"options\":[{\"label\":\"Pending approval\",\"value\":\"pending\"},{\"label\":\"Applied\",\"value\":\"applied\"},{\"label\":\"Approved\",\"value\":\"approved\"},{\"label\":\"Rejected\",\"value\":\"rejected\"}],\"required\":true}','0.1.0','a7f4e2f1c612455547aaf1fff7adabd70bcc1151a3c39bb6ecfdd07d6aa4c34d','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:warranty_waiver.threshold_snapshot','warranty_waiver.threshold_snapshot','warranty_waiver','Approval threshold snapshot','{\"key\":\"threshold_snapshot\",\"name\":\"Approval threshold snapshot\",\"type\":\"currency\",\"config\":{\"_definition_object_key\":\"warranty_waiver\",\"currency_code\":\"CNY\",\"precision\":19,\"rounding_mode\":\"half_even\",\"scale\":2},\"validation\":{},\"required\":true}','0.1.0','a8bb5e2b69bf7b4fe09174832dd7ec56fb1503ee455441abfa59a50063748b79','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('field:warranty_waiver.warranty_asserted','warranty_waiver.warranty_asserted','warranty_waiver','Warranty eligibility asserted','{\"key\":\"warranty_asserted\",\"name\":\"Warranty eligibility asserted\",\"type\":\"boolean\",\"config\":{\"_definition_object_key\":\"warranty_waiver\"},\"validation\":{},\"required\":true}','0.1.0','4dbf5ee78d66a112b23fd93f89966ee251108296f4627b87ed78999e4189c338','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z');
/*!40000 ALTER TABLE `field_definitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `frontend_capability_manifests`
--

DROP TABLE IF EXISTS `frontend_capability_manifests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `frontend_capability_manifests` (
  `workspace_id` varchar(191) NOT NULL,
  `revision` bigint NOT NULL DEFAULT '1',
  `manifest_json` text NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_frontend_capability_manifests_workspace_identity` (`workspace_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `frontend_capability_manifests`
--

LOCK TABLES `frontend_capability_manifests` WRITE;
/*!40000 ALTER TABLE `frontend_capability_manifests` DISABLE KEYS */;
/*!40000 ALTER TABLE `frontend_capability_manifests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `idempotency_cleanup_leases`
--

DROP TABLE IF EXISTS `idempotency_cleanup_leases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `idempotency_cleanup_leases` (
  `id` varchar(191) NOT NULL,
  `lease_owner` varchar(191) NOT NULL DEFAULT '',
  `lease_expires_at` varchar(191) NOT NULL DEFAULT '',
  `fencing_token` bigint NOT NULL DEFAULT '0',
  `last_started_at` varchar(191) NOT NULL DEFAULT '',
  `last_completed_at` varchar(191) NOT NULL DEFAULT '',
  `last_deleted` int NOT NULL DEFAULT '0',
  `last_error` text NOT NULL DEFAULT (_utf8mb4''),
  `updated_at` varchar(191) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `idempotency_cleanup_leases`
--

LOCK TABLES `idempotency_cleanup_leases` WRITE;
/*!40000 ALTER TABLE `idempotency_cleanup_leases` DISABLE KEYS */;
INSERT INTO `idempotency_cleanup_leases` VALUES ('receipts','','',9,'2026-08-21T19:25:48.529281Z','2026-08-21T19:25:48.533413Z',0,'','2026-08-21T19:25:48.533413Z');
/*!40000 ALTER TABLE `idempotency_cleanup_leases` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `identity_access_review_items`
--

DROP TABLE IF EXISTS `identity_access_review_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `identity_access_review_items` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `review_id` varchar(191) NOT NULL,
  `user_id` varchar(191) NOT NULL,
  `role_id` varchar(191) NOT NULL,
  `role_key` varchar(191) NOT NULL,
  `workforce_profile_id` varchar(191) DEFAULT NULL,
  `binding_key` varchar(191) DEFAULT NULL,
  `profile_id` varchar(191) DEFAULT NULL,
  `risk_level` varchar(191) NOT NULL,
  `priority` varchar(191) NOT NULL,
  `priority_reasons_json` text NOT NULL DEFAULT (_utf8mb4'[]'),
  `last_used_at` varchar(191) DEFAULT NULL,
  `status` varchar(191) NOT NULL,
  `decision` varchar(191) DEFAULT NULL,
  `replacement_role_id` varchar(191) DEFAULT NULL,
  `expires_at` varchar(191) DEFAULT NULL,
  `reviewer_id` varchar(191) DEFAULT NULL,
  `reason` text,
  `decided_at` varchar(191) DEFAULT NULL,
  `version` bigint NOT NULL DEFAULT '1',
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_identity_access_review_items_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_identity_access_review_assignment` (`workspace_id`,`review_id`,`user_id`,`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `identity_access_review_items`
--

LOCK TABLES `identity_access_review_items` WRITE;
/*!40000 ALTER TABLE `identity_access_review_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `identity_access_review_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `identity_access_review_receipts`
--

DROP TABLE IF EXISTS `identity_access_review_receipts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `identity_access_review_receipts` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `item_id` varchar(191) NOT NULL,
  `idempotency_key` varchar(191) NOT NULL,
  `request_fingerprint` varchar(191) NOT NULL,
  `result_json` text NOT NULL,
  `created_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_identity_access_review_receipts_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_identity_access_review_receipt` (`workspace_id`,`item_id`,`idempotency_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `identity_access_review_receipts`
--

LOCK TABLES `identity_access_review_receipts` WRITE;
/*!40000 ALTER TABLE `identity_access_review_receipts` DISABLE KEYS */;
/*!40000 ALTER TABLE `identity_access_review_receipts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `identity_access_reviews`
--

DROP TABLE IF EXISTS `identity_access_reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `identity_access_reviews` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `period_start` varchar(191) NOT NULL,
  `period_end` varchar(191) NOT NULL,
  `due_at` varchar(191) NOT NULL,
  `status` varchar(191) NOT NULL,
  `created_by` varchar(191) NOT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_identity_access_reviews_workspace_identity` (`workspace_id`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `identity_access_reviews`
--

LOCK TABLES `identity_access_reviews` WRITE;
/*!40000 ALTER TABLE `identity_access_reviews` DISABLE KEYS */;
/*!40000 ALTER TABLE `identity_access_reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `identity_credentials`
--

DROP TABLE IF EXISTS `identity_credentials`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `identity_credentials` (
  `user_id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `password_hash` text NOT NULL,
  `password_updated_at` varchar(191) NOT NULL,
  `failed_login_count` int NOT NULL DEFAULT '0',
  `locked_until` varchar(191) DEFAULT NULL,
  `last_login_at` varchar(191) DEFAULT NULL,
  `must_change_password` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_identity_credentials_workspace_identity` (`workspace_id`,`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `identity_credentials`
--

LOCK TABLES `identity_credentials` WRITE;
/*!40000 ALTER TABLE `identity_credentials` DISABLE KEYS */;
INSERT INTO `identity_credentials` VALUES ('admin','default','$2a$10$x4lOH0buyG9ks1d/ZSwxsuo.FBJB4wwr5wa8tNNrSlpD0yn/iCdh6','2026-08-21T18:45:47Z',0,NULL,NULL,1,'2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('customer_qin','default','$2a$10$wLHw1MYuCZzN3Lpdy4UMWuLUhj9M9COU5KrWL8gBIaQwIfjpijDZi','2026-08-21T18:45:48Z',0,NULL,NULL,1,'2026-08-21T18:45:48Z','2026-08-21T18:45:48Z'),('customer_sun','default','$2a$10$ZisYAQbDXgPumrxjr1AaMO3DZ9SaxIohTF5FhUhjYUN5n0sUniVy2','2026-08-21T18:45:48Z',0,NULL,NULL,1,'2026-08-21T18:45:48Z','2026-08-21T18:45:48Z'),('customer_user','default','$2a$10$XJFUbmL9HApwsDZktkUHkeGsh49oUuUrMOmwdC2w1oTQLyLOhAEJe','2026-08-21T18:45:48Z',0,NULL,NULL,1,'2026-08-21T18:45:48Z','2026-08-21T18:45:48Z'),('identity_effective_user','default','$2a$10$wiasura2V4y0l/y830h.DeFRKbpx963IStaCMH5bgccDs9fl5JQjC','2026-08-21T18:45:48Z',0,NULL,NULL,1,'2026-08-21T18:45:48Z','2026-08-21T18:45:48Z'),('manager_lin','default','$2a$10$neGgOehY5B1BLex6lWrejOHSgE8RjuNPetekUsAS6T2CfhlKsqK4e','2026-08-21T18:45:48Z',0,NULL,NULL,1,'2026-08-21T18:45:48Z','2026-08-21T18:45:48Z'),('ops_manager_user','default','$2a$10$nK5o6NcNOHf6offwOKRvMerv/kQK3sPCn1WPFji.U53nkfXztdAl6','2026-08-21T18:45:48Z',0,NULL,NULL,1,'2026-08-21T18:45:48Z','2026-08-21T18:45:48Z'),('scheduler_bot','default','$2a$10$FVl8yl5hs7Pz2/SXIZqQC.eyhPwR0ZdaS0A9pRtk0lr.H4BP8lDUG','2026-08-21T18:45:48Z',0,NULL,NULL,1,'2026-08-21T18:45:48Z','2026-08-21T18:45:48Z'),('scheduler_service_user','default','$2a$10$USnvn0kvwomcVWh2rgvyW.odDhN85Kf6cN1rHHayI0H0gd184PbZq','2026-08-21T18:45:48Z',0,NULL,NULL,1,'2026-08-21T18:45:48Z','2026-08-21T18:45:48Z'),('tech_east_chen','default','$2a$10$m3swt3ajZoVvfk.vugUQo.dP6zjmrYWwvNZJjclDSVzNOXGkJeKbC','2026-08-21T18:45:48Z',0,NULL,NULL,1,'2026-08-21T18:45:48Z','2026-08-21T18:45:48Z'),('tech_west_zhao','default','$2a$10$7btaWguFB8m6FpkHCb8nB.SqKwE/UQhDrMJxvsHv8.1xvrP7c7a9a','2026-08-21T18:45:48Z',0,NULL,NULL,1,'2026-08-21T18:45:48Z','2026-08-21T18:45:48Z'),('technician_user','default','$2a$10$b6ikCW53eHXHfMWRjeLTpeF4rAcMwLK8.P2HH7Xcym6XBa4nZDjs2','2026-08-21T18:45:48Z',0,NULL,NULL,1,'2026-08-21T18:45:48Z','2026-08-21T18:45:48Z');
/*!40000 ALTER TABLE `identity_credentials` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `identity_departments`
--

DROP TABLE IF EXISTS `identity_departments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `identity_departments` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `name` text NOT NULL,
  `parent_id` varchar(191) DEFAULT NULL,
  `leader_workforce_profile_id` varchar(191) DEFAULT NULL,
  `path` text NOT NULL,
  `ancestor_ids` text NOT NULL,
  `depth` int NOT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  `status` varchar(191) NOT NULL DEFAULT 'active',
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_identity_departments_workspace_identity` (`workspace_id`,`id`),
  KEY `idx_identity_departments_parent` (`workspace_id`,`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `identity_departments`
--

LOCK TABLES `identity_departments` WRITE;
/*!40000 ALTER TABLE `identity_departments` DISABLE KEYS */;
INSERT INTO `identity_departments` VALUES ('east_station','default','East Station','ops_root',NULL,'/ops_root/east_station','[\"ops_root\"]',1,0,'active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('ops_root','default','Operations',NULL,NULL,'/ops_root','null',0,0,'active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('west_station','default','West Station','ops_root',NULL,'/ops_root/west_station','[\"ops_root\"]',1,0,'active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z');
/*!40000 ALTER TABLE `identity_departments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `identity_entitlement_batch_receipts`
--

DROP TABLE IF EXISTS `identity_entitlement_batch_receipts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `identity_entitlement_batch_receipts` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `actor_id` varchar(191) NOT NULL,
  `idempotency_key` varchar(191) NOT NULL,
  `request_fingerprint` varchar(191) NOT NULL,
  `result_json` text NOT NULL,
  `created_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_identity_entitlement_batch_receipts_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_identity_entitlement_batch_receipt` (`workspace_id`,`idempotency_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `identity_entitlement_batch_receipts`
--

LOCK TABLES `identity_entitlement_batch_receipts` WRITE;
/*!40000 ALTER TABLE `identity_entitlement_batch_receipts` DISABLE KEYS */;
/*!40000 ALTER TABLE `identity_entitlement_batch_receipts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `identity_external_accounts`
--

DROP TABLE IF EXISTS `identity_external_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `identity_external_accounts` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `user_id` varchar(191) NOT NULL,
  `provider` varchar(191) NOT NULL,
  `provider_subject` varchar(191) NOT NULL,
  `email` text,
  `phone` text,
  `display_name` text,
  `avatar_url` text,
  `metadata` text,
  `linked_at` varchar(191) NOT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_identity_external_accounts_workspace_identity` (`workspace_id`,`id`),
  KEY `idx_identity_external_accounts_user` (`workspace_id`,`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `identity_external_accounts`
--

LOCK TABLES `identity_external_accounts` WRITE;
/*!40000 ALTER TABLE `identity_external_accounts` DISABLE KEYS */;
/*!40000 ALTER TABLE `identity_external_accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `identity_menus`
--

DROP TABLE IF EXISTS `identity_menus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `identity_menus` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `menu_key` varchar(191) NOT NULL,
  `label` text NOT NULL,
  `description` text,
  `route` text,
  `icon` varchar(191) DEFAULT NULL,
  `parent_id` varchar(191) DEFAULT NULL,
  `sort_order` int NOT NULL,
  `status` varchar(191) NOT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_identity_menus_workspace_identity` (`workspace_id`,`id`),
  KEY `idx_identity_menus_parent` (`workspace_id`,`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `identity_menus`
--

LOCK TABLES `identity_menus` WRITE;
/*!40000 ALTER TABLE `identity_menus` DISABLE KEYS */;
INSERT INTO `identity_menus` VALUES ('domain','default','domain','Data & Exchange','','','',NULL,100,'active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('menu_all_work_orders','default','all_work_orders','All Work Orders','','business.work_orders.all','',NULL,10,'active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('menu_my_work_orders','default','my_work_orders','My Work Orders','','business.work_orders.my','',NULL,10,'active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('menu_portal_requests','default','portal_requests','My Service Requests','','portal.service_requests','',NULL,10,'active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('menu_reports','default','operations_reports','Operations Reports','','business.reports.operations','',NULL,20,'active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('org_access','default','org_access','Org & Access','','','',NULL,200,'active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('org_data_scopes','default','org_data_scopes','Data scopes','','/admin/org/data-scopes','shield-check','org_access',260,'active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('org_departments','default','org_departments','Departments','','/admin/org/departments','building-2','org_access',230,'active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('org_field_permissions','default','org_field_permissions','Field permissions','','/admin/org/field-permissions','columns-3','org_access',270,'active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('org_menus','default','org_menus','Menus','','/admin/org/menus','square-menu','org_access',250,'active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('org_roles','default','org_roles','Roles','','/admin/org/roles','user-cog','org_access',240,'active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('org_users','default','org_users','Accounts','','/admin/security/accounts','users-round','org_access',210,'active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('org_workforce','default','org_workforce','Workforce','','/admin/org/workforce','briefcase-business','org_access',220,'active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('runtime_operations','default','runtime_operations','Runtime operations','','','',NULL,400,'active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('system','default','system','Tenant configuration','','','',NULL,300,'active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('system_actions','default','system_actions','Actions','','/admin/system/actions','square-function','system',337,'active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('system_audit','default','system_audit','Audit','','/admin/system/audit','list-checks','system',360,'active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('system_automation_rules','default','system_automation_rules','Automation rules','','/admin/system/automation-rules','git-branch','system',340,'active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('system_capability_status','default','system_capability_status','Capability status','','/admin/system/capability-status','badge-check','runtime_operations',450,'active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('system_connector_operations','default','system_connector_operations','Integration activity','','/admin/system/integration-activity','activity','runtime_operations',430,'active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('system_connectors','default','system_connectors','Connectors','','/admin/system/connectors','plug-zap','system',345,'active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('system_dictionaries','default','system_dictionaries','Dictionaries','','/admin/system/dictionaries','book-open','system',320,'active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('system_domain_impact','default','system_domain_impact','Business impact','','/admin/system/domain-impact','git-compare-arrows','system',370,'active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('system_metadata','default','system_metadata','Metadata','','/admin/system/metadata','database','system',380,'active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('system_notifications','default','system_notifications','Notification templates','','/admin/system/notifications','bell-ring','system',347,'active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('system_operations','default','system_operations','Operations','','/admin/system/operations','sliders-horizontal','runtime_operations',420,'active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('system_overview','default','system_overview','System overview','','/admin/system','settings','system',310,'active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('system_scheduler','default','system_scheduler','Scheduler','','/admin/system/scheduler','calendar-clock','system',350,'active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('system_scheduler_operations','default','system_scheduler_operations','Scheduler operations','','/admin/system/scheduler-operations','calendar-clock','runtime_operations',440,'active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('system_workflow_processes','default','system_workflow_processes','Workflow processes','','/admin/system/workflow-processes','git-branch','runtime_operations',410,'active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('system_workflows','default','system_workflows','Workflows','','/admin/system/workflows','workflow','system',330,'active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z');
/*!40000 ALTER TABLE `identity_menus` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `identity_mfa_factors`
--

DROP TABLE IF EXISTS `identity_mfa_factors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `identity_mfa_factors` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `user_id` varchar(191) NOT NULL,
  `factor_type` varchar(191) NOT NULL,
  `label` text,
  `provider` varchar(191) DEFAULT NULL,
  `provider_ref` varchar(191) DEFAULT NULL,
  `status` varchar(191) NOT NULL,
  `verified_at` varchar(191) DEFAULT NULL,
  `last_used_at` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_identity_mfa_factors_workspace_identity` (`workspace_id`,`id`),
  KEY `idx_identity_mfa_factors_user` (`workspace_id`,`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `identity_mfa_factors`
--

LOCK TABLES `identity_mfa_factors` WRITE;
/*!40000 ALTER TABLE `identity_mfa_factors` DISABLE KEYS */;
/*!40000 ALTER TABLE `identity_mfa_factors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `identity_profile_binding_definitions`
--

DROP TABLE IF EXISTS `identity_profile_binding_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `identity_profile_binding_definitions` (
  `id` varchar(191) NOT NULL,
  `resource_key` varchar(191) NOT NULL,
  `object_key` varchar(191) NOT NULL,
  `name` text NOT NULL,
  `payload_json` longtext NOT NULL,
  `schema_version` varchar(191) NOT NULL,
  `schema_hash` varchar(191) NOT NULL,
  `source_kind` varchar(191) NOT NULL,
  `source_id` varchar(191) NOT NULL,
  `disabled_at` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `resource_key` (`resource_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `identity_profile_binding_definitions`
--

LOCK TABLES `identity_profile_binding_definitions` WRITE;
/*!40000 ALTER TABLE `identity_profile_binding_definitions` DISABLE KEYS */;
INSERT INTO `identity_profile_binding_definitions` VALUES ('identity_profile_binding:customer_profile','customer_profile','customer_profile','fieldservice_customer','{\"contract_version\":\"identity-profile-extension\",\"min_reader_version\":\"identity-profile-extension-reader\",\"object_key\":\"customer_profile\",\"identity_relation_field\":\"identity_user_id\",\"cardinality\":\"one_to_one\",\"business_identity\":{\"key\":\"fieldservice_customer\",\"surface_keys\":[\"consumer_portal\"],\"status_field\":\"status\",\"active_status_values\":[\"active\"]},\"binding_lifecycle\":{},\"directory\":{},\"default_visibility\":\"when_readable\",\"provenance\":{\"owner\":\"user-blueprint\"}}','0.1.0','cc39b5eb9b9c9a9154f8eb409f98dd34eb8ddbdb4261cb51343d1dafc5dfb81f','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z');
/*!40000 ALTER TABLE `identity_profile_binding_definitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `identity_profile_binding_events`
--

DROP TABLE IF EXISTS `identity_profile_binding_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `identity_profile_binding_events` (
  `id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `workspace_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `binding_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `object_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `profile_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `operation` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `previous_user_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin DEFAULT NULL,
  `identity_user_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin DEFAULT NULL,
  `binding_version` bigint NOT NULL,
  `idempotency_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `actor_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `reason` text,
  `approval_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin DEFAULT NULL,
  `status` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `created_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  UNIQUE KEY `uniq_identity_profile_binding_events_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_identity_profile_binding_event` (`workspace_id`,`object_key`,`profile_id`,`operation`,`idempotency_key`),
  KEY `idx_identity_profile_binding_events_profile` (`workspace_id`,`object_key`,`profile_id`,`created_at`),
  KEY `idx_identity_profile_binding_events_status` (`status`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `identity_profile_binding_events`
--

LOCK TABLES `identity_profile_binding_events` WRITE;
/*!40000 ALTER TABLE `identity_profile_binding_events` DISABLE KEYS */;
INSERT INTO `identity_profile_binding_events` VALUES ('3b9b46aecf14b67f6f28cd19a18b256fcc1afce6d232757e27250b8596b00543','default','fieldservice_customer','customer_profile','customer_profile_customer_sun_profile','bind',NULL,'customer_sun',1,'manifest-profile-binding:fieldservice_customer:customer_profile_customer_sun_profile','runtime_manifest_seed',NULL,NULL,'pending','2026-08-21T18:45:47.908979Z'),('3cccc7c25528565e80caadb6b8bf3a22a2b72239a74becc7c5f63eeddbcf53df','default','fieldservice_customer','customer_profile','customer_profile_customer_qin_profile','bind',NULL,'customer_qin',1,'manifest-profile-binding:fieldservice_customer:customer_profile_customer_qin_profile','runtime_manifest_seed',NULL,NULL,'pending','2026-08-21T18:45:47.907977Z');
/*!40000 ALTER TABLE `identity_profile_binding_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `identity_profile_binding_receipts`
--

DROP TABLE IF EXISTS `identity_profile_binding_receipts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `identity_profile_binding_receipts` (
  `id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `workspace_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `binding_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `object_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `profile_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `operation` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `idempotency_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `request_fingerprint` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `binding_json` text NOT NULL,
  `created_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  UNIQUE KEY `uniq_identity_profile_binding_receipts_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_identity_profile_binding_receipt` (`workspace_id`,`object_key`,`profile_id`,`operation`,`idempotency_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `identity_profile_binding_receipts`
--

LOCK TABLES `identity_profile_binding_receipts` WRITE;
/*!40000 ALTER TABLE `identity_profile_binding_receipts` DISABLE KEYS */;
INSERT INTO `identity_profile_binding_receipts` VALUES ('939252b26ffda86c917b3e34fbd9775e3af4ab8bf3d8734267ea68d30b13340b','default','fieldservice_customer','customer_profile','customer_profile_customer_sun_profile','bind','manifest-profile-binding:fieldservice_customer:customer_profile_customer_sun_profile','1b85cafa41c2decbb1545d4da371c95a4616eaaa2671639005e7b2d8c92c799d','{\"workspace_id\":\"default\",\"binding_key\":\"fieldservice_customer\",\"object_key\":\"customer_profile\",\"profile_id\":\"customer_profile_customer_sun_profile\",\"identity_user_id\":\"customer_sun\",\"status\":\"active\",\"version\":1,\"created_at\":\"2026-08-21T18:45:47.908978Z\",\"updated_at\":\"2026-08-21T18:45:47.908979Z\"}','2026-08-21T18:45:47.908979Z'),('dbe7e7e7a209002edf7c9858c1e0f90e04366a96bddc51a0b5c78fa702788ed5','default','fieldservice_customer','customer_profile','customer_profile_customer_qin_profile','bind','manifest-profile-binding:fieldservice_customer:customer_profile_customer_qin_profile','d551e72de0373430a27051ecb65f67b810e2364742690e5c780b75d9d72c88e3','{\"workspace_id\":\"default\",\"binding_key\":\"fieldservice_customer\",\"object_key\":\"customer_profile\",\"profile_id\":\"customer_profile_customer_qin_profile\",\"identity_user_id\":\"customer_qin\",\"status\":\"active\",\"version\":1,\"created_at\":\"2026-08-21T18:45:47.907976Z\",\"updated_at\":\"2026-08-21T18:45:47.907977Z\"}','2026-08-21T18:45:47.907977Z');
/*!40000 ALTER TABLE `identity_profile_binding_receipts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `identity_profile_bindings`
--

DROP TABLE IF EXISTS `identity_profile_bindings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `identity_profile_bindings` (
  `id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `workspace_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `binding_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `object_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `profile_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `identity_user_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin DEFAULT NULL,
  `status` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `invitation_channel` varchar(191) CHARACTER SET ascii COLLATE ascii_bin DEFAULT NULL,
  `claim_proof_type` varchar(191) CHARACTER SET ascii COLLATE ascii_bin DEFAULT NULL,
  `version` bigint NOT NULL,
  `created_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `updated_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  UNIQUE KEY `uniq_identity_profile_bindings_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_identity_profile_binding_profile` (`workspace_id`,`object_key`,`profile_id`),
  UNIQUE KEY `uniq_identity_profile_binding_user` (`workspace_id`,`binding_key`,`identity_user_id`),
  KEY `idx_identity_profile_bindings_user` (`workspace_id`,`binding_key`,`identity_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `identity_profile_bindings`
--

LOCK TABLES `identity_profile_bindings` WRITE;
/*!40000 ALTER TABLE `identity_profile_bindings` DISABLE KEYS */;
INSERT INTO `identity_profile_bindings` VALUES ('21f436127458679d97c8eeed1a41f9ffb3f3d068c3ff88dd9385d99e2d6851c8','default','fieldservice_customer','customer_profile','customer_profile_customer_qin_profile','customer_qin','active',NULL,NULL,1,'2026-08-21T18:45:47.907976Z','2026-08-21T18:45:47.907977Z'),('d7ad7e27828a4b694c1fbefeec3b4a70e24d573766be2fa286f0ae41905e27e4','default','fieldservice_customer','customer_profile','customer_profile_customer_sun_profile','customer_sun','active',NULL,NULL,1,'2026-08-21T18:45:47.908978Z','2026-08-21T18:45:47.908979Z');
/*!40000 ALTER TABLE `identity_profile_bindings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `identity_role_menu_assignments`
--

DROP TABLE IF EXISTS `identity_role_menu_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `identity_role_menu_assignments` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `role_id` varchar(191) NOT NULL,
  `menu_id` varchar(191) NOT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_identity_role_menu_assignments_workspace_identity` (`workspace_id`,`id`),
  KEY `idx_identity_role_menus_role` (`workspace_id`,`role_id`),
  KEY `idx_identity_role_menus_menu` (`workspace_id`,`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `identity_role_menu_assignments`
--

LOCK TABLES `identity_role_menu_assignments` WRITE;
/*!40000 ALTER TABLE `identity_role_menu_assignments` DISABLE KEYS */;
INSERT INTO `identity_role_menu_assignments` VALUES ('rolemenu_default_admin_domain','default','admin','domain','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_admin_org_access','default','admin','org_access','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_admin_org_data_scopes','default','admin','org_data_scopes','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_admin_org_departments','default','admin','org_departments','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_admin_org_field_permissions','default','admin','org_field_permissions','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_admin_org_menus','default','admin','org_menus','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_admin_org_roles','default','admin','org_roles','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_admin_org_users','default','admin','org_users','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_admin_org_workforce','default','admin','org_workforce','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_admin_runtime_operations','default','admin','runtime_operations','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_admin_system','default','admin','system','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_admin_system_actions','default','admin','system_actions','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_admin_system_audit','default','admin','system_audit','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_admin_system_automation_rules','default','admin','system_automation_rules','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_admin_system_capability_status','default','admin','system_capability_status','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_admin_system_connector_operations','default','admin','system_connector_operations','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_admin_system_connectors','default','admin','system_connectors','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_admin_system_dictionaries','default','admin','system_dictionaries','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_admin_system_domain_impact','default','admin','system_domain_impact','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_admin_system_metadata','default','admin','system_metadata','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_admin_system_notifications','default','admin','system_notifications','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_admin_system_operations','default','admin','system_operations','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_admin_system_overview','default','admin','system_overview','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_admin_system_scheduler','default','admin','system_scheduler','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_admin_system_scheduler_operations','default','admin','system_scheduler_operations','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_admin_system_workflow_processes','default','admin','system_workflow_processes','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_admin_system_workflows','default','admin','system_workflows','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_customer_menu_portal_requests','default','customer','menu_portal_requests','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_ops_manager_menu_all_work_orders','default','ops_manager','menu_all_work_orders','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_ops_manager_menu_reports','default','ops_manager','menu_reports','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_organization_administrator_org_data_scopes','default','organization_administrator','org_data_scopes','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_organization_administrator_org_departments','default','organization_administrator','org_departments','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_organization_administrator_org_field_permissions','default','organization_administrator','org_field_permissions','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_organization_administrator_org_menus','default','organization_administrator','org_menus','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_organization_administrator_org_roles','default','organization_administrator','org_roles','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_organization_administrator_org_users','default','organization_administrator','org_users','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_organization_administrator_org_workforce','default','organization_administrator','org_workforce','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_organization_administrator_system_actions','default','organization_administrator','system_actions','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_organization_administrator_system_audit','default','organization_administrator','system_audit','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_organization_administrator_system_automation_rules','default','organization_administrator','system_automation_rules','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_organization_administrator_system_connectors','default','organization_administrator','system_connectors','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_organization_administrator_system_dictionaries','default','organization_administrator','system_dictionaries','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_organization_administrator_system_domain_impact','default','organization_administrator','system_domain_impact','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_organization_administrator_system_metadata','default','organization_administrator','system_metadata','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_organization_administrator_system_notifications','default','organization_administrator','system_notifications','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_organization_administrator_system_overview','default','organization_administrator','system_overview','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_organization_administrator_system_scheduler','default','organization_administrator','system_scheduler','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_organization_administrator_system_workflows','default','organization_administrator','system_workflows','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_system_administrator_system_capability_status','default','system_administrator','system_capability_status','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_system_administrator_system_connector_operations','default','system_administrator','system_connector_operations','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_system_administrator_system_operations','default','system_administrator','system_operations','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_system_administrator_system_scheduler_operations','default','system_administrator','system_scheduler_operations','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_system_administrator_system_workflow_processes','default','system_administrator','system_workflow_processes','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('rolemenu_default_technician_menu_my_work_orders','default','technician','menu_my_work_orders','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z');
/*!40000 ALTER TABLE `identity_role_menu_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `identity_role_requests`
--

DROP TABLE IF EXISTS `identity_role_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `identity_role_requests` (
  `id` varchar(255) NOT NULL,
  `workspace_id` varchar(255) NOT NULL,
  `user_id` varchar(255) NOT NULL,
  `requested_by` varchar(255) DEFAULT NULL,
  `provider` varchar(255) DEFAULT NULL,
  `provider_subject` varchar(255) DEFAULT NULL,
  `role_ids_json` text NOT NULL,
  `status` varchar(255) NOT NULL,
  `reason` text,
  `created_at` varchar(255) NOT NULL,
  `updated_at` varchar(255) NOT NULL,
  `reviewed_by` varchar(255) DEFAULT NULL,
  `reviewed_at` varchar(255) DEFAULT NULL,
  `review_note` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `identity_role_requests`
--

LOCK TABLES `identity_role_requests` WRITE;
/*!40000 ALTER TABLE `identity_role_requests` DISABLE KEYS */;
/*!40000 ALTER TABLE `identity_role_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `identity_roles`
--

DROP TABLE IF EXISTS `identity_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `identity_roles` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `role_key` varchar(191) NOT NULL,
  `label` text NOT NULL,
  `description` text,
  `status` varchar(191) NOT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_identity_roles_workspace_identity` (`workspace_id`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `identity_roles`
--

LOCK TABLES `identity_roles` WRITE;
/*!40000 ALTER TABLE `identity_roles` DISABLE KEYS */;
INSERT INTO `identity_roles` VALUES ('admin','default','admin','Admin','','active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('customer','default','customer','Customer','','active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('identity_effective','default','identity_effective','Identity Effective','','active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('ops_manager','default','ops_manager','Operations manager','','active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('organization_administrator','default','organization_administrator','Organization administrator','','active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('scheduler_service','default','scheduler_service','Scheduler service','','active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('system_administrator','default','system_administrator','System administrator','','active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('technician','default','technician','Technician','','active','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z');
/*!40000 ALTER TABLE `identity_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `identity_user_role_assignments`
--

DROP TABLE IF EXISTS `identity_user_role_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `identity_user_role_assignments` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `user_id` varchar(191) NOT NULL,
  `role_id` varchar(191) NOT NULL,
  `workforce_profile_id` varchar(191) DEFAULT NULL,
  `binding_key` varchar(191) DEFAULT NULL,
  `profile_id` varchar(191) DEFAULT NULL,
  `source` varchar(191) NOT NULL DEFAULT 'manual',
  `status` varchar(191) NOT NULL DEFAULT 'active',
  `valid_from` varchar(191) DEFAULT NULL,
  `valid_until` varchar(191) DEFAULT NULL,
  `granted_by` varchar(191) DEFAULT NULL,
  `grant_reason` text,
  `revoked_by` varchar(191) DEFAULT NULL,
  `revoked_at` varchar(191) DEFAULT NULL,
  `revoke_reason` text,
  `expires_at` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_identity_user_role_assignments_workspace_identity` (`workspace_id`,`id`),
  KEY `idx_identity_user_roles_user` (`workspace_id`,`user_id`),
  KEY `idx_identity_user_roles_role` (`workspace_id`,`role_id`),
  KEY `idx_identity_user_roles_workforce` (`workspace_id`,`workforce_profile_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `identity_user_role_assignments`
--

LOCK TABLES `identity_user_role_assignments` WRITE;
/*!40000 ALTER TABLE `identity_user_role_assignments` DISABLE KEYS */;
INSERT INTO `identity_user_role_assignments` VALUES ('identity_user_role_default_admin_admin','default','admin','admin',NULL,NULL,NULL,'manual','active',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('identity_user_role_default_customer_qin_customer','default','customer_qin','customer',NULL,NULL,NULL,'manual','active',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('identity_user_role_default_customer_sun_customer','default','customer_sun','customer',NULL,NULL,NULL,'manual','active',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('identity_user_role_default_customer_user_customer','default','customer_user','customer',NULL,NULL,NULL,'manual','active',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('identity_user_role_default_identity_effective_user_identity_effective','default','identity_effective_user','identity_effective',NULL,NULL,NULL,'manual','active',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('identity_user_role_default_manager_lin_ops_manager','default','manager_lin','ops_manager','manager_lin_workforce',NULL,NULL,'manual','active',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('identity_user_role_default_ops_manager_user_ops_manager','default','ops_manager_user','ops_manager',NULL,NULL,NULL,'manual','active',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('identity_user_role_default_scheduler_bot_scheduler_service','default','scheduler_bot','scheduler_service',NULL,NULL,NULL,'manual','active',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('identity_user_role_default_scheduler_service_user_scheduler_service','default','scheduler_service_user','scheduler_service',NULL,NULL,NULL,'manual','active',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('identity_user_role_default_tech_east_chen_technician','default','tech_east_chen','technician','tech_east_chen_workforce',NULL,NULL,'manual','active',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('identity_user_role_default_tech_west_zhao_technician','default','tech_west_zhao','technician','tech_west_zhao_workforce',NULL,NULL,'manual','active',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('identity_user_role_default_technician_user_technician','default','technician_user','technician',NULL,NULL,NULL,'manual','active',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-08-21T18:45:47Z','2026-08-21T18:45:47Z');
/*!40000 ALTER TABLE `identity_user_role_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `identity_users`
--

DROP TABLE IF EXISTS `identity_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `identity_users` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `name` text NOT NULL,
  `given_name` text NOT NULL DEFAULT (_utf8mb4''),
  `middle_name` text NOT NULL DEFAULT (_utf8mb4''),
  `family_name` text NOT NULL DEFAULT (_utf8mb4''),
  `name_prefix` text NOT NULL DEFAULT (_utf8mb4''),
  `name_suffix` text NOT NULL DEFAULT (_utf8mb4''),
  `native_name` text NOT NULL DEFAULT (_utf8mb4''),
  `name_locale` varchar(255) NOT NULL DEFAULT '',
  `email` text NOT NULL,
  `phone` varchar(255) NOT NULL DEFAULT '',
  `account_type` varchar(191) NOT NULL DEFAULT 'human',
  `locale` varchar(255) NOT NULL DEFAULT '',
  `timezone` varchar(255) NOT NULL DEFAULT '',
  `status` varchar(191) NOT NULL,
  `version` bigint NOT NULL DEFAULT '1',
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_identity_users_workspace_identity` (`workspace_id`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `identity_users`
--

LOCK TABLES `identity_users` WRITE;
/*!40000 ALTER TABLE `identity_users` DISABLE KEYS */;
INSERT INTO `identity_users` VALUES ('admin','default','Admin','','','','','','','','admin@example.com','','human','','','active',1,'2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('customer_qin','default','Qin Portal Customer','','','','','','','','customer_qin@example.com','','human','','','active',2,'2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('customer_sun','default','Sun Portal Customer','','','','','','','','customer_sun@example.com','','human','','','active',2,'2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('customer_user','default','Customer','','','','','','','','customer@example.com','','human','','','active',1,'2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('identity_effective_user','default','Identity Effective','','','','','','','','identity_effective@example.com','','human','','','active',1,'2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('manager_lin','default','Lin Operations Manager','','','','','','','','manager_lin@example.com','','human','','','active',2,'2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('ops_manager_user','default','Operations manager','','','','','','','','ops_manager@example.com','','human','','','active',1,'2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('scheduler_bot','default','Scheduler Acceptance Service','','','','','','','','scheduler_bot@example.com','','human','','','active',2,'2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('scheduler_service_user','default','Scheduler service','','','','','','','','scheduler_service@example.com','','human','','','active',1,'2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('tech_east_chen','default','Chen East Technician','','','','','','','','tech_east_chen@example.com','','human','','','active',2,'2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('tech_west_zhao','default','Zhao West Technician','','','','','','','','tech_west_zhao@example.com','','human','','','active',2,'2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('technician_user','default','Technician','','','','','','','','technician@example.com','','human','','','active',1,'2026-08-21T18:45:47Z','2026-08-21T18:45:47Z');
/*!40000 ALTER TABLE `identity_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `identity_workforce_assignments`
--

DROP TABLE IF EXISTS `identity_workforce_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `identity_workforce_assignments` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `workforce_profile_id` varchar(191) NOT NULL,
  `organization_unit_id` varchar(191) NOT NULL,
  `position_id` varchar(191) DEFAULT NULL,
  `manager_workforce_profile_id` varchar(191) DEFAULT NULL,
  `assignment_type` varchar(191) NOT NULL,
  `effective_from` varchar(191) DEFAULT NULL,
  `effective_to` varchar(191) DEFAULT NULL,
  `status` varchar(191) NOT NULL,
  `version` bigint NOT NULL DEFAULT '1',
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_identity_workforce_assignments_workspace_identity` (`workspace_id`,`id`),
  KEY `idx_identity_workforce_assignments_profile` (`workspace_id`,`workforce_profile_id`),
  KEY `idx_identity_workforce_assignments_unit` (`workspace_id`,`organization_unit_id`),
  KEY `idx_identity_workforce_assignments_manager` (`workspace_id`,`manager_workforce_profile_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `identity_workforce_assignments`
--

LOCK TABLES `identity_workforce_assignments` WRITE;
/*!40000 ALTER TABLE `identity_workforce_assignments` DISABLE KEYS */;
INSERT INTO `identity_workforce_assignments` VALUES ('manager_lin_primary','default','manager_lin_workforce','ops_root',NULL,NULL,'primary',NULL,NULL,'active',1,'2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('tech_east_chen_primary','default','tech_east_chen_workforce','east_station',NULL,'manager_lin_workforce','primary',NULL,NULL,'active',1,'2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('tech_west_zhao_primary','default','tech_west_zhao_workforce','west_station',NULL,'manager_lin_workforce','primary',NULL,NULL,'active',1,'2026-08-21T18:45:47Z','2026-08-21T18:45:47Z');
/*!40000 ALTER TABLE `identity_workforce_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `identity_workforce_legacy_migration_receipts`
--

DROP TABLE IF EXISTS `identity_workforce_legacy_migration_receipts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `identity_workforce_legacy_migration_receipts` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `identity_user_id` varchar(191) NOT NULL,
  `workforce_profile_id` varchar(191) NOT NULL,
  `workforce_assignment_id` varchar(191) DEFAULT NULL,
  `legacy_facts_json` text NOT NULL,
  `migrated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_identity_workforce_legacy_receipt_workspace` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_identity_workforce_legacy_migration_user` (`workspace_id`,`identity_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `identity_workforce_legacy_migration_receipts`
--

LOCK TABLES `identity_workforce_legacy_migration_receipts` WRITE;
/*!40000 ALTER TABLE `identity_workforce_legacy_migration_receipts` DISABLE KEYS */;
/*!40000 ALTER TABLE `identity_workforce_legacy_migration_receipts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `identity_workforce_profiles`
--

DROP TABLE IF EXISTS `identity_workforce_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `identity_workforce_profiles` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `organization_id` varchar(191) NOT NULL,
  `identity_user_id` varchar(191) NOT NULL,
  `worker_no` varchar(191) NOT NULL,
  `worker_type` varchar(191) NOT NULL,
  `work_status` varchar(191) NOT NULL,
  `start_date` varchar(191) DEFAULT NULL,
  `end_date` varchar(191) DEFAULT NULL,
  `primary_assignment_id` varchar(191) DEFAULT NULL,
  `version` bigint NOT NULL DEFAULT '1',
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_identity_workforce_profiles_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_identity_workforce_profiles_user` (`workspace_id`,`organization_id`,`identity_user_id`),
  UNIQUE KEY `uniq_identity_workforce_profiles_worker_no` (`workspace_id`,`organization_id`,`worker_no`),
  KEY `idx_identity_workforce_profiles_user` (`workspace_id`,`identity_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `identity_workforce_profiles`
--

LOCK TABLES `identity_workforce_profiles` WRITE;
/*!40000 ALTER TABLE `identity_workforce_profiles` DISABLE KEYS */;
INSERT INTO `identity_workforce_profiles` VALUES ('manager_lin_workforce','default','m2_field_service','manager_lin','MGR-001','employee','active',NULL,NULL,NULL,1,'2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('tech_east_chen_workforce','default','m2_field_service','tech_east_chen','TECH-E-001','employee','active',NULL,NULL,NULL,1,'2026-08-21T18:45:47Z','2026-08-21T18:45:47Z'),('tech_west_zhao_workforce','default','m2_field_service','tech_west_zhao','TECH-W-001','employee','active',NULL,NULL,NULL,1,'2026-08-21T18:45:47Z','2026-08-21T18:45:47Z');
/*!40000 ALTER TABLE `identity_workforce_profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `identity_workforce_transfer_batch_receipts`
--

DROP TABLE IF EXISTS `identity_workforce_transfer_batch_receipts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `identity_workforce_transfer_batch_receipts` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `actor_id` varchar(191) NOT NULL,
  `idempotency_key` varchar(191) NOT NULL,
  `request_fingerprint` varchar(191) NOT NULL,
  `result_json` text NOT NULL,
  `created_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_identity_workforce_transfer_receipt_workspace` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_identity_workforce_transfer_batch_receipt` (`workspace_id`,`idempotency_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `identity_workforce_transfer_batch_receipts`
--

LOCK TABLES `identity_workforce_transfer_batch_receipts` WRITE;
/*!40000 ALTER TABLE `identity_workforce_transfer_batch_receipts` DISABLE KEYS */;
/*!40000 ALTER TABLE `identity_workforce_transfer_batch_receipts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `integration_api_keys`
--

DROP TABLE IF EXISTS `integration_api_keys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `integration_api_keys` (
  `id` varchar(191) NOT NULL,
  `api_key` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `name` text,
  `token_prefix` varchar(191) NOT NULL DEFAULT '',
  `token_hash` varchar(191) NOT NULL,
  `actor_id` varchar(191) NOT NULL,
  `role_key` varchar(191) NOT NULL,
  `scopes_json` text NOT NULL DEFAULT (_utf8mb4'[]'),
  `status` varchar(191) NOT NULL,
  `expires_at` varchar(191) NOT NULL DEFAULT '',
  `last_used_at` varchar(191) NOT NULL DEFAULT '',
  `created_by` varchar(191) NOT NULL DEFAULT '',
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  `disabled_at` varchar(191) NOT NULL DEFAULT '',
  UNIQUE KEY `uniq_integration_api_keys_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_integration_api_keys_workspace_key` (`workspace_id`,`api_key`),
  UNIQUE KEY `uniq_integration_api_keys_token_hash` (`token_hash`),
  KEY `idx_integration_api_keys_status` (`workspace_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `integration_api_keys`
--

LOCK TABLES `integration_api_keys` WRITE;
/*!40000 ALTER TABLE `integration_api_keys` DISABLE KEYS */;
/*!40000 ALTER TABLE `integration_api_keys` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `integration_connections`
--

DROP TABLE IF EXISTS `integration_connections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `integration_connections` (
  `id` varchar(191) NOT NULL,
  `connection_key` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `connector_key` varchar(191) NOT NULL,
  `provider_key` varchar(191) NOT NULL DEFAULT '',
  `name` text,
  `status` varchar(191) NOT NULL,
  `config_json` text NOT NULL,
  `secret_refs_json` text NOT NULL,
  `created_by` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_integration_connections_workspace_identity` (`workspace_id`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `integration_connections`
--

LOCK TABLES `integration_connections` WRITE;
/*!40000 ALTER TABLE `integration_connections` DISABLE KEYS */;
/*!40000 ALTER TABLE `integration_connections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `integration_credential_refresh_leases`
--

DROP TABLE IF EXISTS `integration_credential_refresh_leases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `integration_credential_refresh_leases` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `connection_key` varchar(191) NOT NULL,
  `lease_owner` varchar(191) NOT NULL,
  `lease_expires_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_integration_credential_refresh_leases_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_integration_credential_refresh_lease` (`workspace_id`,`connection_key`),
  KEY `idx_integration_credential_refresh_lease_expiry` (`lease_expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `integration_credential_refresh_leases`
--

LOCK TABLES `integration_credential_refresh_leases` WRITE;
/*!40000 ALTER TABLE `integration_credential_refresh_leases` DISABLE KEYS */;
/*!40000 ALTER TABLE `integration_credential_refresh_leases` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `integration_event_mapping_definitions`
--

DROP TABLE IF EXISTS `integration_event_mapping_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `integration_event_mapping_definitions` (
  `id` varchar(191) NOT NULL,
  `resource_key` varchar(191) NOT NULL,
  `object_key` varchar(191) NOT NULL,
  `name` text NOT NULL,
  `payload_json` longtext NOT NULL,
  `schema_version` varchar(191) NOT NULL,
  `schema_hash` varchar(191) NOT NULL,
  `source_kind` varchar(191) NOT NULL,
  `source_id` varchar(191) NOT NULL,
  `disabled_at` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `resource_key` (`resource_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `integration_event_mapping_definitions`
--

LOCK TABLES `integration_event_mapping_definitions` WRITE;
/*!40000 ALTER TABLE `integration_event_mapping_definitions` DISABLE KEYS */;
/*!40000 ALTER TABLE `integration_event_mapping_definitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `integration_event_mapping_intents`
--

DROP TABLE IF EXISTS `integration_event_mapping_intents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `integration_event_mapping_intents` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `event_id` varchar(191) NOT NULL,
  `mapping_key` varchar(191) NOT NULL DEFAULT '',
  `target_type` varchar(191) NOT NULL,
  `status` varchar(191) NOT NULL,
  `payload_json` text NOT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_integration_event_mapping_intents_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_integration_event_mapping_intent` (`workspace_id`,`event_id`),
  KEY `idx_integration_event_mapping_intent_status` (`workspace_id`,`status`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `integration_event_mapping_intents`
--

LOCK TABLES `integration_event_mapping_intents` WRITE;
/*!40000 ALTER TABLE `integration_event_mapping_intents` DISABLE KEYS */;
/*!40000 ALTER TABLE `integration_event_mapping_intents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `integration_events`
--

DROP TABLE IF EXISTS `integration_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `integration_events` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `provider` varchar(191) NOT NULL,
  `event_type` varchar(191) NOT NULL,
  `external_id` varchar(191) NOT NULL,
  `status` varchar(191) NOT NULL,
  `payload_json` text NOT NULL,
  `error` text,
  `attempt_count` int NOT NULL DEFAULT '0',
  `next_retry_at` varchar(191) NOT NULL DEFAULT '',
  `last_attempt_at` varchar(191) NOT NULL DEFAULT '',
  `lease_owner` varchar(191) NOT NULL DEFAULT '',
  `lease_expires_at` varchar(191) NOT NULL DEFAULT '',
  `fencing_token` bigint NOT NULL DEFAULT '0',
  `received_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_integration_events_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_integration_events_external` (`workspace_id`,`provider`,`external_id`),
  KEY `idx_integration_events_status` (`workspace_id`,`provider`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `integration_events`
--

LOCK TABLES `integration_events` WRITE;
/*!40000 ALTER TABLE `integration_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `integration_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `integration_external_identities`
--

DROP TABLE IF EXISTS `integration_external_identities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `integration_external_identities` (
  `id` varchar(191) NOT NULL,
  `identity_key` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `provider` varchar(191) NOT NULL,
  `external_subject` varchar(191) NOT NULL,
  `external_subject_type` varchar(191) NOT NULL DEFAULT 'user',
  `external_name` varchar(191) DEFAULT NULL,
  `external_organization` varchar(191) DEFAULT NULL,
  `external_department` varchar(191) DEFAULT NULL,
  `external_group` varchar(191) DEFAULT NULL,
  `external_bot_id` varchar(191) DEFAULT NULL,
  `actor_id` varchar(191) NOT NULL,
  `role_key` varchar(191) NOT NULL,
  `status` varchar(191) NOT NULL,
  `last_resolved_at` varchar(191) DEFAULT NULL,
  `created_by` varchar(191) NOT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  `disabled_at` varchar(191) DEFAULT NULL,
  UNIQUE KEY `uniq_integration_external_identities_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_integration_external_identities_workspace_key` (`workspace_id`,`identity_key`),
  UNIQUE KEY `uniq_integration_external_identities_subject` (`workspace_id`,`provider`,`external_subject_type`,`external_subject`),
  KEY `idx_integration_external_identities_actor` (`actor_id`,`role_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `integration_external_identities`
--

LOCK TABLES `integration_external_identities` WRITE;
/*!40000 ALTER TABLE `integration_external_identities` DISABLE KEYS */;
/*!40000 ALTER TABLE `integration_external_identities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `integration_gmail_sync_states`
--

DROP TABLE IF EXISTS `integration_gmail_sync_states`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `integration_gmail_sync_states` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `connection_key` varchar(191) NOT NULL,
  `account_email` varchar(191) NOT NULL DEFAULT '',
  `history_id` varchar(191) NOT NULL DEFAULT '',
  `status` varchar(191) NOT NULL,
  `next_poll_at` varchar(191) NOT NULL DEFAULT '',
  `last_error_code` varchar(191) NOT NULL DEFAULT '',
  `attempt_count` int NOT NULL DEFAULT '0',
  `lease_owner` varchar(191) NOT NULL DEFAULT '',
  `lease_expires_at` varchar(191) NOT NULL DEFAULT '',
  `fencing_token` bigint NOT NULL DEFAULT '0',
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_integration_gmail_sync_states_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_integration_gmail_sync_state` (`workspace_id`,`connection_key`),
  KEY `idx_integration_gmail_sync_due` (`status`,`next_poll_at`,`lease_expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `integration_gmail_sync_states`
--

LOCK TABLES `integration_gmail_sync_states` WRITE;
/*!40000 ALTER TABLE `integration_gmail_sync_states` DISABLE KEYS */;
/*!40000 ALTER TABLE `integration_gmail_sync_states` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `integration_gmail_watch_states`
--

DROP TABLE IF EXISTS `integration_gmail_watch_states`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `integration_gmail_watch_states` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `connection_key` varchar(191) NOT NULL,
  `project_id` varchar(191) NOT NULL DEFAULT '',
  `topic_id` varchar(191) NOT NULL DEFAULT '',
  `subscription_id` varchar(191) NOT NULL DEFAULT '',
  `status` varchar(191) NOT NULL,
  `expires_at` varchar(191) NOT NULL DEFAULT '',
  `next_renew_at` varchar(191) NOT NULL DEFAULT '',
  `next_pull_at` varchar(191) NOT NULL DEFAULT '',
  `last_error_code` varchar(191) NOT NULL DEFAULT '',
  `attempt_count` int NOT NULL DEFAULT '0',
  `lease_owner` varchar(191) NOT NULL DEFAULT '',
  `lease_expires_at` varchar(191) NOT NULL DEFAULT '',
  `fencing_token` bigint NOT NULL DEFAULT '0',
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_integration_gmail_watch_states_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_integration_gmail_watch_state` (`workspace_id`,`connection_key`),
  KEY `idx_integration_gmail_watch_due` (`status`,`next_renew_at`,`next_pull_at`,`lease_expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `integration_gmail_watch_states`
--

LOCK TABLES `integration_gmail_watch_states` WRITE;
/*!40000 ALTER TABLE `integration_gmail_watch_states` DISABLE KEYS */;
/*!40000 ALTER TABLE `integration_gmail_watch_states` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `integration_invocations`
--

DROP TABLE IF EXISTS `integration_invocations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `integration_invocations` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `connector_key` varchar(191) NOT NULL,
  `provider_key` varchar(191) NOT NULL DEFAULT '',
  `connection_key` varchar(191) DEFAULT NULL,
  `operation` varchar(191) NOT NULL,
  `status` varchar(191) NOT NULL,
  `duration_ms` int NOT NULL DEFAULT '0',
  `request_ref` varchar(191) DEFAULT NULL,
  `response_ref` varchar(191) DEFAULT NULL,
  `error` text,
  `event_id` varchar(191) DEFAULT NULL,
  `object_key` varchar(191) DEFAULT NULL,
  `record_id` varchar(191) DEFAULT NULL,
  `workflow_execution_id` varchar(191) DEFAULT NULL,
  `metadata_json` text NOT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_integration_invocations_workspace_identity` (`workspace_id`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `integration_invocations`
--

LOCK TABLES `integration_invocations` WRITE;
/*!40000 ALTER TABLE `integration_invocations` DISABLE KEYS */;
/*!40000 ALTER TABLE `integration_invocations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `integration_outbox_messages`
--

DROP TABLE IF EXISTS `integration_outbox_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `integration_outbox_messages` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `connector_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `connection_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin DEFAULT NULL,
  `operation` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `status` varchar(191) NOT NULL,
  `payload_json` text NOT NULL,
  `event_id` varchar(191) DEFAULT NULL,
  `request_ref` text,
  `dedup_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '',
  `request_fingerprint` varchar(191) NOT NULL DEFAULT '',
  `response_ref` text,
  `error` text,
  `attempt_count` int NOT NULL DEFAULT '0',
  `next_attempt_at` varchar(191) NOT NULL DEFAULT '',
  `ack_deadline_at` varchar(191) NOT NULL DEFAULT '',
  `last_attempt_at` varchar(191) NOT NULL DEFAULT '',
  `lease_owner` varchar(191) NOT NULL DEFAULT '',
  `lease_expires_at` varchar(191) NOT NULL DEFAULT '',
  `fencing_token` bigint NOT NULL DEFAULT '0',
  `created_by` varchar(191) NOT NULL DEFAULT '',
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_integration_outbox_messages_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_integration_outbox_dedup` (`workspace_id`,`connector_key`,`connection_key`,`operation`,`dedup_key`),
  KEY `idx_integration_outbox_connector` (`workspace_id`,`connector_key`,`status`),
  KEY `idx_integration_outbox_due` (`status`,`next_attempt_at`),
  KEY `idx_integration_outbox_ack_due` (`status`,`ack_deadline_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `integration_outbox_messages`
--

LOCK TABLES `integration_outbox_messages` WRITE;
/*!40000 ALTER TABLE `integration_outbox_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `integration_outbox_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `integration_secret_materials`
--

DROP TABLE IF EXISTS `integration_secret_materials`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `integration_secret_materials` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `secret_key` varchar(191) NOT NULL,
  `ciphertext` text NOT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_integration_secret_materials_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_integration_secret_material` (`workspace_id`,`secret_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `integration_secret_materials`
--

LOCK TABLES `integration_secret_materials` WRITE;
/*!40000 ALTER TABLE `integration_secret_materials` DISABLE KEYS */;
/*!40000 ALTER TABLE `integration_secret_materials` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `integration_secrets`
--

DROP TABLE IF EXISTS `integration_secrets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `integration_secrets` (
  `id` varchar(191) NOT NULL,
  `secret_key` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `kind` varchar(191) NOT NULL,
  `status` varchar(191) NOT NULL,
  `description` text,
  `value_ref` text,
  `fingerprint` varchar(191) DEFAULT NULL,
  `created_by` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  `disabled_at` varchar(191) DEFAULT NULL,
  `expires_at` varchar(191) NOT NULL DEFAULT '',
  `rotated_at` varchar(191) NOT NULL DEFAULT '',
  `revoked_at` varchar(191) NOT NULL DEFAULT '',
  `last_tested_at` varchar(191) NOT NULL DEFAULT '',
  `last_test_status` varchar(191) NOT NULL DEFAULT '',
  `last_test_error` text NOT NULL DEFAULT (_utf8mb4''),
  UNIQUE KEY `uniq_integration_secrets_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_integration_secrets_workspace_key` (`workspace_id`,`secret_key`),
  KEY `idx_integration_secrets_status` (`workspace_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `integration_secrets`
--

LOCK TABLES `integration_secrets` WRITE;
/*!40000 ALTER TABLE `integration_secrets` DISABLE KEYS */;
/*!40000 ALTER TABLE `integration_secrets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `integration_webhook_nonces`
--

DROP TABLE IF EXISTS `integration_webhook_nonces`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `integration_webhook_nonces` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `connector_key` varchar(191) NOT NULL,
  `nonce` varchar(191) NOT NULL,
  `request_timestamp` varchar(191) NOT NULL,
  `created_at` varchar(191) NOT NULL,
  `expires_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_integration_webhook_nonces_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_integration_webhook_nonce` (`workspace_id`,`connector_key`,`nonce`),
  KEY `idx_integration_webhook_nonce_expiry` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `integration_webhook_nonces`
--

LOCK TABLES `integration_webhook_nonces` WRITE;
/*!40000 ALTER TABLE `integration_webhook_nonces` DISABLE KEYS */;
/*!40000 ALTER TABLE `integration_webhook_nonces` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `integration_webhook_subscriptions`
--

DROP TABLE IF EXISTS `integration_webhook_subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `integration_webhook_subscriptions` (
  `id` varchar(191) NOT NULL,
  `subscription_key` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `name` text,
  `connector_key` varchar(191) NOT NULL,
  `connection_key` varchar(191) NOT NULL,
  `event_types_json` text NOT NULL,
  `status` varchar(191) NOT NULL,
  `description` text,
  `created_by` varchar(191) NOT NULL DEFAULT '',
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  `disabled_at` varchar(191) NOT NULL DEFAULT '',
  UNIQUE KEY `uniq_integration_webhook_subscriptions_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_integration_webhook_subscription` (`workspace_id`,`subscription_key`),
  KEY `idx_integration_webhook_subscription_connection` (`workspace_id`,`connection_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `integration_webhook_subscriptions`
--

LOCK TABLES `integration_webhook_subscriptions` WRITE;
/*!40000 ALTER TABLE `integration_webhook_subscriptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `integration_webhook_subscriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_dead_letter`
--

DROP TABLE IF EXISTS `job_dead_letter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_dead_letter` (
  `workspace_id` varchar(191) NOT NULL,
  `id` varchar(191) NOT NULL,
  `created_at` text NOT NULL,
  `updated_at` text NOT NULL,
  `failed_at` text,
  `job_run_id` varchar(191) DEFAULT NULL,
  `last_error` text,
  `reason` text,
  `resolution_idempotency_key` text,
  `resolution_note` text,
  `resolved_at` text,
  `resolved_by` text,
  `scheduler_definition_key` text,
  `status` text,
  UNIQUE KEY `uidx_field_ad841a3fdb0f10a6` (`workspace_id`,`id`),
  KEY `idx_field_6d8a564b655c4374` (`job_run_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_dead_letter`
--

LOCK TABLES `job_dead_letter` WRITE;
/*!40000 ALTER TABLE `job_dead_letter` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_dead_letter` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_run`
--

DROP TABLE IF EXISTS `job_run`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_run` (
  `workspace_id` varchar(191) NOT NULL,
  `id` varchar(191) NOT NULL,
  `created_at` text NOT NULL,
  `updated_at` text NOT NULL,
  `attempt` double DEFAULT NULL,
  `error_category` text,
  `error_message` text,
  `fencing_token` double DEFAULT NULL,
  `finished_at` text,
  `idempotency_key` text,
  `idempotency_scope` text,
  `last_command_key` text,
  `last_command_scope` text,
  `lease_expires_at` text,
  `lease_owner` text,
  `max_attempts` double DEFAULT NULL,
  `next_retry_at` text,
  `payload_json` text,
  `recoverability` text,
  `result_json` text,
  `retry_backoff` text,
  `retry_backoff_seconds` double DEFAULT NULL,
  `retry_delay_seconds` double DEFAULT NULL,
  `retry_max_delay_seconds` double DEFAULT NULL,
  `scheduled_for` text,
  `scheduler_definition_key` text,
  `started_at` text,
  `status` text,
  `target_object` text,
  `target_record_id` text,
  `timeout_seconds` double DEFAULT NULL,
  `triggered_by` text,
  `workflow_execution_id` text,
  `workflow_key` text,
  UNIQUE KEY `uidx_field_c40b40d8de3ad24b` (`workspace_id`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_run`
--

LOCK TABLES `job_run` WRITE;
/*!40000 ALTER TABLE `job_run` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_run` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_run_event`
--

DROP TABLE IF EXISTS `job_run_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_run_event` (
  `workspace_id` varchar(191) NOT NULL,
  `id` varchar(191) NOT NULL,
  `created_at` text NOT NULL,
  `updated_at` text NOT NULL,
  `event_type` text,
  `job_run_id` varchar(191) DEFAULT NULL,
  `message` text,
  `metadata_json` text,
  UNIQUE KEY `uidx_field_b897075fe90fb121` (`workspace_id`,`id`),
  KEY `idx_field_2d456b9301b58e05` (`job_run_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_run_event`
--

LOCK TABLES `job_run_event` WRITE;
/*!40000 ALTER TABLE `job_run_event` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_run_event` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lifecycle_archive_entries`
--

DROP TABLE IF EXISTS `lifecycle_archive_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lifecycle_archive_entries` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `owner` varchar(191) NOT NULL,
  `source_table` varchar(191) NOT NULL,
  `resource_id` varchar(191) NOT NULL,
  `policy_key` varchar(191) NOT NULL,
  `policy_version` varchar(191) NOT NULL,
  `job_id` varchar(191) NOT NULL,
  `payload_hash` varchar(191) NOT NULL,
  `payload_json` text NOT NULL,
  `archived_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_lifecycle_archive_workspace_identity` (`workspace_id`,`id`),
  KEY `idx_lifecycle_archive_source` (`workspace_id`,`source_table`,`resource_id`,`archived_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lifecycle_archive_entries`
--

LOCK TABLES `lifecycle_archive_entries` WRITE;
/*!40000 ALTER TABLE `lifecycle_archive_entries` DISABLE KEYS */;
/*!40000 ALTER TABLE `lifecycle_archive_entries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lifecycle_audit_evidence`
--

DROP TABLE IF EXISTS `lifecycle_audit_evidence`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lifecycle_audit_evidence` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `event` varchar(191) NOT NULL,
  `resource_id` varchar(191) NOT NULL,
  `policy_key` varchar(191) NOT NULL DEFAULT '',
  `created_at` varchar(191) NOT NULL,
  `payload_json` text NOT NULL,
  UNIQUE KEY `uniq_lifecycle_audit_workspace_identity` (`workspace_id`,`id`),
  KEY `idx_lifecycle_audit_workspace` (`workspace_id`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lifecycle_audit_evidence`
--

LOCK TABLES `lifecycle_audit_evidence` WRITE;
/*!40000 ALTER TABLE `lifecycle_audit_evidence` DISABLE KEYS */;
INSERT INTO `lifecycle_audit_evidence` VALUES ('req_d969fc952a6fb319a87cf30c65d6e8ed','default','lifecycle.policy.defaults_installed','default','','2026-08-21T18:45:47.799687Z','{\"id\":\"req_d969fc952a6fb319a87cf30c65d6e8ed\",\"workspace_id\":\"default\",\"event\":\"lifecycle.policy.defaults_installed\",\"actor_id\":\"runtime-lifecycle\",\"resource_id\":\"default\",\"payload\":{\"workspace_id\":\"default\"},\"created_at\":\"2026-08-21T18:45:47.799687Z\"}');
/*!40000 ALTER TABLE `lifecycle_audit_evidence` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lifecycle_cleanup_jobs`
--

DROP TABLE IF EXISTS `lifecycle_cleanup_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lifecycle_cleanup_jobs` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `policy_key` varchar(191) NOT NULL,
  `policy_version` varchar(191) NOT NULL,
  `status` varchar(191) NOT NULL,
  `checkpoint_value` varchar(191) NOT NULL DEFAULT '',
  `lease_owner` varchar(191) NOT NULL DEFAULT '',
  `lease_expires_at` varchar(191) NOT NULL DEFAULT '',
  `fencing_token` bigint NOT NULL DEFAULT '0',
  `updated_at` varchar(191) NOT NULL,
  `payload_json` text NOT NULL,
  UNIQUE KEY `uniq_lifecycle_cleanup_workspace_identity` (`workspace_id`,`id`),
  KEY `idx_lifecycle_cleanup_claim` (`workspace_id`,`status`,`lease_expires_at`,`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lifecycle_cleanup_jobs`
--

LOCK TABLES `lifecycle_cleanup_jobs` WRITE;
/*!40000 ALTER TABLE `lifecycle_cleanup_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `lifecycle_cleanup_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lifecycle_deletion_registry`
--

DROP TABLE IF EXISTS `lifecycle_deletion_registry`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lifecycle_deletion_registry` (
  `request_id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `resolved_identity` varchar(191) NOT NULL,
  `backup_pending` tinyint(1) NOT NULL DEFAULT '1',
  `evidence` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_lifecycle_deletion_workspace_identity` (`workspace_id`,`request_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lifecycle_deletion_registry`
--

LOCK TABLES `lifecycle_deletion_registry` WRITE;
/*!40000 ALTER TABLE `lifecycle_deletion_registry` DISABLE KEYS */;
/*!40000 ALTER TABLE `lifecycle_deletion_registry` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lifecycle_external_erasures`
--

DROP TABLE IF EXISTS `lifecycle_external_erasures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lifecycle_external_erasures` (
  `id` varchar(191) NOT NULL,
  `request_id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `status` varchar(191) NOT NULL,
  `payload_json` text NOT NULL,
  UNIQUE KEY `uniq_lifecycle_external_workspace_identity` (`workspace_id`,`id`),
  KEY `idx_lifecycle_external_request` (`workspace_id`,`request_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lifecycle_external_erasures`
--

LOCK TABLES `lifecycle_external_erasures` WRITE;
/*!40000 ALTER TABLE `lifecycle_external_erasures` DISABLE KEYS */;
/*!40000 ALTER TABLE `lifecycle_external_erasures` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lifecycle_file_artifacts`
--

DROP TABLE IF EXISTS `lifecycle_file_artifacts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lifecycle_file_artifacts` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `object_key` varchar(191) NOT NULL,
  `field_key` varchar(191) NOT NULL,
  `filename` varchar(191) NOT NULL,
  `content_type` varchar(191) NOT NULL,
  `sha256` varchar(191) NOT NULL,
  `size_bytes` bigint NOT NULL,
  `status` varchar(191) NOT NULL,
  `scan_status` varchar(191) NOT NULL DEFAULT 'pending',
  `scan_provider` varchar(191) NOT NULL DEFAULT '',
  `scan_evidence_ref` varchar(191) NOT NULL DEFAULT '',
  `scanned_at` varchar(191) NOT NULL DEFAULT '',
  `created_at` varchar(191) NOT NULL,
  `last_referenced_at` varchar(191) NOT NULL DEFAULT '',
  `delete_after` varchar(191) NOT NULL DEFAULT '',
  `deleted_at` varchar(191) NOT NULL DEFAULT '',
  UNIQUE KEY `uniq_lifecycle_file_workspace_name` (`workspace_id`,`filename`),
  UNIQUE KEY `uniq_lifecycle_file_workspace_identity` (`workspace_id`,`id`),
  KEY `idx_lifecycle_file_cleanup` (`status`,`delete_after`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lifecycle_file_artifacts`
--

LOCK TABLES `lifecycle_file_artifacts` WRITE;
/*!40000 ALTER TABLE `lifecycle_file_artifacts` DISABLE KEYS */;
/*!40000 ALTER TABLE `lifecycle_file_artifacts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lifecycle_legal_holds`
--

DROP TABLE IF EXISTS `lifecycle_legal_holds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lifecycle_legal_holds` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `owner` varchar(191) NOT NULL DEFAULT '',
  `resource_type` varchar(191) NOT NULL DEFAULT '',
  `resource_id` varchar(191) NOT NULL DEFAULT '',
  `starts_at` varchar(191) NOT NULL,
  `ends_at` varchar(191) NOT NULL DEFAULT '',
  `review_at` varchar(191) NOT NULL,
  `payload_json` text NOT NULL,
  UNIQUE KEY `uniq_lifecycle_hold_workspace_identity` (`workspace_id`,`id`),
  KEY `idx_lifecycle_hold_scope` (`workspace_id`,`owner`,`resource_type`,`resource_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lifecycle_legal_holds`
--

LOCK TABLES `lifecycle_legal_holds` WRITE;
/*!40000 ALTER TABLE `lifecycle_legal_holds` DISABLE KEYS */;
/*!40000 ALTER TABLE `lifecycle_legal_holds` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lifecycle_policy_versions`
--

DROP TABLE IF EXISTS `lifecycle_policy_versions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lifecycle_policy_versions` (
  `workspace_id` varchar(191) NOT NULL,
  `policy_key` varchar(191) NOT NULL,
  `version` varchar(191) NOT NULL,
  `revision` bigint NOT NULL,
  `status` varchar(191) NOT NULL,
  `payload_json` text NOT NULL,
  `published_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_lifecycle_policy_version` (`workspace_id`,`policy_key`,`version`),
  UNIQUE KEY `uniq_lifecycle_policy_revision` (`workspace_id`,`policy_key`,`revision`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lifecycle_policy_versions`
--

LOCK TABLES `lifecycle_policy_versions` WRITE;
/*!40000 ALTER TABLE `lifecycle_policy_versions` DISABLE KEYS */;
INSERT INTO `lifecycle_policy_versions` VALUES ('default','agent.dialog.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"agent.dialog.v1\",\"Version\":\"1\",\"Owner\":\"agent\",\"Class\":\"product_retention\",\"Sensitivity\":[\"pii\"],\"DefaultRetention\":31536000000000000,\"MinimumRetention\":2592000000000000,\"StatusRetention\":{},\"ReplayWindow\":0,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":true,\"BackupBehavior\":\"delayed_erase_after_restore\",\"EraseBehavior\":\"anonymize\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','audit.evidence.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"audit.evidence.v1\",\"Version\":\"1\",\"Owner\":\"audit\",\"Class\":\"legal_audit_retention\",\"Sensitivity\":[\"audit\"],\"DefaultRetention\":220752000000000000,\"MinimumRetention\":31536000000000000,\"StatusRetention\":{},\"ReplayWindow\":0,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":true,\"BackupBehavior\":\"compliance_locked\",\"EraseBehavior\":\"anonymize\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','auth.provider_config.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"auth.provider_config.v1\",\"Version\":\"1\",\"Owner\":\"auth\",\"Class\":\"product_retention\",\"Sensitivity\":[\"security\"],\"DefaultRetention\":31536000000000000,\"MinimumRetention\":7776000000000000,\"StatusRetention\":{},\"ReplayWindow\":0,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":true,\"BackupBehavior\":\"delayed_erase_after_restore\",\"EraseBehavior\":\"delete\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','auth.technical_receipt.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"auth.technical_receipt.v1\",\"Version\":\"1\",\"Owner\":\"auth\",\"Class\":\"technical_ttl\",\"Sensitivity\":[\"security\"],\"DefaultRetention\":2592000000000000,\"MinimumRetention\":604800000000000,\"StatusRetention\":{},\"ReplayWindow\":604800000000000,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":false,\"BackupBehavior\":\"standard_restore_then_reconcile\",\"EraseBehavior\":\"delete\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','automation.execution.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"automation.execution.v1\",\"Version\":\"1\",\"Owner\":\"automation\",\"Class\":\"product_retention\",\"Sensitivity\":[\"sensitive\"],\"DefaultRetention\":31536000000000000,\"MinimumRetention\":7776000000000000,\"StatusRetention\":{\"failed\":31536000000000000,\"succeeded\":31536000000000000},\"ReplayWindow\":0,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":true,\"BackupBehavior\":\"standard_restore_then_reconcile\",\"EraseBehavior\":\"anonymize\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','cache.dictionary.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"cache.dictionary.v1\",\"Version\":\"1\",\"Owner\":\"record\",\"Class\":\"technical_ttl\",\"Sensitivity\":null,\"DefaultRetention\":900000000000,\"MinimumRetention\":60000000000,\"StatusRetention\":{},\"ReplayWindow\":0,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":false,\"BackupBehavior\":\"standard_restore_then_reconcile\",\"EraseBehavior\":\"delete\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','cache.runtime_projection.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"cache.runtime_projection.v1\",\"Version\":\"1\",\"Owner\":\"metadata\",\"Class\":\"technical_ttl\",\"Sensitivity\":[\"security\"],\"DefaultRetention\":900000000000,\"MinimumRetention\":60000000000,\"StatusRetention\":{},\"ReplayWindow\":0,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":false,\"BackupBehavior\":\"standard_restore_then_reconcile\",\"EraseBehavior\":\"delete\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','execution.idempotency_receipt.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"execution.idempotency_receipt.v1\",\"Version\":\"1\",\"Owner\":\"action\",\"Class\":\"technical_ttl\",\"Sensitivity\":[\"security\"],\"DefaultRetention\":2592000000000000,\"MinimumRetention\":604800000000000,\"StatusRetention\":{},\"ReplayWindow\":604800000000000,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":false,\"BackupBehavior\":\"standard_restore_then_reconcile\",\"EraseBehavior\":\"delete\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','file.upload.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"file.upload.v1\",\"Version\":\"1\",\"Owner\":\"upload\",\"Class\":\"product_retention\",\"Sensitivity\":[\"pii\"],\"DefaultRetention\":31536000000000000,\"MinimumRetention\":86400000000000,\"StatusRetention\":{},\"ReplayWindow\":0,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":true,\"BackupBehavior\":\"delayed_erase_after_restore\",\"EraseBehavior\":\"delete\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','identity.authentication.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"identity.authentication.v1\",\"Version\":\"1\",\"Owner\":\"identity\",\"Class\":\"user_requested_erase\",\"Sensitivity\":[\"security\"],\"DefaultRetention\":2592000000000000,\"MinimumRetention\":604800000000000,\"StatusRetention\":{},\"ReplayWindow\":0,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":true,\"BackupBehavior\":\"delayed_erase_after_restore\",\"EraseBehavior\":\"delete\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','identity.directory.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"identity.directory.v1\",\"Version\":\"1\",\"Owner\":\"identity\",\"Class\":\"user_requested_erase\",\"Sensitivity\":[\"pii\"],\"DefaultRetention\":7776000000000000,\"MinimumRetention\":2592000000000000,\"StatusRetention\":{},\"ReplayWindow\":0,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":true,\"BackupBehavior\":\"delayed_erase_after_restore\",\"EraseBehavior\":\"anonymize\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','integration.configuration.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"integration.configuration.v1\",\"Version\":\"1\",\"Owner\":\"integration\",\"Class\":\"product_retention\",\"Sensitivity\":[\"sensitive\"],\"DefaultRetention\":31536000000000000,\"MinimumRetention\":7776000000000000,\"StatusRetention\":{},\"ReplayWindow\":0,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":true,\"BackupBehavior\":\"delayed_erase_after_restore\",\"EraseBehavior\":\"anonymize\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','integration.delivery_evidence.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"integration.delivery_evidence.v1\",\"Version\":\"1\",\"Owner\":\"integration\",\"Class\":\"legal_audit_retention\",\"Sensitivity\":[\"audit\"],\"DefaultRetention\":31536000000000000,\"MinimumRetention\":7776000000000000,\"StatusRetention\":{},\"ReplayWindow\":0,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":true,\"BackupBehavior\":\"compliance_locked\",\"EraseBehavior\":\"anonymize\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','integration.event.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"integration.event.v1\",\"Version\":\"1\",\"Owner\":\"integration\",\"Class\":\"product_retention\",\"Sensitivity\":[\"pii\"],\"DefaultRetention\":7776000000000000,\"MinimumRetention\":2592000000000000,\"StatusRetention\":{\"failed\":31536000000000000,\"succeeded\":7776000000000000},\"ReplayWindow\":0,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":true,\"BackupBehavior\":\"delayed_erase_after_restore\",\"EraseBehavior\":\"anonymize\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','integration.identity_mapping.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"integration.identity_mapping.v1\",\"Version\":\"1\",\"Owner\":\"integration\",\"Class\":\"user_requested_erase\",\"Sensitivity\":[\"pii\"],\"DefaultRetention\":7776000000000000,\"MinimumRetention\":2592000000000000,\"StatusRetention\":{},\"ReplayWindow\":0,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":true,\"BackupBehavior\":\"delayed_erase_after_restore\",\"EraseBehavior\":\"anonymize\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','integration.secret.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"integration.secret.v1\",\"Version\":\"1\",\"Owner\":\"integration\",\"Class\":\"user_requested_erase\",\"Sensitivity\":[\"security\"],\"DefaultRetention\":2592000000000000,\"MinimumRetention\":2592000000000000,\"StatusRetention\":{},\"ReplayWindow\":0,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":true,\"BackupBehavior\":\"delayed_erase_after_restore\",\"EraseBehavior\":\"delete\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','integration.webhook_nonce.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"integration.webhook_nonce.v1\",\"Version\":\"1\",\"Owner\":\"integration\",\"Class\":\"technical_ttl\",\"Sensitivity\":[\"security\"],\"DefaultRetention\":86400000000000,\"MinimumRetention\":900000000000,\"StatusRetention\":{},\"ReplayWindow\":900000000000,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":false,\"BackupBehavior\":\"standard_restore_then_reconcile\",\"EraseBehavior\":\"delete\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','localization.text.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"localization.text.v1\",\"Version\":\"1\",\"Owner\":\"localization\",\"Class\":\"product_retention\",\"Sensitivity\":[\"pii\"],\"DefaultRetention\":31536000000000000,\"MinimumRetention\":2592000000000000,\"StatusRetention\":{},\"ReplayWindow\":0,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":true,\"BackupBehavior\":\"standard_restore_then_reconcile\",\"EraseBehavior\":\"anonymize\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','metadata.definition_history.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"metadata.definition_history.v1\",\"Version\":\"1\",\"Owner\":\"metadata\",\"Class\":\"product_retention\",\"Sensitivity\":[\"audit\"],\"DefaultRetention\":220752000000000000,\"MinimumRetention\":31536000000000000,\"StatusRetention\":{},\"ReplayWindow\":0,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":true,\"BackupBehavior\":\"compliance_locked\",\"EraseBehavior\":\"not_eligible\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','notification.history.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"notification.history.v1\",\"Version\":\"1\",\"Owner\":\"notification\",\"Class\":\"product_retention\",\"Sensitivity\":[\"pii\"],\"DefaultRetention\":15552000000000000,\"MinimumRetention\":2592000000000000,\"StatusRetention\":{},\"ReplayWindow\":0,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":true,\"BackupBehavior\":\"standard_restore_then_reconcile\",\"EraseBehavior\":\"anonymize\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','notification.publication_history.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"notification.publication_history.v1\",\"Version\":\"1\",\"Owner\":\"notification\",\"Class\":\"product_retention\",\"Sensitivity\":[\"audit\"],\"DefaultRetention\":63072000000000000,\"MinimumRetention\":7776000000000000,\"StatusRetention\":{},\"ReplayWindow\":0,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":true,\"BackupBehavior\":\"standard_restore_then_reconcile\",\"EraseBehavior\":\"not_eligible\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','operations.break_glass.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"operations.break_glass.v1\",\"Version\":\"1\",\"Owner\":\"operations\",\"Class\":\"legal_audit_retention\",\"Sensitivity\":[\"audit\",\"security\"],\"DefaultRetention\":220752000000000000,\"MinimumRetention\":31536000000000000,\"StatusRetention\":{},\"ReplayWindow\":0,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":true,\"BackupBehavior\":\"compliance_locked\",\"EraseBehavior\":\"not_eligible\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','operations.control.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"operations.control.v1\",\"Version\":\"1\",\"Owner\":\"operations\",\"Class\":\"legal_audit_retention\",\"Sensitivity\":[\"audit\",\"security\"],\"DefaultRetention\":220752000000000000,\"MinimumRetention\":31536000000000000,\"StatusRetention\":{},\"ReplayWindow\":0,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":true,\"BackupBehavior\":\"compliance_locked\",\"EraseBehavior\":\"not_eligible\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','operations.receipt.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"operations.receipt.v1\",\"Version\":\"1\",\"Owner\":\"operations\",\"Class\":\"legal_audit_retention\",\"Sensitivity\":[\"audit\",\"security\"],\"DefaultRetention\":220752000000000000,\"MinimumRetention\":7776000000000000,\"StatusRetention\":{},\"ReplayWindow\":0,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":true,\"BackupBehavior\":\"compliance_locked\",\"EraseBehavior\":\"not_eligible\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','persistence.migration_evidence.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"persistence.migration_evidence.v1\",\"Version\":\"1\",\"Owner\":\"deployment\",\"Class\":\"legal_audit_retention\",\"Sensitivity\":[\"audit\"],\"DefaultRetention\":3153600000000000000,\"MinimumRetention\":3153600000000000000,\"StatusRetention\":{},\"ReplayWindow\":0,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":true,\"BackupBehavior\":\"compliance_locked\",\"EraseBehavior\":\"not_eligible\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','ratelimit.bucket.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"ratelimit.bucket.v1\",\"Version\":\"1\",\"Owner\":\"auth\",\"Class\":\"technical_ttl\",\"Sensitivity\":[\"security\"],\"DefaultRetention\":86400000000000,\"MinimumRetention\":3600000000000,\"StatusRetention\":{},\"ReplayWindow\":0,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":false,\"BackupBehavior\":\"standard_restore_then_reconcile\",\"EraseBehavior\":\"delete\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','record.batch_artifact.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"record.batch_artifact.v1\",\"Version\":\"1\",\"Owner\":\"record\",\"Class\":\"product_retention\",\"Sensitivity\":[\"pii\"],\"DefaultRetention\":7776000000000000,\"MinimumRetention\":86400000000000,\"StatusRetention\":{},\"ReplayWindow\":0,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":true,\"BackupBehavior\":\"delayed_erase_after_restore\",\"EraseBehavior\":\"delete\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','record.object.default.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"record.object.default.v1\",\"Version\":\"1\",\"Owner\":\"record\",\"Class\":\"product_retention\",\"Sensitivity\":[\"sensitive\"],\"DefaultRetention\":31536000000000000,\"MinimumRetention\":2592000000000000,\"StatusRetention\":{},\"ReplayWindow\":0,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":true,\"BackupBehavior\":\"delayed_erase_after_restore\",\"EraseBehavior\":\"anonymize\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','report.download.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"report.download.v1\",\"Version\":\"1\",\"Owner\":\"report\",\"Class\":\"technical_ttl\",\"Sensitivity\":[\"pii\"],\"DefaultRetention\":604800000000000,\"MinimumRetention\":86400000000000,\"StatusRetention\":{},\"ReplayWindow\":0,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":false,\"BackupBehavior\":\"standard_restore_then_reconcile\",\"EraseBehavior\":\"delete\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','report.export.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"report.export.v1\",\"Version\":\"1\",\"Owner\":\"report\",\"Class\":\"legal_audit_retention\",\"Sensitivity\":[\"pii\",\"audit\"],\"DefaultRetention\":31536000000000000,\"MinimumRetention\":7776000000000000,\"StatusRetention\":{\"failed\":31536000000000000,\"succeeded\":31536000000000000},\"ReplayWindow\":0,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":true,\"BackupBehavior\":\"delayed_erase_after_restore\",\"EraseBehavior\":\"anonymize\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','runtime.configuration.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"runtime.configuration.v1\",\"Version\":\"1\",\"Owner\":\"capability\",\"Class\":\"product_retention\",\"Sensitivity\":null,\"DefaultRetention\":31536000000000000,\"MinimumRetention\":7776000000000000,\"StatusRetention\":{},\"ReplayWindow\":0,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":true,\"BackupBehavior\":\"standard_restore_then_reconcile\",\"EraseBehavior\":\"not_eligible\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','scheduler.execution.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"scheduler.execution.v1\",\"Version\":\"1\",\"Owner\":\"scheduler\",\"Class\":\"product_retention\",\"Sensitivity\":[\"audit\"],\"DefaultRetention\":31536000000000000,\"MinimumRetention\":7776000000000000,\"StatusRetention\":{\"dead_letter\":31536000000000000,\"failed\":31536000000000000,\"succeeded\":15552000000000000},\"ReplayWindow\":0,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":true,\"BackupBehavior\":\"standard_restore_then_reconcile\",\"EraseBehavior\":\"anonymize\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','technical.lease_checkpoint.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"technical.lease_checkpoint.v1\",\"Version\":\"1\",\"Owner\":\"integration\",\"Class\":\"technical_ttl\",\"Sensitivity\":null,\"DefaultRetention\":604800000000000,\"MinimumRetention\":86400000000000,\"StatusRetention\":{},\"ReplayWindow\":0,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":false,\"BackupBehavior\":\"standard_restore_then_reconcile\",\"EraseBehavior\":\"delete\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','workflow.definition.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"workflow.definition.v1\",\"Version\":\"1\",\"Owner\":\"workflow\",\"Class\":\"product_retention\",\"Sensitivity\":null,\"DefaultRetention\":63072000000000000,\"MinimumRetention\":31536000000000000,\"StatusRetention\":{},\"ReplayWindow\":0,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":true,\"BackupBehavior\":\"standard_restore_then_reconcile\",\"EraseBehavior\":\"not_eligible\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','workflow.execution.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"workflow.execution.v1\",\"Version\":\"1\",\"Owner\":\"workflow\",\"Class\":\"legal_audit_retention\",\"Sensitivity\":[\"audit\"],\"DefaultRetention\":220752000000000000,\"MinimumRetention\":31536000000000000,\"StatusRetention\":{\"failed\":220752000000000000,\"succeeded\":220752000000000000},\"ReplayWindow\":0,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":true,\"BackupBehavior\":\"compliance_locked\",\"EraseBehavior\":\"anonymize\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z'),('default','workflow.receipt.v1','1',1,'published','{\"workspace_id\":\"default\",\"policy\":{\"Key\":\"workflow.receipt.v1\",\"Version\":\"1\",\"Owner\":\"workflow\",\"Class\":\"technical_ttl\",\"Sensitivity\":[\"security\"],\"DefaultRetention\":2592000000000000,\"MinimumRetention\":604800000000000,\"StatusRetention\":{},\"ReplayWindow\":604800000000000,\"WorkspaceMayExtend\":true,\"WorkspaceMayReduce\":false,\"LegalHoldEligible\":false,\"BackupBehavior\":\"standard_restore_then_reconcile\",\"EraseBehavior\":\"delete\",\"RequiredReferenceChecks\":null},\"status\":\"published\",\"revision\":1,\"published_by\":\"runtime-lifecycle\",\"published_at\":\"2026-08-21T18:45:47.78525Z\",\"estimated_rows\":0,\"estimated_bytes\":0}','2026-08-21T18:45:47.78525Z');
/*!40000 ALTER TABLE `lifecycle_policy_versions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lifecycle_subject_requests`
--

DROP TABLE IF EXISTS `lifecycle_subject_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lifecycle_subject_requests` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `kind` varchar(191) NOT NULL,
  `status` varchar(191) NOT NULL,
  `subject_id` varchar(191) NOT NULL,
  `resolved_identity` varchar(191) NOT NULL DEFAULT '',
  `download_expires_at` varchar(191) NOT NULL DEFAULT '',
  `updated_at` varchar(191) NOT NULL,
  `payload_json` text NOT NULL,
  UNIQUE KEY `uniq_lifecycle_subject_workspace_identity` (`workspace_id`,`id`),
  KEY `idx_lifecycle_subject_identity` (`workspace_id`,`subject_id`,`status`,`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lifecycle_subject_requests`
--

LOCK TABLES `lifecycle_subject_requests` WRITE;
/*!40000 ALTER TABLE `lifecycle_subject_requests` DISABLE KEYS */;
/*!40000 ALTER TABLE `lifecycle_subject_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `metadata_catalog`
--

DROP TABLE IF EXISTS `metadata_catalog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `metadata_catalog` (
  `key` varchar(191) NOT NULL,
  `value` longtext NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `metadata_catalog`
--

LOCK TABLES `metadata_catalog` WRITE;
/*!40000 ALTER TABLE `metadata_catalog` DISABLE KEYS */;
INSERT INTO `metadata_catalog` VALUES ('default_locale','en-US','2026-08-21T18:45:46Z'),('identity_seed_synced_version','0.1.0:ca814278f65e1f915e682cffe16196722eb9f9acb8b0df1bfb784efd5abeca6f','2026-08-21T18:45:47Z'),('name','M2 Equipment Field Service','2026-08-21T18:45:46Z'),('organization_scope_seed_state','{\"scope_ids\":{},\"membership_ids\":{}}','2026-08-21T18:45:47Z'),('schema_hash','ecf1344888d09628e4c210336891bbf07b4065c49c7ac6e963218510c761adf4','2026-08-21T18:45:47Z'),('schema_version','0.1.0','2026-08-21T18:45:46Z'),('template_id','domain_m2_field_service','2026-08-21T18:45:46Z'),('template_version','0.1.0','2026-08-21T18:45:46Z');
/*!40000 ALTER TABLE `metadata_catalog` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `metadata_definition_versions`
--

DROP TABLE IF EXISTS `metadata_definition_versions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `metadata_definition_versions` (
  `id` varchar(191) NOT NULL,
  `resource_type` varchar(191) NOT NULL,
  `resource_key` varchar(191) NOT NULL,
  `schema_version` varchar(191) NOT NULL,
  `schema_hash` varchar(191) NOT NULL,
  `payload_json` longtext NOT NULL,
  `created_at` varchar(191) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `metadata_definition_versions`
--

LOCK TABLES `metadata_definition_versions` WRITE;
/*!40000 ALTER TABLE `metadata_definition_versions` DISABLE KEYS */;
INSERT INTO `metadata_definition_versions` VALUES ('action:version:report_export_audit.request_work_order_export','action','report_export_audit.request_work_order_export','0.1.0','9e186d588348e617ee22c9d3eb5a718343819e613ff6d652901d66aa6cb76141','{\"key\":\"report_export_audit.request_work_order_export\",\"object_key\":\"report_export_audit\",\"label\":\"Request work-order export\",\"kind\":\"object_create\",\"requires_permission\":\"report_export_audit.create\",\"preconditions\":[],\"audit_event\":\"report_export.requested\",\"payload_fields\":[{\"key\":\"purpose\",\"name\":\"Purpose\",\"type\":\"long_text\",\"required\":true},{\"key\":\"report_key\",\"name\":\"Report key\",\"type\":\"text\",\"required\":true},{\"key\":\"requested_at\",\"name\":\"Requested at\",\"type\":\"datetime\",\"required\":true},{\"key\":\"status\",\"name\":\"Status\",\"type\":\"select\",\"options\":[\"requested\"],\"required\":true}],\"idempotency_keys\":[\"report_key\",\"requested_at\"]}','2026-08-21T18:45:46Z'),('action:version:service_request.complete_repair','action','service_request.complete_repair','0.1.0','19e53b8e97aefbce708f2ea0c1935397941b187d7c14cbaf3f0873955b450165','{\"key\":\"service_request.complete_repair\",\"object_key\":\"service_request\",\"label\":\"Complete repair\",\"kind\":\"record_operation\",\"requires_permission\":\"service_request.complete_repair\",\"preconditions\":[],\"audit_event\":\"service_request.completed\",\"input_type\":\"example.com/m2-fieldservice/generated/capabilities.CompleteRepairInput\",\"output_type\":\"example.com/m2-fieldservice/generated/capabilities.CompleteRepairOutput\",\"input_contract_sha256\":\"f65d274f74496892258e1008f6dcc347915ed6cb5ef3968199023f058ca4640e\",\"output_contract_sha256\":\"a80255047c1d82383db63a1b81e0d31b9cf28fdf0d65e28ad74afb58f06104cb\",\"payload_fields\":[{\"key\":\"completed_at\",\"name\":\"Completed at\",\"type\":\"datetime\",\"required\":true},{\"key\":\"quote_amount\",\"name\":\"Quoted fee\",\"type\":\"currency\",\"required\":true,\"source_object_key\":\"service_request\",\"source_field_key\":\"quote_amount\"},{\"key\":\"request_id\",\"name\":\"Request ID\",\"type\":\"text\",\"required\":true},{\"key\":\"usage_lines_json\",\"name\":\"Usage lines JSON\",\"type\":\"long_text\",\"required\":true}],\"output_fields\":[{\"key\":\"service_request_id\",\"type\":\"object_id\",\"required\":true},{\"key\":\"usage_count\",\"type\":\"integer\",\"required\":true},{\"key\":\"fee_ledger_id\",\"type\":\"object_id\",\"required\":true}],\"idempotency_keys\":[\"request_id\"]}','2026-08-21T18:45:46Z'),('action:version:service_request.dispatch_service_request','action','service_request.dispatch_service_request','0.1.0','6834b060272c9fb97839800539609dd2a89ff55ca7e895bda6f00d4bb19e8355','{\"key\":\"service_request.dispatch_service_request\",\"object_key\":\"service_request\",\"label\":\"Dispatch service request\",\"kind\":\"record_operation\",\"requires_permission\":\"service_request.dispatch_service_request\",\"preconditions\":[],\"audit_event\":\"service_request.dispatched\",\"input_type\":\"example.com/m2-fieldservice/generated/capabilities.DispatchServiceRequestInput\",\"output_type\":\"example.com/m2-fieldservice/generated/capabilities.DispatchServiceRequestOutput\",\"input_contract_sha256\":\"002f51a6a133f4604caef3ae206a629fe88c48a5199b8accd976d2f1d77716fa\",\"output_contract_sha256\":\"716793298e843434a2b287bc8dfe05043293500f90f2858cda3d235f3e55880b\",\"payload_fields\":[{\"key\":\"assigned_user_id\",\"name\":\"Assigned technician\",\"type\":\"user\",\"required\":true},{\"key\":\"dispatched_at\",\"name\":\"Dispatched at\",\"type\":\"datetime\",\"required\":true},{\"key\":\"organization_unit_id\",\"name\":\"Station ID\",\"type\":\"text\",\"required\":true},{\"key\":\"request_id\",\"name\":\"Request ID\",\"type\":\"text\",\"required\":true}],\"output_fields\":[{\"key\":\"service_request_id\",\"type\":\"object_id\",\"required\":true},{\"key\":\"status\",\"type\":\"value_domain\",\"required\":true}],\"idempotency_keys\":[\"request_id\"]}','2026-08-21T18:45:46Z'),('action:version:service_request.request_warranty_waiver','action','service_request.request_warranty_waiver','0.1.0','30e41857ed6c82030f7d2421821d339b934cb6871b04caa68377526b48c3c654','{\"key\":\"service_request.request_warranty_waiver\",\"object_key\":\"service_request\",\"label\":\"Request warranty waiver\",\"kind\":\"record_operation\",\"requires_permission\":\"service_request.request_warranty_waiver\",\"preconditions\":[],\"audit_event\":\"warranty_waiver.requested\",\"input_type\":\"example.com/m2-fieldservice/generated/capabilities.RequestWarrantyWaiverInput\",\"output_type\":\"example.com/m2-fieldservice/generated/capabilities.RequestWarrantyWaiverOutput\",\"input_contract_sha256\":\"ca1ef7f04eb05d14ffe5c939cdddc640ee791819e06c22c4978deba5e6ed09e5\",\"output_contract_sha256\":\"6e4ae117866e0e94ab75ad51db849dbf91ce72ca981258aae11bd5fb1b00137e\",\"payload_fields\":[{\"key\":\"request_id\",\"name\":\"Request ID\",\"type\":\"text\",\"required\":true},{\"key\":\"requested_amount\",\"name\":\"Requested waiver\",\"type\":\"currency\",\"required\":true,\"source_object_key\":\"warranty_waiver\",\"source_field_key\":\"requested_amount\"},{\"key\":\"requested_at\",\"name\":\"Requested at\",\"type\":\"datetime\",\"required\":true},{\"key\":\"warranty_asserted\",\"name\":\"Warranty eligibility asserted\",\"type\":\"boolean\",\"required\":true}],\"output_fields\":[{\"key\":\"warranty_waiver_id\",\"type\":\"object_id\",\"required\":true},{\"key\":\"status\",\"type\":\"value_domain\",\"required\":true}],\"idempotency_keys\":[\"request_id\"]}','2026-08-21T18:45:46Z'),('action:version:service_request.send_overdue_reminder','action','service_request.send_overdue_reminder','0.1.0','eb498e98656e6fee9c9ac9aeb030ea7ebb33e0778b68f631db8a20c4e504beb2','{\"key\":\"service_request.send_overdue_reminder\",\"object_key\":\"service_request\",\"label\":\"Send overdue reminder\",\"kind\":\"record_operation\",\"requires_permission\":\"service_request.send_overdue_reminder\",\"preconditions\":[],\"audit_event\":\"service_request.overdue_reminder_sent\",\"input_type\":\"example.com/m2-fieldservice/generated/capabilities.SendOverdueReminderInput\",\"output_type\":\"example.com/m2-fieldservice/generated/capabilities.SendOverdueReminderOutput\",\"input_contract_sha256\":\"19ded76f4f0a61b35947544b48af3eed3f0d53bd28e9797d6875db23ba2308fc\",\"output_contract_sha256\":\"d80d06c14240ffab8e40605df4476213f81ffca8c9807104257b6f4c3ebb5032\",\"payload_fields\":[{\"key\":\"scheduled_at\",\"name\":\"Scheduled at\",\"type\":\"datetime\",\"required\":true}],\"output_fields\":[{\"key\":\"created\",\"type\":\"boolean\",\"required\":true},{\"key\":\"overdue_reminder_id\",\"type\":\"object_id\"}],\"idempotency_keys\":[\"scheduled_at\"]}','2026-08-21T18:45:46Z'),('action:version:service_request.start_assigned_repair','action','service_request.start_assigned_repair','0.1.0','286769698f63a26f656479af0933831feba615c15c78ad1792da004945f352d0','{\"key\":\"service_request.start_assigned_repair\",\"object_key\":\"service_request\",\"label\":\"Start assigned repair\",\"kind\":\"record_operation\",\"requires_permission\":\"service_request.start_assigned_repair\",\"preconditions\":[],\"audit_event\":\"service_request.repair_started\",\"input_type\":\"example.com/m2-fieldservice/generated/capabilities.StartAssignedRepairInput\",\"output_type\":\"example.com/m2-fieldservice/generated/capabilities.StartAssignedRepairOutput\",\"input_contract_sha256\":\"c457c8219a487fa92f83d7e20fa7f62604372d2b682577a3bfbd9c5d10c8378d\",\"output_contract_sha256\":\"0140168d9454cdf60a710c2aca48d85eb5776faa8f1b26e23a1a7547d843b4ec\",\"payload_fields\":[{\"key\":\"request_id\",\"name\":\"Request ID\",\"type\":\"text\",\"required\":true},{\"key\":\"started_at\",\"name\":\"Started at\",\"type\":\"datetime\",\"required\":true}],\"output_fields\":[{\"key\":\"service_request_id\",\"type\":\"object_id\",\"required\":true},{\"key\":\"status\",\"type\":\"value_domain\",\"required\":true}],\"idempotency_keys\":[\"request_id\"]}','2026-08-21T18:45:46Z'),('action:version:service_request.submit_service_request','action','service_request.submit_service_request','0.1.0','03131c9104cb0f7c5b1fd6b090a4e7e0fa7fe45c5c617badade5cf08589d3a09','{\"key\":\"service_request.submit_service_request\",\"object_key\":\"service_request\",\"label\":\"Submit service request\",\"kind\":\"object_operation\",\"requires_permission\":\"service_request.submit_service_request\",\"preconditions\":[],\"audit_event\":\"service_request.submitted\",\"input_type\":\"example.com/m2-fieldservice/generated/capabilities.SubmitServiceRequestInput\",\"output_type\":\"example.com/m2-fieldservice/generated/capabilities.SubmitServiceRequestOutput\",\"input_contract_sha256\":\"ac80cff74c4c63086d60f972eb25276b71c9efef27d8e5576bb5e4a888cf82c6\",\"output_contract_sha256\":\"82c2c286fa64ff6039cb40e7d97d43d2f1f5de972eba6b0ae79a356280bb0fc4\",\"payload_fields\":[{\"key\":\"device_id\",\"name\":\"Device\",\"type\":\"relation\",\"required\":true,\"target_object_key\":\"device\"},{\"key\":\"fault_description\",\"name\":\"Fault description\",\"type\":\"long_text\",\"required\":true},{\"key\":\"preferred_visit_at\",\"name\":\"Preferred visit time\",\"type\":\"datetime\",\"required\":true},{\"key\":\"request_id\",\"name\":\"Request ID\",\"type\":\"text\",\"required\":true},{\"key\":\"submitted_at\",\"name\":\"Submitted at\",\"type\":\"datetime\",\"required\":true}],\"output_fields\":[{\"key\":\"service_request_id\",\"type\":\"object_id\",\"required\":true},{\"key\":\"status\",\"type\":\"value_domain\",\"required\":true}],\"idempotency_keys\":[\"request_id\"]}','2026-08-21T18:45:46Z'),('action:version:service_request.unassign_service_request','action','service_request.unassign_service_request','0.1.0','8acf2f896e3ac269d4a069d049b31394ef42c0265796e53617ecc0233c1dd8a0','{\"key\":\"service_request.unassign_service_request\",\"object_key\":\"service_request\",\"label\":\"Unassign service request\",\"kind\":\"record_operation\",\"requires_permission\":\"service_request.unassign_service_request\",\"preconditions\":[],\"audit_event\":\"service_request.unassigned\",\"input_type\":\"example.com/m2-fieldservice/generated/capabilities.UnassignServiceRequestInput\",\"output_type\":\"example.com/m2-fieldservice/generated/capabilities.UnassignServiceRequestOutput\",\"input_contract_sha256\":\"ca25d84356bae2994ad1ef2e826d1cf3f9b460c6c2b8c6b7ad63e6ccae67a70e\",\"output_contract_sha256\":\"bfe26b4fcdf61461a59c8305bf5c727916dc38f81ff4b3dbc0c3fc0e4d2e6907\",\"payload_fields\":[{\"key\":\"request_id\",\"name\":\"Request ID\",\"type\":\"text\",\"required\":true}],\"output_fields\":[{\"key\":\"service_request_id\",\"type\":\"object_id\",\"required\":true},{\"key\":\"status\",\"type\":\"value_domain\",\"required\":true}],\"idempotency_keys\":[\"request_id\"]}','2026-08-21T18:45:46Z'),('action:version:warranty_waiver.decide_warranty_waiver','action','warranty_waiver.decide_warranty_waiver','0.1.0','297a63d306fbdf7fc67515ad785b8d8d83fa3115be4ff8d001827d728e52ec0f','{\"key\":\"warranty_waiver.decide_warranty_waiver\",\"object_key\":\"warranty_waiver\",\"label\":\"Decide warranty waiver\",\"kind\":\"record_operation\",\"requires_permission\":\"warranty_waiver.decide_warranty_waiver\",\"preconditions\":[],\"audit_event\":\"warranty_waiver.decided\",\"input_type\":\"example.com/m2-fieldservice/generated/capabilities.DecideWarrantyWaiverInput\",\"output_type\":\"example.com/m2-fieldservice/generated/capabilities.DecideWarrantyWaiverOutput\",\"input_contract_sha256\":\"d47de7fb02b4bb4be529c3fdc2579692946f44360698fbb29b18dd53467b4a16\",\"output_contract_sha256\":\"cdf72e574945b2ef7be5e086c84d748948fc15d279fb1477df330ad6fea97edf\",\"payload_fields\":[{\"key\":\"decided_at\",\"name\":\"Decided at\",\"type\":\"datetime\",\"required\":true},{\"key\":\"decision\",\"name\":\"Decision\",\"type\":\"select\",\"options\":[\"approved\",\"rejected\"],\"required\":true},{\"key\":\"rejection_reason\",\"name\":\"Rejection reason\",\"type\":\"long_text\"}],\"output_fields\":[{\"key\":\"warranty_waiver_id\",\"type\":\"object_id\",\"required\":true},{\"key\":\"status\",\"type\":\"value_domain\",\"required\":true}],\"idempotency_keys\":[\"decision\"]}','2026-08-21T18:45:46Z'),('dictionary:version:audit_event_category','dictionary','audit_event_category','0.1.0','61cbfefe652cd4c3c89eecbe89c5bb006588ea40cb876690b9d14d0c2dd649a4','{\"key\":\"audit_event_category\",\"name\":\"Audit event category\",\"description\":\"Default categories shown by audit and operations surfaces.\",\"source\":\"platform\",\"items\":[{\"key\":\"access\",\"label\":\"Access\",\"value\":\"access\",\"sort_order\":10,\"status\":\"active\"},{\"key\":\"metadata\",\"label\":\"Metadata\",\"value\":\"metadata\",\"sort_order\":20,\"status\":\"active\"},{\"key\":\"workflow\",\"label\":\"Workflow\",\"value\":\"workflow\",\"sort_order\":30,\"status\":\"active\"},{\"key\":\"import_export\",\"label\":\"Import / export\",\"value\":\"import_export\",\"sort_order\":40,\"status\":\"active\"},{\"key\":\"operations\",\"label\":\"Operations\",\"value\":\"operations\",\"sort_order\":50,\"status\":\"active\"}]}','2026-08-21T18:45:46Z'),('dictionary:version:platform_operation_status','dictionary','platform_operation_status','0.1.0','5ca97464ea7f3fdbb5d27b05c81d53aede9f2d0c3c47d231a50c0947fb176aab','{\"key\":\"platform_operation_status\",\"name\":\"Platform operation status\",\"description\":\"Default status values used by global system capability pages.\",\"source\":\"platform\",\"items\":[{\"key\":\"enabled\",\"label\":\"Enabled\",\"value\":\"enabled\",\"sort_order\":10,\"status\":\"active\",\"color\":\"green\"},{\"key\":\"disabled\",\"label\":\"Disabled\",\"value\":\"disabled\",\"sort_order\":20,\"status\":\"active\",\"color\":\"slate\"},{\"key\":\"warning\",\"label\":\"Warning\",\"value\":\"warning\",\"sort_order\":30,\"status\":\"active\",\"color\":\"amber\"},{\"key\":\"failed\",\"label\":\"Failed\",\"value\":\"failed\",\"sort_order\":40,\"status\":\"active\",\"color\":\"red\"}]}','2026-08-21T18:45:46Z'),('dictionary:version:workflow_execution_status','dictionary','workflow_execution_status','0.1.0','b26e16ec1bbe98f255331de9176fdab117deb5f169c8a2501a42df724a584343','{\"key\":\"workflow_execution_status\",\"name\":\"Workflow execution status\",\"description\":\"Default workflow execution lifecycle values for the global workflow console.\",\"source\":\"platform\",\"items\":[{\"key\":\"queued\",\"label\":\"Queued\",\"value\":\"queued\",\"sort_order\":10,\"status\":\"active\"},{\"key\":\"running\",\"label\":\"Running\",\"value\":\"running\",\"sort_order\":20,\"status\":\"active\"},{\"key\":\"completed\",\"label\":\"Completed\",\"value\":\"completed\",\"sort_order\":30,\"status\":\"active\"},{\"key\":\"failed\",\"label\":\"Failed\",\"value\":\"failed\",\"sort_order\":40,\"status\":\"active\"},{\"key\":\"dead_lettered\",\"label\":\"Dead lettered\",\"value\":\"dead_lettered\",\"sort_order\":50,\"status\":\"active\"}]}','2026-08-21T18:45:46Z'),('entrypoint:version:fieldservice_business','entrypoint','fieldservice_business','0.1.0','62197f7d05835f163c18f300f363b274d978685a666f34d97fe60b58325836df','{\"key\":\"fieldservice_business\",\"name\":\"Field Service Business Workspace\",\"description\":\"Focused operational workspace for internal roles.\",\"audience\":\"internal\",\"roles\":[\"ops_manager\"],\"default\":true,\"config\":{\"create_objects\":[],\"journeys\":[],\"kind\":\"operator_console\",\"primary_object\":\"service_request\",\"read_objects\":[\"service_request\",\"spare_part\",\"part_usage\",\"warranty_waiver\",\"fee_ledger\"],\"update_objects\":[]}}','2026-08-21T18:45:46Z'),('entrypoint:version:fieldservice_portal','entrypoint','fieldservice_portal','0.1.0','1e1ecd6ea097fcd8367d42250736b83345a43d49cf1b8ba173703bebe54f69ec','{\"key\":\"fieldservice_portal\",\"name\":\"Field Service Customer Portal\",\"description\":\"Self-service domain entrypoint for external customers.\",\"audience\":\"consumer\",\"roles\":[\"customer\"],\"config\":{\"create_objects\":[],\"journeys\":[],\"kind\":\"customer_portal\",\"primary_object\":\"service_request\",\"read_objects\":[\"customer_profile\",\"device\",\"service_request\",\"warranty_waiver\",\"fee_ledger\"],\"update_objects\":[]}}','2026-08-21T18:45:46Z'),('field:version:customer_profile.display_name','field','customer_profile.display_name','0.1.0','7b3469b43023126b1d016de417ce35c3dc069311bb9beea824281ef5812e56cc','{\"key\":\"display_name\",\"name\":\"Display name\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"customer_profile\",\"indexed\":true},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:customer_profile.identity_user_id','field','customer_profile.identity_user_id','0.1.0','5e98691b5eae2bf77d63386b26e94f556117f518610f33d6257c3a19df440204','{\"key\":\"identity_user_id\",\"name\":\"Identity user\",\"type\":\"relation\",\"config\":{\"_definition_object_key\":\"customer_profile\",\"object_key\":\"identity_user\",\"target\":\"identity_user\"},\"validation\":{\"target\":\"identity_user\"},\"required\":false,\"unique\":true}','2026-08-21T18:45:46Z'),('field:version:customer_profile.status','field','customer_profile.status','0.1.0','e52f93b6f31cc99f20de20b7a6719015611874c83842af3f375f796ed19af2f9','{\"key\":\"status\",\"name\":\"Status\",\"type\":\"select\",\"config\":{\"_definition_object_key\":\"customer_profile\",\"indexed\":true},\"validation\":{},\"options\":[{\"label\":\"Active\",\"value\":\"active\"},{\"label\":\"Inactive\",\"value\":\"inactive\"}],\"required\":true}','2026-08-21T18:45:46Z'),('field:version:device.customer_profile_id','field','device.customer_profile_id','0.1.0','6adde0fce4e852ffc0bb9b3e058072be687b8461799bb8ae1d987eaa0e0b2bce','{\"key\":\"customer_profile_id\",\"name\":\"Customer\",\"type\":\"relation\",\"config\":{\"_definition_object_key\":\"device\",\"indexed\":true,\"object_key\":\"customer_profile\",\"target\":\"customer_profile\"},\"validation\":{\"target\":\"customer_profile\"},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:device.name','field','device.name','0.1.0','032e5e3975963cb6fd5d478f18a16ac71aabe4f9f9c3447858f8653155739396','{\"key\":\"name\",\"name\":\"Name\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"device\",\"indexed\":true},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:device.purchase_date','field','device.purchase_date','0.1.0','5cc3698f2018fb467c89b6b06d31c10f1645d63bb6161181bfbdc2d0f3a57e9f','{\"key\":\"purchase_date\",\"name\":\"Purchase date\",\"type\":\"date\",\"config\":{\"_definition_object_key\":\"device\"},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:device.serial_number','field','device.serial_number','0.1.0','8f171e612d56ea49d78a58d842667dafaa161a70de329009f6e9de6f605f5d66','{\"key\":\"serial_number\",\"name\":\"Serial number\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"device\",\"indexed\":true},\"validation\":{},\"required\":true,\"unique\":true}','2026-08-21T18:45:46Z'),('field:version:fee_ledger.amount','field','fee_ledger.amount','0.1.0','c65413eeddc5e80ecf5fd85114f1d18a1e9cd81f86e5c38e8260d3da6d23e0e9','{\"key\":\"amount\",\"name\":\"Amount\",\"type\":\"currency\",\"config\":{\"_definition_object_key\":\"fee_ledger\",\"currency_code\":\"CNY\",\"precision\":19,\"rounding_mode\":\"half_even\",\"scale\":2},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:fee_ledger.calculation_trace','field','fee_ledger.calculation_trace','0.1.0','c7abd7759934f1d4932ae2df67c9a95b159bebc644b6c1d0f00e8089689d60a7','{\"key\":\"calculation_trace\",\"name\":\"Calculation trace\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"fee_ledger\"},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:fee_ledger.input_snapshot','field','fee_ledger.input_snapshot','0.1.0','85862dbba1d1117b8728aed770124e0e566523c95ba3b89055d208c1abbfde18','{\"key\":\"input_snapshot\",\"name\":\"Input snapshot\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"fee_ledger\"},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:fee_ledger.kind','field','fee_ledger.kind','0.1.0','55d97621710a019ca2df95063a448203e9daa6e923318163b197d07a97b4da85','{\"key\":\"kind\",\"name\":\"Entry kind\",\"type\":\"select\",\"config\":{\"_definition_object_key\":\"fee_ledger\",\"indexed\":true},\"validation\":{},\"options\":[{\"label\":\"Charge\",\"value\":\"charge\"},{\"label\":\"Waiver\",\"value\":\"waiver\"},{\"label\":\"Reversal\",\"value\":\"reversal\"},{\"label\":\"Adjustment\",\"value\":\"adjustment\"}],\"required\":true}','2026-08-21T18:45:46Z'),('field:version:fee_ledger.lineage_key','field','fee_ledger.lineage_key','0.1.0','7430b8ef4f24fe45bd1e90467faaf29962e5f1ed695a040273924c6912a7262f','{\"key\":\"lineage_key\",\"name\":\"Lineage key\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"fee_ledger\",\"indexed\":true},\"validation\":{},\"required\":true,\"unique\":true}','2026-08-21T18:45:46Z'),('field:version:fee_ledger.occurred_at','field','fee_ledger.occurred_at','0.1.0','10885d4819b991ee9619cb6e8cb73fbc968e3f679cc5ec97205666c082933ff3','{\"key\":\"occurred_at\",\"name\":\"Occurred at\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"fee_ledger\",\"indexed\":true},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:fee_ledger.policy_snapshot','field','fee_ledger.policy_snapshot','0.1.0','0ca1d74530161d15c52ad1150b4faffd9a136d2d975bb741110aec7098723ec2','{\"key\":\"policy_snapshot\",\"name\":\"Policy snapshot\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"fee_ledger\"},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:fee_ledger.service_request_id','field','fee_ledger.service_request_id','0.1.0','ffe79c055232c8fd4351e1f015354685242d15cc534a3257a14dcc4aab79d1f6','{\"key\":\"service_request_id\",\"name\":\"Service request\",\"type\":\"relation\",\"config\":{\"_definition_object_key\":\"fee_ledger\",\"indexed\":true,\"object_key\":\"service_request\",\"target\":\"service_request\"},\"validation\":{\"target\":\"service_request\"},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:fee_ledger.warranty_waiver_id','field','fee_ledger.warranty_waiver_id','0.1.0','034006fcc9d2ba806521102a0e1bd03ba9ba281881a0ba8c0ab446ac41e4974e','{\"key\":\"warranty_waiver_id\",\"name\":\"Warranty waiver\",\"type\":\"relation\",\"config\":{\"_definition_object_key\":\"fee_ledger\",\"indexed\":true,\"object_key\":\"warranty_waiver\",\"target\":\"warranty_waiver\"},\"validation\":{\"target\":\"warranty_waiver\"},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:job_dead_letter.failed_at','field','job_dead_letter.failed_at','0.1.0','533c211c80431b32eb73d704dd2cbcae216385304806aeac049afa630b28cdbe','{\"key\":\"failed_at\",\"name\":\"Failed At\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"job_dead_letter\"},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:job_dead_letter.job_run_id','field','job_dead_letter.job_run_id','0.1.0','ba73ac27afb961f39d3edf16cc3ba3dcc7e14dabcc9183bc5a899927c913674d','{\"key\":\"job_run_id\",\"name\":\"Job Run\",\"type\":\"relation\",\"config\":{\"_definition_object_key\":\"job_dead_letter\"},\"validation\":{\"target\":\"job_run\"},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:job_dead_letter.last_error','field','job_dead_letter.last_error','0.1.0','b7605e9dd82a0bff4f5580b8854d0c261946a885d566ab3c8a8326ada3eb09da','{\"key\":\"last_error\",\"name\":\"Last Error\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"job_dead_letter\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:job_dead_letter.reason','field','job_dead_letter.reason','0.1.0','0fc155458eda270e1aa914b196b8bee660fa8a87c6251b8505b3499e587eeeae','{\"key\":\"reason\",\"name\":\"Reason\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"job_dead_letter\"},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:job_dead_letter.resolution_idempotency_key','field','job_dead_letter.resolution_idempotency_key','0.1.0','fbb5219fdd943347dd8b4d26dd978ec65ff7ef6e5df3145edde73b2d89a50be4','{\"key\":\"resolution_idempotency_key\",\"name\":\"Resolution Idempotency Key\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"job_dead_letter\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:job_dead_letter.resolution_note','field','job_dead_letter.resolution_note','0.1.0','671b386f4b079b477f9b7e2a40bde86fe5fb572d48e794153fde751bdce7aefe','{\"key\":\"resolution_note\",\"name\":\"Resolution Note\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"job_dead_letter\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:job_dead_letter.resolved_at','field','job_dead_letter.resolved_at','0.1.0','22856093a7c990fe699e32fbd214c2081f482b0ba2346dcabacb8a4a80445d09','{\"key\":\"resolved_at\",\"name\":\"Resolved At\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"job_dead_letter\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:job_dead_letter.resolved_by','field','job_dead_letter.resolved_by','0.1.0','d2e9f60b53363d7820f7ec80423c9f22cfdd1760c2613db7083c2f6835712b48','{\"key\":\"resolved_by\",\"name\":\"Resolved By\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"job_dead_letter\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:job_dead_letter.scheduler_definition_key','field','job_dead_letter.scheduler_definition_key','0.1.0','f72c3c484f6a6ecd8ab06e1898c2c47bd8db6ebc6319127eeaa18968a1512997','{\"key\":\"scheduler_definition_key\",\"name\":\"Scheduler Definition Key\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"job_dead_letter\"},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:job_dead_letter.status','field','job_dead_letter.status','0.1.0','2a91d59e7f20a63a177ecf7276eb0a40f48ddf0bbdafe123f9356e41a2f272c6','{\"key\":\"status\",\"name\":\"Status\",\"type\":\"select\",\"config\":{\"_definition_object_key\":\"job_dead_letter\"},\"validation\":{\"options\":[\"open\",\"retrying\",\"resolved\",\"ignored\"]},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:job_run_event.created_at','field','job_run_event.created_at','0.1.0','0c01c85e6a783865d847099c7dccafdafb0b7f4abc869a230a7acccacd0cf18a','{\"key\":\"created_at\",\"name\":\"Created At\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"job_run_event\"},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:job_run_event.event_type','field','job_run_event.event_type','0.1.0','48149bc6ba4321dd95c14f1112055208bf5c5faabcb78588c27d024a9ab48044','{\"key\":\"event_type\",\"name\":\"Event Type\",\"type\":\"select\",\"config\":{\"_definition_object_key\":\"job_run_event\"},\"validation\":{\"options\":[\"created\",\"lease_acquired\",\"definition_cursor_advanced\",\"state_changed\",\"simulated\",\"workflow_triggered\",\"action_triggered\",\"report_query_run_created\",\"report_export_audit_created\",\"download_task_created\",\"retry_scheduled\",\"dead_lettered\",\"dead_letter_resolved\",\"cancelled\"]},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:job_run_event.job_run_id','field','job_run_event.job_run_id','0.1.0','48602d82b8587c996e56c6ef1cd6375fd4887c4d2e5c8d7c668db2a4a4b0c106','{\"key\":\"job_run_id\",\"name\":\"Job Run\",\"type\":\"relation\",\"config\":{\"_definition_object_key\":\"job_run_event\"},\"validation\":{\"target\":\"job_run\"},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:job_run_event.message','field','job_run_event.message','0.1.0','1f7197220820ddcfd167d71536a72063fb630b265eda131c3e215f8b86c2a04a','{\"key\":\"message\",\"name\":\"Message\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"job_run_event\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:job_run_event.metadata_json','field','job_run_event.metadata_json','0.1.0','6e5e7ee84a02e035c027f5e34fadfd741ba3b794f7c3ac143e57e9c909252d88','{\"key\":\"metadata_json\",\"name\":\"Metadata JSON\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"job_run_event\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:job_run.attempt','field','job_run.attempt','0.1.0','e1baa994127f6dd506be9c8a9b8d4c4783c04f7f8037f1746a4332c7262a3727','{\"key\":\"attempt\",\"name\":\"Attempt\",\"type\":\"number\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:job_run.error_category','field','job_run.error_category','0.1.0','e0b8dd1d51425694c70f9bdbc7cebb279f9f9fa84de6707991440d79a641b087','{\"key\":\"error_category\",\"name\":\"Error Category\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:job_run.error_message','field','job_run.error_message','0.1.0','5d04ed0b00a29b4d6424b462dbf5653889e639154931d39ecca48726c9ec7ab3','{\"key\":\"error_message\",\"name\":\"Error Message\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:job_run.fencing_token','field','job_run.fencing_token','0.1.0','1300f2f29e218e49f14381c13ee137ff062d45606ee6a577a327903929e08a33','{\"key\":\"fencing_token\",\"name\":\"Fencing Token\",\"type\":\"number\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:job_run.finished_at','field','job_run.finished_at','0.1.0','d684cb3f7453d9a6cfd7c492fe0e317ae54a5ede7c7b05334e09611c6339b49b','{\"key\":\"finished_at\",\"name\":\"Finished At\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:job_run.idempotency_key','field','job_run.idempotency_key','0.1.0','7635107e21facb0daec32d48bae7ac7a510612ad3295f12001a4b6c297c7ced0','{\"key\":\"idempotency_key\",\"name\":\"Idempotency Key\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:job_run.idempotency_scope','field','job_run.idempotency_scope','0.1.0','ff16b81bb06e972cc47c4daf5c70787591971bf07525291a658a781301490681','{\"key\":\"idempotency_scope\",\"name\":\"Idempotency Scope\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:job_run.last_command_key','field','job_run.last_command_key','0.1.0','64f8f9a1b246dc66ad127e041f6a762768c19927f1896e8c1faf615b1b6e392f','{\"key\":\"last_command_key\",\"name\":\"Last Command Key\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:job_run.last_command_scope','field','job_run.last_command_scope','0.1.0','329f2208e6da7d0ba06760e1661155faa4047058f86627ae4b842d2a14279da4','{\"key\":\"last_command_scope\",\"name\":\"Last Command Scope\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:job_run.lease_expires_at','field','job_run.lease_expires_at','0.1.0','a3b31ee3c15cb479639667c3352b2d259e87d7ad98e6f7a22dbb11cd3c34103c','{\"key\":\"lease_expires_at\",\"name\":\"Lease Expires At\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:job_run.lease_owner','field','job_run.lease_owner','0.1.0','a55c687793469c72a04853891486d2514f002fac3234812f9aa9ae9739274846','{\"key\":\"lease_owner\",\"name\":\"Lease Owner\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:job_run.max_attempts','field','job_run.max_attempts','0.1.0','b85f419a839b8268d831309b3b49bb45bd981d76d35e9fc4dc36f6a0c523c3b2','{\"key\":\"max_attempts\",\"name\":\"Max Attempts\",\"type\":\"number\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:job_run.next_retry_at','field','job_run.next_retry_at','0.1.0','5b6652a772a819f0618a17c445a794ac755d1b4acda90308d472ee857adc728f','{\"key\":\"next_retry_at\",\"name\":\"Next Retry At\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:job_run.payload_json','field','job_run.payload_json','0.1.0','f9a7e0bbe9c68c80bfce0d5b0121d085166de3d617e530355a0387989ea434e4','{\"key\":\"payload_json\",\"name\":\"Payload JSON\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:job_run.recoverability','field','job_run.recoverability','0.1.0','23de1460dbcd8c21309937dc23742b554e81c12616ed1783b15e38fdb0892b82','{\"key\":\"recoverability\",\"name\":\"Recoverability\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:job_run.result_json','field','job_run.result_json','0.1.0','f125034d83157952313069ba86fb8d786b1d7f8239fba4a395213591f69f5242','{\"key\":\"result_json\",\"name\":\"Result JSON\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:job_run.retry_backoff','field','job_run.retry_backoff','0.1.0','8076580110d09275a6dec2297776054270246c5be61cd20b1f42ca54dfe95713','{\"key\":\"retry_backoff\",\"name\":\"Retry Backoff\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:job_run.retry_backoff_seconds','field','job_run.retry_backoff_seconds','0.1.0','1d7128177c96363b74275bbebfde71a6d6bf12af5ef378b8fb56f803840a5bf1','{\"key\":\"retry_backoff_seconds\",\"name\":\"Retry Backoff Seconds\",\"type\":\"number\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:job_run.retry_delay_seconds','field','job_run.retry_delay_seconds','0.1.0','12ba2625cf87bb8bdb354a8304fcb8dd0ceeae33a3e95b7e881998ab4b4bc8d2','{\"key\":\"retry_delay_seconds\",\"name\":\"Retry Delay Seconds\",\"type\":\"number\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:job_run.retry_max_delay_seconds','field','job_run.retry_max_delay_seconds','0.1.0','9be8761a5c54df3057ece2defd0d5a0e975520e4f6cf493bfc42dd45d17b42a8','{\"key\":\"retry_max_delay_seconds\",\"name\":\"Max Retry Delay Seconds\",\"type\":\"number\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:job_run.scheduled_for','field','job_run.scheduled_for','0.1.0','04da55d41d8f24e81baca3158adeb3abebaf7eec9a0046502eb4c71bba462ab9','{\"key\":\"scheduled_for\",\"name\":\"Scheduled For\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:job_run.scheduler_definition_key','field','job_run.scheduler_definition_key','0.1.0','55ec4a6781fc727a85576d6440e9971a2dbc7b355aa4063d9365e77d7840e9f8','{\"key\":\"scheduler_definition_key\",\"name\":\"Scheduler Definition Key\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:job_run.started_at','field','job_run.started_at','0.1.0','a3832805526ef6b44ec1d11d17add54fa0e6acdbe086ff3fda983f46d61fd7e5','{\"key\":\"started_at\",\"name\":\"Started At\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:job_run.status','field','job_run.status','0.1.0','e6a94e396921eab3b01b25798ea078c74ae5f79cc5e1e4518ffe9dbddf919e7b','{\"key\":\"status\",\"name\":\"Status\",\"type\":\"select\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{\"options\":[\"queued\",\"leased\",\"running\",\"succeeded\",\"failed\",\"retrying\",\"cancelled\",\"dead_letter\"]},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:job_run.target_object','field','job_run.target_object','0.1.0','9a95e2caaa2bfb6752af08c63726f70213d8f437c2b92abaca866308f8e6cfad','{\"key\":\"target_object\",\"name\":\"Target Object\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:job_run.target_record_id','field','job_run.target_record_id','0.1.0','24b29441b7dc78230ade570eb7d218f073a67225189d70a9087a504280251f96','{\"key\":\"target_record_id\",\"name\":\"Target Record ID\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:job_run.timeout_seconds','field','job_run.timeout_seconds','0.1.0','0e9cb26f99f52153b9233d62965b73e49a18c1869d7a89acc4deee98d38c5031','{\"key\":\"timeout_seconds\",\"name\":\"Timeout Seconds\",\"type\":\"number\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:job_run.triggered_by','field','job_run.triggered_by','0.1.0','9316b34bbd8f0e97b41102dd8f28bef728f97738e157f5b65c28187463bd7198','{\"key\":\"triggered_by\",\"name\":\"Triggered By\",\"type\":\"select\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{\"options\":[\"scheduler\",\"manual\",\"api\",\"workflow\",\"retry\"]},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:job_run.workflow_execution_id','field','job_run.workflow_execution_id','0.1.0','4321bf7a7f9d4eb65005d0a39b860603f59e78422f0fc72905b6f993b7798b26','{\"key\":\"workflow_execution_id\",\"name\":\"Workflow Execution ID\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:job_run.workflow_key','field','job_run.workflow_key','0.1.0','403fc1c3dd3c703eccdbce472aa1e16ce75a68847d4ad5bf32fdd711b8888be2','{\"key\":\"workflow_key\",\"name\":\"Workflow Key\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"job_run\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:overdue_reminder.business_date','field','overdue_reminder.business_date','0.1.0','e9391ad69e9b36ddbb36865ad8012c8719613bbeadc1aa587757c92750a584ba','{\"key\":\"business_date\",\"name\":\"Business date\",\"type\":\"date\",\"config\":{\"_definition_object_key\":\"overdue_reminder\",\"indexed\":true},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:overdue_reminder.dedupe_key','field','overdue_reminder.dedupe_key','0.1.0','055c4dfcb854546e54acbc17f3214d512dada0932a80d0735bd07427d1529f78','{\"key\":\"dedupe_key\",\"name\":\"Dedupe key\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"overdue_reminder\",\"indexed\":true},\"validation\":{},\"required\":true,\"unique\":true}','2026-08-21T18:45:46Z'),('field:version:overdue_reminder.owner_department_id','field','overdue_reminder.owner_department_id','0.1.0','913e75f285a8958d61667ecbab6ed2b72e5fc67722245bef849ea9b873b7ccc6','{\"key\":\"owner_department_id\",\"name\":\"Owner department ID\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"overdue_reminder\",\"indexed\":true},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:overdue_reminder.owner_department_path','field','overdue_reminder.owner_department_path','0.1.0','88fcf7b37a576a6b6b29d65275e696d88b2320c7e687f9fa823f57a6bb010c61','{\"key\":\"owner_department_path\",\"name\":\"Owner department path\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"overdue_reminder\",\"indexed\":true},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:overdue_reminder.recipient_user_id','field','overdue_reminder.recipient_user_id','0.1.0','af332200d3eae1257b3b70c5e332dff54dcae84221919d0e2d27ea164cf7fa57','{\"key\":\"recipient_user_id\",\"name\":\"Recipient\",\"type\":\"relation\",\"config\":{\"_definition_object_key\":\"overdue_reminder\",\"object_key\":\"identity_user\",\"scope_owner\":true,\"target\":\"identity_user\"},\"validation\":{\"target\":\"identity_user\"},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:overdue_reminder.sent_at','field','overdue_reminder.sent_at','0.1.0','aba1a457c5ba05530184866f16030c774fe83f189be2754136e81a16df785201','{\"key\":\"sent_at\",\"name\":\"Sent at\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"overdue_reminder\"},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:overdue_reminder.service_request_id','field','overdue_reminder.service_request_id','0.1.0','a78adaa0f921983fa644b8889dd4f36971780fe1e58c39622259396c432b3d98','{\"key\":\"service_request_id\",\"name\":\"Service request\",\"type\":\"relation\",\"config\":{\"_definition_object_key\":\"overdue_reminder\",\"indexed\":true,\"object_key\":\"service_request\",\"target\":\"service_request\"},\"validation\":{\"target\":\"service_request\"},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:part_usage.amount','field','part_usage.amount','0.1.0','962606a84182ae22b43f332b3abfa592ff7671b96a5798bfd91a9b4431068ca4','{\"key\":\"amount\",\"name\":\"Usage amount\",\"type\":\"currency\",\"config\":{\"_definition_object_key\":\"part_usage\",\"currency_code\":\"CNY\",\"precision\":19,\"rounding_mode\":\"half_even\",\"scale\":2},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:part_usage.calculation_trace','field','part_usage.calculation_trace','0.1.0','586ad0d3d264020dd8ede69d1e75f65785e64b8b4e04380c0e2831250e572fee','{\"key\":\"calculation_trace\",\"name\":\"Calculation trace\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"part_usage\"},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:part_usage.occurred_at','field','part_usage.occurred_at','0.1.0','26b6717590152f2e0cb38d9fccd1f2cf91802c698cc6eb331e42d00eb75cd45c','{\"key\":\"occurred_at\",\"name\":\"Occurred at\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"part_usage\",\"indexed\":true},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:part_usage.owner_department_id','field','part_usage.owner_department_id','0.1.0','e40fcd50e3e9f27de8643ec849a3c0cc23e6c68032266d858f2d6d027665da15','{\"key\":\"owner_department_id\",\"name\":\"Owner department ID\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"part_usage\",\"indexed\":true},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:part_usage.owner_department_path','field','part_usage.owner_department_path','0.1.0','009ddd6926e4a072470f3cac8d720c72f80b5eb49839944fd38fd3560ff775fd','{\"key\":\"owner_department_path\",\"name\":\"Owner department path\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"part_usage\",\"indexed\":true},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:part_usage.performed_by_user_id','field','part_usage.performed_by_user_id','0.1.0','aa1b7c739f67df872866b721fc903a28dda3897734dba240d92298f9daf97108','{\"key\":\"performed_by_user_id\",\"name\":\"Performed by\",\"type\":\"user\",\"config\":{\"_definition_object_key\":\"part_usage\",\"auto_assign_current_user\":true,\"scope_owner\":true},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:part_usage.quantity','field','part_usage.quantity','0.1.0','20d2e56d465c7560d6c45cc07ef25899d20204645560e4dd14f173c9d658d026','{\"key\":\"quantity\",\"name\":\"Quantity\",\"type\":\"integer\",\"config\":{\"_definition_object_key\":\"part_usage\"},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:part_usage.service_request_id','field','part_usage.service_request_id','0.1.0','60edee7eef53799d1ec0867f89934b7ab9eae9ed9e58a90b14afb334c8f84e7c','{\"key\":\"service_request_id\",\"name\":\"Service request\",\"type\":\"relation\",\"config\":{\"_definition_object_key\":\"part_usage\",\"indexed\":true,\"object_key\":\"service_request\",\"target\":\"service_request\"},\"validation\":{\"target\":\"service_request\"},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:part_usage.spare_part_id','field','part_usage.spare_part_id','0.1.0','7ae52386d38d6eda6b6f24c38321fb2d730e5d4535085519654803a961f8e270','{\"key\":\"spare_part_id\",\"name\":\"Spare part\",\"type\":\"relation\",\"config\":{\"_definition_object_key\":\"part_usage\",\"indexed\":true,\"object_key\":\"spare_part\",\"target\":\"spare_part\"},\"validation\":{\"target\":\"spare_part\"},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:part_usage.unit_price_snapshot','field','part_usage.unit_price_snapshot','0.1.0','84166fd7a02e46b44723551b0d126fe6c6da1930548e2998944930ee3eecae29','{\"key\":\"unit_price_snapshot\",\"name\":\"Unit price snapshot\",\"type\":\"currency\",\"config\":{\"_definition_object_key\":\"part_usage\",\"currency_code\":\"CNY\",\"precision\":19,\"rounding_mode\":\"half_even\",\"scale\":2},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:record_timer.attempt','field','record_timer.attempt','0.1.0','3a976ea32daf117389f780dd4fbbf54bd9fda1775fa4fb1d313f77a4fd33b8cc','{\"key\":\"attempt\",\"name\":\"Attempt\",\"type\":\"number\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:record_timer.business_calendar_key','field','record_timer.business_calendar_key','0.1.0','0afebd6a8d1efb190d4faeb2a6f30e82af9ccb7ee55b203719a56a0dc3b08154','{\"key\":\"business_calendar_key\",\"name\":\"Business Calendar Key\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:record_timer.cancelled_at','field','record_timer.cancelled_at','0.1.0','a921b8714d36ce8076bd7fd43907b4fb8f0530cc7a67722ad5c7bb9ce7933d93','{\"key\":\"cancelled_at\",\"name\":\"Cancelled At\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:record_timer.due_at','field','record_timer.due_at','0.1.0','36dbfcd092f5cadfff1d8ea2d90e180503fa372c008b9669f40bcbf72feec240','{\"key\":\"due_at\",\"name\":\"Due At\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"record_timer\",\"indexed\":true},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:record_timer.failed_at','field','record_timer.failed_at','0.1.0','dc2d0d1d872a11c3e6b6cce127618e8188418b548f65507da8255faecfea0043','{\"key\":\"failed_at\",\"name\":\"Failed At\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:record_timer.fencing_token','field','record_timer.fencing_token','0.1.0','88fff3f7ee1d2343138589797c658e2449aa4c6b67ffa95edbaa241357ae3d8a','{\"key\":\"fencing_token\",\"name\":\"Fencing Token\",\"type\":\"number\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:record_timer.fired_at','field','record_timer.fired_at','0.1.0','b08b5b5a71cbf22179832eb8e7556f030780f354f112dd40e30254d24925165a','{\"key\":\"fired_at\",\"name\":\"Fired At\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:record_timer.last_error','field','record_timer.last_error','0.1.0','0012e68896d47a3b00f9d0059a14c24add5085a3d1c631c6fd7e427834303678','{\"key\":\"last_error\",\"name\":\"Last Error\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:record_timer.lease_expires_at','field','record_timer.lease_expires_at','0.1.0','2691896e8e158be8809178b7539cff6a8549ed9727c3783c74be106f3ba7d4c3','{\"key\":\"lease_expires_at\",\"name\":\"Lease Expires At\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:record_timer.lease_owner','field','record_timer.lease_owner','0.1.0','b0c46c87fd82da748d6b52ff0a5ab72694e3f247a96b9295c7dd7cafce963840','{\"key\":\"lease_owner\",\"name\":\"Lease Owner\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:record_timer.max_attempts','field','record_timer.max_attempts','0.1.0','12adfd0c74ff318305e541c0ca49626b775c8795af671f21e5e18fda5f40434a','{\"key\":\"max_attempts\",\"name\":\"Max Attempts\",\"type\":\"number\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:record_timer.object_key','field','record_timer.object_key','0.1.0','b7502a90d51b51a40e19269a70c8dfffeadaecd76f023879b1534c03231293c3','{\"key\":\"object_key\",\"name\":\"Object Key\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"record_timer\",\"indexed\":true,\"max_length\":128},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:record_timer.offset_seconds','field','record_timer.offset_seconds','0.1.0','48cf7e8df977741ad70dee6c9da5ab5ad85038c71962f71f612c198335e3cb43','{\"key\":\"offset_seconds\",\"name\":\"Offset Seconds\",\"type\":\"number\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:record_timer.payload_json','field','record_timer.payload_json','0.1.0','99bbfae13d245f2f5d414ac37ac900a8cf110586e38e08a70b6cdd7f1927fa31','{\"key\":\"payload_json\",\"name\":\"Payload JSON\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:record_timer.priority','field','record_timer.priority','0.1.0','e947132e87424b020aab03eb9008e1676243ae831c3c08fd7d28fea8ae5f8462','{\"key\":\"priority\",\"name\":\"Priority\",\"type\":\"number\",\"config\":{\"_definition_object_key\":\"record_timer\",\"indexed\":true},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:record_timer.purpose','field','record_timer.purpose','0.1.0','7b4c6429c4f55a80abf00eaf475d50ebb6c544e2fc33d4b5d9a0fa6e13837536','{\"key\":\"purpose\",\"name\":\"Purpose\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"record_timer\",\"max_length\":128},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:record_timer.record_id','field','record_timer.record_id','0.1.0','9f231649d01851288597dbe7049a661e935d79920afdca7fe76a7eb983fe074f','{\"key\":\"record_id\",\"name\":\"Record ID\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"record_timer\",\"indexed\":true,\"max_length\":128},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:record_timer.retry_delay_seconds','field','record_timer.retry_delay_seconds','0.1.0','49e5380f03c23e6694db9bd27e02bbdfa3917db068c8b26ebd02e0bfb8d9239a','{\"key\":\"retry_delay_seconds\",\"name\":\"Retry Delay Seconds\",\"type\":\"number\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:record_timer.retry_max_delay_seconds','field','record_timer.retry_max_delay_seconds','0.1.0','af64c4b4921b09e78755ac41014617742de11d5582dc9ec9a0b4ee52f7649053','{\"key\":\"retry_max_delay_seconds\",\"name\":\"Retry Max Delay Seconds\",\"type\":\"number\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:record_timer.schedule_mode','field','record_timer.schedule_mode','0.1.0','ea50e1a6939f2fdc653e375314aab188f30418316fcf506fad7d2a5c8ff6c2de','{\"key\":\"schedule_mode\",\"name\":\"Schedule Mode\",\"type\":\"select\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{\"options\":[\"absolute\",\"relative_field\",\"business_calendar\"]},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:record_timer.sequence','field','record_timer.sequence','0.1.0','d1c09ae28c21f51429231a602e0e580f9813e160264f652fb9ad16f51148cc8c','{\"key\":\"sequence\",\"name\":\"Sequence\",\"type\":\"number\",\"config\":{\"_definition_object_key\":\"record_timer\",\"indexed\":true},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:record_timer.source_field','field','record_timer.source_field','0.1.0','07b0368add24bed4219a9e7f998ed8f14e07c245ef17ff4a30166799a42972db','{\"key\":\"source_field\",\"name\":\"Source Field\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:record_timer.status','field','record_timer.status','0.1.0','4be5f313402700d0e71189521596911084d1e632e5302ea7b9a34be7481fd510','{\"key\":\"status\",\"name\":\"Status\",\"type\":\"select\",\"config\":{\"_definition_object_key\":\"record_timer\",\"indexed\":true},\"validation\":{\"options\":[\"scheduled\",\"leased\",\"fired\",\"cancelled\",\"superseded\",\"failed\"]},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:record_timer.supersedes_timer_id','field','record_timer.supersedes_timer_id','0.1.0','d721a145701453b2dab3fe547cf9ea3e9767a03733f0708ecf05693ef2a306d5','{\"key\":\"supersedes_timer_id\",\"name\":\"Supersedes Timer\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:record_timer.target_key','field','record_timer.target_key','0.1.0','bfc8ced3efc6c9eb93739ca994611df291ff1696e269beef5f929030cd56ce87','{\"key\":\"target_key\",\"name\":\"Target Key\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:record_timer.target_type','field','record_timer.target_type','0.1.0','34286dced554da8cd5921e55324e4c182c86945cc40631e34bb53c36faf0db5e','{\"key\":\"target_type\",\"name\":\"Target Type\",\"type\":\"select\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{\"options\":[\"action\",\"workflow\"]},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:record_timer.timer_key','field','record_timer.timer_key','0.1.0','080ce7fd69fbf529a82ae0a3545a17ef458acf455be6a152c0f5a6ff40b00224','{\"key\":\"timer_key\",\"name\":\"Timer Key\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"record_timer\",\"max_length\":128},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:record_timer.timezone','field','record_timer.timezone','0.1.0','faa3400081342cd5ef6985378a9060ffb851b3ffdfbcc9d1c0232b460dac896a','{\"key\":\"timezone\",\"name\":\"Timezone\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"record_timer\"},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:report_export_audit.owner_department_id','field','report_export_audit.owner_department_id','0.1.0','0ae728cd5b31138c7d6165d8a3ec4d32e768633c6bbf2c981d0149fe200bbf2f','{\"key\":\"owner_department_id\",\"name\":\"Owner department ID\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"report_export_audit\",\"indexed\":true},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:report_export_audit.owner_department_path','field','report_export_audit.owner_department_path','0.1.0','fed8404a319a0466f09c5a38a059f41591dcffad29f468ff5dd0ae609761e99c','{\"key\":\"owner_department_path\",\"name\":\"Owner department path\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"report_export_audit\",\"indexed\":true},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:report_export_audit.purpose','field','report_export_audit.purpose','0.1.0','67e5a2152f442e908cf5454498938709e8959ea6ef22d972f78ca31620a49c14','{\"key\":\"purpose\",\"name\":\"Purpose\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"report_export_audit\"},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:report_export_audit.report_key','field','report_export_audit.report_key','0.1.0','9956ba1ffe44c9e84465b809e97ade52fff02e80b2eabd017208acfd145e4526','{\"key\":\"report_key\",\"name\":\"Report key\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"report_export_audit\",\"indexed\":true},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:report_export_audit.requested_at','field','report_export_audit.requested_at','0.1.0','28c6847c035d48fe2604894954d53d14f7dc778ff9f25bf8f9a102a277df0ab4','{\"key\":\"requested_at\",\"name\":\"Requested at\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"report_export_audit\",\"indexed\":true},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:report_export_audit.requester_user_id','field','report_export_audit.requester_user_id','0.1.0','d693732cabfe490858c803f0a1b83bd173fb26d50916b4f75383f9e8cea757e8','{\"key\":\"requester_user_id\",\"name\":\"Requester\",\"type\":\"user\",\"config\":{\"_definition_object_key\":\"report_export_audit\",\"auto_assign_current_user\":true,\"scope_owner\":true},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:report_export_audit.row_count','field','report_export_audit.row_count','0.1.0','80544441c382e55bee7e88aa5b5e2c97fdb8de0e7210dd80ce2b6648accc9f48','{\"key\":\"row_count\",\"name\":\"Row count\",\"type\":\"integer\",\"config\":{\"_definition_object_key\":\"report_export_audit\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:report_export_audit.scope_hash','field','report_export_audit.scope_hash','0.1.0','de0b49d0e8df328b64c5d3b1625f824747cb1a311aaf8f920008c76d4fd7ea8d','{\"key\":\"scope_hash\",\"name\":\"Scope hash\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"report_export_audit\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:report_export_audit.status','field','report_export_audit.status','0.1.0','72b85f0bbc4c6a9187c0a528b44827ecb1bb78ff66849b65e3296c7149cc2343','{\"key\":\"status\",\"name\":\"Status\",\"type\":\"select\",\"config\":{\"_definition_object_key\":\"report_export_audit\",\"indexed\":true},\"validation\":{},\"options\":[{\"label\":\"Requested\",\"value\":\"requested\"},{\"label\":\"Prepared\",\"value\":\"prepared\"},{\"label\":\"Downloaded\",\"value\":\"downloaded\"},{\"label\":\"Denied\",\"value\":\"denied\"},{\"label\":\"Expired\",\"value\":\"expired\"}],\"required\":true}','2026-08-21T18:45:46Z'),('field:version:report_export_download.audit_id','field','report_export_download.audit_id','0.1.0','df85843d0489a743e797f413b50d6e9432100d7855cdf40c55d3c4ee77415ea6','{\"key\":\"audit_id\",\"name\":\"Audit request\",\"type\":\"relation\",\"config\":{\"_definition_object_key\":\"report_export_download\",\"indexed\":true,\"object_key\":\"report_export_audit\",\"target\":\"report_export_audit\"},\"validation\":{\"target\":\"report_export_audit\"},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:report_export_download.content_hash','field','report_export_download.content_hash','0.1.0','7423f18850a449a716b0a756280e5a28855a012433c10a68d59cdf2b7af34d48','{\"key\":\"content_hash\",\"name\":\"Content hash\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"report_export_download\"},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:report_export_download.expires_at','field','report_export_download.expires_at','0.1.0','1d9f4bfa9b6c0bd55aa33d95c65dd81faaa2c98604a05bdd6d73a89da4a52c6f','{\"key\":\"expires_at\",\"name\":\"Expires at\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"report_export_download\",\"indexed\":true},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:report_export_download.filename','field','report_export_download.filename','0.1.0','a0f32e86ee941af23f1c18a0b2a58fbe091e5e7ca7ce60f451af5417538343df','{\"key\":\"filename\",\"name\":\"Filename\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"report_export_download\"},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:report_export_download.owner','field','report_export_download.owner','0.1.0','50666b02bcdb1cb08eb73f95f90a4a6512854f96e441c317d73f290ec61fa650','{\"key\":\"owner\",\"name\":\"Owner\",\"type\":\"user\",\"config\":{\"_definition_object_key\":\"report_export_download\",\"auto_assign_current_user\":true},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:scheduler_cursor.last_run_at','field','scheduler_cursor.last_run_at','0.1.0','ff86bcacc98b659fade71b2269090877f6363aa423df4407b2f02dbff0f4e487','{\"key\":\"last_run_at\",\"name\":\"Last Run At\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"scheduler_cursor\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:scheduler_cursor.last_run_status','field','scheduler_cursor.last_run_status','0.1.0','90b348150a3f2a13166fb2b874220160cef7a83783053dbb2242ed197f2f6bc2','{\"key\":\"last_run_status\",\"name\":\"Last Run Status\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"scheduler_cursor\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:scheduler_cursor.next_run_at','field','scheduler_cursor.next_run_at','0.1.0','2fbe476eaabaefd26183a456d1c4de43af33e4cd42465a5f2d7ac5c8b3ad306b','{\"key\":\"next_run_at\",\"name\":\"Next Run At\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"scheduler_cursor\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:scheduler_cursor.scheduler_definition_key','field','scheduler_cursor.scheduler_definition_key','0.1.0','914c3a0b8c4292737822bf5267bb2caa7a6d1f623f26633ec3f5463afebc5d43','{\"key\":\"scheduler_definition_key\",\"name\":\"Scheduler Definition Key\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"scheduler_cursor\"},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:service_request.assigned_user_id','field','service_request.assigned_user_id','0.1.0','f3f8838c5f042e3eae48d5112dcc7e7eea2c48773fe8d421f51338361f32f437','{\"key\":\"assigned_user_id\",\"name\":\"Assigned technician\",\"type\":\"relation\",\"config\":{\"_definition_object_key\":\"service_request\",\"object_key\":\"identity_user\",\"scope_owner\":true,\"target\":\"identity_user\"},\"validation\":{\"target\":\"identity_user\"},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:service_request.completed_at','field','service_request.completed_at','0.1.0','4849d361c1c7dc79921990c0e56fd05e62b5be72abe11e95c60cd27e7919f9a0','{\"key\":\"completed_at\",\"name\":\"Completed at\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"service_request\",\"indexed\":true},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:service_request.customer_profile_id','field','service_request.customer_profile_id','0.1.0','855c3914fe9cc82d8ba3b3645e421d0923f9ee8c390eaf16e89e4c7c17c52c1e','{\"key\":\"customer_profile_id\",\"name\":\"Customer\",\"type\":\"relation\",\"config\":{\"_definition_object_key\":\"service_request\",\"indexed\":true,\"object_key\":\"customer_profile\",\"target\":\"customer_profile\"},\"validation\":{\"target\":\"customer_profile\"},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:service_request.device_id','field','service_request.device_id','0.1.0','159206d11cf1d027ced968fcd3cd35c8d6d5c3e8fbebaaac5fb7f2f741d47bdf','{\"key\":\"device_id\",\"name\":\"Device\",\"type\":\"relation\",\"config\":{\"_definition_object_key\":\"service_request\",\"indexed\":true,\"object_key\":\"device\",\"target\":\"device\"},\"validation\":{\"target\":\"device\"},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:service_request.dispatched_at','field','service_request.dispatched_at','0.1.0','e14fdf994e65a3e7cf6504bbdf014baadd59383d3dd3b129cef5cbfe99dd67a8','{\"key\":\"dispatched_at\",\"name\":\"Dispatched at\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"service_request\",\"indexed\":true},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:service_request.fault_description','field','service_request.fault_description','0.1.0','cf96d21b76f5451a882dbdc057f0ad06364050c19132a124dd4032e35b2d235d','{\"key\":\"fault_description\",\"name\":\"Fault description\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"service_request\"},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:service_request.organization_unit_id','field','service_request.organization_unit_id','0.1.0','3d3872f055a46c4fdaf3329c7db5083d8fe5b07bb7fcefa948f4e645f13c3798','{\"key\":\"organization_unit_id\",\"name\":\"Station\",\"type\":\"relation\",\"config\":{\"_definition_object_key\":\"service_request\",\"object_key\":\"identity_organization_unit\",\"target\":\"identity_organization_unit\"},\"validation\":{\"target\":\"identity_organization_unit\"},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:service_request.owner_department_id','field','service_request.owner_department_id','0.1.0','a17a32f1c1604126beb0bbe1175b019e25e960559d51e54e34bd440648cd4b37','{\"key\":\"owner_department_id\",\"name\":\"Owner department ID\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"service_request\",\"indexed\":true},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:service_request.owner_department_path','field','service_request.owner_department_path','0.1.0','98b97f2569956ebc16d5da7c0a28003b26bf01ce265011995e0b7952b100d7a2','{\"key\":\"owner_department_path\",\"name\":\"Owner department path\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"service_request\",\"indexed\":true},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:service_request.preferred_visit_at','field','service_request.preferred_visit_at','0.1.0','4d71bec0d12631dc4f157d2d1c1e7eaca54fca342babd00d49cc98e9cc2d6a92','{\"key\":\"preferred_visit_at\",\"name\":\"Preferred visit time\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"service_request\",\"indexed\":true},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:service_request.quote_amount','field','service_request.quote_amount','0.1.0','c2b35cf274b31c8382a19dfbca3d0eaca92902e39c662d88f600456f71396a0c','{\"key\":\"quote_amount\",\"name\":\"Quoted fee\",\"type\":\"currency\",\"config\":{\"_definition_object_key\":\"service_request\",\"currency_code\":\"CNY\",\"precision\":19,\"rounding_mode\":\"half_even\",\"scale\":2},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:service_request.started_at','field','service_request.started_at','0.1.0','5d1b5f15b33517c7c7362e9000a2d14ad70bd3eb0ae603465312a84fe8d8ff97','{\"key\":\"started_at\",\"name\":\"Repair started at\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"service_request\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:service_request.status','field','service_request.status','0.1.0','a08dddd2dcb072c3539e71d045350eebca4ae4414d30c967856e1f415400e7df','{\"key\":\"status\",\"name\":\"Status\",\"type\":\"select\",\"config\":{\"_definition_object_key\":\"service_request\",\"indexed\":true},\"validation\":{},\"options\":[{\"label\":\"Submitted\",\"value\":\"submitted\"},{\"label\":\"Dispatched\",\"value\":\"dispatched\"},{\"label\":\"In repair\",\"value\":\"in_repair\"},{\"label\":\"Completed\",\"value\":\"completed\"}],\"required\":true}','2026-08-21T18:45:46Z'),('field:version:service_request.submitted_at','field','service_request.submitted_at','0.1.0','8d99ab2b26c523626a876dc7280659b01b7183d834514b8d1543a99ce4f5868d','{\"key\":\"submitted_at\",\"name\":\"Submitted at\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"service_request\",\"indexed\":true},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:spare_part.code','field','spare_part.code','0.1.0','a44bdc7f52422ffc34b448e93d1a91968c657d3e960d1a6f21f4c27c7f73822b','{\"key\":\"code\",\"name\":\"Code\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"spare_part\",\"indexed\":true},\"validation\":{},\"required\":true,\"unique\":true}','2026-08-21T18:45:46Z'),('field:version:spare_part.name','field','spare_part.name','0.1.0','d49a4c64fa473126ffc142efbc02c27fcd2d8831d99101d3cd7693eb21eec63c','{\"key\":\"name\",\"name\":\"Name\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"spare_part\",\"indexed\":true},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:spare_part.stock_quantity','field','spare_part.stock_quantity','0.1.0','f80f30ecc8ff1b305d9627d087424626da1ce263d25eda81b92475d6ba038d0b','{\"key\":\"stock_quantity\",\"name\":\"Stock quantity\",\"type\":\"integer\",\"config\":{\"_definition_object_key\":\"spare_part\"},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:spare_part.unit_price','field','spare_part.unit_price','0.1.0','8d967075d948c92e1724bffc87bf360890a50182acc939f017b246268c151a33','{\"key\":\"unit_price\",\"name\":\"Unit price\",\"type\":\"currency\",\"config\":{\"_definition_object_key\":\"spare_part\",\"currency_code\":\"CNY\",\"precision\":19,\"rounding_mode\":\"half_even\",\"scale\":2},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:warranty_waiver.calculation_trace','field','warranty_waiver.calculation_trace','0.1.0','0b783e98c09d78c5e7dd3d59eea03a135a146079337c7648b33a5bda70f9185f','{\"key\":\"calculation_trace\",\"name\":\"Calculation trace\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"warranty_waiver\"},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:warranty_waiver.decided_at','field','warranty_waiver.decided_at','0.1.0','ac464fd91eddf48d0043b30be1e1f5202d57e19d0b7f43c9349f8c0ccec7734b','{\"key\":\"decided_at\",\"name\":\"Decided at\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"warranty_waiver\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:warranty_waiver.decided_by_user_id','field','warranty_waiver.decided_by_user_id','0.1.0','cc779983857bfc84ca4d3e27944ba05af2b3269724c66f1937de62db58f7b28f','{\"key\":\"decided_by_user_id\",\"name\":\"Decided by\",\"type\":\"user\",\"config\":{\"_definition_object_key\":\"warranty_waiver\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:warranty_waiver.owner_department_id','field','warranty_waiver.owner_department_id','0.1.0','747515894b3f41c8aabdd8a407b9108c84fb23d5059e0a1786baa9b67834034b','{\"key\":\"owner_department_id\",\"name\":\"Owner department ID\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"warranty_waiver\",\"indexed\":true},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:warranty_waiver.owner_department_path','field','warranty_waiver.owner_department_path','0.1.0','5d49407a8be938de032b83e319e64149b4825279b9c633b26e4d12a8635d14fe','{\"key\":\"owner_department_path\",\"name\":\"Owner department path\",\"type\":\"text\",\"config\":{\"_definition_object_key\":\"warranty_waiver\",\"indexed\":true},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:warranty_waiver.policy_snapshot','field','warranty_waiver.policy_snapshot','0.1.0','697250825ec47806d3d8009c0722b7c2a2b947a971dc731ef73434441eea7b38','{\"key\":\"policy_snapshot\",\"name\":\"Policy snapshot\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"warranty_waiver\"},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:warranty_waiver.rejection_reason','field','warranty_waiver.rejection_reason','0.1.0','d6637db6051fd8ace5c4f87787ab25b3fba96c89d39b40e0ebb3990bf917f177','{\"key\":\"rejection_reason\",\"name\":\"Rejection reason\",\"type\":\"long_text\",\"config\":{\"_definition_object_key\":\"warranty_waiver\"},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:warranty_waiver.requested_amount','field','warranty_waiver.requested_amount','0.1.0','cad546c1f5623259d2a69e1e580a717bace61dba91c4e98b0aefa648bb4a8a2e','{\"key\":\"requested_amount\",\"name\":\"Requested waiver\",\"type\":\"currency\",\"config\":{\"_definition_object_key\":\"warranty_waiver\",\"currency_code\":\"CNY\",\"precision\":19,\"rounding_mode\":\"half_even\",\"scale\":2},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:warranty_waiver.requested_at','field','warranty_waiver.requested_at','0.1.0','bde47b4d715fc1d5cfcfff074d247010c92118030550900bb20e7ca328d512e0','{\"key\":\"requested_at\",\"name\":\"Requested at\",\"type\":\"datetime\",\"config\":{\"_definition_object_key\":\"warranty_waiver\",\"indexed\":true},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:warranty_waiver.requester_user_id','field','warranty_waiver.requester_user_id','0.1.0','8fdd83bfdbb2076c8697721cb84c397033e56c1f54ac25d0c14bd57459f7a153','{\"key\":\"requester_user_id\",\"name\":\"Requesting technician\",\"type\":\"user\",\"config\":{\"_definition_object_key\":\"warranty_waiver\",\"auto_assign_current_user\":true,\"scope_owner\":true},\"validation\":{},\"required\":false}','2026-08-21T18:45:46Z'),('field:version:warranty_waiver.service_request_id','field','warranty_waiver.service_request_id','0.1.0','09644578404a9056190614cb599c41fc9dcaf108491bd3c45621fb49a282f409','{\"key\":\"service_request_id\",\"name\":\"Service request\",\"type\":\"relation\",\"config\":{\"_definition_object_key\":\"warranty_waiver\",\"indexed\":true,\"object_key\":\"service_request\",\"target\":\"service_request\"},\"validation\":{\"target\":\"service_request\"},\"required\":true,\"unique\":true}','2026-08-21T18:45:46Z'),('field:version:warranty_waiver.status','field','warranty_waiver.status','0.1.0','a7f4e2f1c612455547aaf1fff7adabd70bcc1151a3c39bb6ecfdd07d6aa4c34d','{\"key\":\"status\",\"name\":\"Status\",\"type\":\"select\",\"config\":{\"_definition_object_key\":\"warranty_waiver\",\"indexed\":true},\"validation\":{},\"options\":[{\"label\":\"Pending approval\",\"value\":\"pending\"},{\"label\":\"Applied\",\"value\":\"applied\"},{\"label\":\"Approved\",\"value\":\"approved\"},{\"label\":\"Rejected\",\"value\":\"rejected\"}],\"required\":true}','2026-08-21T18:45:46Z'),('field:version:warranty_waiver.threshold_snapshot','field','warranty_waiver.threshold_snapshot','0.1.0','a8bb5e2b69bf7b4fe09174832dd7ec56fb1503ee455441abfa59a50063748b79','{\"key\":\"threshold_snapshot\",\"name\":\"Approval threshold snapshot\",\"type\":\"currency\",\"config\":{\"_definition_object_key\":\"warranty_waiver\",\"currency_code\":\"CNY\",\"precision\":19,\"rounding_mode\":\"half_even\",\"scale\":2},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('field:version:warranty_waiver.warranty_asserted','field','warranty_waiver.warranty_asserted','0.1.0','4dbf5ee78d66a112b23fd93f89966ee251108296f4627b87ed78999e4189c338','{\"key\":\"warranty_asserted\",\"name\":\"Warranty eligibility asserted\",\"type\":\"boolean\",\"config\":{\"_definition_object_key\":\"warranty_waiver\"},\"validation\":{},\"required\":true}','2026-08-21T18:45:46Z'),('identity_profile_binding:version:customer_profile','identity_profile_binding','customer_profile','0.1.0','cc39b5eb9b9c9a9154f8eb409f98dd34eb8ddbdb4261cb51343d1dafc5dfb81f','{\"contract_version\":\"identity-profile-extension\",\"min_reader_version\":\"identity-profile-extension-reader\",\"object_key\":\"customer_profile\",\"identity_relation_field\":\"identity_user_id\",\"cardinality\":\"one_to_one\",\"business_identity\":{\"key\":\"fieldservice_customer\",\"surface_keys\":[\"consumer_portal\"],\"status_field\":\"status\",\"active_status_values\":[\"active\"]},\"binding_lifecycle\":{},\"directory\":{},\"default_visibility\":\"when_readable\",\"provenance\":{\"owner\":\"user-blueprint\"}}','2026-08-21T18:45:46Z'),('object:version:customer_profile','object','customer_profile','0.1.0','3528f4f423e847858972999740cac3dec799c3f7888f279fe6652a2e6d66c88a','{\"key\":\"customer_profile\",\"name\":\"Customer profile\",\"description\":\"Business customer profile bound one-to-one to a Runtime identity account.\",\"fields\":null,\"ux\":{\"config\":{\"business_identity\":{\"active_status_values\":[\"active\"],\"key\":\"fieldservice_customer\",\"status_field\":\"status\",\"surface_keys\":[\"consumer_portal\"]},\"cardinality\":\"one_to_one\",\"identity_relation_field\":\"identity_user_id\"},\"kind\":\"identity_profile_extension\"}}','2026-08-21T18:45:46Z'),('object:version:device','object','device','0.1.0','495826439820da74bf0b6dd3d89629403bcca33d820ce740e182efe463a993d8','{\"key\":\"device\",\"name\":\"Device\",\"description\":\"Customer-owned equipment eligible for maintenance service.\",\"fields\":null,\"ux\":{\"fallback_view\":\"table\",\"kind\":\"table\"}}','2026-08-21T18:45:46Z'),('object:version:fee_ledger','object','fee_ledger','0.1.0','812001d6d199eeccf17e17a2517476953ffab77b7e0635ec12731e9b7f9bf4cd','{\"key\":\"fee_ledger\",\"name\":\"Fee ledger\",\"description\":\"Append-only charge and waiver facts used to derive final customer fee without historical drift.\",\"fields\":null,\"ux\":{\"fallback_view\":\"table\",\"kind\":\"table\"}}','2026-08-21T18:45:46Z'),('object:version:job_dead_letter','object','job_dead_letter','0.1.0','5d323c3f92de0e473d9257699f63e3ad43eb0674eea2bc87f2e200e76c60f1d8','{\"key\":\"job_dead_letter\",\"name\":\"Job Dead Letter\",\"description\":\"Runtime-owned exhausted scheduler runs.\",\"fields\":null,\"config\":{\"runtime_owned\":true,\"system_kind\":\"scheduler\"}}','2026-08-21T18:45:46Z'),('object:version:job_run','object','job_run','0.1.0','88ecf05461e42701a572ef234dd6707fe46fcfdc405ee7742d1fbaf660ee5838','{\"key\":\"job_run\",\"name\":\"Job Run\",\"description\":\"Runtime-owned scheduler executions.\",\"fields\":null,\"config\":{\"runtime_owned\":true,\"system_kind\":\"scheduler\"}}','2026-08-21T18:45:46Z'),('object:version:job_run_event','object','job_run_event','0.1.0','039fb94e9bfc0bef57d2eb4cf79d1782cb5d6de9b019daab0fce140044486395','{\"key\":\"job_run_event\",\"name\":\"Job Run Event\",\"description\":\"Runtime-owned scheduler audit events.\",\"fields\":null,\"config\":{\"runtime_owned\":true,\"system_kind\":\"scheduler\"}}','2026-08-21T18:45:46Z'),('object:version:overdue_reminder','object','overdue_reminder','0.1.0','b142b7ad823269ff358d855553863e320fd00d6be17c093110537afe3ce4ce2a','{\"key\":\"overdue_reminder\",\"name\":\"Overdue reminder\",\"description\":\"Natural-key reminder fact enforcing at most one notification per request and business date.\",\"fields\":null,\"ux\":{\"fallback_view\":\"table\",\"kind\":\"table\"}}','2026-08-21T18:45:46Z'),('object:version:part_usage','object','part_usage','0.1.0','1ab196b04f90455ef73f0bdc6c276a1b5a8a0a88d6af2159c74ef9a1da97bacf','{\"key\":\"part_usage\",\"name\":\"Part usage\",\"description\":\"Immutable event-time part consumption fact created during repair completion.\",\"fields\":null,\"ux\":{\"fallback_view\":\"table\",\"kind\":\"table\"}}','2026-08-21T18:45:46Z'),('object:version:record_timer','object','record_timer','0.1.0','229e0a71a9bb2bd0373f5890c26c0f702c1892ae1bb6a40dd476ed28070fcaa0','{\"key\":\"record_timer\",\"name\":\"Record Timer\",\"description\":\"Durable record-scoped action and workflow timers.\",\"fields\":null,\"config\":{\"runtime_owned\":true,\"system_kind\":\"scheduler\"}}','2026-08-21T18:45:46Z'),('object:version:report_export_audit','object','report_export_audit','0.1.0','a036e23afe35d6145a81ecc31bc151d7ed7326d9be0b63d89ec91563a80ef262','{\"key\":\"report_export_audit\",\"name\":\"Report export audit\",\"description\":\"Governed work-order export request and terminal audit linkage.\",\"fields\":null,\"ux\":{\"fallback_view\":\"table\",\"kind\":\"table\"}}','2026-08-21T18:45:46Z'),('object:version:report_export_download','object','report_export_download','0.1.0','8e138a078f2d55d29b4c8a6ea15923f2007524288ac5daeea98454e2da06b403','{\"key\":\"report_export_download\",\"name\":\"Report export download\",\"description\":\"Governed export artifact metadata linked to its audit request.\",\"fields\":null,\"ux\":{\"fallback_view\":\"table\",\"kind\":\"table\"}}','2026-08-21T18:45:46Z'),('object:version:scheduler_cursor','object','scheduler_cursor','0.1.0','62b01cdd972bf2e9e9e223c1e62600e07f18383ecf5818f132dbe094a3f0ef28','{\"key\":\"scheduler_cursor\",\"name\":\"Scheduler Cursor\",\"description\":\"Runtime-owned cursor for one published scheduler definition.\",\"fields\":null,\"config\":{\"runtime_owned\":true,\"system_kind\":\"scheduler\"}}','2026-08-21T18:45:46Z'),('object:version:service_request','object','service_request','0.1.0','b2aff1beee995cdfc4af953428f37ccb055880f417f591cbd1bbe390058f3dac','{\"key\":\"service_request\",\"name\":\"Service request\",\"description\":\"Customer repair request and governed internal work-order lifecycle.\",\"fields\":null,\"ux\":{\"fallback_view\":\"table\",\"kind\":\"table\"}}','2026-08-21T18:45:46Z'),('object:version:spare_part','object','spare_part','0.1.0','0b46534956f2ee18a6653c3151b020d6d6901a40de81f5700d073339308f6333','{\"key\":\"spare_part\",\"name\":\"Spare part\",\"description\":\"Maintainable part catalog with exact unit price and non-negative current stock.\",\"fields\":null,\"ux\":{\"fallback_view\":\"table\",\"kind\":\"table\"}}','2026-08-21T18:45:46Z'),('object:version:warranty_waiver','object','warranty_waiver','0.1.0','882afed2d4ced8d8fdb8872f23619f0f6c4bfedba440aa146e2e3893de4b2d74','{\"key\":\"warranty_waiver\",\"name\":\"Warranty waiver\",\"description\":\"Single immutable waiver request with a conditional terminal approval decision.\",\"fields\":null,\"ux\":{\"fallback_view\":\"table\",\"kind\":\"table\"}}','2026-08-21T18:45:46Z'),('report_export_control:version:work_order_detail_export_control','report_export_control','work_order_detail_export_control','0.1.0','5b18c597baf4972a2ce5d4a9be78bb858a4c1b3a5490c7ce84cbd5e2e3152315','{\"key\":\"work_order_detail_export_control\",\"name\":\"Work-order detail governed export\",\"report_key\":\"work_order_detail_export\",\"source_objects\":[\"service_request\"],\"watermark\":true,\"audit_object\":\"report_export_audit\",\"download_object\":\"report_export_download\",\"record_mapping\":{\"audit_report_key_field\":\"report_key\",\"audit_requester_field\":\"requester_user_id\",\"audit_status_field\":\"status\",\"audit_prepared_statuses\":[\"requested\"],\"audit_prepared_status\":\"prepared\",\"audit_downloaded_status\":\"downloaded\",\"audit_denied_status\":\"denied\",\"audit_expired_status\":\"expired\",\"audit_row_count_field\":\"row_count\",\"audit_scope_hash_field\":\"scope_hash\",\"download_audit_field\":\"audit_id\",\"download_filename_field\":\"filename\",\"download_content_hash_field\":\"content_hash\",\"download_expires_at_field\":\"expires_at\"},\"export_action\":\"report_export_audit.request_work_order_export\",\"max_rows\":100000,\"reason\":\"Manager-governed work-order detail CSV\"}','2026-08-21T18:45:46Z'),('report:version:part_usage_summary','report','part_usage_summary','0.1.0','fc05f798da20ddda530ecdce2ceccf1a6eb4a0aff59acba22144933766dae889','{\"key\":\"part_usage_summary\",\"name\":\"Part usage summary\",\"dataset\":{\"source\":{\"object_key\":\"part_usage\",\"alias\":\"usage\"},\"joins\":[{\"alias\":\"part\",\"object_key\":\"spare_part\",\"type\":\"inner\",\"left_alias\":\"usage\",\"left_field\":\"spare_part_id\",\"right_field\":\"id\",\"cardinality\":\"many_to_one\"}],\"dimensions\":[{\"key\":\"part_code\",\"field\":{\"source_alias\":\"part\",\"field_key\":\"code\"}},{\"key\":\"part_name\",\"field\":{\"source_alias\":\"part\",\"field_key\":\"name\"}}],\"measures\":[{\"key\":\"quantity_used\",\"operation\":\"sum\",\"field\":{\"source_alias\":\"usage\",\"field_key\":\"quantity\"}},{\"key\":\"usage_amount\",\"operation\":\"sum\",\"field\":{\"source_alias\":\"usage\",\"field_key\":\"amount\"}}],\"sort\":[{\"key\":\"part_code\",\"direction\":\"asc\"}]},\"required_permissions\":[\"part_usage.read\",\"spare_part.read\"],\"audience_roles\":[\"ops_manager\"],\"evidence_requirements\":[{\"object_key\":\"part_usage\",\"minimum_records\":1,\"required_non_empty_fields\":[\"amount\",\"quantity\"]}],\"materialization\":{\"maximum_lag_seconds\":300,\"consistency_retries\":3}}','2026-08-21T18:45:46Z'),('report:version:work_order_detail_export','report','work_order_detail_export','0.1.0','8aa0fe6501aeabe1803c7e5337b5c9b3310900ea71e1cc129b084bcbf35d57f0','{\"key\":\"work_order_detail_export\",\"name\":\"Work-order detail export\",\"object_sql_v1\":{\"sql\":\"SELECT\\n  sr.id AS request_id,\\n  sr.status AS status,\\n  sr.device_id AS device_id,\\n  sr.customer_profile_id AS customer_profile_id,\\n  sr.assigned_user_id AS assigned_user_id,\\n  sr.quote_amount AS quote_amount,\\n  sr.submitted_at AS submitted_at,\\n  sr.completed_at AS completed_at\\nFROM service_request AS sr\\nORDER BY sr.submitted_at DESC, sr.id ASC\\nLIMIT 10000\\n\",\"source_objects\":[\"service_request\"],\"result_schema\":[{\"key\":\"request_id\",\"type\":\"text\",\"kind\":\"dimension\"},{\"key\":\"status\",\"type\":\"text\",\"kind\":\"dimension\"},{\"key\":\"device_id\",\"type\":\"text\",\"kind\":\"dimension\"},{\"key\":\"customer_profile_id\",\"type\":\"text\",\"kind\":\"dimension\"},{\"key\":\"assigned_user_id\",\"type\":\"text\",\"kind\":\"dimension\"},{\"key\":\"quote_amount\",\"type\":\"currency\",\"kind\":\"measure\",\"precision\":19,\"scale\":2},{\"key\":\"submitted_at\",\"type\":\"datetime\",\"kind\":\"dimension\"},{\"key\":\"completed_at\",\"type\":\"datetime\",\"kind\":\"dimension\"}],\"timeout_milliseconds\":5000},\"required_permissions\":[\"service_request.read\"],\"audience_roles\":[\"ops_manager\"],\"evidence_requirements\":[{\"object_key\":\"service_request\",\"minimum_records\":1,\"required_non_empty_fields\":[\"status\",\"submitted_at\"]}]}','2026-08-21T18:45:46Z'),('report:version:work_order_throughput','report','work_order_throughput','0.1.0','b537280ee079fd750176111977f237eb624e77bdf943699e3201e76262d4938e','{\"key\":\"work_order_throughput\",\"name\":\"Work-order throughput\",\"dataset\":{\"source\":{\"object_key\":\"service_request\",\"alias\":\"request\"},\"dimensions\":[{\"key\":\"status\",\"field\":{\"source_alias\":\"request\",\"field_key\":\"status\"}}],\"measures\":[{\"key\":\"work_orders\",\"operation\":\"count\",\"source_alias\":\"request\"}],\"sort\":[{\"key\":\"status\",\"direction\":\"asc\"}]},\"required_permissions\":[\"service_request.read\"],\"audience_roles\":[\"ops_manager\"],\"evidence_requirements\":[{\"object_key\":\"service_request\",\"minimum_records\":1,\"required_non_empty_fields\":[\"status\"]}],\"materialization\":{\"maximum_lag_seconds\":300,\"consistency_retries\":3}}','2026-08-21T18:45:46Z'),('role:version:admin','role','admin','0.1.0','f4160baec42bd63cdadd2c9b7ebcb5545fd70ae632e2b79dd099215b79712bb4','{\"key\":\"admin\",\"name\":\"Admin\",\"permissions\":[\"workspace.admin\",\"workspace.admin\",\"platform_admin.domain_impact.read\",\"runtime_ops.capability_status.read\",\"identity.users.read\",\"identity.users.write\",\"identity.departments.read\",\"identity.departments.write\",\"identity.workforce.read\",\"identity.workforce.write\",\"identity.roles.read\",\"identity.roles.write\",\"identity.menus.read\",\"identity.menus.write\",\"identity.permissions.read\",\"identity.permissions.write\",\"identity.data_scopes.read\",\"identity.data_scopes.write\",\"identity.field_permissions.read\",\"identity.field_permissions.write\",\"identity.security.read\",\"identity.security.write\",\"identity.profile_binding.manage\",\"identity.permission.configure\",\"identity.audit.view\",\"party.read\",\"party.write\",\"system.read\",\"dictionary.read\",\"dictionary.write\",\"ops.workflow.read\",\"ops.workflow.run\",\"ops.workflow.simulate\",\"ops.workflow.retry\",\"ops.workflow.resolve\",\"ops.workflow.process\",\"workflow.definition.read\",\"workflow.advanced.configure\",\"workflow.process.read\",\"workflow.process.operate\",\"agent.task.read\",\"agent.task.operate\",\"workflow.task.act\",\"automation.rule.read\",\"automation.rule.write\",\"automation.rule.simulate\",\"automation.rule.execute\",\"automation.rule.history.read\",\"scheduler.definition.run\",\"scheduler.definition.read\",\"scheduler.definition.write\",\"job_run.read\",\"job_run.update\",\"audit.read\",\"audit.business.read\",\"audit.business.export\",\"audit.governance.read\",\"audit.governance.export\",\"audit.ops.read\",\"audit.ops.export\",\"import_export.read\",\"metadata.read\",\"metadata.write\",\"metadata.ops.read\",\"operations.read\",\"runtime.idempotency.manage\",\"integration.catalog.view\",\"integration.connection.manage\",\"integration.secret.manage\",\"integration.connection.test\",\"integration.invoke\",\"integration.retry\",\"integration.audit.view\",\"integration.entrypoint.invoke\",\"notification.template.read\",\"notification.template.manage\",\"notification.template.publish\",\"notification.template.approve\",\"notification.policy.read\",\"notification.policy.manage\",\"notification.template.test\"],\"record_scope\":\"all_records\",\"data_permissions\":[{\"object_key\":\"scheduler_cursor\",\"scope\":\"all_records\",\"read\":true,\"write\":true},{\"object_key\":\"job_run\",\"scope\":\"all_records\",\"read\":true,\"write\":true},{\"object_key\":\"job_run_event\",\"scope\":\"all_records\",\"read\":true,\"write\":true},{\"object_key\":\"job_dead_letter\",\"scope\":\"all_records\",\"read\":true,\"write\":true},{\"object_key\":\"record_timer\",\"scope\":\"all_records\",\"read\":true,\"write\":true}]}','2026-08-21T18:45:46Z'),('role:version:customer','role','customer','0.1.0','0cf607cd52547168389641724580e577a15780e41298ed16e89ae95e693b5898','{\"key\":\"customer\",\"name\":\"Customer\",\"permissions\":[\"customer_profile.read\",\"device.read\",\"fee_ledger.read\",\"service_request.read\",\"warranty_waiver.read\",\"service_request.submit_service_request\"],\"record_scope\":\"custom\",\"data_permissions\":[{\"object_key\":\"customer_profile\",\"scope\":\"custom\",\"read\":true,\"write\":false,\"audit_denial\":true,\"predicate\":{\"operator\":\"eq\",\"field_key\":\"identity_user_id\",\"value_source\":\"actor_claim\",\"claim_key\":\"user_id\"}},{\"object_key\":\"device\",\"scope\":\"custom\",\"read\":true,\"write\":false,\"audit_denial\":true,\"predicate\":{\"operator\":\"eq\",\"path\":[{\"direction\":\"forward\",\"relation_field_key\":\"customer_profile_id\",\"target_object_key\":\"customer_profile\"}],\"field_key\":\"identity_user_id\",\"value_source\":\"actor_claim\",\"claim_key\":\"user_id\"}},{\"object_key\":\"fee_ledger\",\"scope\":\"custom\",\"read\":true,\"write\":false,\"audit_denial\":true,\"predicate\":{\"operator\":\"eq\",\"path\":[{\"direction\":\"forward\",\"relation_field_key\":\"service_request_id\",\"target_object_key\":\"service_request\"},{\"direction\":\"forward\",\"relation_field_key\":\"customer_profile_id\",\"target_object_key\":\"customer_profile\"}],\"field_key\":\"identity_user_id\",\"value_source\":\"actor_claim\",\"claim_key\":\"user_id\"}},{\"object_key\":\"service_request\",\"scope\":\"custom\",\"read\":true,\"write\":true,\"audit_denial\":true,\"predicate\":{\"operator\":\"eq\",\"path\":[{\"direction\":\"forward\",\"relation_field_key\":\"customer_profile_id\",\"target_object_key\":\"customer_profile\"}],\"field_key\":\"identity_user_id\",\"value_source\":\"actor_claim\",\"claim_key\":\"user_id\"}},{\"object_key\":\"warranty_waiver\",\"scope\":\"custom\",\"read\":true,\"write\":false,\"audit_denial\":true,\"predicate\":{\"operator\":\"eq\",\"path\":[{\"direction\":\"forward\",\"relation_field_key\":\"service_request_id\",\"target_object_key\":\"service_request\"},{\"direction\":\"forward\",\"relation_field_key\":\"customer_profile_id\",\"target_object_key\":\"customer_profile\"}],\"field_key\":\"identity_user_id\",\"value_source\":\"actor_claim\",\"claim_key\":\"user_id\"}}],\"audience\":\"business_profile\",\"required_binding_key\":\"fieldservice_customer\",\"assignment_mode\":\"system_managed\",\"risk_level\":\"normal\"}','2026-08-21T18:45:46Z'),('role:version:identity_effective','role','identity_effective','0.1.0','f453fb559ac56861f45bbc56f9f99d1c19f46658421e86abb1cee35db1f69f00','{\"key\":\"identity_effective\",\"name\":\"Identity Effective\",\"permissions\":null,\"record_scope\":\"all_records\"}','2026-08-21T18:45:46Z'),('role:version:ops_manager','role','ops_manager','0.1.0','821fe1c72ee61fa5cc34a78addfc7a581ec316e920702793ee818e49eeccf9b1','{\"key\":\"ops_manager\",\"name\":\"Operations manager\",\"permissions\":[\"customer_profile.read\",\"device.read\",\"fee_ledger.read\",\"identity.workforce.read\",\"overdue_reminder.read\",\"part_usage.read\",\"report_export_audit.create\",\"report_export_audit.read\",\"report_export_audit.update\",\"report_export_download.create\",\"report_export_download.read\",\"scheduler.command\",\"service_request.export\",\"service_request.read\",\"spare_part.read\",\"warranty_waiver.read\",\"workflow.task.act\",\"service_request.dispatch_service_request\",\"service_request.unassign_service_request\",\"warranty_waiver.decide_warranty_waiver\"],\"record_scope\":\"all_records\",\"data_permissions\":[{\"object_key\":\"customer_profile\",\"scope\":\"all_records\",\"read\":true,\"write\":false,\"audit_denial\":true},{\"object_key\":\"device\",\"scope\":\"all_records\",\"read\":true,\"write\":false,\"audit_denial\":true},{\"object_key\":\"fee_ledger\",\"scope\":\"all_records\",\"read\":true,\"write\":true,\"audit_denial\":true},{\"object_key\":\"overdue_reminder\",\"scope\":\"all_records\",\"read\":true,\"write\":true,\"audit_denial\":true},{\"object_key\":\"part_usage\",\"scope\":\"all_records\",\"read\":true,\"write\":true,\"audit_denial\":true},{\"object_key\":\"report_export_audit\",\"scope\":\"owned_records\",\"read\":true,\"write\":true,\"audit_denial\":true},{\"object_key\":\"report_export_download\",\"scope\":\"owned_records\",\"read\":true,\"write\":true,\"audit_denial\":true},{\"object_key\":\"service_request\",\"scope\":\"all_records\",\"read\":true,\"write\":true,\"audit_denial\":true},{\"object_key\":\"spare_part\",\"scope\":\"all_records\",\"read\":true,\"write\":true,\"audit_denial\":true},{\"object_key\":\"warranty_waiver\",\"scope\":\"all_records\",\"read\":true,\"write\":true,\"audit_denial\":true}],\"audience\":\"workforce\",\"assignment_mode\":\"request_only\",\"risk_level\":\"privileged\"}','2026-08-21T18:45:46Z'),('role:version:organization_administrator','role','organization_administrator','0.1.0','5eb7ca59eb5a96918ef056c74c37ad7bcd2be7ca22e51973a86d1fda7f6568af','{\"key\":\"organization_administrator\",\"name\":\"Organization administrator\",\"permissions\":[\"identity.users.read\",\"identity.workforce.read\",\"identity.departments.read\",\"identity.roles.read\",\"identity.data_scopes.read\",\"identity.field_permissions.read\",\"system.read\",\"dictionary.read\",\"workflow.definition.read\",\"metadata.read\",\"automation.rule.read\",\"integration.catalog.view\",\"notification.template.read\",\"scheduler.definition.read\",\"audit.read\",\"platform_admin.domain_impact.read\"],\"record_scope\":\"all_records\",\"data_permissions\":[{\"object_key\":\"job_run\",\"scope\":\"none\",\"read\":false,\"write\":false}]}','2026-08-21T18:45:46Z'),('role:version:scheduler_service','role','scheduler_service','0.1.0','b61b1c167ec3b19f1f620cfbb4b2d453ccfba62037daee2f10e5d12a36ad1225','{\"key\":\"scheduler_service\",\"name\":\"Scheduler service\",\"permissions\":[\"service_request.send_overdue_reminder\"],\"record_scope\":\"all_records\",\"data_permissions\":[{\"object_key\":\"customer_profile\",\"scope\":\"all_records\",\"read\":true,\"write\":false,\"audit_denial\":true},{\"object_key\":\"device\",\"scope\":\"all_records\",\"read\":true,\"write\":false,\"audit_denial\":true},{\"object_key\":\"overdue_reminder\",\"scope\":\"all_records\",\"read\":true,\"write\":true,\"audit_denial\":true},{\"object_key\":\"service_request\",\"scope\":\"all_records\",\"read\":true,\"write\":false,\"audit_denial\":true}],\"audience\":\"service\",\"assignment_mode\":\"manual\",\"risk_level\":\"normal\"}','2026-08-21T18:45:46Z'),('role:version:system_administrator','role','system_administrator','0.1.0','07096722037751475bb615622cc0ba296b0ccaa6e53d0905b00788aecda88336','{\"key\":\"system_administrator\",\"name\":\"System administrator\",\"permissions\":[\"workflow.process.read\",\"operations.read\",\"integration.audit.view\",\"job_run.read\",\"runtime_ops.capability_status.read\"],\"record_scope\":\"all_records\",\"data_permissions\":[{\"object_key\":\"job_run\",\"scope\":\"all_records\",\"read\":true,\"write\":false}]}','2026-08-21T18:45:46Z'),('role:version:technician','role','technician','0.1.0','d7fb1eb9d5e2d9dc09818d393fa8da9fbecccc0efda73f82dd5a8cf9d3a822f6','{\"key\":\"technician\",\"name\":\"Technician\",\"permissions\":[\"identity.workforce.read\",\"part_usage.read\",\"service_request.read\",\"spare_part.read\",\"warranty_waiver.read\",\"service_request.complete_repair\",\"service_request.request_warranty_waiver\",\"service_request.start_assigned_repair\"],\"record_scope\":\"department\",\"data_permissions\":[{\"object_key\":\"customer_profile\",\"scope\":\"all_records\",\"read\":true,\"write\":false,\"audit_denial\":true},{\"object_key\":\"device\",\"scope\":\"all_records\",\"read\":true,\"write\":false,\"audit_denial\":true},{\"object_key\":\"fee_ledger\",\"scope\":\"all_records\",\"read\":false,\"write\":true,\"audit_denial\":true},{\"object_key\":\"overdue_reminder\",\"scope\":\"department\",\"read\":true,\"write\":false,\"audit_denial\":true},{\"object_key\":\"part_usage\",\"scope\":\"department\",\"read\":true,\"write\":true,\"audit_denial\":true},{\"object_key\":\"service_request\",\"scope\":\"department\",\"read\":true,\"write\":true,\"audit_denial\":true},{\"object_key\":\"spare_part\",\"scope\":\"all_records\",\"read\":true,\"write\":true,\"audit_denial\":true},{\"object_key\":\"warranty_waiver\",\"scope\":\"department\",\"read\":true,\"write\":true,\"audit_denial\":true}],\"audience\":\"workforce\",\"assignment_mode\":\"manual\",\"risk_level\":\"normal\"}','2026-08-21T18:45:46Z'),('scheduler:version:weekday_overdue_reminders','scheduler','weekday_overdue_reminders','0.1.0','593e5c98b34bd397cc7b60a94065a553c98718651106a6b6a499fcdb26b076ae','{\"__seed_key\":\"weekday_overdue_reminders\",\"key\":\"weekday_overdue_reminders\",\"max_attempts\":3,\"missed_window_policy\":\"catch_up_one\",\"name\":\"Weekday overdue service reminders\",\"schedule_expression\":\"0 9 * * 1-5\",\"schedule_type\":\"cron\",\"status\":\"enabled\",\"target_key\":\"scheduled:overdue_service_request_scan\",\"target_type\":\"workflow\",\"timeout_seconds\":300,\"timezone\":\"Asia/Shanghai\",\"trigger_type\":\"scheduled\"}','2026-08-21T18:45:46Z'),('validation:version:record_timer_identity','validation','record_timer_identity','0.1.0','178dee73a7ee90b83bb8be3fcb85c1fa3b8198fc45f51c7df0c759c9cead2fb4','{\"key\":\"record_timer_identity\",\"object_key\":\"record_timer\",\"type\":\"composite_unique\",\"fields\":[\"timer_key\",\"object_key\",\"record_id\",\"purpose\"]}','2026-08-21T18:45:46Z'),('validation:version:service_request_lifecycle','validation','service_request_lifecycle','0.1.0','8310cd8e5325244fd8a6daba514ba17514aadd3ca878f29207604a674e8bebff','{\"key\":\"service_request_lifecycle\",\"object_key\":\"service_request\",\"type\":\"state_machine\",\"field_key\":\"status\",\"severity\":\"error\",\"message\":\"Service request lifecycle\",\"config\":{\"field_key\":\"status\",\"states\":[\"completed\",\"dispatched\",\"in_repair\",\"submitted\"],\"terminal_states\":[\"completed\"],\"transitions\":[{\"action_key\":\"service_request.start_assigned_repair\",\"from\":\"dispatched\",\"to\":\"in_repair\"},{\"action_key\":\"service_request.unassign_service_request\",\"from\":\"dispatched\",\"to\":\"submitted\"},{\"action_key\":\"service_request.complete_repair\",\"from\":\"in_repair\",\"to\":\"completed\"},{\"action_key\":\"service_request.dispatch_service_request\",\"from\":\"submitted\",\"to\":\"dispatched\"}]}}','2026-08-21T18:45:46Z'),('view:version:customer_profile_detail','view','customer_profile_detail','0.1.0','a633b95229d7cc9629eb20ffc42085492804db2b7397ffa29d8bebf282d86e87','{\"key\":\"customer_profile_detail\",\"name\":\"Customer profile Detail\",\"object_key\":\"customer_profile\",\"type\":\"detail\",\"config\":{\"columns\":[\"display_name\",\"identity_user_id\",\"status\"],\"search_fields\":[\"display_name\",\"status\"],\"sections\":[\"main\"]}}','2026-08-21T18:45:46Z'),('view:version:customer_profile_list','view','customer_profile_list','0.1.0','4ada495527d802366bad8a5376b728c24bdd916a6f4ed93673c929ed7303b9c2','{\"key\":\"customer_profile_list\",\"name\":\"Customer profile\",\"object_key\":\"customer_profile\",\"type\":\"table\",\"config\":{\"columns\":[\"display_name\",\"identity_user_id\",\"status\"],\"page_size\":25,\"search_fields\":[\"display_name\",\"status\"]}}','2026-08-21T18:45:46Z'),('view:version:device_detail','view','device_detail','0.1.0','eb6b4e76f2454a21b95fa58667a7a6069cd05f9b655f53251a54c79190607b33','{\"key\":\"device_detail\",\"name\":\"Device Detail\",\"object_key\":\"device\",\"type\":\"detail\",\"config\":{\"columns\":[\"name\",\"customer_profile_id\",\"purchase_date\",\"serial_number\"],\"search_fields\":[\"name\"],\"sections\":[\"main\"]}}','2026-08-21T18:45:46Z'),('view:version:device_list','view','device_list','0.1.0','d87a963d6608becf9cd63a9e078dc466fa8fd37a52b07ca1880f5bd1fdceb8a6','{\"key\":\"device_list\",\"name\":\"Device\",\"object_key\":\"device\",\"type\":\"table\",\"config\":{\"columns\":[\"name\",\"customer_profile_id\",\"purchase_date\",\"serial_number\"],\"page_size\":25,\"search_fields\":[\"name\"]}}','2026-08-21T18:45:46Z'),('view:version:fee_ledger_detail','view','fee_ledger_detail','0.1.0','8b162adc5180a6870053dcd2d58054ceda5451acad70b990402ac692bd978281','{\"key\":\"fee_ledger_detail\",\"name\":\"Fee ledger Detail\",\"object_key\":\"fee_ledger\",\"type\":\"detail\",\"config\":{\"columns\":[\"amount\",\"calculation_trace\",\"input_snapshot\",\"kind\",\"lineage_key\",\"occurred_at\"],\"search_fields\":[\"kind\",\"lineage_key\"],\"sections\":[\"main\"]}}','2026-08-21T18:45:46Z'),('view:version:fee_ledger_list','view','fee_ledger_list','0.1.0','b275d3fd760e314fbec5c1accd0de6fa44146105e59773e2875f4fd217f7b11e','{\"key\":\"fee_ledger_list\",\"name\":\"Fee ledger\",\"object_key\":\"fee_ledger\",\"type\":\"table\",\"config\":{\"columns\":[\"amount\",\"calculation_trace\",\"input_snapshot\",\"kind\",\"lineage_key\",\"occurred_at\"],\"page_size\":25,\"search_fields\":[\"kind\",\"lineage_key\"]}}','2026-08-21T18:45:46Z'),('view:version:overdue_reminder_detail','view','overdue_reminder_detail','0.1.0','8a0ed412d0d58d1f1eca6234b3303309433115398a201bbb4cf5765ad8aedf41','{\"key\":\"overdue_reminder_detail\",\"name\":\"Overdue reminder Detail\",\"object_key\":\"overdue_reminder\",\"type\":\"detail\",\"config\":{\"columns\":[\"business_date\",\"dedupe_key\",\"owner_department_id\",\"owner_department_path\",\"recipient_user_id\",\"sent_at\"],\"search_fields\":[\"dedupe_key\",\"owner_department_id\",\"owner_department_path\"],\"sections\":[\"main\"]}}','2026-08-21T18:45:46Z'),('view:version:overdue_reminder_list','view','overdue_reminder_list','0.1.0','2bddd9684ca1f425877f5cd4a72dc6a809e5af39783fa71bbd7b4d57308e9517','{\"key\":\"overdue_reminder_list\",\"name\":\"Overdue reminder\",\"object_key\":\"overdue_reminder\",\"type\":\"table\",\"config\":{\"columns\":[\"business_date\",\"dedupe_key\",\"owner_department_id\",\"owner_department_path\",\"recipient_user_id\",\"sent_at\"],\"page_size\":25,\"search_fields\":[\"dedupe_key\",\"owner_department_id\",\"owner_department_path\"]}}','2026-08-21T18:45:46Z'),('view:version:part_usage_detail','view','part_usage_detail','0.1.0','e3f7b21f08e8553f34964179c4a9759bf46ac319c417109fe989e4289595e255','{\"key\":\"part_usage_detail\",\"name\":\"Part usage Detail\",\"object_key\":\"part_usage\",\"type\":\"detail\",\"config\":{\"columns\":[\"amount\",\"calculation_trace\",\"occurred_at\",\"owner_department_id\",\"owner_department_path\",\"performed_by_user_id\"],\"search_fields\":[\"owner_department_id\",\"owner_department_path\"],\"sections\":[\"main\"]}}','2026-08-21T18:45:46Z'),('view:version:part_usage_list','view','part_usage_list','0.1.0','86dfa7bd89f0b4e89fd76f53846e4bb5106eed2dbe1cf8434679c949f5b54359','{\"key\":\"part_usage_list\",\"name\":\"Part usage\",\"object_key\":\"part_usage\",\"type\":\"table\",\"config\":{\"columns\":[\"amount\",\"calculation_trace\",\"occurred_at\",\"owner_department_id\",\"owner_department_path\",\"performed_by_user_id\"],\"page_size\":25,\"search_fields\":[\"owner_department_id\",\"owner_department_path\"]}}','2026-08-21T18:45:46Z'),('view:version:report_export_audit_detail','view','report_export_audit_detail','0.1.0','5d1b41b6e3bd6e8b20c43cc4ee5e5c7cdead04a16e92601e44f98d6cb47b72f6','{\"key\":\"report_export_audit_detail\",\"name\":\"Report export audit Detail\",\"object_key\":\"report_export_audit\",\"type\":\"detail\",\"config\":{\"columns\":[\"owner_department_id\",\"owner_department_path\",\"purpose\",\"report_key\",\"requested_at\",\"requester_user_id\"],\"search_fields\":[\"owner_department_id\",\"owner_department_path\",\"report_key\"],\"sections\":[\"main\"]}}','2026-08-21T18:45:46Z'),('view:version:report_export_audit_list','view','report_export_audit_list','0.1.0','e6d2c30b2b66081698883513c675aa0d0d109ce06cdf0fd3f769ab26490888ac','{\"key\":\"report_export_audit_list\",\"name\":\"Report export audit\",\"object_key\":\"report_export_audit\",\"type\":\"table\",\"config\":{\"columns\":[\"owner_department_id\",\"owner_department_path\",\"purpose\",\"report_key\",\"requested_at\",\"requester_user_id\"],\"page_size\":25,\"search_fields\":[\"owner_department_id\",\"owner_department_path\",\"report_key\"]}}','2026-08-21T18:45:46Z'),('view:version:report_export_download_detail','view','report_export_download_detail','0.1.0','ec6814b60587559d307735969aee51c196a114cdf4864093356001abe1aff65f','{\"key\":\"report_export_download_detail\",\"name\":\"Report export download Detail\",\"object_key\":\"report_export_download\",\"type\":\"detail\",\"config\":{\"columns\":[\"audit_id\",\"content_hash\",\"expires_at\",\"filename\",\"owner\"],\"search_fields\":[\"content_hash\",\"filename\"],\"sections\":[\"main\"]}}','2026-08-21T18:45:46Z'),('view:version:report_export_download_list','view','report_export_download_list','0.1.0','ee3bab1bb21cf0f11e8201f72f4d82da8d9d3b201b0c7fd2b0b7c75a7a5934ed','{\"key\":\"report_export_download_list\",\"name\":\"Report export download\",\"object_key\":\"report_export_download\",\"type\":\"table\",\"config\":{\"columns\":[\"audit_id\",\"content_hash\",\"expires_at\",\"filename\",\"owner\"],\"page_size\":25,\"search_fields\":[\"content_hash\",\"filename\"]}}','2026-08-21T18:45:46Z'),('view:version:service_request_detail','view','service_request_detail','0.1.0','a3bc89c465b7837d4fdba8d1404d00ed47e7b5a40511ccd93aed8dc316b44a4d','{\"key\":\"service_request_detail\",\"name\":\"Service request Detail\",\"object_key\":\"service_request\",\"type\":\"detail\",\"config\":{\"columns\":[\"assigned_user_id\",\"completed_at\",\"customer_profile_id\",\"device_id\",\"dispatched_at\",\"fault_description\"],\"search_fields\":[\"owner_department_id\",\"owner_department_path\",\"status\"],\"sections\":[\"main\"]}}','2026-08-21T18:45:46Z'),('view:version:service_request_list','view','service_request_list','0.1.0','6a3c21f46c57c2f5d2114f96ad9c7f45b09319becb6b1d2d2c1581e00ce2223c','{\"key\":\"service_request_list\",\"name\":\"Service request list\",\"object_key\":\"service_request\",\"type\":\"table\",\"config\":{\"business_view\":\"list\",\"columns\":[\"device_id\",\"status\",\"assigned_user_id\",\"quote_amount\",\"submitted_at\"],\"filters\":[{\"field\":\"status\",\"key\":\"submitted\",\"value\":\"submitted\"},{\"field\":\"status\",\"key\":\"dispatched\",\"value\":\"dispatched\"}],\"page_size\":50,\"search_fields\":[\"fault_description\"],\"sort\":[{\"direction\":\"desc\",\"field\":\"submitted_at\"},{\"direction\":\"asc\",\"field\":\"id\"}]}}','2026-08-21T18:45:46Z'),('view:version:spare_part_detail','view','spare_part_detail','0.1.0','e79aa39ce05c36b4c2f7b07c4f086244a96b3557c466092a6e2b3085af62ae19','{\"key\":\"spare_part_detail\",\"name\":\"Spare part Detail\",\"object_key\":\"spare_part\",\"type\":\"detail\",\"config\":{\"columns\":[\"name\",\"code\",\"stock_quantity\",\"unit_price\"],\"search_fields\":[\"name\"],\"sections\":[\"main\"]}}','2026-08-21T18:45:46Z'),('view:version:spare_part_list','view','spare_part_list','0.1.0','1ae6f72fb3114159bce16072be286af36818f4ed71670516a458479eb4aad4df','{\"key\":\"spare_part_list\",\"name\":\"Spare part list\",\"object_key\":\"spare_part\",\"type\":\"table\",\"config\":{\"business_view\":\"list\",\"columns\":[\"code\",\"name\",\"unit_price\",\"stock_quantity\"],\"filters\":[],\"page_size\":50,\"search_fields\":[\"code\",\"name\"],\"sort\":[{\"direction\":\"asc\",\"field\":\"code\"},{\"direction\":\"asc\",\"field\":\"id\"}]}}','2026-08-21T18:45:46Z'),('view:version:warranty_waiver_detail','view','warranty_waiver_detail','0.1.0','efaf4eab744154f9cc511f1a98614914b46f635804da493ca499675aa3c2110e','{\"key\":\"warranty_waiver_detail\",\"name\":\"Warranty waiver Detail\",\"object_key\":\"warranty_waiver\",\"type\":\"detail\",\"config\":{\"columns\":[\"calculation_trace\",\"decided_at\",\"decided_by_user_id\",\"owner_department_id\",\"owner_department_path\",\"policy_snapshot\"],\"search_fields\":[\"owner_department_id\",\"owner_department_path\",\"status\"],\"sections\":[\"main\"]}}','2026-08-21T18:45:46Z'),('view:version:warranty_waiver_list','view','warranty_waiver_list','0.1.0','2031e2ed963331726a1160be82defe3e324dd71029f5cf32fdb0c5b0c763b18c','{\"key\":\"warranty_waiver_list\",\"name\":\"Warranty waiver\",\"object_key\":\"warranty_waiver\",\"type\":\"table\",\"config\":{\"columns\":[\"calculation_trace\",\"decided_at\",\"decided_by_user_id\",\"owner_department_id\",\"owner_department_path\",\"policy_snapshot\"],\"page_size\":25,\"search_fields\":[\"owner_department_id\",\"owner_department_path\",\"status\"]}}','2026-08-21T18:45:46Z'),('workflow:version:overdue_service_request_scan','workflow','overdue_service_request_scan','0.1.0','aa5b3f2a21fc262b743c399e60615964cd2d89e5d404911b1e1630da5095197b','{\"key\":\"overdue_service_request_scan\",\"name\":\"Overdue service request scan\",\"trigger\":{\"type\":\"scheduled\"},\"condition\":{\"field\":\"status\",\"type\":\"field_equals\",\"value\":\"dispatched\"},\"action\":{\"type\":\"workflow_graph\"},\"trigger_contract\":{\"type\":\"scheduled\",\"object_key\":\"service_request\"},\"enabled\":true,\"run_as\":\"scheduler_service\",\"graph\":{\"version\":2,\"nodes\":[{\"id\":\"schedule_trigger\",\"type\":\"trigger\",\"name\":\"Scheduled record scan\"},{\"id\":\"send_reminder\",\"type\":\"action\",\"name\":\"Send eligible overdue reminder\",\"contract\":{\"action\":{\"action_key\":\"service_request.send_overdue_reminder\",\"object_key\":\"service_request\",\"record_id\":\"$record.id\",\"input\":{\"scheduled_at\":\"$workflow.scheduled_at\"},\"on_error\":\"fail\"}}}],\"edges\":[{\"id\":\"trigger_to_reminder\",\"source\":\"schedule_trigger\",\"target\":\"send_reminder\"}]}}','2026-08-21T18:45:46Z'),('workflow:version:platform.audit_retention_check','workflow','platform.audit_retention_check','0.1.0','6bcdea614cf9b271dbeebdaf5fcf760fcba193ca43a9ed4dd123309cfd5742ec','{\"key\":\"platform.audit_retention_check\",\"name\":\"Audit retention check\",\"trigger\":{\"type\":\"manual\"},\"condition\":{\"type\":\"always\"},\"action\":{\"type\":\"workflow_graph\"},\"trigger_contract\":{\"type\":\"manual\"},\"condition_contract\":{\"type\":\"always\"},\"enabled\":true,\"retry\":{\"max_attempts\":3,\"delay_seconds\":60},\"audit_event\":\"platform_audit_retention_checked\",\"graph\":{\"version\":2,\"nodes\":[{\"id\":\"manual_trigger\",\"type\":\"trigger\",\"name\":\"Run audit retention check\"}],\"edges\":null}}','2026-08-21T18:45:46Z'),('workflow:version:platform.metadata_health_check','workflow','platform.metadata_health_check','0.1.0','d35b2ac8904714b0758ae5865488613949ccd607c3b536605281087fd71ebdc3','{\"key\":\"platform.metadata_health_check\",\"name\":\"Metadata health check\",\"trigger\":{\"type\":\"manual\"},\"condition\":{\"type\":\"always\"},\"action\":{\"type\":\"workflow_graph\"},\"trigger_contract\":{\"type\":\"manual\"},\"condition_contract\":{\"type\":\"always\"},\"enabled\":true,\"retry\":{\"max_attempts\":3,\"delay_seconds\":60},\"audit_event\":\"platform_metadata_health_checked\",\"graph\":{\"version\":2,\"nodes\":[{\"id\":\"manual_trigger\",\"type\":\"trigger\",\"name\":\"Run metadata health check\"}],\"edges\":null}}','2026-08-21T18:45:46Z'),('workflow:version:warranty_waiver_approval','workflow','warranty_waiver_approval','0.1.0','bc1e690354bcb8187a10b6f75d2731a658ffd6c2be01b815e4c1dda985eb53d9','{\"key\":\"warranty_waiver_approval\",\"name\":\"Warranty waiver approval\",\"trigger\":{\"type\":\"record_created\"},\"condition\":{\"field\":\"status\",\"type\":\"field_equals\",\"value\":\"pending\"},\"action\":{\"type\":\"workflow_graph\"},\"trigger_contract\":{\"type\":\"record_created\",\"object_key\":\"warranty_waiver\"},\"enabled\":true,\"run_as\":\"ops_manager\",\"graph\":{\"version\":2,\"nodes\":[{\"id\":\"waiver_created\",\"type\":\"trigger\",\"name\":\"Pending waiver created\"},{\"id\":\"manager_approval\",\"type\":\"approval\",\"name\":\"Operations manager approval\",\"contract\":{\"approval\":{\"mode\":\"any\",\"resolvers\":[{\"type\":\"role\",\"priority\":1,\"role_key\":\"ops_manager\"}],\"resolver_mode\":\"union\",\"empty_assignee_policy\":\"fail\"}}},{\"id\":\"apply_waiver\",\"type\":\"action\",\"name\":\"Apply approved waiver\",\"contract\":{\"action\":{\"action_key\":\"warranty_waiver.decide_warranty_waiver\",\"object_key\":\"warranty_waiver\",\"record_id\":\"$record.id\",\"input\":{\"decided_at\":\"$now\",\"decision\":\"approved\"},\"on_error\":\"fail\"}}},{\"id\":\"reject_waiver\",\"type\":\"action\",\"name\":\"Record rejected waiver\",\"contract\":{\"action\":{\"action_key\":\"warranty_waiver.decide_warranty_waiver\",\"object_key\":\"warranty_waiver\",\"record_id\":\"$record.id\",\"input\":{\"decided_at\":\"$now\",\"decision\":\"rejected\",\"rejection_reason\":\"Rejected by operations manager\"},\"on_error\":\"fail\"}}}],\"edges\":[{\"id\":\"created_to_approval\",\"source\":\"waiver_created\",\"target\":\"manager_approval\"},{\"id\":\"approved_to_apply\",\"source\":\"manager_approval\",\"target\":\"apply_waiver\",\"branch\":\"approved\"},{\"id\":\"rejected_to_record\",\"source\":\"manager_approval\",\"target\":\"reject_waiver\",\"branch\":\"rejected\"}]}}','2026-08-21T18:45:46Z');
/*!40000 ALTER TABLE `metadata_definition_versions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `metadata_exact_decimal_migrations`
--

DROP TABLE IF EXISTS `metadata_exact_decimal_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `metadata_exact_decimal_migrations` (
  `id` varchar(191) NOT NULL,
  `contract_version` varchar(191) NOT NULL,
  `object_key` varchar(191) NOT NULL,
  `column_keys` longtext NOT NULL,
  `from_types` longtext NOT NULL,
  `to_types` longtext NOT NULL,
  `row_count` bigint NOT NULL,
  `before_hash` varchar(191) NOT NULL,
  `after_hash` varchar(191) NOT NULL,
  `applied_at` varchar(191) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `metadata_exact_decimal_migrations`
--

LOCK TABLES `metadata_exact_decimal_migrations` WRITE;
/*!40000 ALTER TABLE `metadata_exact_decimal_migrations` DISABLE KEYS */;
/*!40000 ALTER TABLE `metadata_exact_decimal_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_alert_groups`
--

DROP TABLE IF EXISTS `notification_alert_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification_alert_groups` (
  `workspace_id` varchar(191) NOT NULL,
  `recipient_user_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `surface` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `group_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `state` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `occurrence_count` int NOT NULL DEFAULT '1',
  `first_occurred_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `last_occurred_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `acknowledged_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '',
  `acknowledged_by` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '',
  `resolved_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '',
  `last_event_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `updated_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  UNIQUE KEY `uniq_notification_alert_group` (`workspace_id`,`recipient_user_id`,`surface`,`group_key`),
  KEY `idx_notification_alert_group_state` (`workspace_id`,`state`,`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_alert_groups`
--

LOCK TABLES `notification_alert_groups` WRITE;
/*!40000 ALTER TABLE `notification_alert_groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `notification_alert_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_channel_plans`
--

DROP TABLE IF EXISTS `notification_channel_plans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification_channel_plans` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `event_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `channel` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `status` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `payload_json` longtext NOT NULL,
  `attempt_count` int NOT NULL DEFAULT '0',
  `next_attempt_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '',
  `last_error_code` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '',
  `outbox_message_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '',
  `lease_owner` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '',
  `lease_expires_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '',
  `fencing_token` bigint NOT NULL DEFAULT '0',
  `created_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `updated_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  UNIQUE KEY `uniq_notification_channel_plan_identity` (`workspace_id`,`id`),
  KEY `idx_notification_channel_plan_due` (`status`,`next_attempt_at`,`lease_expires_at`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_channel_plans`
--

LOCK TABLES `notification_channel_plans` WRITE;
/*!40000 ALTER TABLE `notification_channel_plans` DISABLE KEYS */;
/*!40000 ALTER TABLE `notification_channel_plans` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_delivery_policy`
--

DROP TABLE IF EXISTS `notification_delivery_policy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification_delivery_policy` (
  `policy_key` varchar(191) NOT NULL,
  `payload_json` longtext NOT NULL,
  `updated_by` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`policy_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_delivery_policy`
--

LOCK TABLES `notification_delivery_policy` WRITE;
/*!40000 ALTER TABLE `notification_delivery_policy` DISABLE KEYS */;
/*!40000 ALTER TABLE `notification_delivery_policy` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_delivery_reservations`
--

DROP TABLE IF EXISTS `notification_delivery_reservations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification_delivery_reservations` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `recipient_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `template_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `channel` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `dedupe_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '',
  `created_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  UNIQUE KEY `uniq_notification_delivery_reservation_workspace_identity` (`workspace_id`,`id`),
  KEY `idx_notification_delivery_frequency` (`workspace_id`,`recipient_key`,`channel`,`created_at`),
  KEY `idx_notification_delivery_dedupe` (`workspace_id`,`recipient_key`,`template_key`,`channel`,`dedupe_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_delivery_reservations`
--

LOCK TABLES `notification_delivery_reservations` WRITE;
/*!40000 ALTER TABLE `notification_delivery_reservations` DISABLE KEYS */;
/*!40000 ALTER TABLE `notification_delivery_reservations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_event_failures`
--

DROP TABLE IF EXISTS `notification_event_failures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification_event_failures` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `event_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `event_type` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `source` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `source_event_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `stage` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `error_code` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `attempt` int NOT NULL,
  `disposition` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `retryable` int NOT NULL DEFAULT '0',
  `next_attempt_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '',
  `fencing_token` bigint NOT NULL,
  `occurred_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  UNIQUE KEY `uniq_notification_event_failure_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_notification_event_failure_attempt` (`workspace_id`,`event_id`,`fencing_token`),
  KEY `idx_notification_event_failure_governance` (`workspace_id`,`occurred_at`,`stage`,`error_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_event_failures`
--

LOCK TABLES `notification_event_failures` WRITE;
/*!40000 ALTER TABLE `notification_event_failures` DISABLE KEYS */;
/*!40000 ALTER TABLE `notification_event_failures` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_events`
--

DROP TABLE IF EXISTS `notification_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification_events` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `source` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `source_event_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `status` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `payload_json` longtext NOT NULL,
  `attempt_count` int NOT NULL DEFAULT '0',
  `next_attempt_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '',
  `last_error_code` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '',
  `lease_owner` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '',
  `lease_expires_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '',
  `fencing_token` bigint NOT NULL DEFAULT '0',
  `occurred_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `created_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `updated_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  UNIQUE KEY `uniq_notification_event_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_notification_event_source_identity` (`workspace_id`,`source`,`source_event_id`),
  KEY `idx_notification_event_due` (`status`,`next_attempt_at`,`lease_expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_events`
--

LOCK TABLES `notification_events` WRITE;
/*!40000 ALTER TABLE `notification_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `notification_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_inbox_delegations`
--

DROP TABLE IF EXISTS `notification_inbox_delegations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification_inbox_delegations` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `owner_user_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `delegate_user_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `surface` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `starts_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '',
  `ends_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '',
  `enabled` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `updated_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  UNIQUE KEY `uniq_notification_inbox_delegation_identity` (`workspace_id`,`id`),
  KEY `idx_notification_inbox_delegation_delegate` (`workspace_id`,`delegate_user_id`,`surface`,`enabled`,`starts_at`,`ends_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_inbox_delegations`
--

LOCK TABLES `notification_inbox_delegations` WRITE;
/*!40000 ALTER TABLE `notification_inbox_delegations` DISABLE KEYS */;
/*!40000 ALTER TABLE `notification_inbox_delegations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_inbox_items`
--

DROP TABLE IF EXISTS `notification_inbox_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification_inbox_items` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `recipient_user_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `surface` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `event_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `event_type` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `source` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `category` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `severity` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `title` longtext NOT NULL,
  `body` longtext NOT NULL,
  `search_text` longtext NOT NULL,
  `payload_json` longtext NOT NULL,
  `subject_type` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '',
  `subject_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '',
  `action_state` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `alert_state` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '',
  `group_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '',
  `occurrence_count` int NOT NULL DEFAULT '1',
  `first_occurred_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `last_occurred_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `read_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '',
  `archived_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '',
  `expires_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '',
  `created_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `updated_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  UNIQUE KEY `uniq_notification_inbox_workspace_identity` (`workspace_id`,`id`),
  KEY `idx_notification_inbox_mailbox` (`workspace_id`,`recipient_user_id`,`surface`,`archived_at`,`updated_at`,`id`),
  KEY `idx_notification_inbox_unread` (`workspace_id`,`recipient_user_id`,`surface`,`read_at`,`archived_at`),
  KEY `idx_notification_inbox_facets` (`workspace_id`,`recipient_user_id`,`surface`,`category`,`source`,`severity`,`archived_at`),
  KEY `idx_notification_inbox_group` (`workspace_id`,`recipient_user_id`,`surface`,`group_key`,`alert_state`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_inbox_items`
--

LOCK TABLES `notification_inbox_items` WRITE;
/*!40000 ALTER TABLE `notification_inbox_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `notification_inbox_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_inbox_saved_views`
--

DROP TABLE IF EXISTS `notification_inbox_saved_views`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification_inbox_saved_views` (
  `workspace_id` varchar(191) NOT NULL,
  `recipient_user_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `surface` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `view_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `payload_json` longtext NOT NULL,
  `created_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `updated_at` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  UNIQUE KEY `uniq_notification_inbox_saved_view` (`workspace_id`,`recipient_user_id`,`surface`,`view_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_inbox_saved_views`
--

LOCK TABLES `notification_inbox_saved_views` WRITE;
/*!40000 ALTER TABLE `notification_inbox_saved_views` DISABLE KEYS */;
/*!40000 ALTER TABLE `notification_inbox_saved_views` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_recipient_preferences`
--

DROP TABLE IF EXISTS `notification_recipient_preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification_recipient_preferences` (
  `workspace_id` varchar(191) NOT NULL,
  `recipient_key` varchar(191) NOT NULL,
  `payload_json` longtext NOT NULL,
  `updated_by` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_notification_recipient_preference` (`workspace_id`,`recipient_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_recipient_preferences`
--

LOCK TABLES `notification_recipient_preferences` WRITE;
/*!40000 ALTER TABLE `notification_recipient_preferences` DISABLE KEYS */;
/*!40000 ALTER TABLE `notification_recipient_preferences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_template_publication_locks`
--

DROP TABLE IF EXISTS `notification_template_publication_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification_template_publication_locks` (
  `template_key` varchar(191) NOT NULL,
  `request_id` varchar(191) NOT NULL,
  `created_at` varchar(191) NOT NULL,
  PRIMARY KEY (`template_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_template_publication_locks`
--

LOCK TABLES `notification_template_publication_locks` WRITE;
/*!40000 ALTER TABLE `notification_template_publication_locks` DISABLE KEYS */;
/*!40000 ALTER TABLE `notification_template_publication_locks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_template_publication_requests`
--

DROP TABLE IF EXISTS `notification_template_publication_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification_template_publication_requests` (
  `id` varchar(191) NOT NULL,
  `template_key` varchar(191) NOT NULL,
  `snapshot_json` longtext NOT NULL,
  `candidate_hash` varchar(191) NOT NULL,
  `draft_updated_at` varchar(191) NOT NULL,
  `status` varchar(191) NOT NULL,
  `scheduled_for` varchar(191) NOT NULL DEFAULT '',
  `requested_by` varchar(191) NOT NULL,
  `requested_at` varchar(191) NOT NULL,
  `reviewed_by` varchar(191) NOT NULL DEFAULT '',
  `reviewed_at` varchar(191) NOT NULL DEFAULT '',
  `published_version` int NOT NULL DEFAULT '0',
  `failure` text NOT NULL,
  `lease_owner` varchar(191) NOT NULL DEFAULT '',
  `lease_expires_at` varchar(191) NOT NULL DEFAULT '',
  `fencing_token` bigint NOT NULL DEFAULT '0',
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_notification_publication_template` (`template_key`,`requested_at`),
  KEY `idx_notification_publication_due` (`status`,`scheduled_for`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_template_publication_requests`
--

LOCK TABLES `notification_template_publication_requests` WRITE;
/*!40000 ALTER TABLE `notification_template_publication_requests` DISABLE KEYS */;
/*!40000 ALTER TABLE `notification_template_publication_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_template_records`
--

DROP TABLE IF EXISTS `notification_template_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification_template_records` (
  `template_key` varchar(191) NOT NULL,
  `draft_json` longtext,
  `published_json` longtext,
  `published_version` int NOT NULL DEFAULT '0',
  `status` varchar(191) NOT NULL DEFAULT 'active',
  `updated_by` varchar(191) NOT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`template_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_template_records`
--

LOCK TABLES `notification_template_records` WRITE;
/*!40000 ALTER TABLE `notification_template_records` DISABLE KEYS */;
/*!40000 ALTER TABLE `notification_template_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_template_versions`
--

DROP TABLE IF EXISTS `notification_template_versions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification_template_versions` (
  `id` varchar(191) NOT NULL,
  `template_key` varchar(191) NOT NULL,
  `version` int NOT NULL,
  `payload_json` longtext NOT NULL,
  `content_hash` varchar(191) NOT NULL,
  `published_by` varchar(191) NOT NULL,
  `published_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_notification_template_version` (`template_key`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_template_versions`
--

LOCK TABLES `notification_template_versions` WRITE;
/*!40000 ALTER TABLE `notification_template_versions` DISABLE KEYS */;
/*!40000 ALTER TABLE `notification_template_versions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `object_definitions`
--

DROP TABLE IF EXISTS `object_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `object_definitions` (
  `id` varchar(191) NOT NULL,
  `resource_key` varchar(191) NOT NULL,
  `object_key` varchar(191) NOT NULL,
  `name` text NOT NULL,
  `payload_json` longtext NOT NULL,
  `schema_version` varchar(191) NOT NULL,
  `schema_hash` varchar(191) NOT NULL,
  `source_kind` varchar(191) NOT NULL,
  `source_id` varchar(191) NOT NULL,
  `disabled_at` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `resource_key` (`resource_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `object_definitions`
--

LOCK TABLES `object_definitions` WRITE;
/*!40000 ALTER TABLE `object_definitions` DISABLE KEYS */;
INSERT INTO `object_definitions` VALUES ('object:customer_profile','customer_profile','customer_profile','Customer profile','{\"key\":\"customer_profile\",\"name\":\"Customer profile\",\"description\":\"Business customer profile bound one-to-one to a Runtime identity account.\",\"fields\":null,\"ux\":{\"config\":{\"business_identity\":{\"active_status_values\":[\"active\"],\"key\":\"fieldservice_customer\",\"status_field\":\"status\",\"surface_keys\":[\"consumer_portal\"]},\"cardinality\":\"one_to_one\",\"identity_relation_field\":\"identity_user_id\"},\"kind\":\"identity_profile_extension\"}}','0.1.0','3528f4f423e847858972999740cac3dec799c3f7888f279fe6652a2e6d66c88a','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('object:device','device','device','Device','{\"key\":\"device\",\"name\":\"Device\",\"description\":\"Customer-owned equipment eligible for maintenance service.\",\"fields\":null,\"ux\":{\"fallback_view\":\"table\",\"kind\":\"table\"}}','0.1.0','495826439820da74bf0b6dd3d89629403bcca33d820ce740e182efe463a993d8','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('object:fee_ledger','fee_ledger','fee_ledger','Fee ledger','{\"key\":\"fee_ledger\",\"name\":\"Fee ledger\",\"description\":\"Append-only charge and waiver facts used to derive final customer fee without historical drift.\",\"fields\":null,\"ux\":{\"fallback_view\":\"table\",\"kind\":\"table\"}}','0.1.0','812001d6d199eeccf17e17a2517476953ffab77b7e0635ec12731e9b7f9bf4cd','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('object:job_dead_letter','job_dead_letter','job_dead_letter','Job Dead Letter','{\"key\":\"job_dead_letter\",\"name\":\"Job Dead Letter\",\"description\":\"Runtime-owned exhausted scheduler runs.\",\"fields\":null,\"config\":{\"runtime_owned\":true,\"system_kind\":\"scheduler\"}}','0.1.0','5d323c3f92de0e473d9257699f63e3ad43eb0674eea2bc87f2e200e76c60f1d8','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('object:job_run','job_run','job_run','Job Run','{\"key\":\"job_run\",\"name\":\"Job Run\",\"description\":\"Runtime-owned scheduler executions.\",\"fields\":null,\"config\":{\"runtime_owned\":true,\"system_kind\":\"scheduler\"}}','0.1.0','88ecf05461e42701a572ef234dd6707fe46fcfdc405ee7742d1fbaf660ee5838','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('object:job_run_event','job_run_event','job_run_event','Job Run Event','{\"key\":\"job_run_event\",\"name\":\"Job Run Event\",\"description\":\"Runtime-owned scheduler audit events.\",\"fields\":null,\"config\":{\"runtime_owned\":true,\"system_kind\":\"scheduler\"}}','0.1.0','039fb94e9bfc0bef57d2eb4cf79d1782cb5d6de9b019daab0fce140044486395','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('object:overdue_reminder','overdue_reminder','overdue_reminder','Overdue reminder','{\"key\":\"overdue_reminder\",\"name\":\"Overdue reminder\",\"description\":\"Natural-key reminder fact enforcing at most one notification per request and business date.\",\"fields\":null,\"ux\":{\"fallback_view\":\"table\",\"kind\":\"table\"}}','0.1.0','b142b7ad823269ff358d855553863e320fd00d6be17c093110537afe3ce4ce2a','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('object:part_usage','part_usage','part_usage','Part usage','{\"key\":\"part_usage\",\"name\":\"Part usage\",\"description\":\"Immutable event-time part consumption fact created during repair completion.\",\"fields\":null,\"ux\":{\"fallback_view\":\"table\",\"kind\":\"table\"}}','0.1.0','1ab196b04f90455ef73f0bdc6c276a1b5a8a0a88d6af2159c74ef9a1da97bacf','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('object:record_timer','record_timer','record_timer','Record Timer','{\"key\":\"record_timer\",\"name\":\"Record Timer\",\"description\":\"Durable record-scoped action and workflow timers.\",\"fields\":null,\"config\":{\"runtime_owned\":true,\"system_kind\":\"scheduler\"}}','0.1.0','229e0a71a9bb2bd0373f5890c26c0f702c1892ae1bb6a40dd476ed28070fcaa0','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('object:report_export_audit','report_export_audit','report_export_audit','Report export audit','{\"key\":\"report_export_audit\",\"name\":\"Report export audit\",\"description\":\"Governed work-order export request and terminal audit linkage.\",\"fields\":null,\"ux\":{\"fallback_view\":\"table\",\"kind\":\"table\"}}','0.1.0','a036e23afe35d6145a81ecc31bc151d7ed7326d9be0b63d89ec91563a80ef262','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('object:report_export_download','report_export_download','report_export_download','Report export download','{\"key\":\"report_export_download\",\"name\":\"Report export download\",\"description\":\"Governed export artifact metadata linked to its audit request.\",\"fields\":null,\"ux\":{\"fallback_view\":\"table\",\"kind\":\"table\"}}','0.1.0','8e138a078f2d55d29b4c8a6ea15923f2007524288ac5daeea98454e2da06b403','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('object:scheduler_cursor','scheduler_cursor','scheduler_cursor','Scheduler Cursor','{\"key\":\"scheduler_cursor\",\"name\":\"Scheduler Cursor\",\"description\":\"Runtime-owned cursor for one published scheduler definition.\",\"fields\":null,\"config\":{\"runtime_owned\":true,\"system_kind\":\"scheduler\"}}','0.1.0','62b01cdd972bf2e9e9e223c1e62600e07f18383ecf5818f132dbe094a3f0ef28','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('object:service_request','service_request','service_request','Service request','{\"key\":\"service_request\",\"name\":\"Service request\",\"description\":\"Customer repair request and governed internal work-order lifecycle.\",\"fields\":null,\"ux\":{\"fallback_view\":\"table\",\"kind\":\"table\"}}','0.1.0','b2aff1beee995cdfc4af953428f37ccb055880f417f591cbd1bbe390058f3dac','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('object:spare_part','spare_part','spare_part','Spare part','{\"key\":\"spare_part\",\"name\":\"Spare part\",\"description\":\"Maintainable part catalog with exact unit price and non-negative current stock.\",\"fields\":null,\"ux\":{\"fallback_view\":\"table\",\"kind\":\"table\"}}','0.1.0','0b46534956f2ee18a6653c3151b020d6d6901a40de81f5700d073339308f6333','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('object:warranty_waiver','warranty_waiver','warranty_waiver','Warranty waiver','{\"key\":\"warranty_waiver\",\"name\":\"Warranty waiver\",\"description\":\"Single immutable waiver request with a conditional terminal approval decision.\",\"fields\":null,\"ux\":{\"fallback_view\":\"table\",\"kind\":\"table\"}}','0.1.0','882afed2d4ced8d8fdb8872f23619f0f6c4bfedba440aa146e2e3893de4b2d74','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z');
/*!40000 ALTER TABLE `object_definitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `operation_state_example_definitions`
--

DROP TABLE IF EXISTS `operation_state_example_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `operation_state_example_definitions` (
  `id` varchar(191) NOT NULL,
  `resource_key` varchar(191) NOT NULL,
  `object_key` varchar(191) NOT NULL,
  `name` text NOT NULL,
  `payload_json` longtext NOT NULL,
  `schema_version` varchar(191) NOT NULL,
  `schema_hash` varchar(191) NOT NULL,
  `source_kind` varchar(191) NOT NULL,
  `source_id` varchar(191) NOT NULL,
  `disabled_at` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `resource_key` (`resource_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `operation_state_example_definitions`
--

LOCK TABLES `operation_state_example_definitions` WRITE;
/*!40000 ALTER TABLE `operation_state_example_definitions` DISABLE KEYS */;
/*!40000 ALTER TABLE `operation_state_example_definitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `overdue_reminder`
--

DROP TABLE IF EXISTS `overdue_reminder`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `overdue_reminder` (
  `workspace_id` varchar(191) NOT NULL,
  `id` varchar(191) NOT NULL,
  `created_at` text NOT NULL,
  `updated_at` text NOT NULL,
  `business_date` varchar(191) DEFAULT NULL,
  `dedupe_key` varchar(191) DEFAULT NULL,
  `owner_department_id` varchar(191) DEFAULT NULL,
  `owner_department_path` varchar(191) DEFAULT NULL,
  `recipient_user_id` varchar(191) DEFAULT NULL,
  `sent_at` text,
  `service_request_id` varchar(191) DEFAULT NULL,
  UNIQUE KEY `uidx_field_064782dfc91632e3` (`workspace_id`,`id`),
  UNIQUE KEY `uidx_field_c5444c5064d15ad1` (`workspace_id`,`dedupe_key`),
  KEY `idx_field_b16ab104a263adb6` (`business_date`),
  KEY `idx_field_18088933235671ee` (`owner_department_id`),
  KEY `idx_field_f6bb31d7e9855286` (`owner_department_path`),
  KEY `idx_field_cd42eade6f493267` (`recipient_user_id`),
  KEY `idx_field_789df287487488d8` (`service_request_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `overdue_reminder`
--

LOCK TABLES `overdue_reminder` WRITE;
/*!40000 ALTER TABLE `overdue_reminder` DISABLE KEYS */;
INSERT INTO `overdue_reminder` VALUES ('default','overdue_reminder_reminder_qin_overdue','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z','2026-08-20','request_qin_dispatched:2026-08-20','east_station','/ops_root/east_station','tech_east_chen','2026-08-20T01:00:00Z','service_request_request_qin_dispatched');
/*!40000 ALTER TABLE `overdue_reminder` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `part_usage`
--

DROP TABLE IF EXISTS `part_usage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `part_usage` (
  `workspace_id` varchar(191) NOT NULL,
  `id` varchar(191) NOT NULL,
  `created_at` text NOT NULL,
  `updated_at` text NOT NULL,
  `amount` decimal(19,2) DEFAULT NULL,
  `calculation_trace` text,
  `occurred_at` varchar(191) DEFAULT NULL,
  `owner_department_id` varchar(191) DEFAULT NULL,
  `owner_department_path` varchar(191) DEFAULT NULL,
  `performed_by_user_id` text,
  `quantity` bigint DEFAULT NULL,
  `service_request_id` varchar(191) DEFAULT NULL,
  `spare_part_id` varchar(191) DEFAULT NULL,
  `unit_price_snapshot` decimal(19,2) DEFAULT NULL,
  UNIQUE KEY `uidx_field_d54f2248f28ed59c` (`workspace_id`,`id`),
  KEY `idx_field_bda969b23fe5a004` (`occurred_at`),
  KEY `idx_field_32c0517eaf44dcc9` (`owner_department_id`),
  KEY `idx_field_86e2352bdc19c91e` (`owner_department_path`),
  KEY `idx_field_4b7c7223a5f3e7f9` (`service_request_id`),
  KEY `idx_field_0a2b48a4ac7bcc39` (`spare_part_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `part_usage`
--

LOCK TABLES `part_usage` WRITE;
/*!40000 ALTER TABLE `part_usage` DISABLE KEYS */;
INSERT INTO `part_usage` VALUES ('default','part_usage_usage_qin_filter','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z',241.00,'2 * CNY 120.50 = CNY 241.00','2026-08-15T03:00:00Z',NULL,NULL,NULL,2,'service_request_request_qin_completed_direct','spare_part_part_filter',120.50);
/*!40000 ALTER TABLE `part_usage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `party_addresses`
--

DROP TABLE IF EXISTS `party_addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `party_addresses` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `party_id` varchar(191) NOT NULL,
  `type` varchar(191) NOT NULL,
  `line1` text NOT NULL,
  `line2` text NOT NULL DEFAULT (_utf8mb4''),
  `locality` text NOT NULL DEFAULT (_utf8mb4''),
  `region` text NOT NULL DEFAULT (_utf8mb4''),
  `postal_code` varchar(191) NOT NULL DEFAULT '',
  `country` varchar(191) NOT NULL DEFAULT '',
  `is_primary` tinyint(1) NOT NULL DEFAULT '0',
  `status` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_party_addresses_workspace_identity` (`workspace_id`,`id`),
  KEY `idx_party_addresses_party` (`workspace_id`,`party_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `party_addresses`
--

LOCK TABLES `party_addresses` WRITE;
/*!40000 ALTER TABLE `party_addresses` DISABLE KEYS */;
/*!40000 ALTER TABLE `party_addresses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `party_communication_preferences`
--

DROP TABLE IF EXISTS `party_communication_preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `party_communication_preferences` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `party_id` varchar(191) NOT NULL,
  `channel` varchar(191) NOT NULL,
  `allowed` tinyint(1) NOT NULL DEFAULT '0',
  `preferred` tinyint(1) NOT NULL DEFAULT '0',
  `locale` varchar(191) NOT NULL DEFAULT '',
  UNIQUE KEY `uniq_party_communication_preferences_workspace_identity` (`workspace_id`,`id`),
  KEY `idx_party_communication_preferences_party` (`workspace_id`,`party_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `party_communication_preferences`
--

LOCK TABLES `party_communication_preferences` WRITE;
/*!40000 ALTER TABLE `party_communication_preferences` DISABLE KEYS */;
/*!40000 ALTER TABLE `party_communication_preferences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `party_consents`
--

DROP TABLE IF EXISTS `party_consents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `party_consents` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `party_id` varchar(191) NOT NULL,
  `purpose` varchar(191) NOT NULL,
  `status` varchar(191) NOT NULL,
  `legal_basis` varchar(191) NOT NULL DEFAULT '',
  `source` varchar(191) NOT NULL,
  `captured_at` varchar(191) NOT NULL,
  `expires_at` varchar(191) NOT NULL DEFAULT '',
  `policy_version` varchar(191) NOT NULL DEFAULT '',
  UNIQUE KEY `uniq_party_consents_workspace_identity` (`workspace_id`,`id`),
  KEY `idx_party_consents_party` (`workspace_id`,`party_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `party_consents`
--

LOCK TABLES `party_consents` WRITE;
/*!40000 ALTER TABLE `party_consents` DISABLE KEYS */;
/*!40000 ALTER TABLE `party_consents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `party_contact_points`
--

DROP TABLE IF EXISTS `party_contact_points`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `party_contact_points` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `party_id` varchar(191) NOT NULL,
  `type` varchar(191) NOT NULL,
  `value` text NOT NULL,
  `label` text NOT NULL DEFAULT (_utf8mb4''),
  `is_primary` tinyint(1) NOT NULL DEFAULT '0',
  `verified_at` varchar(191) NOT NULL DEFAULT '',
  `status` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_party_contact_points_workspace_identity` (`workspace_id`,`id`),
  KEY `idx_party_contact_points_party` (`workspace_id`,`party_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `party_contact_points`
--

LOCK TABLES `party_contact_points` WRITE;
/*!40000 ALTER TABLE `party_contact_points` DISABLE KEYS */;
/*!40000 ALTER TABLE `party_contact_points` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `party_identifiers`
--

DROP TABLE IF EXISTS `party_identifiers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `party_identifiers` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `party_id` varchar(191) NOT NULL,
  `type` varchar(191) NOT NULL,
  `value` text NOT NULL,
  `issuer` text NOT NULL DEFAULT (_utf8mb4''),
  `status` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_party_identifiers_workspace_identity` (`workspace_id`,`id`),
  KEY `idx_party_identifiers_party` (`workspace_id`,`party_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `party_identifiers`
--

LOCK TABLES `party_identifiers` WRITE;
/*!40000 ALTER TABLE `party_identifiers` DISABLE KEYS */;
/*!40000 ALTER TABLE `party_identifiers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `party_job_catalog`
--

DROP TABLE IF EXISTS `party_job_catalog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `party_job_catalog` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `code` varchar(191) NOT NULL,
  `name` text NOT NULL,
  `family` varchar(191) NOT NULL DEFAULT '',
  `level` varchar(191) NOT NULL DEFAULT '',
  `description` text NOT NULL DEFAULT (_utf8mb4''),
  `status` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_party_job_catalog_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `idx_party_job_catalog_code` (`workspace_id`,`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `party_job_catalog`
--

LOCK TABLES `party_job_catalog` WRITE;
/*!40000 ALTER TABLE `party_job_catalog` DISABLE KEYS */;
/*!40000 ALTER TABLE `party_job_catalog` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `party_marketing_subscriptions`
--

DROP TABLE IF EXISTS `party_marketing_subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `party_marketing_subscriptions` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `party_id` varchar(191) NOT NULL,
  `channel` varchar(191) NOT NULL,
  `topic` varchar(191) NOT NULL,
  `status` varchar(191) NOT NULL,
  `contact_point_id` varchar(191) NOT NULL DEFAULT '',
  `source` varchar(191) NOT NULL,
  `subscribed_at` varchar(191) NOT NULL DEFAULT '',
  `unsubscribed_at` varchar(191) NOT NULL DEFAULT '',
  UNIQUE KEY `uniq_party_marketing_subscriptions_workspace_identity` (`workspace_id`,`id`),
  KEY `idx_party_marketing_subscriptions_party` (`workspace_id`,`party_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `party_marketing_subscriptions`
--

LOCK TABLES `party_marketing_subscriptions` WRITE;
/*!40000 ALTER TABLE `party_marketing_subscriptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `party_marketing_subscriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `party_organization_extension_memberships`
--

DROP TABLE IF EXISTS `party_organization_extension_memberships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `party_organization_extension_memberships` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `extension_id` varchar(191) NOT NULL,
  `workforce_profile_id` varchar(191) NOT NULL,
  `effective_from` varchar(191) NOT NULL DEFAULT '',
  `effective_to` varchar(191) NOT NULL DEFAULT '',
  `status` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_party_organization_extension_memberships_workspace_identity` (`workspace_id`,`id`),
  KEY `idx_party_organization_membership_profile` (`workspace_id`,`workforce_profile_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `party_organization_extension_memberships`
--

LOCK TABLES `party_organization_extension_memberships` WRITE;
/*!40000 ALTER TABLE `party_organization_extension_memberships` DISABLE KEYS */;
/*!40000 ALTER TABLE `party_organization_extension_memberships` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `party_organization_extensions`
--

DROP TABLE IF EXISTS `party_organization_extensions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `party_organization_extensions` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `kind` varchar(191) NOT NULL,
  `code` varchar(191) NOT NULL,
  `name` text NOT NULL,
  `claim_value` varchar(191) NOT NULL DEFAULT '',
  `parent_id` varchar(191) NOT NULL DEFAULT '',
  `organization_unit_id` varchar(191) NOT NULL DEFAULT '',
  `status` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_party_organization_extensions_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `idx_party_organization_extension_code` (`workspace_id`,`kind`,`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `party_organization_extensions`
--

LOCK TABLES `party_organization_extensions` WRITE;
/*!40000 ALTER TABLE `party_organization_extensions` DISABLE KEYS */;
/*!40000 ALTER TABLE `party_organization_extensions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `party_organizations`
--

DROP TABLE IF EXISTS `party_organizations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `party_organizations` (
  `party_id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `legal_name` text NOT NULL,
  `registration_number` varchar(191) NOT NULL DEFAULT '',
  UNIQUE KEY `uniq_party_organizations_workspace_identity` (`workspace_id`,`party_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `party_organizations`
--

LOCK TABLES `party_organizations` WRITE;
/*!40000 ALTER TABLE `party_organizations` DISABLE KEYS */;
/*!40000 ALTER TABLE `party_organizations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `party_parties`
--

DROP TABLE IF EXISTS `party_parties`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `party_parties` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `kind` varchar(191) NOT NULL,
  `display_name` text NOT NULL,
  `status` varchar(191) NOT NULL,
  `version` bigint NOT NULL DEFAULT '1',
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_party_parties_workspace_identity` (`workspace_id`,`id`),
  KEY `idx_party_parties_kind` (`workspace_id`,`kind`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `party_parties`
--

LOCK TABLES `party_parties` WRITE;
/*!40000 ALTER TABLE `party_parties` DISABLE KEYS */;
/*!40000 ALTER TABLE `party_parties` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `party_persons`
--

DROP TABLE IF EXISTS `party_persons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `party_persons` (
  `party_id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `given_name` text NOT NULL DEFAULT (_utf8mb4''),
  `family_name` text NOT NULL DEFAULT (_utf8mb4''),
  `birth_date` varchar(191) NOT NULL DEFAULT '',
  UNIQUE KEY `uniq_party_persons_workspace_identity` (`workspace_id`,`party_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `party_persons`
--

LOCK TABLES `party_persons` WRITE;
/*!40000 ALTER TABLE `party_persons` DISABLE KEYS */;
/*!40000 ALTER TABLE `party_persons` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `party_positions`
--

DROP TABLE IF EXISTS `party_positions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `party_positions` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `code` varchar(191) NOT NULL,
  `name` text NOT NULL,
  `job_catalog_item_id` varchar(191) NOT NULL,
  `organization_unit_id` varchar(191) NOT NULL DEFAULT '',
  `headcount` bigint NOT NULL DEFAULT '1',
  `effective_from` varchar(191) NOT NULL DEFAULT '',
  `effective_to` varchar(191) NOT NULL DEFAULT '',
  `status` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_party_positions_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `idx_party_positions_code` (`workspace_id`,`code`),
  KEY `idx_party_positions_job` (`workspace_id`,`job_catalog_item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `party_positions`
--

LOCK TABLES `party_positions` WRITE;
/*!40000 ALTER TABLE `party_positions` DISABLE KEYS */;
/*!40000 ALTER TABLE `party_positions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `party_privacy_preferences`
--

DROP TABLE IF EXISTS `party_privacy_preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `party_privacy_preferences` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `party_id` varchar(191) NOT NULL,
  `preference_key` varchar(191) NOT NULL,
  `value` text NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_party_privacy_preferences_workspace_identity` (`workspace_id`,`id`),
  KEY `idx_party_privacy_preferences_party` (`workspace_id`,`party_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `party_privacy_preferences`
--

LOCK TABLES `party_privacy_preferences` WRITE;
/*!40000 ALTER TABLE `party_privacy_preferences` DISABLE KEYS */;
/*!40000 ALTER TABLE `party_privacy_preferences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `preference_definitions`
--

DROP TABLE IF EXISTS `preference_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `preference_definitions` (
  `id` varchar(191) NOT NULL,
  `resource_key` varchar(191) NOT NULL,
  `object_key` varchar(191) NOT NULL,
  `name` text NOT NULL,
  `payload_json` longtext NOT NULL,
  `schema_version` varchar(191) NOT NULL,
  `schema_hash` varchar(191) NOT NULL,
  `source_kind` varchar(191) NOT NULL,
  `source_id` varchar(191) NOT NULL,
  `disabled_at` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `resource_key` (`resource_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `preference_definitions`
--

LOCK TABLES `preference_definitions` WRITE;
/*!40000 ALTER TABLE `preference_definitions` DISABLE KEYS */;
/*!40000 ALTER TABLE `preference_definitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `record_batch_job_chunks`
--

DROP TABLE IF EXISTS `record_batch_job_chunks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `record_batch_job_chunks` (
  `workspace_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `job_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `sequence_no` int NOT NULL,
  `content` text NOT NULL,
  `created_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_record_batch_job_chunk` (`workspace_id`,`job_id`,`sequence_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `record_batch_job_chunks`
--

LOCK TABLES `record_batch_job_chunks` WRITE;
/*!40000 ALTER TABLE `record_batch_job_chunks` DISABLE KEYS */;
/*!40000 ALTER TABLE `record_batch_job_chunks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `record_batch_jobs`
--

DROP TABLE IF EXISTS `record_batch_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `record_batch_jobs` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `kind` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `object_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `status` varchar(191) NOT NULL,
  `idempotency_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `request_fingerprint` varchar(191) NOT NULL,
  `payload_json` text NOT NULL,
  `checkpoint_value` int NOT NULL DEFAULT '0',
  `checkpoint_cursor` text NOT NULL DEFAULT (_utf8mb4''),
  `total_value` int NOT NULL DEFAULT '0',
  `result_filename` varchar(191) NOT NULL DEFAULT '',
  `result_content_type` varchar(191) NOT NULL DEFAULT '',
  `result_chunks` int NOT NULL DEFAULT '0',
  `audit_id` varchar(191) NOT NULL DEFAULT '',
  `result_artifact_id` varchar(191) NOT NULL DEFAULT '',
  `error_code` varchar(191) NOT NULL DEFAULT '',
  `attempt_count` int NOT NULL DEFAULT '0',
  `next_attempt_at` varchar(191) NOT NULL DEFAULT '',
  `lease_owner` varchar(191) NOT NULL DEFAULT '',
  `lease_expires_at` varchar(191) NOT NULL DEFAULT '',
  `fencing_token` bigint NOT NULL DEFAULT '0',
  `actor_id` varchar(191) NOT NULL DEFAULT '',
  `role_key` varchar(191) NOT NULL DEFAULT '',
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_record_batch_jobs_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_record_batch_job_idempotency` (`workspace_id`,`kind`,`object_key`,`idempotency_key`),
  KEY `idx_record_batch_job_due` (`status`,`next_attempt_at`,`lease_expires_at`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `record_batch_jobs`
--

LOCK TABLES `record_batch_jobs` WRITE;
/*!40000 ALTER TABLE `record_batch_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `record_batch_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `record_mutation_executions`
--

DROP TABLE IF EXISTS `record_mutation_executions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `record_mutation_executions` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `operation` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `object_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `target_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '',
  `idempotency_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `request_fingerprint` varchar(191) NOT NULL,
  `status` varchar(191) NOT NULL,
  `result_json` text NOT NULL,
  `lease_owner` varchar(191) NOT NULL,
  `lease_expires_at` varchar(191) NOT NULL,
  `fencing_token` bigint NOT NULL DEFAULT '1',
  `response_status` int NOT NULL DEFAULT '0',
  `error_code` varchar(191) NOT NULL DEFAULT '',
  `expires_at` varchar(191) NOT NULL DEFAULT '',
  `actor_id` varchar(191) NOT NULL DEFAULT '',
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_record_mutation_executions_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_record_mutation_execution_scope` (`workspace_id`,`operation`,`object_key`,`target_id`,`idempotency_key`),
  KEY `idx_record_mutation_execution_lease` (`status`,`lease_expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `record_mutation_executions`
--

LOCK TABLES `record_mutation_executions` WRITE;
/*!40000 ALTER TABLE `record_mutation_executions` DISABLE KEYS */;
/*!40000 ALTER TABLE `record_mutation_executions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `record_timer`
--

DROP TABLE IF EXISTS `record_timer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `record_timer` (
  `workspace_id` varchar(191) NOT NULL,
  `id` varchar(191) NOT NULL,
  `created_at` text NOT NULL,
  `updated_at` text NOT NULL,
  `attempt` double DEFAULT NULL,
  `business_calendar_key` text,
  `cancelled_at` text,
  `due_at` varchar(191) DEFAULT NULL,
  `failed_at` text,
  `fencing_token` double DEFAULT NULL,
  `fired_at` text,
  `last_error` text,
  `lease_expires_at` text,
  `lease_owner` text,
  `max_attempts` double DEFAULT NULL,
  `object_key` varchar(128) DEFAULT NULL,
  `offset_seconds` double DEFAULT NULL,
  `payload_json` text,
  `priority` double DEFAULT NULL,
  `purpose` varchar(128) DEFAULT NULL,
  `record_id` varchar(128) DEFAULT NULL,
  `retry_delay_seconds` double DEFAULT NULL,
  `retry_max_delay_seconds` double DEFAULT NULL,
  `schedule_mode` text,
  `sequence` double DEFAULT NULL,
  `source_field` text,
  `status` varchar(191) DEFAULT NULL,
  `supersedes_timer_id` text,
  `target_key` text,
  `target_type` text,
  `timer_key` varchar(128) DEFAULT NULL,
  `timezone` text,
  UNIQUE KEY `uidx_field_cd19bcab569af407` (`workspace_id`,`id`),
  UNIQUE KEY `uidx_record_timer_1155489bf0` (`workspace_id`,`timer_key`,`object_key`,`record_id`,`purpose`),
  KEY `idx_field_31248f1b23c0f744` (`due_at`),
  KEY `idx_field_72d51216c4f1b772` (`object_key`),
  KEY `idx_field_4e13782aed141c0d` (`priority`),
  KEY `idx_field_de8f7245f3a3e622` (`purpose`),
  KEY `idx_field_a25cf0d390006f4f` (`record_id`),
  KEY `idx_field_cf24ab3edfdd5c28` (`sequence`),
  KEY `idx_field_0e697587593e78e8` (`status`),
  KEY `idx_field_f812a7a21f9a1ddc` (`timer_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `record_timer`
--

LOCK TABLES `record_timer` WRITE;
/*!40000 ALTER TABLE `record_timer` DISABLE KEYS */;
/*!40000 ALTER TABLE `record_timer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `report_definitions`
--

DROP TABLE IF EXISTS `report_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `report_definitions` (
  `id` varchar(191) NOT NULL,
  `resource_key` varchar(191) NOT NULL,
  `object_key` varchar(191) NOT NULL,
  `name` text NOT NULL,
  `payload_json` longtext NOT NULL,
  `schema_version` varchar(191) NOT NULL,
  `schema_hash` varchar(191) NOT NULL,
  `source_kind` varchar(191) NOT NULL,
  `source_id` varchar(191) NOT NULL,
  `disabled_at` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `resource_key` (`resource_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `report_definitions`
--

LOCK TABLES `report_definitions` WRITE;
/*!40000 ALTER TABLE `report_definitions` DISABLE KEYS */;
INSERT INTO `report_definitions` VALUES ('report:part_usage_summary','part_usage_summary','','Part usage summary','{\"key\":\"part_usage_summary\",\"name\":\"Part usage summary\",\"dataset\":{\"source\":{\"object_key\":\"part_usage\",\"alias\":\"usage\"},\"joins\":[{\"alias\":\"part\",\"object_key\":\"spare_part\",\"type\":\"inner\",\"left_alias\":\"usage\",\"left_field\":\"spare_part_id\",\"right_field\":\"id\",\"cardinality\":\"many_to_one\"}],\"dimensions\":[{\"key\":\"part_code\",\"field\":{\"source_alias\":\"part\",\"field_key\":\"code\"}},{\"key\":\"part_name\",\"field\":{\"source_alias\":\"part\",\"field_key\":\"name\"}}],\"measures\":[{\"key\":\"quantity_used\",\"operation\":\"sum\",\"field\":{\"source_alias\":\"usage\",\"field_key\":\"quantity\"}},{\"key\":\"usage_amount\",\"operation\":\"sum\",\"field\":{\"source_alias\":\"usage\",\"field_key\":\"amount\"}}],\"sort\":[{\"key\":\"part_code\",\"direction\":\"asc\"}]},\"required_permissions\":[\"part_usage.read\",\"spare_part.read\"],\"audience_roles\":[\"ops_manager\"],\"evidence_requirements\":[{\"object_key\":\"part_usage\",\"minimum_records\":1,\"required_non_empty_fields\":[\"amount\",\"quantity\"]}],\"materialization\":{\"maximum_lag_seconds\":300,\"consistency_retries\":3}}','0.1.0','fc05f798da20ddda530ecdce2ceccf1a6eb4a0aff59acba22144933766dae889','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('report:work_order_detail_export','work_order_detail_export','','Work-order detail export','{\"key\":\"work_order_detail_export\",\"name\":\"Work-order detail export\",\"object_sql_v1\":{\"sql\":\"SELECT\\n  sr.id AS request_id,\\n  sr.status AS status,\\n  sr.device_id AS device_id,\\n  sr.customer_profile_id AS customer_profile_id,\\n  sr.assigned_user_id AS assigned_user_id,\\n  sr.quote_amount AS quote_amount,\\n  sr.submitted_at AS submitted_at,\\n  sr.completed_at AS completed_at\\nFROM service_request AS sr\\nORDER BY sr.submitted_at DESC, sr.id ASC\\nLIMIT 10000\\n\",\"source_objects\":[\"service_request\"],\"result_schema\":[{\"key\":\"request_id\",\"type\":\"text\",\"kind\":\"dimension\"},{\"key\":\"status\",\"type\":\"text\",\"kind\":\"dimension\"},{\"key\":\"device_id\",\"type\":\"text\",\"kind\":\"dimension\"},{\"key\":\"customer_profile_id\",\"type\":\"text\",\"kind\":\"dimension\"},{\"key\":\"assigned_user_id\",\"type\":\"text\",\"kind\":\"dimension\"},{\"key\":\"quote_amount\",\"type\":\"currency\",\"kind\":\"measure\",\"precision\":19,\"scale\":2},{\"key\":\"submitted_at\",\"type\":\"datetime\",\"kind\":\"dimension\"},{\"key\":\"completed_at\",\"type\":\"datetime\",\"kind\":\"dimension\"}],\"timeout_milliseconds\":5000},\"required_permissions\":[\"service_request.read\"],\"audience_roles\":[\"ops_manager\"],\"evidence_requirements\":[{\"object_key\":\"service_request\",\"minimum_records\":1,\"required_non_empty_fields\":[\"status\",\"submitted_at\"]}]}','0.1.0','8aa0fe6501aeabe1803c7e5337b5c9b3310900ea71e1cc129b084bcbf35d57f0','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('report:work_order_throughput','work_order_throughput','','Work-order throughput','{\"key\":\"work_order_throughput\",\"name\":\"Work-order throughput\",\"dataset\":{\"source\":{\"object_key\":\"service_request\",\"alias\":\"request\"},\"dimensions\":[{\"key\":\"status\",\"field\":{\"source_alias\":\"request\",\"field_key\":\"status\"}}],\"measures\":[{\"key\":\"work_orders\",\"operation\":\"count\",\"source_alias\":\"request\"}],\"sort\":[{\"key\":\"status\",\"direction\":\"asc\"}]},\"required_permissions\":[\"service_request.read\"],\"audience_roles\":[\"ops_manager\"],\"evidence_requirements\":[{\"object_key\":\"service_request\",\"minimum_records\":1,\"required_non_empty_fields\":[\"status\"]}],\"materialization\":{\"maximum_lag_seconds\":300,\"consistency_retries\":3}}','0.1.0','b537280ee079fd750176111977f237eb624e77bdf943699e3201e76262d4938e','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z');
/*!40000 ALTER TABLE `report_definitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `report_export_artifacts`
--

DROP TABLE IF EXISTS `report_export_artifacts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `report_export_artifacts` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `report_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `object_key` varchar(191) NOT NULL,
  `audit_id` varchar(191) NOT NULL,
  `business_download_id` varchar(191) NOT NULL DEFAULT '',
  `requester_user_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `role_key` varchar(191) NOT NULL,
  `idempotency_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `token` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `filename` text NOT NULL,
  `scope_json` text NOT NULL,
  `scope_sha256` varchar(191) NOT NULL,
  `authorization_scope_sha256` varchar(191) NOT NULL,
  `report_definition_sha256` varchar(191) NOT NULL,
  `control_definition_sha256` varchar(191) NOT NULL,
  `content_base64` text NOT NULL,
  `content_sha256` varchar(191) NOT NULL,
  `row_count` bigint NOT NULL,
  `watermarked` tinyint(1) NOT NULL,
  `created_at` varchar(191) NOT NULL,
  `expires_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_report_export_artifacts_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_report_export_idempotency` (`workspace_id`,`requester_user_id`,`report_key`,`idempotency_key`),
  UNIQUE KEY `uniq_report_export_token` (`workspace_id`,`token`),
  KEY `idx_report_export_expiry` (`workspace_id`,`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `report_export_artifacts`
--

LOCK TABLES `report_export_artifacts` WRITE;
/*!40000 ALTER TABLE `report_export_artifacts` DISABLE KEYS */;
/*!40000 ALTER TABLE `report_export_artifacts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `report_export_audit`
--

DROP TABLE IF EXISTS `report_export_audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `report_export_audit` (
  `workspace_id` varchar(191) NOT NULL,
  `id` varchar(191) NOT NULL,
  `created_at` text NOT NULL,
  `updated_at` text NOT NULL,
  `owner_department_id` varchar(191) DEFAULT NULL,
  `owner_department_path` varchar(191) DEFAULT NULL,
  `purpose` text,
  `report_key` varchar(191) DEFAULT NULL,
  `requested_at` varchar(191) DEFAULT NULL,
  `requester_user_id` text,
  `row_count` bigint DEFAULT NULL,
  `scope_hash` text,
  `status` varchar(191) DEFAULT NULL,
  UNIQUE KEY `uidx_field_50cdd776c1d0ca09` (`workspace_id`,`id`),
  KEY `idx_field_532972f2b8883f52` (`owner_department_id`),
  KEY `idx_field_6da5a0715d7c9dd5` (`owner_department_path`),
  KEY `idx_field_19f1a12016f5b804` (`report_key`),
  KEY `idx_field_5d157e7009cc6d51` (`requested_at`),
  KEY `idx_field_15d4467e90c41463` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `report_export_audit`
--

LOCK TABLES `report_export_audit` WRITE;
/*!40000 ALTER TABLE `report_export_audit` DISABLE KEYS */;
INSERT INTO `report_export_audit` VALUES ('default','report_export_audit_export_audit_seed','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z',NULL,NULL,'Acceptance seed export','work_order_detail_export','2026-08-20T02:00:00Z',NULL,NULL,NULL,'requested');
/*!40000 ALTER TABLE `report_export_audit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `report_export_control_definitions`
--

DROP TABLE IF EXISTS `report_export_control_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `report_export_control_definitions` (
  `id` varchar(191) NOT NULL,
  `resource_key` varchar(191) NOT NULL,
  `object_key` varchar(191) NOT NULL,
  `name` text NOT NULL,
  `payload_json` longtext NOT NULL,
  `schema_version` varchar(191) NOT NULL,
  `schema_hash` varchar(191) NOT NULL,
  `source_kind` varchar(191) NOT NULL,
  `source_id` varchar(191) NOT NULL,
  `disabled_at` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `resource_key` (`resource_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `report_export_control_definitions`
--

LOCK TABLES `report_export_control_definitions` WRITE;
/*!40000 ALTER TABLE `report_export_control_definitions` DISABLE KEYS */;
INSERT INTO `report_export_control_definitions` VALUES ('report_export_control:work_order_detail_export_control','work_order_detail_export_control','work_order_detail_export','Work-order detail governed export','{\"key\":\"work_order_detail_export_control\",\"name\":\"Work-order detail governed export\",\"report_key\":\"work_order_detail_export\",\"source_objects\":[\"service_request\"],\"watermark\":true,\"audit_object\":\"report_export_audit\",\"download_object\":\"report_export_download\",\"record_mapping\":{\"audit_report_key_field\":\"report_key\",\"audit_requester_field\":\"requester_user_id\",\"audit_status_field\":\"status\",\"audit_prepared_statuses\":[\"requested\"],\"audit_prepared_status\":\"prepared\",\"audit_downloaded_status\":\"downloaded\",\"audit_denied_status\":\"denied\",\"audit_expired_status\":\"expired\",\"audit_row_count_field\":\"row_count\",\"audit_scope_hash_field\":\"scope_hash\",\"download_audit_field\":\"audit_id\",\"download_filename_field\":\"filename\",\"download_content_hash_field\":\"content_hash\",\"download_expires_at_field\":\"expires_at\"},\"export_action\":\"report_export_audit.request_work_order_export\",\"max_rows\":100000,\"reason\":\"Manager-governed work-order detail CSV\"}','0.1.0','5b18c597baf4972a2ce5d4a9be78bb858a4c1b3a5490c7ce84cbd5e2e3152315','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z');
/*!40000 ALTER TABLE `report_export_control_definitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `report_export_download`
--

DROP TABLE IF EXISTS `report_export_download`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `report_export_download` (
  `workspace_id` varchar(191) NOT NULL,
  `id` varchar(191) NOT NULL,
  `created_at` text NOT NULL,
  `updated_at` text NOT NULL,
  `audit_id` varchar(191) DEFAULT NULL,
  `content_hash` text,
  `expires_at` varchar(191) DEFAULT NULL,
  `filename` text,
  `owner` text,
  UNIQUE KEY `uidx_field_09e40ddea0af8071` (`workspace_id`,`id`),
  KEY `idx_field_1d3a76f5ee2a5220` (`audit_id`),
  KEY `idx_field_080471105f5c03dc` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `report_export_download`
--

LOCK TABLES `report_export_download` WRITE;
/*!40000 ALTER TABLE `report_export_download` DISABLE KEYS */;
INSERT INTO `report_export_download` VALUES ('default','report_export_download_export_download_seed','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z','report_export_audit_export_audit_seed','seed-content-hash','2026-08-22T02:00:00Z','work-orders-seed.csv',NULL);
/*!40000 ALTER TABLE `report_export_download` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `report_snapshots`
--

DROP TABLE IF EXISTS `report_snapshots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `report_snapshots` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `report_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `access_scope_hash` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `idempotency_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `status` varchar(191) NOT NULL,
  `summary_json` text NOT NULL,
  `watermark` varchar(191) NOT NULL DEFAULT '',
  `source_versions_json` text NOT NULL,
  `row_count` bigint NOT NULL DEFAULT '0',
  `source_row_count` bigint NOT NULL DEFAULT '0',
  `started_at` varchar(191) NOT NULL,
  `refreshed_at` varchar(191) NOT NULL DEFAULT '',
  `error_code` varchar(191) NOT NULL DEFAULT '',
  UNIQUE KEY `uniq_report_snapshots_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_report_snapshot_idempotency` (`workspace_id`,`report_key`,`access_scope_hash`,`idempotency_key`),
  KEY `idx_report_snapshot_latest` (`workspace_id`,`report_key`,`access_scope_hash`,`status`,`refreshed_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `report_snapshots`
--

LOCK TABLES `report_snapshots` WRITE;
/*!40000 ALTER TABLE `report_snapshots` DISABLE KEYS */;
/*!40000 ALTER TABLE `report_snapshots` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_definitions`
--

DROP TABLE IF EXISTS `role_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_definitions` (
  `id` varchar(191) NOT NULL,
  `resource_key` varchar(191) NOT NULL,
  `object_key` varchar(191) NOT NULL,
  `name` text NOT NULL,
  `payload_json` longtext NOT NULL,
  `schema_version` varchar(191) NOT NULL,
  `schema_hash` varchar(191) NOT NULL,
  `source_kind` varchar(191) NOT NULL,
  `source_id` varchar(191) NOT NULL,
  `disabled_at` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `resource_key` (`resource_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_definitions`
--

LOCK TABLES `role_definitions` WRITE;
/*!40000 ALTER TABLE `role_definitions` DISABLE KEYS */;
INSERT INTO `role_definitions` VALUES ('role:admin','admin','','Admin','{\"key\":\"admin\",\"name\":\"Admin\",\"permissions\":[\"workspace.admin\",\"workspace.admin\",\"platform_admin.domain_impact.read\",\"runtime_ops.capability_status.read\",\"identity.users.read\",\"identity.users.write\",\"identity.departments.read\",\"identity.departments.write\",\"identity.workforce.read\",\"identity.workforce.write\",\"identity.roles.read\",\"identity.roles.write\",\"identity.menus.read\",\"identity.menus.write\",\"identity.permissions.read\",\"identity.permissions.write\",\"identity.data_scopes.read\",\"identity.data_scopes.write\",\"identity.field_permissions.read\",\"identity.field_permissions.write\",\"identity.security.read\",\"identity.security.write\",\"identity.profile_binding.manage\",\"identity.permission.configure\",\"identity.audit.view\",\"party.read\",\"party.write\",\"system.read\",\"dictionary.read\",\"dictionary.write\",\"ops.workflow.read\",\"ops.workflow.run\",\"ops.workflow.simulate\",\"ops.workflow.retry\",\"ops.workflow.resolve\",\"ops.workflow.process\",\"workflow.definition.read\",\"workflow.advanced.configure\",\"workflow.process.read\",\"workflow.process.operate\",\"agent.task.read\",\"agent.task.operate\",\"workflow.task.act\",\"automation.rule.read\",\"automation.rule.write\",\"automation.rule.simulate\",\"automation.rule.execute\",\"automation.rule.history.read\",\"scheduler.definition.run\",\"scheduler.definition.read\",\"scheduler.definition.write\",\"job_run.read\",\"job_run.update\",\"audit.read\",\"audit.business.read\",\"audit.business.export\",\"audit.governance.read\",\"audit.governance.export\",\"audit.ops.read\",\"audit.ops.export\",\"import_export.read\",\"metadata.read\",\"metadata.write\",\"metadata.ops.read\",\"operations.read\",\"runtime.idempotency.manage\",\"integration.catalog.view\",\"integration.connection.manage\",\"integration.secret.manage\",\"integration.connection.test\",\"integration.invoke\",\"integration.retry\",\"integration.audit.view\",\"integration.entrypoint.invoke\",\"notification.template.read\",\"notification.template.manage\",\"notification.template.publish\",\"notification.template.approve\",\"notification.policy.read\",\"notification.policy.manage\",\"notification.template.test\"],\"record_scope\":\"all_records\",\"data_permissions\":[{\"object_key\":\"scheduler_cursor\",\"scope\":\"all_records\",\"read\":true,\"write\":true},{\"object_key\":\"job_run\",\"scope\":\"all_records\",\"read\":true,\"write\":true},{\"object_key\":\"job_run_event\",\"scope\":\"all_records\",\"read\":true,\"write\":true},{\"object_key\":\"job_dead_letter\",\"scope\":\"all_records\",\"read\":true,\"write\":true},{\"object_key\":\"record_timer\",\"scope\":\"all_records\",\"read\":true,\"write\":true}]}','0.1.0','f4160baec42bd63cdadd2c9b7ebcb5545fd70ae632e2b79dd099215b79712bb4','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('role:customer','customer','','Customer','{\"key\":\"customer\",\"name\":\"Customer\",\"permissions\":[\"customer_profile.read\",\"device.read\",\"fee_ledger.read\",\"service_request.read\",\"warranty_waiver.read\",\"service_request.submit_service_request\"],\"record_scope\":\"custom\",\"data_permissions\":[{\"object_key\":\"customer_profile\",\"scope\":\"custom\",\"read\":true,\"write\":false,\"audit_denial\":true,\"predicate\":{\"operator\":\"eq\",\"field_key\":\"identity_user_id\",\"value_source\":\"actor_claim\",\"claim_key\":\"user_id\"}},{\"object_key\":\"device\",\"scope\":\"custom\",\"read\":true,\"write\":false,\"audit_denial\":true,\"predicate\":{\"operator\":\"eq\",\"path\":[{\"direction\":\"forward\",\"relation_field_key\":\"customer_profile_id\",\"target_object_key\":\"customer_profile\"}],\"field_key\":\"identity_user_id\",\"value_source\":\"actor_claim\",\"claim_key\":\"user_id\"}},{\"object_key\":\"fee_ledger\",\"scope\":\"custom\",\"read\":true,\"write\":false,\"audit_denial\":true,\"predicate\":{\"operator\":\"eq\",\"path\":[{\"direction\":\"forward\",\"relation_field_key\":\"service_request_id\",\"target_object_key\":\"service_request\"},{\"direction\":\"forward\",\"relation_field_key\":\"customer_profile_id\",\"target_object_key\":\"customer_profile\"}],\"field_key\":\"identity_user_id\",\"value_source\":\"actor_claim\",\"claim_key\":\"user_id\"}},{\"object_key\":\"service_request\",\"scope\":\"custom\",\"read\":true,\"write\":true,\"audit_denial\":true,\"predicate\":{\"operator\":\"eq\",\"path\":[{\"direction\":\"forward\",\"relation_field_key\":\"customer_profile_id\",\"target_object_key\":\"customer_profile\"}],\"field_key\":\"identity_user_id\",\"value_source\":\"actor_claim\",\"claim_key\":\"user_id\"}},{\"object_key\":\"warranty_waiver\",\"scope\":\"custom\",\"read\":true,\"write\":false,\"audit_denial\":true,\"predicate\":{\"operator\":\"eq\",\"path\":[{\"direction\":\"forward\",\"relation_field_key\":\"service_request_id\",\"target_object_key\":\"service_request\"},{\"direction\":\"forward\",\"relation_field_key\":\"customer_profile_id\",\"target_object_key\":\"customer_profile\"}],\"field_key\":\"identity_user_id\",\"value_source\":\"actor_claim\",\"claim_key\":\"user_id\"}}],\"audience\":\"business_profile\",\"required_binding_key\":\"fieldservice_customer\",\"assignment_mode\":\"system_managed\",\"risk_level\":\"normal\"}','0.1.0','0cf607cd52547168389641724580e577a15780e41298ed16e89ae95e693b5898','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('role:identity_effective','identity_effective','','Identity Effective','{\"key\":\"identity_effective\",\"name\":\"Identity Effective\",\"permissions\":null,\"record_scope\":\"all_records\"}','0.1.0','f453fb559ac56861f45bbc56f9f99d1c19f46658421e86abb1cee35db1f69f00','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('role:ops_manager','ops_manager','','Operations manager','{\"key\":\"ops_manager\",\"name\":\"Operations manager\",\"permissions\":[\"customer_profile.read\",\"device.read\",\"fee_ledger.read\",\"identity.workforce.read\",\"overdue_reminder.read\",\"part_usage.read\",\"report_export_audit.create\",\"report_export_audit.read\",\"report_export_audit.update\",\"report_export_download.create\",\"report_export_download.read\",\"scheduler.command\",\"service_request.export\",\"service_request.read\",\"spare_part.read\",\"warranty_waiver.read\",\"workflow.task.act\",\"service_request.dispatch_service_request\",\"service_request.unassign_service_request\",\"warranty_waiver.decide_warranty_waiver\"],\"record_scope\":\"all_records\",\"data_permissions\":[{\"object_key\":\"customer_profile\",\"scope\":\"all_records\",\"read\":true,\"write\":false,\"audit_denial\":true},{\"object_key\":\"device\",\"scope\":\"all_records\",\"read\":true,\"write\":false,\"audit_denial\":true},{\"object_key\":\"fee_ledger\",\"scope\":\"all_records\",\"read\":true,\"write\":true,\"audit_denial\":true},{\"object_key\":\"overdue_reminder\",\"scope\":\"all_records\",\"read\":true,\"write\":true,\"audit_denial\":true},{\"object_key\":\"part_usage\",\"scope\":\"all_records\",\"read\":true,\"write\":true,\"audit_denial\":true},{\"object_key\":\"report_export_audit\",\"scope\":\"owned_records\",\"read\":true,\"write\":true,\"audit_denial\":true},{\"object_key\":\"report_export_download\",\"scope\":\"owned_records\",\"read\":true,\"write\":true,\"audit_denial\":true},{\"object_key\":\"service_request\",\"scope\":\"all_records\",\"read\":true,\"write\":true,\"audit_denial\":true},{\"object_key\":\"spare_part\",\"scope\":\"all_records\",\"read\":true,\"write\":true,\"audit_denial\":true},{\"object_key\":\"warranty_waiver\",\"scope\":\"all_records\",\"read\":true,\"write\":true,\"audit_denial\":true}],\"audience\":\"workforce\",\"assignment_mode\":\"request_only\",\"risk_level\":\"privileged\"}','0.1.0','821fe1c72ee61fa5cc34a78addfc7a581ec316e920702793ee818e49eeccf9b1','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('role:organization_administrator','organization_administrator','','Organization administrator','{\"key\":\"organization_administrator\",\"name\":\"Organization administrator\",\"permissions\":[\"identity.users.read\",\"identity.workforce.read\",\"identity.departments.read\",\"identity.roles.read\",\"identity.data_scopes.read\",\"identity.field_permissions.read\",\"system.read\",\"dictionary.read\",\"workflow.definition.read\",\"metadata.read\",\"automation.rule.read\",\"integration.catalog.view\",\"notification.template.read\",\"scheduler.definition.read\",\"audit.read\",\"platform_admin.domain_impact.read\"],\"record_scope\":\"all_records\",\"data_permissions\":[{\"object_key\":\"job_run\",\"scope\":\"none\",\"read\":false,\"write\":false}]}','0.1.0','5eb7ca59eb5a96918ef056c74c37ad7bcd2be7ca22e51973a86d1fda7f6568af','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('role:scheduler_service','scheduler_service','','Scheduler service','{\"key\":\"scheduler_service\",\"name\":\"Scheduler service\",\"permissions\":[\"service_request.send_overdue_reminder\"],\"record_scope\":\"all_records\",\"data_permissions\":[{\"object_key\":\"customer_profile\",\"scope\":\"all_records\",\"read\":true,\"write\":false,\"audit_denial\":true},{\"object_key\":\"device\",\"scope\":\"all_records\",\"read\":true,\"write\":false,\"audit_denial\":true},{\"object_key\":\"overdue_reminder\",\"scope\":\"all_records\",\"read\":true,\"write\":true,\"audit_denial\":true},{\"object_key\":\"service_request\",\"scope\":\"all_records\",\"read\":true,\"write\":false,\"audit_denial\":true}],\"audience\":\"service\",\"assignment_mode\":\"manual\",\"risk_level\":\"normal\"}','0.1.0','b61b1c167ec3b19f1f620cfbb4b2d453ccfba62037daee2f10e5d12a36ad1225','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('role:system_administrator','system_administrator','','System administrator','{\"key\":\"system_administrator\",\"name\":\"System administrator\",\"permissions\":[\"workflow.process.read\",\"operations.read\",\"integration.audit.view\",\"job_run.read\",\"runtime_ops.capability_status.read\"],\"record_scope\":\"all_records\",\"data_permissions\":[{\"object_key\":\"job_run\",\"scope\":\"all_records\",\"read\":true,\"write\":false}]}','0.1.0','07096722037751475bb615622cc0ba296b0ccaa6e53d0905b00788aecda88336','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('role:technician','technician','','Technician','{\"key\":\"technician\",\"name\":\"Technician\",\"permissions\":[\"identity.workforce.read\",\"part_usage.read\",\"service_request.read\",\"spare_part.read\",\"warranty_waiver.read\",\"service_request.complete_repair\",\"service_request.request_warranty_waiver\",\"service_request.start_assigned_repair\"],\"record_scope\":\"department\",\"data_permissions\":[{\"object_key\":\"customer_profile\",\"scope\":\"all_records\",\"read\":true,\"write\":false,\"audit_denial\":true},{\"object_key\":\"device\",\"scope\":\"all_records\",\"read\":true,\"write\":false,\"audit_denial\":true},{\"object_key\":\"fee_ledger\",\"scope\":\"all_records\",\"read\":false,\"write\":true,\"audit_denial\":true},{\"object_key\":\"overdue_reminder\",\"scope\":\"department\",\"read\":true,\"write\":false,\"audit_denial\":true},{\"object_key\":\"part_usage\",\"scope\":\"department\",\"read\":true,\"write\":true,\"audit_denial\":true},{\"object_key\":\"service_request\",\"scope\":\"department\",\"read\":true,\"write\":true,\"audit_denial\":true},{\"object_key\":\"spare_part\",\"scope\":\"all_records\",\"read\":true,\"write\":true,\"audit_denial\":true},{\"object_key\":\"warranty_waiver\",\"scope\":\"department\",\"read\":true,\"write\":true,\"audit_denial\":true}],\"audience\":\"workforce\",\"assignment_mode\":\"manual\",\"risk_level\":\"normal\"}','0.1.0','d7fb1eb9d5e2d9dc09818d393fa8da9fbecccc0efda73f82dd5a8cf9d3a822f6','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z');
/*!40000 ALTER TABLE `role_definitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rule_set_definitions`
--

DROP TABLE IF EXISTS `rule_set_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rule_set_definitions` (
  `id` varchar(191) NOT NULL,
  `resource_key` varchar(191) NOT NULL,
  `object_key` varchar(191) NOT NULL,
  `name` text NOT NULL,
  `payload_json` longtext NOT NULL,
  `schema_version` varchar(191) NOT NULL,
  `schema_hash` varchar(191) NOT NULL,
  `source_kind` varchar(191) NOT NULL,
  `source_id` varchar(191) NOT NULL,
  `disabled_at` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `resource_key` (`resource_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rule_set_definitions`
--

LOCK TABLES `rule_set_definitions` WRITE;
/*!40000 ALTER TABLE `rule_set_definitions` DISABLE KEYS */;
/*!40000 ALTER TABLE `rule_set_definitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `runtime_break_glass_grants`
--

DROP TABLE IF EXISTS `runtime_break_glass_grants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `runtime_break_glass_grants` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `state` varchar(191) NOT NULL,
  `actor_id` varchar(191) NOT NULL,
  `approver_ids_json` text NOT NULL,
  `reason` text NOT NULL,
  `incident_ref` varchar(191) NOT NULL,
  `alert_target` varchar(191) NOT NULL,
  `audit_event_id` varchar(191) NOT NULL,
  `expires_at` varchar(191) NOT NULL,
  `revision` bigint NOT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  `revoked_at` varchar(191) NOT NULL DEFAULT '',
  `revoked_by` varchar(191) NOT NULL DEFAULT '',
  `revocation_note` text NOT NULL DEFAULT (_utf8mb4''),
  UNIQUE KEY `uniq_runtime_break_glass_grants_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_runtime_break_glass_audit` (`workspace_id`,`audit_event_id`),
  KEY `idx_runtime_break_glass_active` (`workspace_id`,`state`,`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `runtime_break_glass_grants`
--

LOCK TABLES `runtime_break_glass_grants` WRITE;
/*!40000 ALTER TABLE `runtime_break_glass_grants` DISABLE KEYS */;
/*!40000 ALTER TABLE `runtime_break_glass_grants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `runtime_database_retirements`
--

DROP TABLE IF EXISTS `runtime_database_retirements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `runtime_database_retirements` (
  `id` varchar(191) NOT NULL,
  `engine` varchar(32) NOT NULL,
  `database_name` varchar(128) NOT NULL,
  `schema_name` varchar(128) NOT NULL DEFAULT '',
  `object_kind` varchar(64) NOT NULL,
  `object_name` varchar(191) NOT NULL,
  `parent_name` varchar(191) NOT NULL DEFAULT '',
  `owner` varchar(191) NOT NULL,
  `state` varchar(191) NOT NULL,
  `blocked_reason` text NOT NULL DEFAULT (_utf8mb4''),
  `read_count` bigint NOT NULL DEFAULT '0',
  `write_count` bigint NOT NULL DEFAULT '0',
  `last_read_at` varchar(191) NOT NULL DEFAULT '',
  `last_write_at` varchar(191) NOT NULL DEFAULT '',
  `source_counts_json` text NOT NULL DEFAULT (_utf8mb4'{}'),
  `retirement_json` text NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_runtime_database_retirement_object` (`engine`,`database_name`,`schema_name`,`object_kind`,`object_name`,`parent_name`),
  KEY `idx_runtime_database_retirement_status` (`state`,`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `runtime_database_retirements`
--

LOCK TABLES `runtime_database_retirements` WRITE;
/*!40000 ALTER TABLE `runtime_database_retirements` DISABLE KEYS */;
/*!40000 ALTER TABLE `runtime_database_retirements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `runtime_operation_controls`
--

DROP TABLE IF EXISTS `runtime_operation_controls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `runtime_operation_controls` (
  `system_purpose` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `control_kind` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `owner` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `state` varchar(191) NOT NULL,
  `reason` text NOT NULL,
  `reference` varchar(191) NOT NULL DEFAULT '',
  `updated_by` varchar(191) NOT NULL,
  `revision` bigint NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_runtime_operation_control` (`system_purpose`,`control_kind`,`owner`),
  KEY `idx_runtime_operation_control_state` (`system_purpose`,`control_kind`,`state`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `runtime_operation_controls`
--

LOCK TABLES `runtime_operation_controls` WRITE;
/*!40000 ALTER TABLE `runtime_operation_controls` DISABLE KEYS */;
/*!40000 ALTER TABLE `runtime_operation_controls` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `runtime_operations`
--

DROP TABLE IF EXISTS `runtime_operations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `runtime_operations` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `system_purpose` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '',
  `kind` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `permission` varchar(191) NOT NULL,
  `resource_type` varchar(191) NOT NULL,
  `resource_id` varchar(191) NOT NULL DEFAULT '',
  `idempotency_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `request_fingerprint` varchar(191) NOT NULL,
  `requested_by` varchar(191) NOT NULL,
  `reason` text NOT NULL,
  `reference` varchar(191) NOT NULL DEFAULT '',
  `status` varchar(191) NOT NULL,
  `status_url` text NOT NULL,
  `result_json` text NOT NULL,
  `error_code` varchar(191) NOT NULL DEFAULT '',
  `failure_class` varchar(191) NOT NULL DEFAULT '',
  `next_action` text NOT NULL DEFAULT (_utf8mb4''),
  `related_ids_json` text NOT NULL,
  `correlation` varchar(191) NOT NULL DEFAULT '',
  `evidence_json` text NOT NULL,
  `created_at` varchar(191) NOT NULL,
  `started_at` varchar(191) NOT NULL DEFAULT '',
  `finished_at` varchar(191) NOT NULL DEFAULT '',
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_runtime_operations_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_runtime_operation_key` (`workspace_id`,`system_purpose`,`kind`,`idempotency_key`),
  KEY `idx_runtime_operation_status` (`workspace_id`,`status`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `runtime_operations`
--

LOCK TABLES `runtime_operations` WRITE;
/*!40000 ALTER TABLE `runtime_operations` DISABLE KEYS */;
/*!40000 ALTER TABLE `runtime_operations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `runtime_rate_limit_bucket`
--

DROP TABLE IF EXISTS `runtime_rate_limit_bucket`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `runtime_rate_limit_bucket` (
  `bucket_key` varchar(255) NOT NULL,
  `window_start_ns` bigint NOT NULL,
  `request_count` bigint NOT NULL,
  `updated_at_ns` bigint NOT NULL,
  PRIMARY KEY (`bucket_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `runtime_rate_limit_bucket`
--

LOCK TABLES `runtime_rate_limit_bucket` WRITE;
/*!40000 ALTER TABLE `runtime_rate_limit_bucket` DISABLE KEYS */;
/*!40000 ALTER TABLE `runtime_rate_limit_bucket` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `runtime_release_cohorts`
--

DROP TABLE IF EXISTS `runtime_release_cohorts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `runtime_release_cohorts` (
  `cohort_key` varchar(191) NOT NULL,
  `combination_sha256` varchar(191) NOT NULL DEFAULT '',
  `identity_json` text NOT NULL DEFAULT (_utf8mb4''),
  `generation` bigint NOT NULL DEFAULT '0',
  `revision` bigint NOT NULL DEFAULT '0',
  `updated_at` varchar(191) NOT NULL DEFAULT '',
  PRIMARY KEY (`cohort_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `runtime_release_cohorts`
--

LOCK TABLES `runtime_release_cohorts` WRITE;
/*!40000 ALTER TABLE `runtime_release_cohorts` DISABLE KEYS */;
INSERT INTO `runtime_release_cohorts` VALUES ('active','2246e66db51d180572b7633e2d59b1e83f5783b10d431bf5bd76dd8770e85ecb','{\"contract_version\":\"domainry-runtime-release-identity-v2\",\"build_mode\":\"development\",\"runtime_version\":\"v0.0.0-source-318b0a23fff4fee2\",\"runtimeext_contract_version\":\"runtimeext-v15\",\"runtimeext_contract_sha256\":\"5e211b170a91d1ea04309f7e658ab18efb6f9f07c8f6130ccbdd5cf60257523f\",\"connectorext_contract_version\":\"connectorext-v16\",\"connectorext_contract_sha256\":\"bee106e94084dd69152f47bccb4f18d61d4243268e74372d02e3d5369aace7c9\",\"domain_sdk_contract_version\":\"runtime-domain-sdk-v21\",\"domain_sdk_contract_sha256\":\"621bd49abbdc75e7a62c0883b9941757d3814cde2a1fc35cd65f6c73b1fdc271\",\"domain_sdk_generator_version\":\"domaincodegen-v21\",\"domain_sdk_build_constraint\":\"domainry_domain_sdk_e465d148a7b244066fd47e3ed7b1555380551a4b2d2f3e8d3a77f002512e2152\",\"metadata_snapshot_sha256\":\"d7689a071cab658ff87fbc6bc58cd48f532b8f4bc0047ff37a8d3fdb61c3d91a\",\"generated_sdk_sha256\":\"ba899ddf52dffc422311057713de94b4fbc855a947ced2602131994f9ee05ba3\",\"project_module\":\"\",\"verification_receipt_sha256\":\"\",\"project_input_sha256\":\"\",\"project_source_sha256\":\"\",\"handler_catalog_sha256\":\"\",\"handler_registry_sha256\":\"58c7b06fa9b525d590c11c2f3f63022df72ccbf3dfb9bd1d89a99ab0d86ad2ba\",\"connector_registry_sha256\":\"29d2d9912c323a416536430ebced0eb03b50f45d6ba99a9d0747b99ea24249f8\",\"signing_key_id\":\"\",\"signing_public_key_sha256\":\"\",\"combination_sha256\":\"2246e66db51d180572b7633e2d59b1e83f5783b10d431bf5bd76dd8770e85ecb\"}',1,180,'2026-08-21T18:45:46.732193Z');
/*!40000 ALTER TABLE `runtime_release_cohorts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `runtime_release_instances`
--

DROP TABLE IF EXISTS `runtime_release_instances`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `runtime_release_instances` (
  `instance_id` varchar(191) NOT NULL,
  `combination_sha256` varchar(191) NOT NULL,
  `generation` bigint NOT NULL,
  `lease_expires_at` varchar(191) NOT NULL,
  `joined_at` varchar(191) NOT NULL,
  `heartbeat_at` varchar(191) NOT NULL,
  PRIMARY KEY (`instance_id`),
  KEY `idx_runtime_release_instance_expiry` (`lease_expires_at`),
  KEY `idx_runtime_release_instance_cohort` (`generation`,`combination_sha256`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `runtime_release_instances`
--

LOCK TABLES `runtime_release_instances` WRITE;
/*!40000 ALTER TABLE `runtime_release_instances` DISABLE KEYS */;
/*!40000 ALTER TABLE `runtime_release_instances` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `runtime_worker_queue_scopes`
--

DROP TABLE IF EXISTS `runtime_worker_queue_scopes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `runtime_worker_queue_scopes` (
  `id` varchar(191) NOT NULL,
  `queue_kind` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `scope_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_runtime_worker_queue_scope` (`queue_kind`,`scope_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `runtime_worker_queue_scopes`
--

LOCK TABLES `runtime_worker_queue_scopes` WRITE;
/*!40000 ALTER TABLE `runtime_worker_queue_scopes` DISABLE KEYS */;
/*!40000 ALTER TABLE `runtime_worker_queue_scopes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `scheduler_cursor`
--

DROP TABLE IF EXISTS `scheduler_cursor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `scheduler_cursor` (
  `workspace_id` varchar(191) NOT NULL,
  `id` varchar(191) NOT NULL,
  `created_at` text NOT NULL,
  `updated_at` text NOT NULL,
  `last_run_at` text,
  `last_run_status` text,
  `next_run_at` text,
  `scheduler_definition_key` text,
  UNIQUE KEY `uidx_field_d88f179a58656b3b` (`workspace_id`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scheduler_cursor`
--

LOCK TABLES `scheduler_cursor` WRITE;
/*!40000 ALTER TABLE `scheduler_cursor` DISABLE KEYS */;
INSERT INTO `scheduler_cursor` VALUES ('default','weekday_overdue_reminders','2026-08-21T18:45:48Z','2026-08-21T18:45:48Z','','','2026-08-24T01:00:00Z','weekday_overdue_reminders');
/*!40000 ALTER TABLE `scheduler_cursor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `scheduler_definitions`
--

DROP TABLE IF EXISTS `scheduler_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `scheduler_definitions` (
  `id` varchar(191) NOT NULL,
  `resource_key` varchar(191) NOT NULL,
  `object_key` varchar(191) NOT NULL,
  `name` text NOT NULL,
  `payload_json` longtext NOT NULL,
  `schema_version` varchar(191) NOT NULL,
  `schema_hash` varchar(191) NOT NULL,
  `source_kind` varchar(191) NOT NULL,
  `source_id` varchar(191) NOT NULL,
  `disabled_at` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `resource_key` (`resource_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scheduler_definitions`
--

LOCK TABLES `scheduler_definitions` WRITE;
/*!40000 ALTER TABLE `scheduler_definitions` DISABLE KEYS */;
INSERT INTO `scheduler_definitions` VALUES ('scheduler:weekday_overdue_reminders','weekday_overdue_reminders','','Weekday overdue service reminders','{\"__seed_key\":\"weekday_overdue_reminders\",\"key\":\"weekday_overdue_reminders\",\"max_attempts\":3,\"missed_window_policy\":\"catch_up_one\",\"name\":\"Weekday overdue service reminders\",\"schedule_expression\":\"0 9 * * 1-5\",\"schedule_type\":\"cron\",\"status\":\"enabled\",\"target_key\":\"scheduled:overdue_service_request_scan\",\"target_type\":\"workflow\",\"timeout_seconds\":300,\"timezone\":\"Asia/Shanghai\",\"trigger_type\":\"scheduled\"}','0.1.0','593e5c98b34bd397cc7b60a94065a553c98718651106a6b6a499fcdb26b076ae','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z');
/*!40000 ALTER TABLE `scheduler_definitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sensitive_field_policy_definitions`
--

DROP TABLE IF EXISTS `sensitive_field_policy_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sensitive_field_policy_definitions` (
  `id` varchar(191) NOT NULL,
  `resource_key` varchar(191) NOT NULL,
  `object_key` varchar(191) NOT NULL,
  `name` text NOT NULL,
  `payload_json` longtext NOT NULL,
  `schema_version` varchar(191) NOT NULL,
  `schema_hash` varchar(191) NOT NULL,
  `source_kind` varchar(191) NOT NULL,
  `source_id` varchar(191) NOT NULL,
  `disabled_at` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `resource_key` (`resource_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sensitive_field_policy_definitions`
--

LOCK TABLES `sensitive_field_policy_definitions` WRITE;
/*!40000 ALTER TABLE `sensitive_field_policy_definitions` DISABLE KEYS */;
/*!40000 ALTER TABLE `sensitive_field_policy_definitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_request`
--

DROP TABLE IF EXISTS `service_request`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `service_request` (
  `workspace_id` varchar(191) NOT NULL,
  `id` varchar(191) NOT NULL,
  `created_at` text NOT NULL,
  `updated_at` text NOT NULL,
  `assigned_user_id` varchar(191) DEFAULT NULL,
  `completed_at` varchar(191) DEFAULT NULL,
  `customer_profile_id` varchar(191) DEFAULT NULL,
  `device_id` varchar(191) DEFAULT NULL,
  `dispatched_at` varchar(191) DEFAULT NULL,
  `fault_description` text,
  `organization_unit_id` varchar(191) DEFAULT NULL,
  `owner_department_id` varchar(191) DEFAULT NULL,
  `owner_department_path` varchar(191) DEFAULT NULL,
  `preferred_visit_at` varchar(191) DEFAULT NULL,
  `quote_amount` decimal(19,2) DEFAULT NULL,
  `started_at` text,
  `status` varchar(191) DEFAULT NULL,
  `submitted_at` varchar(191) DEFAULT NULL,
  UNIQUE KEY `uidx_field_368339e27cd739b1` (`workspace_id`,`id`),
  KEY `idx_field_727f9256c8d6b956` (`assigned_user_id`),
  KEY `idx_field_5ac3b0f40776397e` (`completed_at`),
  KEY `idx_field_9e5dcd7b8cc6d308` (`customer_profile_id`),
  KEY `idx_field_133fa37bf52d6162` (`device_id`),
  KEY `idx_field_5228b2cbf95c8257` (`dispatched_at`),
  KEY `idx_field_423b2e3ffbdd5421` (`organization_unit_id`),
  KEY `idx_field_6495ab69ee744be1` (`owner_department_id`),
  KEY `idx_field_ae72e036680474b8` (`owner_department_path`),
  KEY `idx_field_498233236c9f8bff` (`preferred_visit_at`),
  KEY `idx_field_23898ddb50c662e8` (`status`),
  KEY `idx_field_783e7ea2b85d669a` (`submitted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_request`
--

LOCK TABLES `service_request` WRITE;
/*!40000 ALTER TABLE `service_request` DISABLE KEYS */;
INSERT INTO `service_request` VALUES ('default','service_request_request_qin_completed_direct','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z','tech_east_chen','2026-08-15T03:00:00Z','customer_profile_customer_qin_profile','device_device_qin_press','2026-08-14T02:00:00Z','Seal replacement completed',NULL,'east_station','/ops_root/east_station','2026-08-18T03:00:00Z',800.00,'2026-08-15T01:00:00Z','completed','2026-08-14T01:00:00Z'),('default','service_request_request_qin_completed_no_waiver','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z','tech_east_chen','2026-08-16T05:00:00Z','customer_profile_customer_qin_profile','device_device_qin_press','2026-08-15T02:00:00Z','Sensor calibration completed',NULL,'east_station','/ops_root/east_station','2026-08-19T04:00:00Z',600.00,'2026-08-16T01:00:00Z','completed','2026-08-15T01:00:00Z'),('default','service_request_request_qin_dispatched','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z','tech_east_chen',NULL,'customer_profile_customer_qin_profile','device_device_qin_press','2026-08-18T01:00:00Z','Control panel alarm requires diagnosis',NULL,'east_station','/ops_root/east_station','2026-08-22T02:00:00Z',NULL,NULL,'dispatched','2026-08-17T01:00:00Z'),('default','service_request_request_qin_dispatched_fresh','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z','tech_east_chen',NULL,'customer_profile_customer_qin_profile','device_device_qin_press','2026-08-21T00:30:00Z','Newly assigned inspection',NULL,'east_station','/ops_root/east_station','2026-08-23T02:00:00Z',NULL,NULL,'dispatched','2026-08-20T01:00:00Z'),('default','service_request_request_qin_submitted','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z',NULL,NULL,'customer_profile_customer_qin_profile','device_device_qin_press',NULL,'Hydraulic pressure drops intermittently',NULL,NULL,NULL,'2026-08-24T01:00:00Z',NULL,NULL,'submitted','2026-08-20T01:00:00Z'),('default','service_request_request_sun_completed_pending','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z','tech_west_zhao','2026-08-14T05:00:00Z','customer_profile_customer_sun_profile','device_device_sun_lathe','2026-08-13T02:00:00Z','Bearing replacement completed',NULL,'west_station','/ops_root/west_station','2026-08-18T04:00:00Z',1800.00,'2026-08-14T01:00:00Z','completed','2026-08-13T01:00:00Z'),('default','service_request_request_sun_in_repair','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z','tech_west_zhao',NULL,'customer_profile_customer_sun_profile','device_device_sun_lathe','2026-08-18T02:00:00Z','Spindle vibration under load',NULL,'west_station','/ops_root/west_station','2026-08-22T03:00:00Z',NULL,'2026-08-19T01:00:00Z','in_repair','2026-08-18T01:00:00Z');
/*!40000 ALTER TABLE `service_request` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `skill_definitions`
--

DROP TABLE IF EXISTS `skill_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `skill_definitions` (
  `id` varchar(191) NOT NULL,
  `resource_key` varchar(191) NOT NULL,
  `object_key` varchar(191) NOT NULL,
  `name` text NOT NULL,
  `payload_json` longtext NOT NULL,
  `schema_version` varchar(191) NOT NULL,
  `schema_hash` varchar(191) NOT NULL,
  `source_kind` varchar(191) NOT NULL,
  `source_id` varchar(191) NOT NULL,
  `disabled_at` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `resource_key` (`resource_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `skill_definitions`
--

LOCK TABLES `skill_definitions` WRITE;
/*!40000 ALTER TABLE `skill_definitions` DISABLE KEYS */;
/*!40000 ALTER TABLE `skill_definitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `spare_part`
--

DROP TABLE IF EXISTS `spare_part`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `spare_part` (
  `workspace_id` varchar(191) NOT NULL,
  `id` varchar(191) NOT NULL,
  `created_at` text NOT NULL,
  `updated_at` text NOT NULL,
  `code` varchar(191) DEFAULT NULL,
  `name` varchar(191) DEFAULT NULL,
  `stock_quantity` bigint DEFAULT NULL,
  `unit_price` decimal(19,2) DEFAULT NULL,
  UNIQUE KEY `uidx_field_74dd96c24e1cb20c` (`workspace_id`,`id`),
  UNIQUE KEY `uidx_field_4f5a72738b6ef6bc` (`workspace_id`,`code`),
  KEY `idx_field_73771d1944a4e8a5` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `spare_part`
--

LOCK TABLES `spare_part` WRITE;
/*!40000 ALTER TABLE `spare_part` DISABLE KEYS */;
INSERT INTO `spare_part` VALUES ('default','spare_part_part_bearing','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z','PART-BEARING-001','Spindle Bearing',5,680.00),('default','spare_part_part_controller','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z','PART-CONTROL-001','Controller Module',0,950.00),('default','spare_part_part_filter','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z','PART-FILTER-001','Hydraulic Filter',20,120.50);
/*!40000 ALTER TABLE `spare_part` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `surface_definitions`
--

DROP TABLE IF EXISTS `surface_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `surface_definitions` (
  `id` varchar(191) NOT NULL,
  `resource_key` varchar(191) NOT NULL,
  `object_key` varchar(191) NOT NULL,
  `name` text NOT NULL,
  `payload_json` longtext NOT NULL,
  `schema_version` varchar(191) NOT NULL,
  `schema_hash` varchar(191) NOT NULL,
  `source_kind` varchar(191) NOT NULL,
  `source_id` varchar(191) NOT NULL,
  `disabled_at` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `resource_key` (`resource_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `surface_definitions`
--

LOCK TABLES `surface_definitions` WRITE;
/*!40000 ALTER TABLE `surface_definitions` DISABLE KEYS */;
/*!40000 ALTER TABLE `surface_definitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transaction_boundary_intents`
--

DROP TABLE IF EXISTS `transaction_boundary_intents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transaction_boundary_intents` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `owner` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `operation` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `resource_id` varchar(191) NOT NULL,
  `idempotency_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `status` varchar(191) NOT NULL,
  `payload_json` text NOT NULL,
  `compensation_payload_json` text NOT NULL,
  `attempt_count` int NOT NULL DEFAULT '0',
  `next_attempt_at` varchar(191) NOT NULL DEFAULT '',
  `lease_owner` varchar(191) NOT NULL DEFAULT '',
  `lease_expires_at` varchar(191) NOT NULL DEFAULT '',
  `fencing_token` bigint NOT NULL DEFAULT '0',
  `last_error` text NOT NULL DEFAULT (_utf8mb4''),
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_transaction_boundary_intents_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_transaction_boundary_intent` (`workspace_id`,`owner`,`operation`,`idempotency_key`),
  KEY `idx_transaction_boundary_intent_due` (`status`,`next_attempt_at`,`lease_expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transaction_boundary_intents`
--

LOCK TABLES `transaction_boundary_intents` WRITE;
/*!40000 ALTER TABLE `transaction_boundary_intents` DISABLE KEYS */;
/*!40000 ALTER TABLE `transaction_boundary_intents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `validation_definitions`
--

DROP TABLE IF EXISTS `validation_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `validation_definitions` (
  `id` varchar(191) NOT NULL,
  `resource_key` varchar(191) NOT NULL,
  `object_key` varchar(191) NOT NULL,
  `name` text NOT NULL,
  `payload_json` longtext NOT NULL,
  `schema_version` varchar(191) NOT NULL,
  `schema_hash` varchar(191) NOT NULL,
  `source_kind` varchar(191) NOT NULL,
  `source_id` varchar(191) NOT NULL,
  `disabled_at` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `resource_key` (`resource_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `validation_definitions`
--

LOCK TABLES `validation_definitions` WRITE;
/*!40000 ALTER TABLE `validation_definitions` DISABLE KEYS */;
INSERT INTO `validation_definitions` VALUES ('validation:record_timer_identity','record_timer_identity','record_timer','','{\"key\":\"record_timer_identity\",\"object_key\":\"record_timer\",\"type\":\"composite_unique\",\"fields\":[\"timer_key\",\"object_key\",\"record_id\",\"purpose\"]}','0.1.0','178dee73a7ee90b83bb8be3fcb85c1fa3b8198fc45f51c7df0c759c9cead2fb4','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('validation:service_request_lifecycle','service_request_lifecycle','service_request','Service request lifecycle','{\"key\":\"service_request_lifecycle\",\"object_key\":\"service_request\",\"type\":\"state_machine\",\"field_key\":\"status\",\"severity\":\"error\",\"message\":\"Service request lifecycle\",\"config\":{\"field_key\":\"status\",\"states\":[\"completed\",\"dispatched\",\"in_repair\",\"submitted\"],\"terminal_states\":[\"completed\"],\"transitions\":[{\"action_key\":\"service_request.start_assigned_repair\",\"from\":\"dispatched\",\"to\":\"in_repair\"},{\"action_key\":\"service_request.unassign_service_request\",\"from\":\"dispatched\",\"to\":\"submitted\"},{\"action_key\":\"service_request.complete_repair\",\"from\":\"in_repair\",\"to\":\"completed\"},{\"action_key\":\"service_request.dispatch_service_request\",\"from\":\"submitted\",\"to\":\"dispatched\"}]}}','0.1.0','8310cd8e5325244fd8a6daba514ba17514aadd3ca878f29207604a674e8bebff','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z');
/*!40000 ALTER TABLE `validation_definitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `view_definitions`
--

DROP TABLE IF EXISTS `view_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `view_definitions` (
  `id` varchar(191) NOT NULL,
  `resource_key` varchar(191) NOT NULL,
  `object_key` varchar(191) NOT NULL,
  `name` text NOT NULL,
  `payload_json` longtext NOT NULL,
  `schema_version` varchar(191) NOT NULL,
  `schema_hash` varchar(191) NOT NULL,
  `source_kind` varchar(191) NOT NULL,
  `source_id` varchar(191) NOT NULL,
  `disabled_at` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `resource_key` (`resource_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `view_definitions`
--

LOCK TABLES `view_definitions` WRITE;
/*!40000 ALTER TABLE `view_definitions` DISABLE KEYS */;
INSERT INTO `view_definitions` VALUES ('view:customer_profile_detail','customer_profile_detail','customer_profile','Customer profile Detail','{\"key\":\"customer_profile_detail\",\"name\":\"Customer profile Detail\",\"object_key\":\"customer_profile\",\"type\":\"detail\",\"config\":{\"columns\":[\"display_name\",\"identity_user_id\",\"status\"],\"search_fields\":[\"display_name\",\"status\"],\"sections\":[\"main\"]}}','0.1.0','a633b95229d7cc9629eb20ffc42085492804db2b7397ffa29d8bebf282d86e87','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('view:customer_profile_list','customer_profile_list','customer_profile','Customer profile','{\"key\":\"customer_profile_list\",\"name\":\"Customer profile\",\"object_key\":\"customer_profile\",\"type\":\"table\",\"config\":{\"columns\":[\"display_name\",\"identity_user_id\",\"status\"],\"page_size\":25,\"search_fields\":[\"display_name\",\"status\"]}}','0.1.0','4ada495527d802366bad8a5376b728c24bdd916a6f4ed93673c929ed7303b9c2','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('view:device_detail','device_detail','device','Device Detail','{\"key\":\"device_detail\",\"name\":\"Device Detail\",\"object_key\":\"device\",\"type\":\"detail\",\"config\":{\"columns\":[\"name\",\"customer_profile_id\",\"purchase_date\",\"serial_number\"],\"search_fields\":[\"name\"],\"sections\":[\"main\"]}}','0.1.0','eb6b4e76f2454a21b95fa58667a7a6069cd05f9b655f53251a54c79190607b33','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('view:device_list','device_list','device','Device','{\"key\":\"device_list\",\"name\":\"Device\",\"object_key\":\"device\",\"type\":\"table\",\"config\":{\"columns\":[\"name\",\"customer_profile_id\",\"purchase_date\",\"serial_number\"],\"page_size\":25,\"search_fields\":[\"name\"]}}','0.1.0','d87a963d6608becf9cd63a9e078dc466fa8fd37a52b07ca1880f5bd1fdceb8a6','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('view:fee_ledger_detail','fee_ledger_detail','fee_ledger','Fee ledger Detail','{\"key\":\"fee_ledger_detail\",\"name\":\"Fee ledger Detail\",\"object_key\":\"fee_ledger\",\"type\":\"detail\",\"config\":{\"columns\":[\"amount\",\"calculation_trace\",\"input_snapshot\",\"kind\",\"lineage_key\",\"occurred_at\"],\"search_fields\":[\"kind\",\"lineage_key\"],\"sections\":[\"main\"]}}','0.1.0','8b162adc5180a6870053dcd2d58054ceda5451acad70b990402ac692bd978281','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('view:fee_ledger_list','fee_ledger_list','fee_ledger','Fee ledger','{\"key\":\"fee_ledger_list\",\"name\":\"Fee ledger\",\"object_key\":\"fee_ledger\",\"type\":\"table\",\"config\":{\"columns\":[\"amount\",\"calculation_trace\",\"input_snapshot\",\"kind\",\"lineage_key\",\"occurred_at\"],\"page_size\":25,\"search_fields\":[\"kind\",\"lineage_key\"]}}','0.1.0','b275d3fd760e314fbec5c1accd0de6fa44146105e59773e2875f4fd217f7b11e','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('view:overdue_reminder_detail','overdue_reminder_detail','overdue_reminder','Overdue reminder Detail','{\"key\":\"overdue_reminder_detail\",\"name\":\"Overdue reminder Detail\",\"object_key\":\"overdue_reminder\",\"type\":\"detail\",\"config\":{\"columns\":[\"business_date\",\"dedupe_key\",\"owner_department_id\",\"owner_department_path\",\"recipient_user_id\",\"sent_at\"],\"search_fields\":[\"dedupe_key\",\"owner_department_id\",\"owner_department_path\"],\"sections\":[\"main\"]}}','0.1.0','8a0ed412d0d58d1f1eca6234b3303309433115398a201bbb4cf5765ad8aedf41','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('view:overdue_reminder_list','overdue_reminder_list','overdue_reminder','Overdue reminder','{\"key\":\"overdue_reminder_list\",\"name\":\"Overdue reminder\",\"object_key\":\"overdue_reminder\",\"type\":\"table\",\"config\":{\"columns\":[\"business_date\",\"dedupe_key\",\"owner_department_id\",\"owner_department_path\",\"recipient_user_id\",\"sent_at\"],\"page_size\":25,\"search_fields\":[\"dedupe_key\",\"owner_department_id\",\"owner_department_path\"]}}','0.1.0','2bddd9684ca1f425877f5cd4a72dc6a809e5af39783fa71bbd7b4d57308e9517','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('view:part_usage_detail','part_usage_detail','part_usage','Part usage Detail','{\"key\":\"part_usage_detail\",\"name\":\"Part usage Detail\",\"object_key\":\"part_usage\",\"type\":\"detail\",\"config\":{\"columns\":[\"amount\",\"calculation_trace\",\"occurred_at\",\"owner_department_id\",\"owner_department_path\",\"performed_by_user_id\"],\"search_fields\":[\"owner_department_id\",\"owner_department_path\"],\"sections\":[\"main\"]}}','0.1.0','e3f7b21f08e8553f34964179c4a9759bf46ac319c417109fe989e4289595e255','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('view:part_usage_list','part_usage_list','part_usage','Part usage','{\"key\":\"part_usage_list\",\"name\":\"Part usage\",\"object_key\":\"part_usage\",\"type\":\"table\",\"config\":{\"columns\":[\"amount\",\"calculation_trace\",\"occurred_at\",\"owner_department_id\",\"owner_department_path\",\"performed_by_user_id\"],\"page_size\":25,\"search_fields\":[\"owner_department_id\",\"owner_department_path\"]}}','0.1.0','86dfa7bd89f0b4e89fd76f53846e4bb5106eed2dbe1cf8434679c949f5b54359','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('view:report_export_audit_detail','report_export_audit_detail','report_export_audit','Report export audit Detail','{\"key\":\"report_export_audit_detail\",\"name\":\"Report export audit Detail\",\"object_key\":\"report_export_audit\",\"type\":\"detail\",\"config\":{\"columns\":[\"owner_department_id\",\"owner_department_path\",\"purpose\",\"report_key\",\"requested_at\",\"requester_user_id\"],\"search_fields\":[\"owner_department_id\",\"owner_department_path\",\"report_key\"],\"sections\":[\"main\"]}}','0.1.0','5d1b41b6e3bd6e8b20c43cc4ee5e5c7cdead04a16e92601e44f98d6cb47b72f6','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('view:report_export_audit_list','report_export_audit_list','report_export_audit','Report export audit','{\"key\":\"report_export_audit_list\",\"name\":\"Report export audit\",\"object_key\":\"report_export_audit\",\"type\":\"table\",\"config\":{\"columns\":[\"owner_department_id\",\"owner_department_path\",\"purpose\",\"report_key\",\"requested_at\",\"requester_user_id\"],\"page_size\":25,\"search_fields\":[\"owner_department_id\",\"owner_department_path\",\"report_key\"]}}','0.1.0','e6d2c30b2b66081698883513c675aa0d0d109ce06cdf0fd3f769ab26490888ac','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('view:report_export_download_detail','report_export_download_detail','report_export_download','Report export download Detail','{\"key\":\"report_export_download_detail\",\"name\":\"Report export download Detail\",\"object_key\":\"report_export_download\",\"type\":\"detail\",\"config\":{\"columns\":[\"audit_id\",\"content_hash\",\"expires_at\",\"filename\",\"owner\"],\"search_fields\":[\"content_hash\",\"filename\"],\"sections\":[\"main\"]}}','0.1.0','ec6814b60587559d307735969aee51c196a114cdf4864093356001abe1aff65f','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('view:report_export_download_list','report_export_download_list','report_export_download','Report export download','{\"key\":\"report_export_download_list\",\"name\":\"Report export download\",\"object_key\":\"report_export_download\",\"type\":\"table\",\"config\":{\"columns\":[\"audit_id\",\"content_hash\",\"expires_at\",\"filename\",\"owner\"],\"page_size\":25,\"search_fields\":[\"content_hash\",\"filename\"]}}','0.1.0','ee3bab1bb21cf0f11e8201f72f4d82da8d9d3b201b0c7fd2b0b7c75a7a5934ed','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('view:service_request_detail','service_request_detail','service_request','Service request Detail','{\"key\":\"service_request_detail\",\"name\":\"Service request Detail\",\"object_key\":\"service_request\",\"type\":\"detail\",\"config\":{\"columns\":[\"assigned_user_id\",\"completed_at\",\"customer_profile_id\",\"device_id\",\"dispatched_at\",\"fault_description\"],\"search_fields\":[\"owner_department_id\",\"owner_department_path\",\"status\"],\"sections\":[\"main\"]}}','0.1.0','a3bc89c465b7837d4fdba8d1404d00ed47e7b5a40511ccd93aed8dc316b44a4d','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('view:service_request_list','service_request_list','service_request','Service request list','{\"key\":\"service_request_list\",\"name\":\"Service request list\",\"object_key\":\"service_request\",\"type\":\"table\",\"config\":{\"business_view\":\"list\",\"columns\":[\"device_id\",\"status\",\"assigned_user_id\",\"quote_amount\",\"submitted_at\"],\"filters\":[{\"field\":\"status\",\"key\":\"submitted\",\"value\":\"submitted\"},{\"field\":\"status\",\"key\":\"dispatched\",\"value\":\"dispatched\"}],\"page_size\":50,\"search_fields\":[\"fault_description\"],\"sort\":[{\"direction\":\"desc\",\"field\":\"submitted_at\"},{\"direction\":\"asc\",\"field\":\"id\"}]}}','0.1.0','6a3c21f46c57c2f5d2114f96ad9c7f45b09319becb6b1d2d2c1581e00ce2223c','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('view:spare_part_detail','spare_part_detail','spare_part','Spare part Detail','{\"key\":\"spare_part_detail\",\"name\":\"Spare part Detail\",\"object_key\":\"spare_part\",\"type\":\"detail\",\"config\":{\"columns\":[\"name\",\"code\",\"stock_quantity\",\"unit_price\"],\"search_fields\":[\"name\"],\"sections\":[\"main\"]}}','0.1.0','e79aa39ce05c36b4c2f7b07c4f086244a96b3557c466092a6e2b3085af62ae19','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('view:spare_part_list','spare_part_list','spare_part','Spare part list','{\"key\":\"spare_part_list\",\"name\":\"Spare part list\",\"object_key\":\"spare_part\",\"type\":\"table\",\"config\":{\"business_view\":\"list\",\"columns\":[\"code\",\"name\",\"unit_price\",\"stock_quantity\"],\"filters\":[],\"page_size\":50,\"search_fields\":[\"code\",\"name\"],\"sort\":[{\"direction\":\"asc\",\"field\":\"code\"},{\"direction\":\"asc\",\"field\":\"id\"}]}}','0.1.0','1ae6f72fb3114159bce16072be286af36818f4ed71670516a458479eb4aad4df','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('view:warranty_waiver_detail','warranty_waiver_detail','warranty_waiver','Warranty waiver Detail','{\"key\":\"warranty_waiver_detail\",\"name\":\"Warranty waiver Detail\",\"object_key\":\"warranty_waiver\",\"type\":\"detail\",\"config\":{\"columns\":[\"calculation_trace\",\"decided_at\",\"decided_by_user_id\",\"owner_department_id\",\"owner_department_path\",\"policy_snapshot\"],\"search_fields\":[\"owner_department_id\",\"owner_department_path\",\"status\"],\"sections\":[\"main\"]}}','0.1.0','efaf4eab744154f9cc511f1a98614914b46f635804da493ca499675aa3c2110e','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('view:warranty_waiver_list','warranty_waiver_list','warranty_waiver','Warranty waiver','{\"key\":\"warranty_waiver_list\",\"name\":\"Warranty waiver\",\"object_key\":\"warranty_waiver\",\"type\":\"table\",\"config\":{\"columns\":[\"calculation_trace\",\"decided_at\",\"decided_by_user_id\",\"owner_department_id\",\"owner_department_path\",\"policy_snapshot\"],\"page_size\":25,\"search_fields\":[\"owner_department_id\",\"owner_department_path\",\"status\"]}}','0.1.0','2031e2ed963331726a1160be82defe3e324dd71029f5cf32fdb0c5b0c763b18c','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z');
/*!40000 ALTER TABLE `view_definitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `warranty_waiver`
--

DROP TABLE IF EXISTS `warranty_waiver`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `warranty_waiver` (
  `workspace_id` varchar(191) NOT NULL,
  `id` varchar(191) NOT NULL,
  `created_at` text NOT NULL,
  `updated_at` text NOT NULL,
  `calculation_trace` text,
  `decided_at` text,
  `decided_by_user_id` text,
  `owner_department_id` varchar(191) DEFAULT NULL,
  `owner_department_path` varchar(191) DEFAULT NULL,
  `policy_snapshot` text,
  `rejection_reason` text,
  `requested_amount` decimal(19,2) DEFAULT NULL,
  `requested_at` varchar(191) DEFAULT NULL,
  `requester_user_id` text,
  `service_request_id` varchar(191) DEFAULT NULL,
  `status` varchar(191) DEFAULT NULL,
  `threshold_snapshot` decimal(19,2) DEFAULT NULL,
  `warranty_asserted` tinyint(1) DEFAULT NULL,
  UNIQUE KEY `uidx_field_c0eef764347d8af7` (`workspace_id`,`id`),
  UNIQUE KEY `uidx_field_71130f88039bce85` (`workspace_id`,`service_request_id`),
  KEY `idx_field_352044efc1066cd8` (`owner_department_id`),
  KEY `idx_field_f2df9610de846a8c` (`owner_department_path`),
  KEY `idx_field_2abaa7041d5d0e7b` (`requested_at`),
  KEY `idx_field_ed6bd3a89e6b8333` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `warranty_waiver`
--

LOCK TABLES `warranty_waiver` WRITE;
/*!40000 ALTER TABLE `warranty_waiver` DISABLE KEYS */;
INSERT INTO `warranty_waiver` VALUES ('default','warranty_waiver_waiver_qin_direct','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z','CNY 300.00 < CNY 500.00; applied directly','2026-08-15T03:05:00Z',NULL,NULL,NULL,'Direct when requested amount is below CNY 500.00',NULL,300.00,'2026-08-15T03:05:00Z',NULL,'service_request_request_qin_completed_direct','applied',500.00,1),('default','warranty_waiver_waiver_sun_pending','2026-08-21T18:45:47Z','2026-08-21T18:45:47Z','CNY 500.00 >= CNY 500.00; pending manager approval',NULL,NULL,NULL,NULL,'Approval required when requested amount is at least CNY 500.00',NULL,500.00,'2026-08-14T05:05:00Z',NULL,'service_request_request_sun_completed_pending','pending',500.00,1);
/*!40000 ALTER TABLE `warranty_waiver` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `web_push_subscriptions`
--

DROP TABLE IF EXISTS `web_push_subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `web_push_subscriptions` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) NOT NULL,
  `user_id` varchar(191) NOT NULL,
  `endpoint_hash` varchar(191) NOT NULL,
  `endpoint` text NOT NULL,
  `p256dh` text NOT NULL,
  `auth_secret` text NOT NULL,
  `status` varchar(191) NOT NULL,
  `expires_at` varchar(191) NOT NULL DEFAULT '',
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  `revoked_at` varchar(191) NOT NULL DEFAULT '',
  UNIQUE KEY `uniq_web_push_subscription_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_web_push_subscription_endpoint` (`workspace_id`,`endpoint_hash`),
  KEY `idx_web_push_subscription_user` (`workspace_id`,`user_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `web_push_subscriptions`
--

LOCK TABLES `web_push_subscriptions` WRITE;
/*!40000 ALTER TABLE `web_push_subscriptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `web_push_subscriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workflow_definition_identities`
--

DROP TABLE IF EXISTS `workflow_definition_identities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `workflow_definition_identities` (
  `id` varchar(191) NOT NULL,
  `workflow_key` varchar(191) NOT NULL,
  `name` text NOT NULL,
  `owner_user_id` varchar(191) DEFAULT NULL,
  `enabled` int NOT NULL,
  `current_draft_version_id` varchar(191) DEFAULT NULL,
  `current_published_version_id` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_workflow_definition_key` (`workflow_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workflow_definition_identities`
--

LOCK TABLES `workflow_definition_identities` WRITE;
/*!40000 ALTER TABLE `workflow_definition_identities` DISABLE KEYS */;
INSERT INTO `workflow_definition_identities` VALUES ('workflow_definition_1787337947833642000','overdue_service_request_scan','Overdue service request scan',NULL,1,NULL,'workflow_version_1787337947833643000','2026-08-21T18:45:47.833642Z','2026-08-21T18:45:47.833642Z'),('workflow_definition_1787337947836092000','platform.audit_retention_check','Audit retention check',NULL,1,NULL,'workflow_version_1787337947836094000','2026-08-21T18:45:47.836092Z','2026-08-21T18:45:47.836092Z'),('workflow_definition_1787337947837929000','platform.metadata_health_check','Metadata health check',NULL,1,NULL,'workflow_version_1787337947837929000','2026-08-21T18:45:47.837928Z','2026-08-21T18:45:47.837928Z'),('workflow_definition_1787337947841299000','warranty_waiver_approval','Warranty waiver approval',NULL,1,NULL,'workflow_version_1787337947841300000','2026-08-21T18:45:47.841299Z','2026-08-21T18:45:47.841299Z');
/*!40000 ALTER TABLE `workflow_definition_identities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workflow_definition_versions`
--

DROP TABLE IF EXISTS `workflow_definition_versions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `workflow_definition_versions` (
  `id` varchar(191) NOT NULL,
  `definition_id` varchar(191) NOT NULL,
  `version_no` int NOT NULL,
  `status` varchar(191) NOT NULL,
  `revision` int NOT NULL,
  `content_hash` varchar(191) DEFAULT NULL,
  `workflow_json` text NOT NULL,
  `validation_report_json` text NOT NULL,
  `publish_note` text,
  `created_by` varchar(191) NOT NULL,
  `published_by` varchar(191) DEFAULT NULL,
  `publish_idempotency_key` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  `published_at` varchar(191) DEFAULT NULL,
  `archived_at` varchar(191) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_workflow_version_number` (`definition_id`,`version_no`),
  UNIQUE KEY `idx_workflow_publish_idempotency` (`definition_id`,`publish_idempotency_key`),
  KEY `idx_workflow_version_status` (`definition_id`,`status`,`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workflow_definition_versions`
--

LOCK TABLES `workflow_definition_versions` WRITE;
/*!40000 ALTER TABLE `workflow_definition_versions` DISABLE KEYS */;
INSERT INTO `workflow_definition_versions` VALUES ('workflow_version_1787337947833643000','workflow_definition_1787337947833642000',1,'published',1,'aa5b3f2a21fc262b743c399e60615964cd2d89e5d404911b1e1630da5095197b','{\"key\":\"overdue_service_request_scan\",\"name\":\"Overdue service request scan\",\"trigger\":{\"type\":\"scheduled\"},\"condition\":{\"field\":\"status\",\"type\":\"field_equals\",\"value\":\"dispatched\"},\"action\":{\"type\":\"workflow_graph\"},\"trigger_contract\":{\"type\":\"scheduled\",\"object_key\":\"service_request\"},\"enabled\":true,\"run_as\":\"scheduler_service\",\"graph\":{\"version\":2,\"nodes\":[{\"id\":\"schedule_trigger\",\"type\":\"trigger\",\"name\":\"Scheduled record scan\"},{\"id\":\"send_reminder\",\"type\":\"action\",\"name\":\"Send eligible overdue reminder\",\"contract\":{\"action\":{\"action_key\":\"service_request.send_overdue_reminder\",\"object_key\":\"service_request\",\"record_id\":\"$record.id\",\"input\":{\"scheduled_at\":\"$workflow.scheduled_at\"},\"on_error\":\"fail\"}}}],\"edges\":[{\"id\":\"trigger_to_reminder\",\"source\":\"schedule_trigger\",\"target\":\"send_reminder\"}]}}','{\"valid\":true,\"issues\":[],\"validated_at\":\"2026-08-21T18:45:47.832021Z\"}','','system','system','metadata:aa5b3f2a21fc262b743c399e60615964cd2d89e5d404911b1e1630da5095197b:version:1','2026-08-21T18:45:47.833642Z','2026-08-21T18:45:47.833642Z','2026-08-21T18:45:47.833642Z',NULL),('workflow_version_1787337947836094000','workflow_definition_1787337947836092000',1,'published',1,'6bcdea614cf9b271dbeebdaf5fcf760fcba193ca43a9ed4dd123309cfd5742ec','{\"key\":\"platform.audit_retention_check\",\"name\":\"Audit retention check\",\"trigger\":{\"type\":\"manual\"},\"condition\":{\"type\":\"always\"},\"action\":{\"type\":\"workflow_graph\"},\"trigger_contract\":{\"type\":\"manual\"},\"condition_contract\":{\"type\":\"always\"},\"enabled\":true,\"retry\":{\"max_attempts\":3,\"delay_seconds\":60},\"audit_event\":\"platform_audit_retention_checked\",\"graph\":{\"version\":2,\"nodes\":[{\"id\":\"manual_trigger\",\"type\":\"trigger\",\"name\":\"Run audit retention check\"}],\"edges\":null}}','{\"valid\":true,\"issues\":[],\"validated_at\":\"2026-08-21T18:45:47.835535Z\"}','','system','system','metadata:6bcdea614cf9b271dbeebdaf5fcf760fcba193ca43a9ed4dd123309cfd5742ec:version:1','2026-08-21T18:45:47.836092Z','2026-08-21T18:45:47.836092Z','2026-08-21T18:45:47.836092Z',NULL),('workflow_version_1787337947837929000','workflow_definition_1787337947837929000',1,'published',1,'d35b2ac8904714b0758ae5865488613949ccd607c3b536605281087fd71ebdc3','{\"key\":\"platform.metadata_health_check\",\"name\":\"Metadata health check\",\"trigger\":{\"type\":\"manual\"},\"condition\":{\"type\":\"always\"},\"action\":{\"type\":\"workflow_graph\"},\"trigger_contract\":{\"type\":\"manual\"},\"condition_contract\":{\"type\":\"always\"},\"enabled\":true,\"retry\":{\"max_attempts\":3,\"delay_seconds\":60},\"audit_event\":\"platform_metadata_health_checked\",\"graph\":{\"version\":2,\"nodes\":[{\"id\":\"manual_trigger\",\"type\":\"trigger\",\"name\":\"Run metadata health check\"}],\"edges\":null}}','{\"valid\":true,\"issues\":[],\"validated_at\":\"2026-08-21T18:45:47.837525Z\"}','','system','system','metadata:d35b2ac8904714b0758ae5865488613949ccd607c3b536605281087fd71ebdc3:version:1','2026-08-21T18:45:47.837928Z','2026-08-21T18:45:47.837928Z','2026-08-21T18:45:47.837928Z',NULL),('workflow_version_1787337947841300000','workflow_definition_1787337947841299000',1,'published',1,'bc1e690354bcb8187a10b6f75d2731a658ffd6c2be01b815e4c1dda985eb53d9','{\"key\":\"warranty_waiver_approval\",\"name\":\"Warranty waiver approval\",\"trigger\":{\"type\":\"record_created\"},\"condition\":{\"field\":\"status\",\"type\":\"field_equals\",\"value\":\"pending\"},\"action\":{\"type\":\"workflow_graph\"},\"trigger_contract\":{\"type\":\"record_created\",\"object_key\":\"warranty_waiver\"},\"enabled\":true,\"run_as\":\"ops_manager\",\"graph\":{\"version\":2,\"nodes\":[{\"id\":\"waiver_created\",\"type\":\"trigger\",\"name\":\"Pending waiver created\"},{\"id\":\"manager_approval\",\"type\":\"approval\",\"name\":\"Operations manager approval\",\"contract\":{\"approval\":{\"mode\":\"any\",\"resolvers\":[{\"type\":\"role\",\"priority\":1,\"role_key\":\"ops_manager\"}],\"resolver_mode\":\"union\",\"empty_assignee_policy\":\"fail\"}}},{\"id\":\"apply_waiver\",\"type\":\"action\",\"name\":\"Apply approved waiver\",\"contract\":{\"action\":{\"action_key\":\"warranty_waiver.decide_warranty_waiver\",\"object_key\":\"warranty_waiver\",\"record_id\":\"$record.id\",\"input\":{\"decided_at\":\"$now\",\"decision\":\"approved\"},\"on_error\":\"fail\"}}},{\"id\":\"reject_waiver\",\"type\":\"action\",\"name\":\"Record rejected waiver\",\"contract\":{\"action\":{\"action_key\":\"warranty_waiver.decide_warranty_waiver\",\"object_key\":\"warranty_waiver\",\"record_id\":\"$record.id\",\"input\":{\"decided_at\":\"$now\",\"decision\":\"rejected\",\"rejection_reason\":\"Rejected by operations manager\"},\"on_error\":\"fail\"}}}],\"edges\":[{\"id\":\"created_to_approval\",\"source\":\"waiver_created\",\"target\":\"manager_approval\"},{\"id\":\"approved_to_apply\",\"source\":\"manager_approval\",\"target\":\"apply_waiver\",\"branch\":\"approved\"},{\"id\":\"rejected_to_record\",\"source\":\"manager_approval\",\"target\":\"reject_waiver\",\"branch\":\"rejected\"}]}}','{\"valid\":true,\"issues\":[],\"validated_at\":\"2026-08-21T18:45:47.839185Z\"}','','system','system','metadata:bc1e690354bcb8187a10b6f75d2731a658ffd6c2be01b815e4c1dda985eb53d9:version:1','2026-08-21T18:45:47.841299Z','2026-08-21T18:45:47.841299Z','2026-08-21T18:45:47.841299Z',NULL);
/*!40000 ALTER TABLE `workflow_definition_versions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workflow_definitions`
--

DROP TABLE IF EXISTS `workflow_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `workflow_definitions` (
  `id` varchar(191) NOT NULL,
  `resource_key` varchar(191) NOT NULL,
  `object_key` varchar(191) NOT NULL,
  `name` text NOT NULL,
  `payload_json` longtext NOT NULL,
  `schema_version` varchar(191) NOT NULL,
  `schema_hash` varchar(191) NOT NULL,
  `source_kind` varchar(191) NOT NULL,
  `source_id` varchar(191) NOT NULL,
  `disabled_at` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `resource_key` (`resource_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workflow_definitions`
--

LOCK TABLES `workflow_definitions` WRITE;
/*!40000 ALTER TABLE `workflow_definitions` DISABLE KEYS */;
INSERT INTO `workflow_definitions` VALUES ('workflow:overdue_service_request_scan','overdue_service_request_scan','','Overdue service request scan','{\"key\":\"overdue_service_request_scan\",\"name\":\"Overdue service request scan\",\"trigger\":{\"type\":\"scheduled\"},\"condition\":{\"field\":\"status\",\"type\":\"field_equals\",\"value\":\"dispatched\"},\"action\":{\"type\":\"workflow_graph\"},\"trigger_contract\":{\"type\":\"scheduled\",\"object_key\":\"service_request\"},\"enabled\":true,\"run_as\":\"scheduler_service\",\"graph\":{\"version\":2,\"nodes\":[{\"id\":\"schedule_trigger\",\"type\":\"trigger\",\"name\":\"Scheduled record scan\"},{\"id\":\"send_reminder\",\"type\":\"action\",\"name\":\"Send eligible overdue reminder\",\"contract\":{\"action\":{\"action_key\":\"service_request.send_overdue_reminder\",\"object_key\":\"service_request\",\"record_id\":\"$record.id\",\"input\":{\"scheduled_at\":\"$workflow.scheduled_at\"},\"on_error\":\"fail\"}}}],\"edges\":[{\"id\":\"trigger_to_reminder\",\"source\":\"schedule_trigger\",\"target\":\"send_reminder\"}]}}','0.1.0','aa5b3f2a21fc262b743c399e60615964cd2d89e5d404911b1e1630da5095197b','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('workflow:platform.audit_retention_check','platform.audit_retention_check','','Audit retention check','{\"key\":\"platform.audit_retention_check\",\"name\":\"Audit retention check\",\"trigger\":{\"type\":\"manual\"},\"condition\":{\"type\":\"always\"},\"action\":{\"type\":\"workflow_graph\"},\"trigger_contract\":{\"type\":\"manual\"},\"condition_contract\":{\"type\":\"always\"},\"enabled\":true,\"retry\":{\"max_attempts\":3,\"delay_seconds\":60},\"audit_event\":\"platform_audit_retention_checked\",\"graph\":{\"version\":2,\"nodes\":[{\"id\":\"manual_trigger\",\"type\":\"trigger\",\"name\":\"Run audit retention check\"}],\"edges\":null}}','0.1.0','6bcdea614cf9b271dbeebdaf5fcf760fcba193ca43a9ed4dd123309cfd5742ec','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('workflow:platform.metadata_health_check','platform.metadata_health_check','','Metadata health check','{\"key\":\"platform.metadata_health_check\",\"name\":\"Metadata health check\",\"trigger\":{\"type\":\"manual\"},\"condition\":{\"type\":\"always\"},\"action\":{\"type\":\"workflow_graph\"},\"trigger_contract\":{\"type\":\"manual\"},\"condition_contract\":{\"type\":\"always\"},\"enabled\":true,\"retry\":{\"max_attempts\":3,\"delay_seconds\":60},\"audit_event\":\"platform_metadata_health_checked\",\"graph\":{\"version\":2,\"nodes\":[{\"id\":\"manual_trigger\",\"type\":\"trigger\",\"name\":\"Run metadata health check\"}],\"edges\":null}}','0.1.0','d35b2ac8904714b0758ae5865488613949ccd607c3b536605281087fd71ebdc3','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z'),('workflow:warranty_waiver_approval','warranty_waiver_approval','','Warranty waiver approval','{\"key\":\"warranty_waiver_approval\",\"name\":\"Warranty waiver approval\",\"trigger\":{\"type\":\"record_created\"},\"condition\":{\"field\":\"status\",\"type\":\"field_equals\",\"value\":\"pending\"},\"action\":{\"type\":\"workflow_graph\"},\"trigger_contract\":{\"type\":\"record_created\",\"object_key\":\"warranty_waiver\"},\"enabled\":true,\"run_as\":\"ops_manager\",\"graph\":{\"version\":2,\"nodes\":[{\"id\":\"waiver_created\",\"type\":\"trigger\",\"name\":\"Pending waiver created\"},{\"id\":\"manager_approval\",\"type\":\"approval\",\"name\":\"Operations manager approval\",\"contract\":{\"approval\":{\"mode\":\"any\",\"resolvers\":[{\"type\":\"role\",\"priority\":1,\"role_key\":\"ops_manager\"}],\"resolver_mode\":\"union\",\"empty_assignee_policy\":\"fail\"}}},{\"id\":\"apply_waiver\",\"type\":\"action\",\"name\":\"Apply approved waiver\",\"contract\":{\"action\":{\"action_key\":\"warranty_waiver.decide_warranty_waiver\",\"object_key\":\"warranty_waiver\",\"record_id\":\"$record.id\",\"input\":{\"decided_at\":\"$now\",\"decision\":\"approved\"},\"on_error\":\"fail\"}}},{\"id\":\"reject_waiver\",\"type\":\"action\",\"name\":\"Record rejected waiver\",\"contract\":{\"action\":{\"action_key\":\"warranty_waiver.decide_warranty_waiver\",\"object_key\":\"warranty_waiver\",\"record_id\":\"$record.id\",\"input\":{\"decided_at\":\"$now\",\"decision\":\"rejected\",\"rejection_reason\":\"Rejected by operations manager\"},\"on_error\":\"fail\"}}}],\"edges\":[{\"id\":\"created_to_approval\",\"source\":\"waiver_created\",\"target\":\"manager_approval\"},{\"id\":\"approved_to_apply\",\"source\":\"manager_approval\",\"target\":\"apply_waiver\",\"branch\":\"approved\"},{\"id\":\"rejected_to_record\",\"source\":\"manager_approval\",\"target\":\"reject_waiver\",\"branch\":\"rejected\"}]}}','0.1.0','bc1e690354bcb8187a10b6f75d2731a658ffd6c2be01b815e4c1dda985eb53d9','generated','domain_m2_field_service',NULL,'2026-08-21T18:45:46Z','2026-08-21T18:45:46Z');
/*!40000 ALTER TABLE `workflow_definitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workflow_execution_receipts`
--

DROP TABLE IF EXISTS `workflow_execution_receipts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `workflow_execution_receipts` (
  `id` varchar(191) NOT NULL,
  `workspace_id` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `workflow_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `idempotency_key` varchar(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `request_fingerprint` varchar(191) NOT NULL,
  `status` varchar(191) NOT NULL,
  `execution_id` varchar(191) NOT NULL DEFAULT '',
  `lease_owner` varchar(191) NOT NULL,
  `lease_expires_at` varchar(191) NOT NULL,
  `fencing_token` bigint NOT NULL DEFAULT '1',
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  `expires_at` varchar(191) NOT NULL DEFAULT '',
  UNIQUE KEY `uniq_workflow_execution_receipts_workspace_identity` (`workspace_id`,`id`),
  UNIQUE KEY `uniq_workflow_execution_receipt_scope` (`workspace_id`,`workflow_key`,`idempotency_key`),
  KEY `idx_workflow_execution_receipt_lease` (`status`,`lease_expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workflow_execution_receipts`
--

LOCK TABLES `workflow_execution_receipts` WRITE;
/*!40000 ALTER TABLE `workflow_execution_receipts` DISABLE KEYS */;
/*!40000 ALTER TABLE `workflow_execution_receipts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workflow_node_instances`
--

DROP TABLE IF EXISTS `workflow_node_instances`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `workflow_node_instances` (
  `workspace_id` varchar(191) NOT NULL,
  `id` varchar(191) NOT NULL,
  `process_id` varchar(191) NOT NULL,
  `node_id` varchar(191) NOT NULL,
  `node_type` varchar(191) NOT NULL,
  `iteration` int NOT NULL,
  `status` varchar(191) NOT NULL,
  `input_json` text NOT NULL,
  `output_json` text NOT NULL,
  `error_code` varchar(191) DEFAULT NULL,
  `started_at` varchar(191) NOT NULL,
  `completed_at` varchar(191) DEFAULT NULL,
  UNIQUE KEY `uniq_workflow_node_workspace_id` (`workspace_id`,`id`),
  UNIQUE KEY `idx_workflow_node_process` (`workspace_id`,`process_id`,`node_id`,`iteration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workflow_node_instances`
--

LOCK TABLES `workflow_node_instances` WRITE;
/*!40000 ALTER TABLE `workflow_node_instances` DISABLE KEYS */;
/*!40000 ALTER TABLE `workflow_node_instances` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workflow_process_events`
--

DROP TABLE IF EXISTS `workflow_process_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `workflow_process_events` (
  `workspace_id` varchar(191) NOT NULL,
  `id` varchar(191) NOT NULL,
  `process_id` varchar(191) NOT NULL,
  `node_id` varchar(191) DEFAULT NULL,
  `task_id` varchar(191) DEFAULT NULL,
  `event` varchar(191) NOT NULL,
  `actor_id` varchar(191) NOT NULL,
  `summary` text NOT NULL,
  `metadata_json` text NOT NULL,
  `created_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_workflow_event_workspace_id` (`workspace_id`,`id`),
  KEY `idx_workflow_event_process` (`workspace_id`,`process_id`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workflow_process_events`
--

LOCK TABLES `workflow_process_events` WRITE;
/*!40000 ALTER TABLE `workflow_process_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `workflow_process_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workflow_process_instances`
--

DROP TABLE IF EXISTS `workflow_process_instances`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `workflow_process_instances` (
  `workspace_id` varchar(191) NOT NULL,
  `id` varchar(191) NOT NULL,
  `workflow_key` varchar(191) NOT NULL,
  `workflow_name` text NOT NULL,
  `workflow_definition_version_id` varchar(191) NOT NULL DEFAULT '',
  `definition_version` int NOT NULL,
  `definition_hash` varchar(191) NOT NULL,
  `definition_json` text NOT NULL,
  `object_key` varchar(191) DEFAULT NULL,
  `record_id` varchar(191) DEFAULT NULL,
  `initiator_id` varchar(191) NOT NULL,
  `initiator_role_key` varchar(191) DEFAULT NULL,
  `status` varchar(191) NOT NULL,
  `current_node_ids_json` text NOT NULL,
  `variables_json` text NOT NULL,
  `result_json` text NOT NULL,
  `error_code` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  `completed_at` varchar(191) DEFAULT NULL,
  UNIQUE KEY `uniq_workflow_process_workspace_id` (`workspace_id`,`id`),
  KEY `idx_workflow_process_business_record` (`workspace_id`,`object_key`,`record_id`,`created_at`),
  KEY `idx_workflow_process_status` (`workspace_id`,`status`,`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workflow_process_instances`
--

LOCK TABLES `workflow_process_instances` WRITE;
/*!40000 ALTER TABLE `workflow_process_instances` DISABLE KEYS */;
/*!40000 ALTER TABLE `workflow_process_instances` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workflow_tasks`
--

DROP TABLE IF EXISTS `workflow_tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `workflow_tasks` (
  `workspace_id` varchar(191) NOT NULL,
  `id` varchar(191) NOT NULL,
  `process_id` varchar(191) NOT NULL,
  `node_instance_id` varchar(191) NOT NULL,
  `node_id` varchar(191) NOT NULL,
  `title` text NOT NULL,
  `assignee_user_id` varchar(191) DEFAULT NULL,
  `assignee_name` text,
  `assignee_role_key` varchar(191) DEFAULT NULL,
  `resolver_snapshot_json` text NOT NULL DEFAULT (_utf8mb4'[]'),
  `candidate_source` varchar(191) DEFAULT NULL,
  `node_definition_version` int NOT NULL DEFAULT '0',
  `sequence_no` int NOT NULL,
  `status` varchar(191) NOT NULL,
  `decision` varchar(191) DEFAULT NULL,
  `comment` text,
  `due_at` varchar(191) DEFAULT NULL,
  `completed_by` varchar(191) DEFAULT NULL,
  `completed_at` varchar(191) DEFAULT NULL,
  `created_at` varchar(191) NOT NULL,
  `updated_at` varchar(191) NOT NULL,
  UNIQUE KEY `uniq_workflow_task_workspace_id` (`workspace_id`,`id`),
  KEY `idx_workflow_task_assignee` (`workspace_id`,`assignee_user_id`,`status`,`created_at`),
  KEY `idx_workflow_task_process` (`workspace_id`,`process_id`,`node_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workflow_tasks`
--

LOCK TABLES `workflow_tasks` WRITE;
/*!40000 ALTER TABLE `workflow_tasks` DISABLE KEYS */;
/*!40000 ALTER TABLE `workflow_tasks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'domainry_m2_fieldservice_e235a3d6e4fb_mysql_opt12_canary01'
--

--
-- Dumping routines for database 'domainry_m2_fieldservice_e235a3d6e4fb_mysql_opt12_canary01'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-08-22  3:32:56
