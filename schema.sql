-- مخطط قاعدة البيانات السحابية لتطبيق زاد (Supabase / PostgreSQL)
-- تم التصميم والبرمجة من قبل المهندس سلام الأعرجي

CREATE TABLE IF NOT EXISTS locations_hierarchy (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    governorate TEXT NOT NULL,
    district TEXT NOT NULL,
    subdistrict TEXT NOT NULL,
    area_name TEXT NOT NULL,
    center_lat DOUBLE PRECISION NOT NULL,
    center_lng DOUBLE PRECISION NOT NULL
);

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name TEXT NOT NULL,
    phone TEXT UNIQUE NOT NULL,
    role TEXT CHECK (role IN ('beneficiary', 'buyer', 'donor', 'volunteer')) DEFAULT 'beneficiary',
    is_verified_silent BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS surplus_offers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    donor_id UUID REFERENCES users(id) ON DELETE SET NULL,
    donor_name TEXT NOT NULL,
    is_individual BOOLEAN DEFAULT FALSE,
    title TEXT NOT NULL,
    category TEXT NOT NULL,
    quantity_remaining INT NOT NULL CHECK (quantity_remaining >= 0),
    original_price INT DEFAULT 0,
    discounted_price INT DEFAULT 0,
    is_silent_eligible BOOLEAN DEFAULT TRUE,
    governorate TEXT NOT NULL,
    district TEXT NOT NULL,
    subdistrict TEXT NOT NULL,
    area_name TEXT NOT NULL,
    lat DOUBLE PRECISION NOT NULL,
    lng DOUBLE PRECISION NOT NULL,
    expires_text TEXT DEFAULT 'متاح الآن',
    expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '3 hours'),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS reservations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    offer_id UUID REFERENCES surplus_offers(id) ON DELETE CASCADE,
    recipient_id UUID REFERENCES users(id) ON DELETE SET NULL,
    qr_token TEXT UNIQUE NOT NULL,
    status TEXT CHECK (status IN ('reserved', 'picked_up', 'expired')) DEFAULT 'reserved',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- تفعيل الحماية على مستوى الصفوف (Row Level Security) للنشر العام
ALTER TABLE surplus_offers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public read active offers" ON surplus_offers FOR SELECT USING (quantity_remaining > 0);
CREATE POLICY "Allow public insert offers" ON surplus_offers FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update quantity" ON surplus_offers FOR UPDATE USING (true);
