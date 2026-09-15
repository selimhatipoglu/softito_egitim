-- =========================================
-- KÜTÜPHANE VERİTABANI ÖDEVİ
-- =========================================


-- 1) TABLO TASARIMI VE KISITLAR

-- SQLite'ta yabancı anahtar denetimi aktif hale getirildi.
PRAGMA foreign_keys = ON;


-- Üyeler tablosu oluşturuldu.
CREATE TABLE uyeler (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ad TEXT NOT NULL,
    yas INTEGER CHECK(yas > 13),
    sehir TEXT DEFAULT 'Erzincan',
    kayit TEXT DEFAULT CURRENT_TIMESTAMP
);


-- Kitaplar tablosu oluşturuldu.
-- Kitap adı boş bırakılamaz ve aynı kitap adı tekrar eklenemez.
CREATE TABLE kitaplar (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ad TEXT UNIQUE NOT NULL
);


-- Ödünç tablosu oluşturuldu.
-- uye_id ve kitap_id birlikte birincil anahtar olarak tanımlandı.
-- Üye silindiğinde o üyeye ait ödünç kayıtlarının da silinmesi sağlandı.
CREATE TABLE odunc (
    uye_id INTEGER REFERENCES uyeler(id) ON DELETE CASCADE,
    kitap_id INTEGER REFERENCES kitaplar(id),
    gun INTEGER,
    PRIMARY KEY (uye_id, kitap_id)
);


-- kitap_id için ON DELETE CASCADE kullanılmadı.
-- Bu nedenle ödünç kaydı bulunan bir kitap silinmeye çalışılırsa
-- FOREIGN KEY kısıtı nedeniyle işlem engellenir.
-- Böylece geçmiş ödünç kayıtlarının yanlışlıkla silinmesi önlenmiş olur.


-- =========================================
-- 2) VERİ EKLEME
-- =========================================


-- Kitaplar tablosuna 5 kitap eklendi.
INSERT INTO kitaplar (ad) VALUES
('Suç ve Ceza'),
('1984'),
('Kürk Mantolu Madonna'),
('Simyacı'),
('Sefiller');


-- Üyeler tablosuna şehir bilgisi belirtilen 7 üye eklendi.
INSERT INTO uyeler (ad, yas, sehir) VALUES
('Ahmet Yılmaz', 16, 'Ankara'),
('Ayşe Demir', 17, 'İstanbul'),
('Mehmet Kaya', 15, 'Erzincan'),
('Fatma Çelik', 20, 'İzmir'),
('Can Şahin', 18, 'Bursa'),
('Zeynep Aydın', 22, 'Erzincan'),
('Ali Koç', 14, 'Antalya');


-- Şehir bilgisi belirtilmeden 3 üye eklendi.
-- Bu kayıtlarda DEFAULT değeri olan 'Erzincan' kullanıldı.
INSERT INTO uyeler (ad, yas) VALUES
('Elif Arslan', 19),
('Mustafa Yıldız', 16),
('İrem Öztürk', 21);


-- Yaşı 10 olan bir üye eklenmeye çalışıldığında
-- CHECK(yas > 13) kısıtı nedeniyle kayıt eklenmez.

-- INSERT INTO uyeler (ad, yas)
-- VALUES ('Hatalı Üye', 10);


-- Olmayan uye_id = 99 ile ödünç kaydı eklenmeye çalışıldığında
-- FOREIGN KEY kısıtı nedeniyle işlem başarısız olur.

-- INSERT INTO odunc (uye_id, kitap_id, gun)
-- VALUES (99, 1, 10);


-- Her üyeye en az iki kitap için ödünç kaydı eklendi.
-- Gün değerleri 3 ile 45 arasında tutuldu.
INSERT INTO odunc (uye_id, kitap_id, gun) VALUES
(1, 1, 10),
(1, 2, 32),

(2, 1, 18),
(2, 3, 25),

(3, 2, 40),
(3, 4, 12),

(4, 3, 35),
(4, 5, 20),

(5, 1, 7),
(5, 4, 28),

(6, 2, 45),
(6, 5, 16),

(7, 3, 14),
(7, 4, 33),

(8, 1, 22),
(8, 5, 11),

(9, 2, 19),
(9, 3, 37),

(10, 4, 9),
(10, 5, 31);


-- =========================================
-- 3) JOIN
-- =========================================


-- Üye adı, kitap adı ve gün sayısı birlikte listelendi.
SELECT
    u.ad AS uye,
    k.ad AS kitap,
    o.gun
FROM odunc o
JOIN uyeler u ON u.id = o.uye_id
JOIN kitaplar k ON k.id = o.kitap_id;


-- 30 günden uzun süre tutulan kitaplar listelendi.
SELECT
    u.ad AS uye,
    k.ad AS kitap,
    o.gun
FROM odunc o
JOIN uyeler u ON u.id = o.uye_id
JOIN kitaplar k ON k.id = o.kitap_id
WHERE o.gun > 30;


-- Sadece Erzincan'daki üyelerin ödünç aldığı kitaplar listelendi.
SELECT
    u.ad AS uye,
    k.ad AS kitap,
    o.gun
FROM odunc o
JOIN uyeler u ON u.id = o.uye_id
JOIN kitaplar k ON k.id = o.kitap_id
WHERE u.sehir = 'Erzincan';


-- Hiç kitap almamış üyelerin de listede görünmesi için LEFT JOIN kullanıldı.
SELECT
    u.ad AS uye,
    k.ad AS kitap,
    o.gun
FROM uyeler u
LEFT JOIN odunc o ON u.id = o.uye_id
LEFT JOIN kitaplar k ON k.id = o.kitap_id;


-- =========================================
-- 4) GRUPLAMA VE TOPLAMA FONKSİYONLARI
-- =========================================


-- Her üyenin ortalama tutma süresi,
-- aldığı kitap sayısı ve en uzun tutma süresi hesaplandı.
SELECT
    uye_id,
    AVG(gun) AS ortalama_gun,
    COUNT(*) AS kitap_sayisi,
    MAX(gun) AS en_uzun_sure
FROM odunc
GROUP BY uye_id;


-- Ortalama tutma süresi 20 günün üzerinde olan üyeler listelendi.
SELECT
    uye_id,
    AVG(gun) AS ortalama_gun,
    COUNT(*) AS kitap_sayisi,
    MAX(gun) AS en_uzun_sure
FROM odunc
GROUP BY uye_id
HAVING AVG(gun) > 20;


-- AVG(gun) gruplama sonucunda elde edilen bir değer olduğu için HAVING kullanıldı.
-- WHERE satırları gruplamadan önce filtreler.
-- HAVING ise gruplama işlemi tamamlandıktan sonra oluşan sonuçları filtreler.


-- Her kitabın kaç kez ödünç alındığı kitap adıyla birlikte gösterildi.
SELECT
    k.ad AS kitap,
    COUNT(o.kitap_id) AS odunc_sayisi
FROM kitaplar k
LEFT JOIN odunc o ON k.id = o.kitap_id
GROUP BY k.id, k.ad;


-- Şehirlere göre üye sayıları hesaplandı ve çoktan aza sıralandı.
SELECT
    sehir,
    COUNT(*) AS uye_sayisi
FROM uyeler
GROUP BY sehir
ORDER BY uye_sayisi DESC;


-- =========================================
-- 5) ALT SORGU
-- =========================================


-- En az bir kitabı 30 günden uzun süre tutan üyelerin adları listelendi.
SELECT ad
FROM uyeler
WHERE id IN (
    SELECT uye_id
    FROM odunc
    WHERE gun > 30
);


-- Hiç ödünç alınmamış kitaplar NOT IN kullanılarak listelendi.
SELECT ad
FROM kitaplar
WHERE id NOT IN (
    SELECT kitap_id
    FROM odunc
);


-- Genel ortalama sürenin üzerinde tutulan ödünç kayıtları listelendi.
SELECT *
FROM odunc
WHERE gun > (
    SELECT AVG(gun)
    FROM odunc
);


-- =========================================
-- 6) CASE
-- =========================================


-- Her ödünç kaydı gün sayısına göre sınıflandırıldı.
SELECT
    uye_id,
    kitap_id,
    gun,
    CASE
        WHEN gun > 30 THEN 'Gecikmiş'
        WHEN gun BETWEEN 15 AND 30 THEN 'Uyarı'
        ELSE 'Normal'
    END AS durum
FROM odunc;


-- Üyeler yaşlarına göre Genç veya Yetişkin olarak etiketlendi.
SELECT
    ad,
    yas,
    CASE
        WHEN yas <= 18 THEN 'Genç'
        ELSE 'Yetişkin'
    END AS yas_grubu
FROM uyeler;


-- Her durumdan kaç adet ödünç kaydı olduğu hesaplandı.
SELECT
    CASE
        WHEN gun > 30 THEN 'Gecikmiş'
        WHEN gun BETWEEN 15 AND 30 THEN 'Uyarı'
        ELSE 'Normal'
    END AS durum,
    COUNT(*) AS adet
FROM odunc
GROUP BY
    CASE
        WHEN gun > 30 THEN 'Gecikmiş'
        WHEN gun BETWEEN 15 AND 30 THEN 'Uyarı'
        ELSE 'Normal'
    END;


-- =========================================
-- 7) INDEX
-- =========================================


-- uyeler.ad sütununda index oluşturuldu.
CREATE INDEX idx_uyeler_ad
ON uyeler(ad);


-- Bu index özellikle ad alanına göre yapılan arama sorgularını hızlandırabilir.
-- Örnek:
-- SELECT * FROM uyeler WHERE ad = 'Ahmet Yılmaz';


-- uyeler tablosuna eposta sütunu eklendi.
ALTER TABLE uyeler
ADD COLUMN eposta TEXT;


-- Eposta sütununda UNIQUE index oluşturuldu.
-- Böylece aynı e-posta adresinin iki farklı üyeye verilmesi engellendi.
CREATE UNIQUE INDEX idx_uyeler_eposta
ON uyeler(eposta);


-- İlk üyeye bir e-posta adresi atandı.
UPDATE uyeler
SET eposta = 'test@mail.com'
WHERE id = 1;


-- Aynı e-posta ikinci üyeye atanmak istendiğinde
-- UNIQUE index nedeniyle işlem başarısız olur.

-- UPDATE uyeler
-- SET eposta = 'test@mail.com'
-- WHERE id = 2;