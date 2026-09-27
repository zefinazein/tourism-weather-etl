CREATE SCHEMA raw;
CREATE SCHEMA warehouse;

DROP TABLE IF EXISTS raw.raw_bps_kunjungan;
CREATE TABLE raw.raw_bps_kunjungan (
	id SERIAL PRIMARY KEY,
	provinsi VARCHAR(100),
	tahun INT,
	bulan INT,
	jumlah_wisman BIGINT,
	jumlah_wisnus BIGINT,
	tpk DECIMAL(5,2),
	rlm DECIMAL(5,2)
);

DROP TABLE IF EXISTS raw.raw_openmeteo_cuaca;
CREATE TABLE raw.raw_openmeteo_cuaca (
	id      	SERIAL PRIMARY KEY,
	tanggal 	DATE,
	kota    	VARCHAR(100),
	curah_hujan_mm  DECIMAL(8,2),
	suhu_max_c  DECIMAL(5,2),
	suhu_min_c  DECIMAL(5,2)
);

DROP TABLE IF EXISTS raw.raw_google_trends
CREATE TABLE raw.raw_google_trends (
	id SERIAL PRIMARY KEY,
	tanggal DATE,
	wisata_bali INT,
	wisata_yogyakarta INT,
	wisata_lombok INT,
	wisata_palembang INT,
	wisata_surabaya INT
);