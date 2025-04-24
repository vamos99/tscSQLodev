-- ERD aracılığı ile oluşturulmuştur.
-- En altta test etmek için yardımcı sorgular vardır. (Yapay Zeka hazırladı.)

BEGIN;


CREATE TABLE IF NOT EXISTS public.bloggonderileri
(
    gonderi_id bigserial NOT NULL,
    yazar_id bigint NOT NULL,
    baslik character varying(255) COLLATE pg_catalog."default" NOT NULL,
    icerik text COLLATE pg_catalog."default" NOT NULL,
    yayin_tarihi timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT bloggonderileri_pkey PRIMARY KEY (gonderi_id)
);

CREATE TABLE IF NOT EXISTS public.egitimler
(
    egitim_id bigserial NOT NULL,
    ad character varying(200) COLLATE pg_catalog."default" NOT NULL,
    aciklama text COLLATE pg_catalog."default",
    baslangic_tarihi date,
    bitis_tarihi date,
    egitmen_bilgisi character varying(100) COLLATE pg_catalog."default",
    kategori_id smallint,
    CONSTRAINT egitimler_pkey PRIMARY KEY (egitim_id)
);

CREATE TABLE IF NOT EXISTS public.kategoriler
(
    kategori_id smallserial NOT NULL,
    ad character varying(100) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT kategoriler_pkey PRIMARY KEY (kategori_id),
    CONSTRAINT kategoriler_ad_key UNIQUE (ad)
);

CREATE TABLE IF NOT EXISTS public.katilimlar
(
    katilim_id bigserial NOT NULL,
    uye_id bigint NOT NULL,
    egitim_id bigint NOT NULL,
    katilim_tarihi timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT katilimlar_pkey PRIMARY KEY (katilim_id),
    CONSTRAINT uq_uye_egitim UNIQUE (uye_id, egitim_id)
);

CREATE TABLE IF NOT EXISTS public.sertifikaatamalari
(
    atama_id bigserial NOT NULL,
    uye_id bigint NOT NULL,
    sertifika_id bigint NOT NULL,
    alim_tarihi date NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT sertifikaatamalari_pkey PRIMARY KEY (atama_id),
    CONSTRAINT uq_uye_sertifika UNIQUE (uye_id, sertifika_id)
);

CREATE TABLE IF NOT EXISTS public.sertifikalar
(
    sertifika_id bigserial NOT NULL,
    sertifika_kodu character varying(100) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT sertifikalar_pkey PRIMARY KEY (sertifika_id),
    CONSTRAINT sertifikalar_sertifika_kodu_key UNIQUE (sertifika_kodu)
);

CREATE TABLE IF NOT EXISTS public.uyeler
(
    uye_id bigserial NOT NULL,
    kullanici_adi character varying(50) COLLATE pg_catalog."default" NOT NULL,
    e_posta character varying(100) COLLATE pg_catalog."default" NOT NULL,
    sifre character varying(255) COLLATE pg_catalog."default" NOT NULL,
    ad character varying(50) COLLATE pg_catalog."default",
    soyad character varying(50) COLLATE pg_catalog."default",
    kayit_tarihi timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uyeler_pkey PRIMARY KEY (uye_id),
    CONSTRAINT uyeler_e_posta_key UNIQUE (e_posta),
    CONSTRAINT uyeler_kullanici_adi_key UNIQUE (kullanici_adi)
);

ALTER TABLE IF EXISTS public.bloggonderileri
    ADD CONSTRAINT fk_gonderi_yazar FOREIGN KEY (yazar_id)
    REFERENCES public.uyeler (uye_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_blog_gonderileri_yazar_id
    ON public.bloggonderileri(yazar_id);


ALTER TABLE IF EXISTS public.egitimler
    ADD CONSTRAINT fk_egitim_kategori FOREIGN KEY (kategori_id)
    REFERENCES public.kategoriler (kategori_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_egitimler_kategori_id
    ON public.egitimler(kategori_id);


ALTER TABLE IF EXISTS public.katilimlar
    ADD CONSTRAINT fk_katilim_egitim FOREIGN KEY (egitim_id)
    REFERENCES public.egitimler (egitim_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_katilimlar_egitim_id
    ON public.katilimlar(egitim_id);


ALTER TABLE IF EXISTS public.katilimlar
    ADD CONSTRAINT fk_katilim_uye FOREIGN KEY (uye_id)
    REFERENCES public.uyeler (uye_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_katilimlar_uye_id
    ON public.katilimlar(uye_id);


ALTER TABLE IF EXISTS public.sertifikaatamalari
    ADD CONSTRAINT fk_atama_sertifika FOREIGN KEY (sertifika_id)
    REFERENCES public.sertifikalar (sertifika_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE RESTRICT;
CREATE INDEX IF NOT EXISTS idx_sertifika_atamalari_sertifika_id
    ON public.sertifikaatamalari(sertifika_id);


ALTER TABLE IF EXISTS public.sertifikaatamalari
    ADD CONSTRAINT fk_atama_uye FOREIGN KEY (uye_id)
    REFERENCES public.uyeler (uye_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_sertifika_atamalari_uye_id
    ON public.sertifikaatamalari(uye_id);

END;


/*

--test

-- Kategoriler Ekle
INSERT INTO Kategoriler (ad) VALUES
('Programlama'),
('Veritabanı'),
('Tasarım');

-- Üyeler Ekle
INSERT INTO Uyeler (kullanici_adi, e_posta, sifre, ad, soyad) VALUES
('testuser1', 'user1@example.com', 'pass123', 'Ahmet', 'Kaya'),
('testuser2', 'user2@example.com', 'pass456', 'Zeynep', 'Demir'),
('testuser3', 'user3@example.com', 'pass789', 'Mehmet', 'Çelik');

-- Eğitimler Ekle (Mevcut kategori ve üye ID'lerini kullanarak - Varsayım ID: 1, 2, 3)
INSERT INTO Egitimler (ad, aciklama, kategori_id, egitmen_bilgisi, baslangic_tarihi) VALUES
('Temel Python', 'Python diline giriş eğitimi.', 1, 'Ahmet Kaya', '2024-07-01'),
('SQL Başlangıç', 'Veritabanı sorgulama esasları.', 2, 'Ahmet Kaya', '2024-07-15'),
('Web Tasarım Giriş', 'HTML ve CSS temelleri.', 3, 'Zeynep Demir', '2024-08-01');

-- Katılımlar Ekle (Mevcut üye ve eğitim ID'lerini kullanarak - Varsayım ID: 1, 2, 3)
INSERT INTO Katilimlar (uye_id, egitim_id) VALUES
(1, 1),
(1, 2),
(2, 1),
(3, 3);

-- Sertifikalar Ekle (Benzersiz kodlar)
INSERT INTO Sertifikalar (sertifika_kodu) VALUES
('PYTHON-TEMEL-2024'),
('SQL-BASLANGIC-2024');

-- Sertifika Atamaları Ekle (Mevcut üye ve sertifika ID'lerini kullanarak - Varsayım ID: 1, 2)
INSERT INTO SertifikaAtamalari (uye_id, sertifika_id, alim_tarihi) VALUES
(1, 1, '2024-08-15'),
(1, 2, '2024-08-20'),
(2, 1, '2024-09-01');

-- Blog Gönderileri Ekle (Mevcut üye ID'lerini kullanarak - Varsayım ID: 1, 2)
INSERT INTO BlogGonderileri (yazar_id, baslik, icerik) VALUES
(1, 'Python Listeleri', 'Python programlamada listelerin kullanımı...'),
(2, 'SQL JOIN Mantığı', 'Farklı JOIN türleri nasıl çalışır?'),
(1, 'Veritabanı Normalizasyonu', 'NF1, NF2, NF3 kuralları...');


/*

Sorgu 1: Tüm üyeleri listele
SELECT uye_id, kullanici_adi, e_posta, ad, soyad, kayit_tarihi
FROM Uyeler;

Sorgu 2: 'Programlama' kategorisindeki eğitimleri listele
SELECT e.ad AS egitim_adi, e.egitmen_bilgisi
FROM Egitimler e
JOIN Kategoriler k ON e.kategori_id = k.kategori_id
WHERE k.ad = 'Programlama';

Sorgu 3: 'testuser1' (Ahmet Kaya) kullanıcısının katıldığı eğitimlerin adlarını listele
SELECT e.ad
FROM Egitimler e
JOIN Katilimlar k ON e.egitim_id = k.egitim_id
JOIN Uyeler u ON k.uye_id = u.uye_id
WHERE u.kullanici_adi = 'testuser1';

Sorgu 4: 'PYTHON-TEMEL-2024' kodlu sertifikayı alan kullanıcıları listele
SELECT u.kullanici_adi, sa.alim_tarihi
FROM Uyeler u
JOIN SertifikaAtamalari sa ON u.uye_id = sa.uye_id
JOIN Sertifikalar s ON sa.sertifika_id = s.sertifika_id
WHERE s.sertifika_kodu = 'PYTHON-TEMEL-2024';

Sorgu 5: Tüm blog gönderilerini yazarlarıyla birlikte, en yeniden eskiye doğru sırala
SELECT
    b.baslik,
    b.icerik,
    b.yayin_tarihi,
    u.kullanici_adi AS yazar
FROM BlogGonderileri b
JOIN Uyeler u ON b.yazar_id = u.uye_id
ORDER BY b.yayin_tarihi DESC;

*/

*/