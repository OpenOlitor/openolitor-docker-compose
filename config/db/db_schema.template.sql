{% for csa in csas -%}

CREATE DATABASE IF NOT EXISTS `{{csa.db.databaseName}}`;
USE {{csa.db.databaseName}} ;
DROP USER IF EXISTS '{{csa.db.databaseInternalUser}}'@'172.16.0.4';
DROP USER IF EXISTS '{{csa.db.databaseReadOnlyUser}}'@'%';
DROP USER IF EXISTS '{{csa.db.databaseAdmin}}'@'%';

CREATE USER '{{csa.db.databaseInternalUser}}'@'172.16.0.4' IDENTIFIED BY '{{csa.db.databaseInternalUserPassword}}' REQUIRE NONE;
CREATE USER '{{csa.db.databaseReadOnlyUser}}'@'%' IDENTIFIED BY '{{csa.db.databaseReadOnlyUserPassword}}' REQUIRE SSL;
CREATE USER '{{csa.db.databaseAdmin}}'@'%' IDENTIFIED BY '{{csa.db.databaseAdminPassword}}' REQUIRE SSL;

GRANT USAGE ON `{{csa.db.databaseName}}`.* TO '{{csa.db.databaseInternalUser}}'@'172.16.0.4';
GRANT ALL privileges ON `{{csa.db.databaseName}}`.* TO '{{csa.db.databaseInternalUser}}'@'172.16.0.4';
GRANT USAGE ON `{{csa.db.databaseName}}`.* TO '{{csa.db.databaseAdmin}}'@'%';
GRANT ALL privileges ON `{{csa.db.databaseName}}`.* TO '{{csa.db.databaseAdmin}}'@'%';
GRANT SELECT ON `{{csa.db.databaseName}}`.* TO '{{csa.db.databaseReadOnlyUser}}'@'%';
FLUSH PRIVILEGES;

ALTER TABLE IF EXISTS persistence_journal RENAME archive_persistence_journal;
ALTER TABLE IF EXISTS persistence_metadata RENAME archive_persistence_metadata;
ALTER TABLE IF EXISTS persistence_snapshot RENAME archive_persistence_snapshot;

CREATE TABLE IF NOT EXISTS DBSchema (
  id BIGINT NOT NULL,
  revision BIGINT NOT NULL,
  status varchar(50) NOT NULL,
  erstelldat DATETIME NOT NULL,
  ersteller BIGINT NOT NULL,
  modifidat DATETIME NOT NULL,
  modifikator BIGINT NOT NULL,
  PRIMARY KEY (id)
) CHARACTER SET utf8mb4 COLLATE = 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS PersistenceEventState  (
  id BIGINT not null,
  persistence_id varchar(100) not null,
  last_transaction_nr BIGINT default 0,
  last_sequence_nr BIGINT default 0,
  erstelldat datetime not null,
  ersteller BIGINT not null,
  modifidat datetime not null,
  modifikator BIGINT not null
) CHARACTER SET utf8mb4 COLLATE = 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS event_journal(
    ordering SERIAL,
    deleted BOOLEAN DEFAULT false NOT NULL,
    persistence_id VARCHAR(255) NOT NULL,
    sequence_number BIGINT NOT NULL,
    writer TEXT NOT NULL,
    write_timestamp BIGINT NOT NULL,
    adapter_manifest TEXT NOT NULL,
    event_payload MEDIUMBLOB NOT NULL,
    event_ser_id INTEGER NOT NULL,
    event_ser_manifest TEXT NOT NULL,
    meta_payload MEDIUMBLOB,
    meta_ser_id INTEGER,meta_ser_manifest TEXT,
    PRIMARY KEY(persistence_id,sequence_number)
) CHARACTER SET utf8mb4 COLLATE = 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX IF NOT EXISTS event_journal_ordering_idx ON event_journal(ordering);

CREATE TABLE IF NOT EXISTS event_tag (
    event_id BIGINT UNSIGNED NOT NULL,
    tag VARCHAR(255) NOT NULL,
    PRIMARY KEY(event_id, tag),
    FOREIGN KEY (event_id)
        REFERENCES event_journal(ordering)
        ON DELETE CASCADE
    ) CHARACTER SET utf8mb4 COLLATE = 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS snapshot (
    persistence_id VARCHAR(255) NOT NULL,
    sequence_number BIGINT NOT NULL,
    created BIGINT NOT NULL,
    snapshot_ser_id INTEGER NOT NULL,
    snapshot_ser_manifest TEXT NOT NULL,
    snapshot_payload MEDIUMBLOB NOT NULL,
    meta_ser_id INTEGER,
    meta_ser_manifest TEXT,
    meta_payload MEDIUMBLOB,
  PRIMARY KEY (persistence_id, sequence_number)) CHARACTER SET utf8mb4 COLLATE = 'utf8mb4_unicode_ci';

CREATE OR REPLACE VIEW {{csa.db.databaseName}}.journal_view AS
  SELECT 2 AS journal_version, persistence_id, sequence_number as sequence_nr, event_payload as message FROM event_journal;

{% endfor %}
