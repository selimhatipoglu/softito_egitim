-- BÖLÜM 1 - TABLO KURMA

CREATE TABLE oyuncaklar (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    isim TEXT NOT NULL,
    cesit TEXT,
    fiyat INTEGER CHECK(fiyat > 0),
    renk TEXT DEFAULT 'kırmızı'
);


-- BÖLÜM 2 - EKLEME

-- Renk yazılmadığı için varsayılan olarak "kırmızı" olur
INSERT INTO oyuncaklar (isim, cesit, fiyat)
VALUES ('Şimşek', 'araba', 50);

-- Tek komutla 4 oyuncak ekleme
INSERT INTO oyuncaklar (isim, cesit, fiyat, renk) VALUES
('Ayıcık', 'peluş', 80, 'kahverengi'),
('Kale Seti', 'lego', 150, 'gri'),
('Zıpzıp', 'top', 20, 'sarı'),
('Barbi', 'bebek', 90, 'pembe');


-- BÖLÜM 3 - BULMA

-- Tüm oyuncakları göster
SELECT *
FROM oyuncaklar;

-- Fiyatı 80 TL ve üzeri olanların sadece isim ve fiyatını göster
SELECT isim, fiyat
FROM oyuncaklar
WHERE fiyat >= 80;

-- En pahalı 2 oyuncağı listele
SELECT *
FROM oyuncaklar
ORDER BY fiyat DESC
LIMIT 2;

-- İsmi Z harfiyle başlayan oyuncakları bul
SELECT *
FROM oyuncaklar
WHERE isim LIKE 'Z%';

-- Sadece araba ve topları göster
SELECT *
FROM oyuncaklar
WHERE cesit IN ('araba', 'top');

-- Fiyatı 20 ile 60 TL arasında olanları listele
SELECT *
FROM oyuncaklar
WHERE fiyat BETWEEN 20 AND 60;


-- BÖLÜM 4 - DEĞİŞTİRME VE SİLME

-- Şimşek'in rengini mavi yap
UPDATE oyuncaklar
SET renk = 'mavi'
WHERE isim = 'Şimşek';

-- Zıpzıp'ı sil
DELETE FROM oyuncaklar
WHERE isim = 'Zıpzıp';


-- Bunu çalıştırırsam tablonun içindeki bütün kayıtlar silinir.
-- Tablo ise kalır.
-- DELETE FROM oyuncaklar;****


-- BÖLÜM 5 - TABLOYU DÜZENLEME

-- Yeni "kimin" sütunu ekle
ALTER TABLE oyuncaklar
ADD COLUMN kimin TEXT;

-- Kale Seti'nin sahibini Ali yap
UPDATE oyuncaklar
SET kimin = 'Ali'
WHERE isim = 'Kale Seti';

-- "cesit" sütununun adını "tur" olarak değiştir
ALTER TABLE oyuncaklar
RENAME COLUMN cesit TO tur;