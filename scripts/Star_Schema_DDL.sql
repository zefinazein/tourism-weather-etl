-- Dimensi Waktu: berisi info bulan, kuartal, musim
CREATE TABLE warehouse.dim_waktu (
	id_waktu	SERIAL PRIMARY KEY,
	tahun   	INT NOT NULL,
	bulan   	INT NOT NULL,      	-- 1-12
	nama_bulan  VARCHAR(20),       	-- 'Januari', 'Februari', dst
	kuartal 	INT,               	-- 1-4
	musim   	VARCHAR(20),       	-- 'Hujan' atau 'Kemarau'
	UNIQUE(tahun, bulan)
);

-- Populate dim_waktu dengan semua bulan 2023-2025
INSERT INTO warehouse.dim_waktu (tahun, bulan, nama_bulan, kuartal, musim)
SELECT
	y AS tahun,
	m AS bulan,
	CASE m
    	WHEN 1  THEN 'Januari'  WHEN 2  THEN 'Februari'
    	WHEN 3  THEN 'Maret'	WHEN 4  THEN 'April'
    	WHEN 5  THEN 'Mei'  	WHEN 6  THEN 'Juni'
    	WHEN 7  THEN 'Juli' 	WHEN 8  THEN 'Agustus'
    	WHEN 9  THEN 'September' WHEN 10 THEN 'Oktober'
    	WHEN 11 THEN 'November' WHEN 12 THEN 'Desember'
	END AS nama_bulan,
	CASE WHEN m BETWEEN 1 AND 3  THEN 1
     	WHEN m BETWEEN 4 AND 6  THEN 2
     	WHEN m BETWEEN 7 AND 9  THEN 3
     	ELSE 4 END AS kuartal,
	CASE WHEN m BETWEEN 11 AND 12 OR m BETWEEN 1 AND 4
     	THEN 'Hujan' ELSE 'Kemarau' END AS musim
FROM generate_series(2023, 2025) y
CROSS JOIN generate_series(1, 12) m
ORDER BY y, m;

-- Dimensi Provinsi
CREATE TABLE warehouse.dim_provinsi (
	id_provinsi 	SERIAL PRIMARY KEY,
	nama_provinsi   VARCHAR(100) NOT NULL,
	kota_cuaca  	VARCHAR(100),  -- kota untuk matching data Open-Meteo
	latitude    	DECIMAL(9,6),
	longitude   	DECIMAL(9,6),
	pulau       	VARCHAR(50)
);

-- Populate dim_provinsi
INSERT INTO warehouse.dim_provinsi (nama_provinsi, kota_cuaca, latitude, longitude, pulau) VALUES
	('BALI',       	'bali',    	-8.67,   115.21,  'Bali'),
	('DI YOGYAKARTA',  'yogyakarta',  -7.80,   110.36,  'Jawa'),
	('NUSA TENGGARA BARAT', 'lombok', -8.58,   116.10,  'Lombok'),
	('SUMATERA SELATAN', 'palembang', -2.99, 104.76, 'Sumatera'), 
	('JAWA TIMUR', 'surabaya', -7.25, 112.75, 'Jawa'); 

-- Dimensi Kategori Cuaca
CREATE TABLE warehouse.dim_kategori_cuaca (
	id_kategori 	SERIAL PRIMARY KEY,
	kategori    	VARCHAR(50),   -- 'Sangat Basah', 'Basah', 'Normal', 'Kering'
	range_hujan 	VARCHAR(50),
	min_mm      	DECIMAL,
	max_mm      	DECIMAL
);

INSERT INTO warehouse.dim_kategori_cuaca (kategori, range_hujan, min_mm, max_mm) VALUES
	('Kering',  	'< 100 mm/bulan',   	0,    100),
	('Normal',  	'100-200 mm/bulan',	100,   200),
	('Basah',   	'200-400 mm/bulan',	200,   400),
	('Sangat Basah','> 400 mm/bulan',  	400, 9999);

CREATE TABLE warehouse.fact_kunjungan_pariwisata (
	id_fakta        	SERIAL PRIMARY KEY,
	id_waktu        	INT REFERENCES warehouse.dim_waktu(id_waktu),
	id_provinsi     	INT REFERENCES warehouse.dim_provinsi(id_provinsi),
	id_kategori_cuaca   INT REFERENCES warehouse.dim_kategori_cuaca(id_kategori),
	jumlah_wisman   	BIGINT,
	jumlah_wisnus   	BIGINT,
	tpk    				DECIMAL(5,2),
	rlm					DECIMAL(5,2),
	avg_suhu        	DECIMAL(5,2),
	total_curah_hujan   DECIMAL(8,2),
	skor_trends     	INT
);

INSERT INTO warehouse.fact_kunjungan_pariwisata
    (id_waktu, id_provinsi, id_kategori_cuaca, jumlah_wisman,
     jumlah_wisnus, tpk, rlm, avg_suhu, total_curah_hujan, skor_trends)
SELECT
    dw.id_waktu,
    dp.id_provinsi,
    dk.id_kategori,
    s.jumlah_wisman,
    s.jumlah_wisnus,
    s.tpk,
    s.rlm,
    s.avg_suhu,
    s.total_curah_hujan,
    s.avg_skor_trends
FROM warehouse.master_join s
JOIN warehouse.dim_waktu dw ON dw.tahun = s.tahun AND dw.bulan = s.bulan
JOIN warehouse.dim_provinsi dp ON dp.nama_provinsi = s.provinsi
JOIN warehouse.dim_kategori_cuaca dk ON s.total_curah_hujan >= dk.min_mm AND s.total_curah_hujan < dk.max_mm;

SELECT * FROM warehouse.fact_kunjungan_pariwisata